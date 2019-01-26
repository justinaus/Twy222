//
//  AkApiManager.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

struct AkApiUrlStruct {
    static let URL_ROOT = "http://openapi.airkorea.or.kr/openapi/services/rest/"
    
    static let URL_STAION_INFO = "MsrstnInfoInqireSvc/"
    static let URL_AIR_INFO = "ArpltnInforInqireSvc/";
}

final class AkApiManager {
    static let shared = AkApiManager();
    
    public func getAirData( dateNow: Date, tmX: Double, tmY: Double, callback:@escaping ( AirModel? ) -> Void ) {
        func onCompleteStation( model: AkApiStationModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            print(modelNotNil)
        }
        
        getAirStation(dateNow: dateNow, tmX: tmX, tmY: tmY, callback: onCompleteStation)
    }
    
    private func getAirStation( dateNow: Date, tmX: Double, tmY: Double, callback:@escaping ( AkApiStationModel? ) -> Void ) {
        let api = AkApiStation.shared;
        
        func onComplete( model: AkApiStationModel? ) {
            callback( model );
        }
        
        api.getData(dateNow: dateNow, tmX: tmX, tmY: tmY, callback: onComplete)
    }
}
