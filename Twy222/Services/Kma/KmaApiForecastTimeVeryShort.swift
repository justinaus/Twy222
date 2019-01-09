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
    
    public func getData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( KmaApiForecastTimeVeryShortModel? ) -> Void ) {
        let URL_SERVICE = "ForecastTimeData";
        
        let dateBase = getBaseDate( dateNow: dateNow );
        
        func onComplete( arrItem: Array<[String:Any]>? ) {
            if( arrItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( arrItem: arrItem! );
            callback( model );
        }
        
        makeCall(serviceName: URL_SERVICE, baseDate: dateBase, kmaX: kmaX, kmaY: kmaY, callback: onComplete );
    }
    
    private func makeModel( arrItem: Array<[ String : Any ]> ) -> KmaApiForecastTimeVeryShortModel? {
        let len = arrItem.count;
        
        var dateBase: Date?;
        var dateFcst: Date?;
        
        var skyEnum: KmaSkyEnum?;
        var ptyEnum: KmaPtyEnum?;
        
        for i in 0..<len {
            let obj = arrItem[ i ];
            
            if( i == 0 ) {
                guard let dateBaseTemp = KmaUtils.getDateByDateAndTime(anyDate: obj["baseDate"], anyTime: obj["baseTime"]) else {
                    return nil;
                }
                dateBase = dateBaseTemp;
            }
            
            guard let dateKma = KmaUtils.getDateByDateAndTime(anyDate: obj["fcstDate"], anyTime: obj["fcstTime"]) else {
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
        
        if( dateBase == nil || dateFcst == nil || skyEnum == nil || ptyEnum == nil ) {
            return nil;
        }
        
        let model: KmaApiForecastTimeVeryShortModel = KmaApiForecastTimeVeryShortModel(dateForecast: dateFcst!, skyEnum: skyEnum!, ptyEnum: ptyEnum!)
        
        return model;
    }
    
    private func getBaseDate( dateNow: Date ) -> Date {
        let LIMIT_MINUTES = 45;
        
        let calendar = Calendar.current;
        let minute = calendar.component(.minute, from: dateNow);
        
        var dateRet = dateNow;
        
        if( minute <= LIMIT_MINUTES ) {
            dateRet = Calendar.current.date(byAdding: .hour, value: -1, to: dateNow)!;
        }
        
        let hour = calendar.component(.hour, from: dateRet);
        
        dateRet = Calendar.current.date(bySettingHour: hour, minute: 30, second: 0, of: dateRet)!
        
        return dateRet
    }
}
