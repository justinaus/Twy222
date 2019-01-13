//
//  KmaApiForecastTimeVeryShort.swift
//  Twy222
//  초단기 예보 조회
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiForecastTimeVeryShort: KmaApiBase {
    static let shared = KmaApiForecastTimeVeryShort();
    
    public func getData( dateNow: Date, dateBase:Date, kmaX: Int, kmaY: Int, callback:@escaping ( KmaApiForecastTimeVeryShortModel? ) -> Void ) {
        let URL_SERVICE = "ForecastTimeData";
        
//        print( "초단기 예보 조회 base time", DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( arrItem: Array<[String:Any]>? ) {
            if( arrItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( dateNow: dateNow, dateBase: dateBase, arrItem: arrItem! );
            callback( model );
        }
        
        makeCall( serviceName: URL_SERVICE, baseDate: dateBase, kmaX: kmaX, kmaY: kmaY, callback: onComplete );
    }
    
    public func getBaseDate( dateNow: Date ) -> Date {
        let LIMIT_MINUTES = 45;
        
        let calendar = Calendar.current;
        let minute = calendar.component(.minute, from: dateNow);
        
        var dateRet = dateNow;
        
        if( minute <= LIMIT_MINUTES ) {
            dateRet = calendar.date(byAdding: .hour, value: -1, to: dateNow)!;
        }
        
        let hour = calendar.component(.hour, from: dateRet);
        
        dateRet = calendar.date(bySettingHour: hour, minute: 30, second: 0, of: dateRet)!
        
        return dateRet
    }
    
    public func hasToCall( prevDateCalled: Date?, baseDateToCall: Date ) -> Bool {
        if( prevDateCalled == nil ) {
            return true;
        }
        
        return DateUtil.getIsSameDateAndMinute(date0: prevDateCalled!, date1: baseDateToCall);
    }
    
    private func makeModel( dateNow: Date, dateBase: Date, arrItem: Array<[ String : Any ]> ) -> KmaApiForecastTimeVeryShortModel? {
        let len = arrItem.count;
        
        var dateFcst: Date?;
        
        var temperature: Double?;
        var skyEnum: KmaSkyEnum?;
        var ptyEnum: KmaPtyEnum?;
        
        for i in 0..<len {
            let obj = arrItem[ i ];

            guard let dateForecast = KmaUtils.getDateByDateAndTime(anyDate: obj["fcstDate"], anyTime: obj["fcstTime"]) else {
                continue;
            }
            
            // 지금 현재 시간의 다음 시간 ex 02:10 이면 03:00 정보, 02:50이면 03:00 정보 사용.
            
            let nowHour = Calendar.current.component(.hour, from: dateNow);
            let forecastHour = Calendar.current.component(.hour, from: dateForecast);
            
            if( nowHour + 1 != forecastHour ) {
                continue;
            }
            
            if( dateFcst == nil ) {
                dateFcst = dateForecast;
            }
            
            guard let category = obj[ "category" ] as? String else {
                continue;
            }
            
            switch( category ) {
            case KmaCategoryCodeEnum.T1H.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Double else {
                    continue;
                }
                
                temperature = fcstValue;
                
                break;
            case KmaCategoryCodeEnum.PTY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Int else {
                    continue;
                }
                guard let ptyEnumTemp = KmaPtyEnum(rawValue: fcstValue) else {
                    continue;
                }
                
                ptyEnum = ptyEnumTemp;
                
                break;
            case KmaCategoryCodeEnum.SKY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Int else {
                    continue;
                }
                guard let skyEnumTemp = KmaSkyEnum(rawValue: fcstValue) else {
                    continue;
                }
                
                skyEnum = skyEnumTemp;
                break;
            default:
                continue;
            }
        }
        
        if( temperature == nil || dateFcst == nil || skyEnum == nil || ptyEnum == nil ) {
            return nil;
        }
        
        let model: KmaApiForecastTimeVeryShortModel = KmaApiForecastTimeVeryShortModel( dateBase: dateBase, dateForecast: dateFcst!, temperature: temperature!, skyEnum: skyEnum!, ptyEnum: ptyEnum!);
        
//        print( "초단기 예보 받은 값", DateUtil.getStringByDate(date: dateFcst!) );
        
        return model;
    }
}
