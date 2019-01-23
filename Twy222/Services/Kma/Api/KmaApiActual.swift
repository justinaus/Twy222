//
//  KmaApiCurrent.swift
//  Twy222
//  초단기 실황 조회.
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiActual: KmaApiShortBase {
    static let shared = KmaApiActual();
    
    let URL_SERVICE = "ForecastGrib";
    
    public func getData( dateBase:Date, kmaXY: KmaXY, callback:@escaping ( KmaApiActualModel? ) -> Void ) {
//        print("지정 시간 날씨 basetime   " + DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( arrItem: Array<[String:Any]>? ) {
            if( arrItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( kmaXY: kmaXY, arrItem: arrItem! );
            callback( model );
        }
        
        makeCall(serviceName: URL_SERVICE, baseDate: dateBase, kmaXY: kmaXY, callback: onComplete );
    }
    
    public func getBaseDate( dateNow: Date ) -> Date {
        let LIMIT_MINUTES = 40;
        
        let calendar = Calendar.current;
        let minute = calendar.component(.minute, from: dateNow);
        
        var dateRet = dateNow;
        
        if( minute <= LIMIT_MINUTES ) {
            dateRet = calendar.date(byAdding: .hour, value: -1, to: dateNow)!;
        }
        
        let hour = calendar.component(.hour, from: dateRet);
        
        dateRet = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateRet)!
        
        return dateRet
    }
    
    private func makeModel( kmaXY: KmaXY, arrItem: Array<[ String : Any ]> ) -> KmaApiActualModel? {
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

        let model: KmaApiActualModel = KmaApiActualModel(dateBase: dateBase!, kmaXY: kmaXY, temperature: temerature!);

        return model;
    }
}
