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
    
    public func getData( dateNow: Date, dateBase:Date, regionId: String, callback:@escaping ( KmaApiMidTemperatureModel? ) -> Void ) {
        let URL_SERVICE = "getMiddleTemperature";
        
//        print( "중기 예보 call base time", DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( dictItem: [String:Any]? ) {
            if( dictItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( dateBase: dateBase, dictItem: dictItem! );
            callback( model );
        }
        
        makeCall(serviceName: URL_SERVICE, baseDate: dateBase, regId: regionId, callback: onComplete);
    }
    
    private func makeModel( dateBase: Date, dictItem: [String:Any] ) -> KmaApiMidTemperatureModel? {
        let model = KmaApiMidTemperatureModel(dateBaseToCall: dateBase);
        
        for i in 2 ..< 7 {
            guard let max = dictItem[ "taMax\(i+1)" ] as? Double else {
                return nil;
            }
            guard let min = dictItem[ "taMin\(i+1)" ] as? Double else {
                return nil;
            }
            
            let tempMaxMin = TemperatureMaxMinModel(max: max, min: min);
            
            model.list.append( tempMaxMin );
        }
        
        return model;
    }
    
    public func getRegionId( addressSiDo: String?, addressGu: String? ) -> String? {
        var regionId: String?;
        
        if( addressSiDo != nil ) {
            regionId = KmaApiMidTemperatureRegion.shared.getRegionCode(strDosi: addressSiDo!);
        }
        
        if( regionId == nil && addressGu != nil ) {
            regionId = KmaApiMidTemperatureRegion.shared.getRegionCode(strDosi: addressGu!);
        }
        
        return regionId;
    }
}
