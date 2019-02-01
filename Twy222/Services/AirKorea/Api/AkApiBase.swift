//
//  AkApiBase.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AkApiBase {
    public func makeCall( url: String, callbackComplete:@escaping (JSON) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        var encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!;
        encodedUrl += "&ServiceKey=\(DataGoKrConfig.APP_KEY)";
        
        Alamofire.request(encodedUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                callbackComplete( json );
            case .failure(let error):
                print(error)
                callbackError( ErrorModel() );
            }
        }
    }
}




