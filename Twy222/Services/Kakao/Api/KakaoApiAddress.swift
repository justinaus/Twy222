//
//  KakaoApiAddress.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KakaoApiAddress: KakaoApiBase {
    static let shared = KakaoApiAddress();
    
    public func getData( dateNow: Date, lon: Double, lat: Double, callbackComplete: @escaping (KakaoApiAddressModel) -> Void, callbackError: @escaping (ErrorModel) -> Void ) {
        let URL_SERVICE = "coord2regioncode.json";
        
        func onComplete( json: [String:Any] ) {
            guard let model = makeModel(dateNow: dateNow, json: json) else {
                callbackError( ErrorModel() );
                return;
            }
            
            callbackComplete( model );
        }
        
        makeCall(serviceName: URL_SERVICE, lat: lat, lon: lon, callbackComplete: onComplete, callbackError: callbackError);
    }
    
    private func makeModel( dateNow: Date, json: [String:Any] ) -> KakaoApiAddressModel? {
        guard let documents = json[ "documents" ] as? Array< [ String : Any ] > else {
            return nil;
        }
        
        for item in documents {
            guard let region_type = item[ "region_type" ] as? String else {
                continue;
            }
            // 일단 법정 타입 데이터로.
            if( region_type == "H" ) {
                continue;
            }
            
            guard let code = item[ "code" ] as? String else {
                return nil;
            }
            guard let x = item[ "x" ] as? Double else {
                return nil;
            }
            guard let y = item[ "y" ] as? Double else {
                return nil;
            }
            guard let address_name = item[ "address_name" ] as? String else {
                return nil;
            }
            
            let model = KakaoApiAddressModel(dateBase: dateNow, regionCode: code, addressFull: address_name, tmX: x, tmY: y);
            
            if let region_1depth_name = item[ "region_1depth_name" ] as? String {
                model.setAddressSido(value: region_1depth_name);
            }
            if let region_2depth_name = item[ "region_2depth_name" ] as? String {
                model.setAddressGu(value: region_2depth_name);
            }
            if let region_3depth_name = item[ "region_3depth_name" ] as? String {
                model.setAddressDong(value: region_3depth_name);
            }
            
            return model;
        }
        
        return nil;
    }
}
