//
//  AkApiBase.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class AkApiBase {
    public func makeCall( url: String, callbackComplete:@escaping ([String:Any]) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        var encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!;
        encodedUrl += "&ServiceKey=\(DataGoKrConfig.APP_KEY)";
        
        guard let urlObjct = URL(string: encodedUrl) else {
            callbackError( ErrorModel() );
            return;
        }
        
        var request = URLRequest(url: urlObjct );
        request.httpMethod = "GET"
        
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
}




