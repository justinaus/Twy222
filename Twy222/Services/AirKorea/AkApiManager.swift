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
            
            if( modelNotNil.list.count == 0 ) {
                callback( nil );
                return;
            }
            
            // 일단 그냥 측정소 첫번째 거 쓰겠다.
            let stationModel = modelNotNil.list[0];
            
            getAirPm(dateNow: dateNow, stationName: stationModel.stationName, callback: onCompleteAirPm);
        }
        
        func onCompleteAirPm( model: AkApiAirPmModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            let retModel = AirModel(dateBase: modelNotNil.dateCalled, stationName: modelNotNil.stationName, pm10Value: modelNotNil.pm10, pm25Value: modelNotNil.pm25);
            callback( retModel );
        }
        
        getStation(dateNow: dateNow, tmX: tmX, tmY: tmY, callback: onCompleteStation)
    }
    
    private func getStation( dateNow: Date, tmX: Double, tmY: Double, callback:@escaping ( AkApiStationModel? ) -> Void ) {
        let api = AkApiStation.shared;
        
        func onComplete( model: AkApiStationModel? ) {
            callback( model );
        }
        
        api.getData(dateNow: dateNow, tmX: tmX, tmY: tmY, callback: onComplete);
    }
    
    private func getAirPm( dateNow: Date, stationName: String, callback:@escaping ( AkApiAirPmModel? ) -> Void ) {
        let api = AkApiAirPm.shared;
        
        func onComplete( model: AkApiAirPmModel? ) {
            callback( model );
        }
        
        api.getData(dateNow: dateNow, stationName: stationName, callback: onComplete);
    }
}
