//
//  KmaUtils.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

struct KmaApiUrlStruct {
    static let URL_ROOT = "http://newsky2.kma.go.kr/service/"
    
    // (신)동네예보정보조회서비스
    static let URL_SHORT_FORECAST = "SecndSrtpdFrcstInfoService2/"
    
    static let URL_MID_FORECAST = "MiddleFrcstInfoService/";
}

enum KmaCategoryCodeEnum : String {
    // 강수 형태
    case PTY = "PTY";
    
    // 하늘 상태
    case SKY = "SKY";
    
    // 기온
    case T1H = "T1H";
    
    // 기온 3시간 단위.
    case T3H = "T3H";
    
    case TMX = "TMX";
    case TMN = "TMN";
}

public enum KmaSkyEnum : Int {
    // 맑음
    case GOOD = 1;
    // 구름조금 2 / 구름많음 3 / 흐림 4
    case LITTLE_CLOUDY, QUITE_CLOUDY, CLOUDY;
    
    var description: String {
        switch self {
        case .GOOD:
            return "맑음"
        case .LITTLE_CLOUDY:
            return "구름조금"
        case .QUITE_CLOUDY:
            return "구름많음"
        case .CLOUDY:
            return "흐림"
        }
    }
}

public enum KmaPtyEnum : Int {
    // 없음
    case NONE = 0;
    //    없음(0), 비(1), 비/눈(2), 눈(3)
    case RAINY, RAINY_AND_SNOWY, SNOWY;
    
    var description: String {
        switch self {
        case .NONE:
            return "없음"
        case .RAINY:
            return "비"
        case .RAINY_AND_SNOWY:
            return "비/눈"
        case .SNOWY:
            return "눈"
        }
    }
}

class KmaUtils {
    public static func createDate( kmaDate: String, kmaTime: String ) -> Date? {
        // "fcstDate":20190107,"fcstTime":"0700"
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMdd HHmm"
        let dateRet = formatter.date(from: "\(kmaDate) \(kmaTime)");
        
        return dateRet;
    }
    
    public static func getBaseDateAndBaseTime( date: Date ) -> ( baseDate: String, baseTime: String ) {
        let formatter = DateFormatter();
        
        formatter.dateFormat = "yyyyMMdd";
        let baseDate = formatter.string(from: date);
        
        formatter.dateFormat = "HHmm";
        let baseTime = formatter.string(from: date);
        
        return ( baseDate: baseDate, baseTime: baseTime );
    }
    
    public static func getDateByDateAndTime( anyDate: Any?, anyTime: Any? ) -> Date? {
        var strDate: String?;
        var strTime: String?;
        
        // string으로 들어오는지 int로 들어오는지 뭔가 이상함. 둘 다 대응하겠다.
        if let baseDate = anyDate as? String {
            strDate = baseDate;
        } else if let baseDate = anyDate as? Int {
            strDate = String(baseDate);
        } else {
            return nil;
        }
        
        if let baseTime = anyTime as? String {
            strTime = baseTime;
        } else if let baseTime = anyTime as? Int {
            strTime = String(baseTime);
        } else {
            return nil;
        }
        
        if( strDate == nil || strTime == nil ) {
            return nil;
        }
        
        guard let dateBase = KmaUtils.createDate(kmaDate: strDate!, kmaTime: strTime!) else {
            return nil;
        }

        return dateBase;
    }
    
    public static func getStatusImageName( skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum, isDay:Bool ) -> String {
        switch ptyEnum {
        case KmaPtyEnum.RAINY:
            if( skyEnum == KmaSkyEnum.GOOD || skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "12" : "40";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return "21";
            } else {
                return "36";
            }
        case KmaPtyEnum.SNOWY:
            if( skyEnum == KmaSkyEnum.GOOD || skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "13" : "41";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return "32";
            } else {
                return "37";
            }
        case KmaPtyEnum.RAINY_AND_SNOWY:
            if( skyEnum == KmaSkyEnum.GOOD || skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "14" : "42";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return "04";
            } else {
                return "39";
            }
        default:
            if( skyEnum == KmaSkyEnum.GOOD ) {
                return isDay ? "01" : "08";
            } else if( skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "02" : "09";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return isDay ? "03" : "10";
            } else {
                return "18";
            }
        }
    }
    
    public static func getSkyStatusText( skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum ) -> String {
        if( ptyEnum != KmaPtyEnum.NONE ) {
            return ptyEnum.description;
        }
        
        return skyEnum.description;
    }
    
    public static func getKmaXY( lat: Double, lon: Double ) -> KmaXY {
        let result = FronteerKr.convertGRID_GPS( toGrid: true, lat_X: lat, lng_Y: lon );
        
        let kmaXY = KmaXY(x: result.x, y: result.y);
        // 기상청 기준 좌표 :  62, 122
        
        return kmaXY;
    }
    
    public static func concatNotOverlap( arrBase: [DailyModel], arrAdd: [DailyModel] ) -> [DailyModel] {
        var arrAddCopied = arrAdd;
        
        for ( index, item ) in arrAddCopied.enumerated().reversed() {
            let nDay = Calendar.current.component(.day, from: item.date);
            
            if( getHasAlready( arr: arrBase, nDay: nDay ) ) {
                arrAddCopied.remove( at: index );
            }
        }
        
        arrAddCopied.append( contentsOf: arrBase );
        
        return arrAddCopied;
    }
    
    public static func getHasAlready( arr: [DailyModel], nDay: Int ) -> Bool {
        for model in arr {
            let nDayAleady = Calendar.current.component(.day, from: model.date);
            
            if( nDayAleady == nDay ) {
                return true;
            }
        }
        
        return false;
    }
    
    public static func makeDailyModelList( arrDual: [[IDate]] ) -> [DailyModel] {
        var arrRet = [DailyModel]();
        
        var dailyModel: DailyModel;
        
        for arr in arrDual {
            dailyModel = makeDailyModel( arrByDay: arr );
            
            arrRet.append( dailyModel );
        }
        
        return arrRet;
    }
    
    public static func makeDailyModel( arrByDay: [IDate] ) -> DailyModel {
        var nTempMax: Double = -100;
        var nTempMin: Double = 100;
        
        var ptyEnum: KmaPtyEnum = KmaPtyEnum.NONE;
        var skyEnum: KmaSkyEnum = KmaSkyEnum.GOOD;
        
        for item in arrByDay {
            if let actualModel = item as? KmaApiActualModel {
                if( actualModel.temperature > nTempMax ) {
                    nTempMax = actualModel.temperature;
                }
                if( actualModel.temperature < nTempMin ) {
                    nTempMin = actualModel.temperature;
                }
            } else if let kmaHourlyModel = item as? KmaHourlyModel {
                if let temperatureMax = kmaHourlyModel.temperatureMax {
                    if( temperatureMax > nTempMax ) {
                        nTempMax = temperatureMax;
                    }
                }
                if let temperatureMin = kmaHourlyModel.temperatureMin {
                    if( temperatureMin < nTempMin ) {
                        nTempMin = temperatureMin;
                    }
                }
                
                if( kmaHourlyModel.ptyEnum.rawValue > ptyEnum.rawValue ) {
                    ptyEnum = kmaHourlyModel.ptyEnum;
                }
                if( kmaHourlyModel.skyEnum.rawValue > skyEnum.rawValue ) {
                    skyEnum = kmaHourlyModel.skyEnum;
                }
            }
        }
        
//        print("\(nTempMax) /// \(nTempMin) \(skyEnum.description) \(ptyEnum.description)");
        
        let skyImage = KmaUtils.getStatusImageName(skyEnum: skyEnum, ptyEnum: ptyEnum, isDay: true);
        let skyText = KmaUtils.getSkyStatusText(skyEnum: skyEnum, ptyEnum: ptyEnum);
        
        // 있는 날짜로 자른 거니까 무조건 한개는 값이 있다.
        let model = DailyModel(date: arrByDay[0].date, temperatureMax: nTempMax, temperatureMin: nTempMin, skyStatusImageName: skyImage, skyStatusText: skyText);
        return model;
    }
    
    public static func makeDualArrayByDay( dateNow: Date, arrOrigin: [IDate] ) -> [[IDate]] {
        if( arrOrigin.count == 0 ) {
            return [];
        }
        
        let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: dateNow)!;
        let nDayYesterday = Calendar.current.component(.day, from: dateYesterday);
        
        var arrRet = [[IDate]]();
        var arrDay = [IDate]();
        
        var nDayPrev: Int?;
        
        for item in arrOrigin {
            let nDay = Calendar.current.component(.day, from: item.date);
            
            // 현재 날짜 보다 이전이면 패스.
            if( nDayYesterday == nDay ) {
                continue;
            }
            
            if( nDayPrev == nil ) {
                nDayPrev = nDay;
            } else if( nDayPrev != nDay ) {
                arrRet.append( arrDay );
                
                nDayPrev = nDay;
                
                arrDay = [];
            }
            
            arrDay.append(item);
        }
        
        arrRet.append( arrDay );
        
        return arrRet;
    }
}
