//
//  KmaApiForecastTimeVeryShort.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiForecastTimeVeryShort {
    static let shared = KmaApiForecastTimeVeryShort();
    
    public func getUrl( dateNow: Date, kmaX: Int, kmaY: Int ) -> String {
        let URL_SERVICE = "ForecastTimeData"
        
        let RESULT_TYPE = "json"
        let NUM_OF_ROWS = 100
        
        let dateBaseTime = getBaseTime( dateNow: dateNow );
        
        let tupleBaseToCall = KmaUtils.getBaseDateAndBaseTime(date: dateBaseTime);
        
        let url = "\(KmaApiStruct.URL_ROOT)\(KmaApiStruct.URL_MID_FORECAST)\(URL_SERVICE)?ServiceKey=\(DataGoKrConfig.APP_KEY)&base_date=\(tupleBaseToCall.baseDate)&base_time=\(tupleBaseToCall.baseTime)&nx=\(kmaX)&ny=\(kmaY)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        return url;
    }
    
    public func makeModel( arrItem: Array<[ String : Any ]> ) -> WeatherHourlyModel? {
        let len = arrItem.count;
        
        var dateBase: Date?;
        var dateFcst: Date?;
        
        var temerature: Double?;
        var skyType: Int?;
        var ptyType: Int?;
        
        for i in 0..<len {
            let obj = arrItem[ i ];
            
            if( i == 0 ) {
                guard let dateBaseTemp = getDateBase( obj: obj ) else {
                    return nil;
                }
                
                dateBase = dateBaseTemp;
            }
            
            guard let dateKma = getDateKma(obj: obj) else {
                continue;
            }
            
            let componenets = Calendar.current.dateComponents([.hour], from: dateBase!, to: dateKma);
            
            if( componenets.hour! > 0 ) {
                // 제일 가까운 시간 정보만 사용.
                continue;
            }
            
            if( dateFcst == nil ) {
                dateFcst = dateKma;
            }
            
            guard let category = obj[ "category" ] as? String else {
                continue;
            }
            
            switch( category ) {
            case KmaCategoryCodeEnum.T1H.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Double else {
                    continue;
                }
                temerature = fcstValue;
                break;
            case KmaCategoryCodeEnum.PTY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Int else {
                    continue;
                }
                ptyType = fcstValue;
                break;
            case KmaCategoryCodeEnum.SKY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Int else {
                    continue;
                }
                skyType = fcstValue;
                break;
            default:
                continue;
            }
        }
        
        if( dateBase == nil || dateFcst == nil || temerature == nil || skyType == nil || ptyType == nil ) {
            return nil;
        }
        
        let hour = Calendar.current.component(.hour, from: dateFcst!);
        
        let isDay = Utils.getIsDay(hour: hour);
        let skyStatusImageName = KmaUtils.getStatusImageName(skyType: skyType!, ptyType: ptyType!, isDay: isDay)
        
        let model: WeatherHourlyModel = WeatherHourlyModel(date: dateFcst!, temperature: temerature!, skyStatusImageName: skyStatusImageName)
        
        return model;
    }
    
    private func getDateBase( obj: [ String : Any ] ) -> Date? {
        guard let baseDate = obj[ "baseDate" ] as? Int else {
            return nil;
        }
        guard let baseTime = obj[ "baseTime" ] as? String else {
            return nil;
        }
        guard let dateBase = KmaUtils.createDate(kmaDate: String( baseDate ), kmaTime: baseTime) else {
            return nil;
        }
        
        return dateBase;
    }
    private func getDateKma( obj: [ String : Any ] ) -> Date? {
        guard let fcstDate = obj[ "fcstDate" ] as? Int else {
            return nil;
        }
        guard let fcstTime = obj[ "fcstTime" ] as? String else {
            return nil;
        }
        
        guard let dateKma = KmaUtils.createDate(kmaDate: String( fcstDate ), kmaTime: fcstTime) else {
            return nil;
        }
        
        return dateKma;
    }
    
    private func getBaseTime( dateNow: Date ) -> Date {
        let calendar = Calendar.current;
        let minute = calendar.component(.minute, from: dateNow);
        
        // clone.
        var dateRet = dateNow;
        
        if( minute <= 40 ) {
            dateRet = Calendar.current.date(byAdding: .hour, value: -1, to: dateNow)!;
        }
        
        let hour = calendar.component(.hour, from: dateRet);
        
        dateRet = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: dateRet)!
        
        return dateRet
    }
}
