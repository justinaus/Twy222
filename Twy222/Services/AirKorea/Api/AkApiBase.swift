//
//  AkApiBase.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class AkApiBase {
    public func makeCall( url: String, callback:@escaping ( [String:Any]? ) -> Void ) {
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
                
                guard let jsonStringAny = json as? [String:Any] else {
                    callback( nil );
                    return;
                }
                
                callback( jsonStringAny );
            }
        }
        
        currentTask.resume();
    }
}




