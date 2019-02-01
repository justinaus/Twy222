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
import Alamofire
import SwiftyJSON

class KmaApiShortBase {
    public func makeCall( serviceName: String, baseDate: Date, kmaXY: KmaXY, callbackComplete:@escaping (Array<JSON>) -> Void, callbackError: @escaping (ErrorModel) -> Void) {
        let url = getUrl(serviceName: serviceName, baseDate: baseDate, kmaXY: kmaXY);
        
        var encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!;
        encodedUrl += "&ServiceKey=\(DataGoKrConfig.APP_KEY)";
        
        Alamofire.request(encodedUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value);
                
                guard let itemArray = self.getItemArray(json: json) else {
                    callbackError( ErrorModel() );
                    return;
                }
                
                callbackComplete( itemArray );
            case .failure(let error):
                print(error)
                callbackError( ErrorModel() );
            }
        }
    }
    
    private func getUrl( serviceName: String, baseDate: Date, kmaXY: KmaXY ) -> String {
        let RESULT_TYPE = "json"
        let NUM_OF_ROWS = 999
        
        let baseDateAndBaseTime = KmaUtils.getBaseDateAndBaseTime(date: baseDate);
        
//        let url = "\(KmaApiUrlStruct.URL_ROOT)\(KmaApiUrlStruct.URL_SHORT_FORECAST)\(serviceName)?ServiceKey=\(DataGoKrConfig.APP_KEY)&base_date=\(baseDateAndBaseTime.baseDate)&base_time=\(baseDateAndBaseTime.baseTime)&nx=\(kmaXY.x)&ny=\(kmaXY.y)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        let url = "\(KmaApiUrlStruct.URL_ROOT)\(KmaApiUrlStruct.URL_SHORT_FORECAST)\(serviceName)?base_date=\(baseDateAndBaseTime.baseDate)&base_time=\(baseDateAndBaseTime.baseTime)&nx=\(kmaXY.x)&ny=\(kmaXY.y)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        return url;
    }
    
    private func getItemArray( json: JSON ) -> Array<JSON>? {
        if let resultCode = json[ "response" ][ "header" ][ "resultCode" ].string {
            if( resultCode != "0000" ) {
                print("resultCode : ", resultCode );
                return nil;
            }
        }
        
        let arrItem = json["response"]["body"]["items"]["item"].array;
        return arrItem;
    }
}
