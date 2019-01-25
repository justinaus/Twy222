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
    
    public func getData( dateBase:Date, regionId: String, callback:@escaping ( KmaApiMidTemperatureModel? ) -> Void ) {
        let URL_SERVICE = "getMiddleTemperature";
        
//        print("중기 기온 call basetime   " + DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( dictItem: [String:Any]? ) {
            if( dictItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( dateBase: dateBase, regId: regionId, dictItem: dictItem! );
            callback( model );
        }
        
        makeCall(serviceName: URL_SERVICE, baseDate: dateBase, regId: regionId, callback: onComplete);
    }
    
    public func hasToCall( prevModel: KmaApiMidTemperatureModel, newDateBase: Date, newRegId: String) -> Bool {
        if( !DateUtil.getIsSameDateAndMinute(date0: prevModel.dateBaseCalled, date1: newDateBase) ) {
            return true;
        }
        
        if( prevModel.regId != newRegId ) {
            return true;
        }
        
        return false;
    }
    
    private func makeModel( dateBase: Date, regId: String, dictItem: [String:Any] ) -> KmaApiMidTemperatureModel? {
        let model = KmaApiMidTemperatureModel(dateBase: dateBase, regId: regId);
        
        // 3일 ~ 10일 제공. 근데 그냥 5개만 하자.
        for i in 2 ..< 7 {
            guard let max = dictItem[ "taMax\(i+1)" ] as? Double else {
                return nil;
            }
            guard let min = dictItem[ "taMin\(i+1)" ] as? Double else {
                return nil;
            }
            
            let date = Calendar.current.date(byAdding: .day, value: i+1, to: dateBase)!;
            
            let tempMaxMin = DailyTemperatureMaxMinModel(date: date, max: max, min: min)
            
            model.list.append( tempMaxMin );
        }
        
        return model;
    }
    
    public func getRegionId( addressSiDo: String?, addressGu: String? ) -> String? {
        var regionId: String?;
        
        if( addressSiDo != nil ) {
            regionId = KmaApiMidTemperatureRegionManager.shared.getRegionCode(strDosi: addressSiDo!);
        }
        
        if( regionId == nil && addressGu != nil ) {
            regionId = KmaApiMidTemperatureRegionManager.shared.getRegionCode(strDosi: addressGu!);
        }
        
        return regionId;
    }
}
