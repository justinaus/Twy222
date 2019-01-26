//
//  KakaoApiManager.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

struct KakaoApiUrlStruct {
    static let URL_GEO_ROOT = "https://dapi.kakao.com/v2/local/geo/"
    
//    static let URL_SHORT_FORECAST = "SecndSrtpdFrcstInfoService2/"
//    static let URL_MID_FORECAST = "MiddleFrcstInfoService/";
}

final class KakaoApiManager {
    static let shared = KakaoApiManager();
    
    public func getAddressData( dateNow: Date, lat: Double, lon: Double, callback:@escaping ( IAddressModel? ) -> Void ) {
        let api = KakaoApiAddress.shared;
        
        func onComplete( model: KakaoApiAddressModel? ) {
            callback( model );
        }
        
        api.getData(dateNow: dateNow, lon: lon, lat: lat, callback: onComplete)
    }
}
