//
//  AkApiManager.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit
import CoreData


struct AkApiUrlStruct {
    static let URL_ROOT = "http://openapi.airkorea.or.kr/openapi/services/rest/"
    
    static let URL_STAION_INFO = "MsrstnInfoInqireSvc/"
    static let URL_AIR_INFO = "ArpltnInforInqireSvc/";
}

final class AkApiManager {
    static let shared = AkApiManager();
    
    public func getAirData( dateNow: Date, tmX: Double, tmY: Double, callbackComplete:@escaping (Air) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
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
            guard let coreDataModel = makeCoreDataModel(model: model) else {
                callbackError( ErrorModel() );
                return;
            }
            
            callbackComplete( coreDataModel );
        }
        
        getStation(dateNow: dateNow, tmX: tmX, tmY: tmY, callbackComplete: onCompleteStation, callbackError: callbackError)
    }
    
    private func makeCoreDataModel( model: AkApiAirPmModel ) -> Air? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil;
        }
        let context = appDelegate.persistentContainer.viewContext;
        
        let newObject = Air(context: context);
        
        newObject.dateBaseCalled = model.dateCalled;
        newObject.pm10Value = Int16(model.pm10);
        newObject.pm25Value = Int16(model.pm25);
        newObject.stationName = model.stationName;
        
        return newObject;
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
