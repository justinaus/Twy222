//
//  KakaoApiService.swift
//  Twy222
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KakaoApiService {
    static let shared = KakaoApiService();
    
    public func getGridModel( lon: Double, lat: Double, callback:@escaping ( GridModel? ) -> Void ) {
        let url = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=\(lon)&y=\(lat)";
        
        guard let urlObjct = URL(string: url) else {
            callback( nil );
            return;
        }
        
        var request = URLRequest(url: urlObjct );
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(KakaoConfig.APP_KEY)", forHTTPHeaderField: "Authorization");
        
        let currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if (error != nil) {
                print(error!);
                callback( nil );
            } else {
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                    callback( nil );
                    return;
                }
                
                guard let jsonStringAny = json as? [String:Any] else {
                    callback( nil );
                    return;
                }
                
                guard let gridModel = self.parseJson( json: jsonStringAny ) else {
                    callback( nil );
                    return;
                }
                
                callback( gridModel );
            }
        }
        
        currentTask.resume()
    }
    
    private func parseJson( json: [String:Any] ) -> GridModel? {
        guard let documents = json[ "documents" ] as? Array< [ String : Any ] > else {
            return nil;
        }
        
        let len = documents.count;
        
        for i in 0..<len {
            let obj = documents[ i ];
            
            guard let region_type = obj[ "region_type" ] as? String else {
                continue;
            }
            
            // 일단 법정 타입 데이터로.
            if( region_type == "H" ) {
                continue;
            }
            
            guard let gridModel = makeGridModel( obj ) else {
                continue;
            }
            
            return gridModel;
        }
        
        return nil;
    }
    
    private func makeGridModel( _ obj: [ String : Any ] ) -> GridModel? {
        guard let code = obj[ "code" ] as? String else {
            return nil;
        }
        guard let x = obj[ "x" ] as? Double else {
            return nil;
        }
        guard let y = obj[ "y" ] as? Double else {
            return nil;
        }
        
//        let gridModel:GridModel = GridModel( id: code, lat: String(y), lon: String(x) );
        let gridModel:GridModel = GridModel( id: code, lat: y, lon: x );
        
        if let region_1depth_name = obj[ "region_1depth_name" ] as? String {
            gridModel.setAddressSido(value: region_1depth_name);
        }
        if let region_2depth_name = obj[ "region_2depth_name" ] as? String {
            gridModel.setAddressGu(value: region_2depth_name);
        }
        if let region_3depth_name = obj[ "region_3depth_name" ] as? String {
            gridModel.setAddressDong(value: region_3depth_name);
        }
        if let address_name = obj[ "address_name" ] as? String {
            gridModel.setAddressFull(value: address_name);
        }
        
        if( gridModel.getAddressTitle() == nil ) {
            return nil;
        }
        
        return gridModel;
    }
    
}
