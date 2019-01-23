//
//  KmaApiBase.swift
//  Twy222
//  기상청 api base.
//  모든 기상청 api는 이 클래스를 상속한다.
//  공통적으로 사용 되는 부분을 여기에.
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiShortBase {
    public func makeCall( serviceName: String, baseDate: Date, kmaXY: KmaXY, callback:@escaping ( Array<[String:Any]>? ) -> Void ) {
        let url = getUrl(serviceName: serviceName, baseDate: baseDate, kmaXY: kmaXY);
        
        guard let urlObjct = URL(string: url) else {
            callback( nil );
            return;
        }
        
        var request = URLRequest(url: urlObjct );
        request.httpMethod = "GET"
        
        let currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if (error != nil) {
                print(error!);
                callback( nil );
            } else {
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                    callback( nil );
                    return;
                }
                
                let arrItem = self.getItemArray( anyJson: json );
                callback( arrItem );
            }
        }
        
        currentTask.resume();
    }
    
    private func getUrl( serviceName: String, baseDate: Date, kmaXY: KmaXY ) -> String {
        let RESULT_TYPE = "json"
        let NUM_OF_ROWS = 999
        
        let baseDateAndBaseTime = KmaUtils.getBaseDateAndBaseTime(date: baseDate);
        
        let url = "\(KmaApiUrlStruct.URL_ROOT)\(KmaApiUrlStruct.URL_SHORT_FORECAST)\(serviceName)?ServiceKey=\(DataGoKrConfig.APP_KEY)&base_date=\(baseDateAndBaseTime.baseDate)&base_time=\(baseDateAndBaseTime.baseTime)&nx=\(kmaXY.x)&ny=\(kmaXY.y)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        return url;
    }
    
    private func getItemArray( anyJson: Any ) -> Array<[ String : Any ]>? {
        guard let json = anyJson as? [String:Any] else {
            return nil;
        }
        
        guard let response = json[ "response" ] as? [ String : Any ] else {
            return nil;
        }
        guard let header = response[ "header" ] as? [ String : Any ] else {
            return nil;
        }
        guard let resultCode = header[ "resultCode" ] as? String else {
            return nil;
        }
        if( resultCode != "0000" ) {
            print("resultCode : ", resultCode )
            return nil;
        }
        guard let body = response[ "body" ] as? [ String : Any ] else {
            return nil;
        }
        guard let items = body[ "items" ] as? [ String : Any ] else {
            return nil;
        }
        guard let item = items[ "item" ] as? Array<[ String : Any ]> else {
            return nil;
        }
        
        return item;
    }
    
    public func getStatusImageName( skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum, isDay:Bool ) -> String {
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
    
    public func getSkyStatusText( skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum ) -> String {
        if( ptyEnum != KmaPtyEnum.NONE ) {
            return ptyEnum.description;
        }
        
        return skyEnum.description;
    }
    
    public func getKmaXY( lat: Double, lon: Double ) -> KmaXY {
        let result = FronteerKr.convertGRID_GPS( toGrid: true, lat_X: lat, lng_Y: lon );
        
        let kmaXY = KmaXY(x: result.x, y: result.y);
        // 기상청 기준 좌표 :  62, 122

        return kmaXY;
    }
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
