//
//  기상청 api 관련.
//  KmaApiService.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

struct KmaApiStruct {
    static let URL_ROOT = "http://newsky2.kma.go.kr/service/"
    
    // (신)동네예보정보조회서비스
    static let URL_MID_FORECAST = "SecndSrtpdFrcstInfoService2/"
}

final class KmaApiService {
    static let shared = KmaApiService();
    
    public func getNowModel( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( WeatherHourlyModel? ) -> Void ) {
        let url = KmaApiForecastTimeVeryShort.shared.getUrl(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY);
        
        func onComplete( json: Any? ) {
            if( json == nil ) {
                callback( nil );
                return;
            }
            
            guard let arrItem = getItemArray( anyJson: json! ) else {
                callback( nil );
                return;
            }
            
            guard let model = KmaApiForecastTimeVeryShort.shared.makeModel(arrItem: arrItem) else {
                callback( nil );
                return;
            }

            callback( model );
        }
        
        getData( url: url, callback: onComplete );
    }
    
    
    private func getData( url: String, callback:@escaping ( Any? ) -> Void ) {
        guard let urlObjct = URL(string: url) else {
            callback( nil );
            return;
        }
        
        var request = URLRequest(url: urlObjct );
        request.httpMethod = "GET"
        
        let currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if (error != nil) {
                print(error!);
                callback( nil );
            } else {
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                    callback( nil );
                    return;
                }
                
                callback( json );
            }
        }
        
        currentTask.resume()
    }
    
    private func getItemArray( anyJson: Any ) -> Array<[ String : Any ]>? {
        guard let json = anyJson as? [String:Any] else {
            return nil;
        }
        
        guard let response = json[ "response" ] as? [ String : Any ] else {
            return nil;
        }
        guard let header = response[ "header" ] as? [ String : Any ] else {
            return nil;
        }
        guard let resultCode = header[ "resultCode" ] as? String else {
            return nil;
        }
        if( resultCode != "0000" ) {
            return nil;
        }
        guard let body = response[ "body" ] as? [ String : Any ] else {
            return nil;
        }
        guard let items = body[ "items" ] as? [ String : Any ] else {
            return nil;
        }
        guard let item = items[ "item" ] as? Array<[ String : Any ]> else {
            return nil;
        }
        
        return item;
    }
}

