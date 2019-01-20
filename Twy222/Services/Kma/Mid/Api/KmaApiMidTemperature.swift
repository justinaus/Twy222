//
//  KmaMidApiTemperature.swift
//  Twy222
//
//  Created by Bonkook Koo on 13/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiMidTemperature: KmaApiMidBase {
    static let shared = KmaApiMidTemperature();
    
    private class TemperatureMaxMin {
        var max: Double;
        var min: Double;
        
        init( max: Double, min: Double ) {
            self.max = max;
            self.min = min;
        }
    }
    
    public func getData( dateNow: Date, dateBase:Date, regionId: String, callback:@escaping ( KmaApiMidModel? ) -> Void ) {
        let URL_SERVICE = "getMiddleTemperature";
        
        print( "중기 예보 call base time", DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( dictItem: [String:Any]? ) {
            if( dictItem == nil ) {
                callback( nil );
                return;
            }
            
            let arrTemperature = makeTemperatureArray( dictItem: dictItem! );
            
            print(arrTemperature);
            
//            callback( model );
        }
        
        makeCall(serviceName: URL_SERVICE, baseDate: dateBase, regId: regionId, callback: onComplete);
    }
    
    private func makeTemperatureArray( dictItem: [String:Any] ) -> Array<TemperatureMaxMin>? {
        var arrRet: Array<TemperatureMaxMin> = [];
        
        for i in 2 ..< 10 {
            guard let max = dictItem[ "taMax\(i+1)" ] as? Double else {
                return nil;
            }
            guard let min = dictItem[ "taMin\(i+1)" ] as? Double else {
                return nil;
            }
            
            arrRet.append( TemperatureMaxMin(max: max, min: min) );
        }
        
        return arrRet;
    }

    public func getBaseDate( dateNow: Date ) -> Date {
        let calendar = Calendar.current;
        
        //0600, 1800
        // 18시 10분 이후는 1800로 호출, 아니면 0600시로 호출 하게끔.
        let limitDate = calendar.date(bySettingHour: 18, minute: 10, second: 0, of: dateNow);
        
        var dateBaseToCall: Date?;
        
        if( dateNow > limitDate! ) {
            dateBaseToCall = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: dateNow);
        } else {
            dateBaseToCall = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: dateNow);
        }
        
        return dateBaseToCall!
    }
}
