//
//  KakaoApiBase.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KakaoApiBase {
    public func makeCall( serviceName: String, lat: Double, lon: Double, callbackComplete:@escaping ([String:Any]) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let url = getUrl(serviceName: serviceName, lat: lat, lon: lon);
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!;
        
        guard let urlObjct = URL(string: encodedUrl) else {
            callbackError( ErrorModel() );
            return;
        }
        
        var request = URLRequest(url: urlObjct );
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(KakaoConfig.APP_KEY)", forHTTPHeaderField: "Authorization");
        
        let currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if (error != nil) {
                print(error!);
                callbackError( ErrorModel() );
            } else {
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                    callbackError( ErrorModel() );
                    return;
                }
                
                guard let jsonStringAny = json as? [String:Any] else {
                    callbackError( ErrorModel() );
                    return;
                }
                
                callbackComplete( jsonStringAny );
            }
        }
        
        currentTask.resume();
    }
    
    private func getUrl( serviceName: String, lat: Double, lon: Double ) -> String {
        // tm 좌표로 반환 받을 것.
//        let url = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=\(lon)&y=\(lat)";
        let url = "\(KakaoApiUrlStruct.URL_GEO_ROOT)\(serviceName)?x=\(lon)&y=\(lat)&input_coord=WGS84&output_coord=TM";
        
        return url;
    }
}
