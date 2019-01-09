//
//  KmaApiCurrent.swift
//  Twy222
//  초단기 실황 조회.
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiCurrent: KmaApiBase {
    static let shared = KmaApiCurrent();
    
    public func getData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( KmaApiCurrentModel? ) -> Void ) {
        let URL_SERVICE = "ForecastGrib";
        
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
    
    private func makeModel( arrItem: Array<[ String : Any ]> ) -> KmaApiCurrentModel? {
        let len = arrItem.count;

        var dateBase: Date?;
        var temerature: Double?;
        
        for i in 0..<len {
            let obj = arrItem[ i ];

            guard let category = obj[ "category" ] as? String else {
                continue;
            }

            switch( category ) {
            case KmaCategoryCodeEnum.T1H.rawValue:
                guard let obsrValue = obj[ "obsrValue" ] as? Double else {
                    return nil;
                }
                guard let dateBaseTemp = KmaUtils.getDateByDateAndTime(anyDate: obj[ "baseDate" ], anyTime: obj[ "baseTime" ]) else {
                    return nil;
                }
                
                temerature = obsrValue;
                dateBase = dateBaseTemp;
                
                break;
            default:
                continue;
            }
        }

        if( dateBase == nil || temerature == nil ) {
            return nil;
        }

        let model: KmaApiCurrentModel = KmaApiCurrentModel(date: dateBase!, temperature: temerature!);

        return model;
    }
    
    private func getBaseDate( dateNow: Date ) -> Date {
        let LIMIT_MINUTES = 40;
        
        let calendar = Calendar.current;
        let minute = calendar.component(.minute, from: dateNow);
        
        var dateRet = dateNow;
        
        if( minute <= LIMIT_MINUTES ) {
            dateRet = Calendar.current.date(byAdding: .hour, value: -1, to: dateNow)!;
        }
        
        let hour = calendar.component(.hour, from: dateRet);
        
        dateRet = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: dateRet)!
        
        return dateRet
    }
}
