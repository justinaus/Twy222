//
//  KakaoApiManager.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit

struct KakaoApiUrlStruct {
    static let URL_GEO_ROOT = "https://dapi.kakao.com/v2/local/geo/"
    
//    static let URL_SHORT_FORECAST = "SecndSrtpdFrcstInfoService2/"
//    static let URL_MID_FORECAST = "MiddleFrcstInfoService/";
}

final class KakaoApiManager {
    static let shared = KakaoApiManager();
    
    public func getAddressData( dateNow: Date, lat: Double, lon: Double, callbackComplete:@escaping (AddressEntity) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = KakaoApiAddress.shared;
        
        func onComplete( model: KakaoApiAddressModel ) {
//            guard let coreDataModel = makeCoreDataModel(model: model) else {
//                callbackError( ErrorModel() );
//                return;
//            }
            
            let coreDataModel = makeCoreDataModel(model: model)
            
            callbackComplete( coreDataModel );
        }
        
        api.getData(dateNow: dateNow, lon: lon, lat: lat, callbackComplete: onComplete, callbackError: callbackError)
    }
    
    private func makeCoreDataModel( model: KakaoApiAddressModel ) -> AddressEntity {
        let context = CoreDataManager.shared.context!;
        
        let newObject = AddressEntity(context: context);
        
        newObject.dateCalled = model.dateCalled;
        newObject.addressFull = model.addressFull;
        newObject.addressSiDo = model.addressSiDo;
        newObject.addressGu = model.addressGu;
        newObject.addressDong = model.addressDong;
        newObject.tmX = model.tmX;
        newObject.tmY = model.tmY;
        
        return newObject;
    }
}
