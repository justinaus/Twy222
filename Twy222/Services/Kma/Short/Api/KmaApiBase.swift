//
//  KmaApiBase.swift
//  Twy222
//  기상청 api base.
//  모든 기상청 api는 이 클래스를 상속한다.
//  공통적으로 사용 되는 부분을 여기에.
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiBase {
    
    public func makeCall( serviceName: String, baseDate: Date, kmaX: Int, kmaY: Int, callback:@escaping ( Array<[String:Any]>? ) -> Void ) {
        let url = getUrl(serviceName: serviceName, baseDate: baseDate, kmaX: kmaX, kmaY: kmaY);
        
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
                
                let arrItem = self.getItemArray( anyJson: json );
                callback( arrItem );
            }
        }
        
        currentTask.resume();
    }
    
    
    private func getUrl( serviceName: String, baseDate: Date, kmaX: Int, kmaY: Int ) -> String {
        let RESULT_TYPE = "json"
        let NUM_OF_ROWS = 999
        
        let baseDateAndBaseTime = KmaUtils.getBaseDateAndBaseTime(date: baseDate);
        
        let url = "\(KmaApiUrlStruct.URL_ROOT)\(KmaApiUrlStruct.URL_SHORT_FORECAST)\(serviceName)?ServiceKey=\(DataGoKrConfig.APP_KEY)&base_date=\(baseDateAndBaseTime.baseDate)&base_time=\(baseDateAndBaseTime.baseTime)&nx=\(kmaX)&ny=\(kmaY)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        return url;
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
            print("resultCode : ", resultCode )
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
