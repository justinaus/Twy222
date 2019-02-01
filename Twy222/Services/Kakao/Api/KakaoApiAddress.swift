//
//  KakaoApiAddress.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import SwiftyJSON

final class KakaoApiAddress: KakaoApiBase {
    static let shared = KakaoApiAddress();
    
    public func getData( dateNow: Date, lon: Double, lat: Double, callbackComplete: @escaping (KakaoApiAddressModel) -> Void, callbackError: @escaping (ErrorModel) -> Void ) {
        let URL_SERVICE = "coord2regioncode.json";
        
        func onComplete( json: JSON ) {
            guard let model = makeModel(dateNow: dateNow, json: json) else {
                callbackError( ErrorModel() );
                return;
            }
            
            callbackComplete( model );
        }
        
        makeCall(serviceName: URL_SERVICE, lat: lat, lon: lon, callbackComplete: onComplete, callbackError: callbackError);
    }
    
    private func makeModel( dateNow: Date, json: JSON ) -> KakaoApiAddressModel? {
        guard let documents = json[ "documents" ].array else {
            return nil;
        }
        
        for item in documents {
            // 일단 법정 타입 데이터만 사용.
            if( item[ "region_type" ].string != "B" ) {
                continue;
            }
            
            guard let code = item[ "code" ].string else {
                return nil;
            }
            guard let x = item[ "x" ].double else {
                return nil;
            }
            guard let y = item[ "y" ].double else {
                return nil;
            }
            guard let address_name = item[ "address_name" ].string else {
                return nil;
            }
            
            let model = KakaoApiAddressModel(dateBase: dateNow, regionCode: code, addressFull: address_name, tmX: x, tmY: y);
            
            if let region_1depth_name = item[ "region_1depth_name" ].string {
                model.setAddressSido(value: region_1depth_name);
            }
            if let region_2depth_name = item[ "region_2depth_name" ].string {
                model.setAddressGu(value: region_2depth_name);
            }
            if let region_3depth_name = item[ "region_3depth_name" ].string {
                model.setAddressDong(value: region_3depth_name);
            }
            
            return model;
        }
        
        return nil;
    }
}
