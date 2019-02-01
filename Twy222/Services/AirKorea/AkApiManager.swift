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
    
    public func getAirData( dateNow: Date, tmX: Double, tmY: Double, callbackComplete:@escaping (AirModel?) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        func onCompleteStation( model: AkApiStationModel ) {
            if( model.list.count == 0 ) {
                callbackError( ErrorModel() );
                return;
            }
            
            // 일단 그냥 측정소 첫번째 거 쓰겠다.
            let stationModel = model.list[0];
            
            getAirPm(dateNow: dateNow, stationName: stationModel.stationName, callbackComplete: onCompleteAirPm, callbackError: callbackError);
        }
        
        func onCompleteAirPm( model: AkApiAirPmModel ) {
            let retModel = AirModel(dateBase: model.dateCalled, stationName: model.stationName, pm10Value: model.pm10, pm25Value: model.pm25);
            callbackComplete( retModel );
        }
        
        getStation(dateNow: dateNow, tmX: tmX, tmY: tmY, callbackComplete: onCompleteStation, callbackError: callbackError)
    }
    
    private func getStation( dateNow: Date, tmX: Double, tmY: Double, callbackComplete:@escaping (AkApiStationModel) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = AkApiStation.shared;
        
        api.getData(dateNow: dateNow, tmX: tmX, tmY: tmY, callbackComplete: callbackComplete, callbackError: callbackError);
    }
    
    private func getAirPm( dateNow: Date, stationName: String, callbackComplete:@escaping (AkApiAirPmModel) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = AkApiAirPm.shared;
        
        api.getData(dateNow: dateNow, stationName: stationName, callbackComplete: callbackComplete, callbackError: callbackError);
    }
}
