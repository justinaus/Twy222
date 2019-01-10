//
//  KmaApiForecastSpace3hours.swift
//  Twy222
//
//  Created by Bonkook Koo on 10/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiForecastSpace3hours: KmaApiBase {
    static let shared = KmaApiForecastSpace3hours();
    
    public func getData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( KmaApiForecastSpace3hours? ) -> Void ) {
        let URL_SERVICE = "ForecastSpaceData";
        
        let dateBase = getBaseDate( dateNow: dateNow );
        
        func onComplete( arrItem: Array<[String:Any]>? ) {
            if( arrItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( dateNow: dateNow, arrItem: arrItem! );
            callback( model );
        }
        
        makeCall( serviceName: URL_SERVICE, baseDate: dateBase, kmaX: kmaX, kmaY: kmaY, callback: onComplete );
    }
    
    private func makeModel( dateNow:Date, arrItem: Array<[ String : Any ]> ) -> KmaApiForecastSpace3hours? {
        // 개수를 조절한다. 왜냐면 그 숫자만큼 어제 실황을 콜해야 하니깐...
        // 8개 제공하자.
        
        
        
        return nil;
    }
    
    
    
    public func getBaseDate( dateNow: Date ) -> Date {
        //0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300
        let arrBaseHour = [ 2, 5, 8, 11, 14, 17, 20, 23 ];
        let LIMIT_MINUTES = 10;
        
        let calendar = Calendar.current;
        let component = calendar.dateComponents([.hour,.minute], from: dateNow);
        
        let nowHour = calendar.component(.hour, from: dateNow);
        
        var dateBaseToCall: Date?;
        
        for hour in arrBaseHour {
            if( nowHour > hour ) {
                dateBaseToCall = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateNow);
                break;
            } else if( nowHour == hour ) {
                dateBaseToCall = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateNow);
                
                if( component.minute! <= LIMIT_MINUTES ) {
                    dateBaseToCall = calendar.date(byAdding: .hour, value: -3, to: dateBaseToCall!);
                }
                break;
            }
        }
        
        if( dateBaseToCall == nil ) {
            // 0시, 01시.
            let hour = arrBaseHour.last!;
            dateBaseToCall = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateNow);
            
            dateBaseToCall = calendar.date(byAdding: .day, value: -1, to: dateBaseToCall!);
        }
        
        print(dateBaseToCall)
        
        return dateBaseToCall!
    }
}
