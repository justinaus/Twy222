//
//  KmaMidApiBase.swift
//  Twy222
//
//  Created by Bonkook Koo on 13/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class KmaApiMidBase {
    
    public func makeCall( serviceName: String, baseDate: Date, regId: String, callbackComplete:@escaping (JSON) -> Void, callbackError: @escaping (ErrorModel) -> Void ) {
        let url = getUrl(serviceName: serviceName, baseDate: baseDate, regId: regId);
        
        var encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!;
        encodedUrl += "&ServiceKey=\(DataGoKrConfig.APP_KEY)";
        
        Alamofire.request(encodedUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value);
                
                guard let item = self.getItemDictionary(json: json) else {
                    callbackError( ErrorModel() );
                    return;
                }
                
                callbackComplete( item );
            case .failure(let error):
                print(error)
                callbackError( ErrorModel() );
            }
        }
        
        
    }
    
    private func getUrl( serviceName: String, baseDate: Date, regId: String ) -> String {
        let RESULT_TYPE = "json"
        let NUM_OF_ROWS = 999
        
        let baseDateAndBaseTime = KmaUtils.getBaseDateAndBaseTime(date: baseDate);
        
//        let url = "\(KmaApiUrlStruct.URL_ROOT)\(KmaApiUrlStruct.URL_MID_FORECAST)\(serviceName)?ServiceKey=\(DataGoKrConfig.APP_KEY)&tmFc=\(baseDateAndBaseTime.baseDate)\(baseDateAndBaseTime.baseTime)&regId=\(regId)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        let url = "\(KmaApiUrlStruct.URL_ROOT)\(KmaApiUrlStruct.URL_MID_FORECAST)\(serviceName)?tmFc=\(baseDateAndBaseTime.baseDate)\(baseDateAndBaseTime.baseTime)&regId=\(regId)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        return url;
    }
    
    private func getItemDictionary( json: JSON ) -> JSON? {
        if let resultCode = json[ "response" ][ "header" ][ "resultCode" ].string {
            if( resultCode != "0000" ) {
                print("resultCode : ", resultCode );
                return nil;
            }
        }
        
        let item = json["response"]["body"]["items"]["item"];
        return item;
    }
    
    public func getBaseDate( dateNow: Date ) -> Date {
        let calendar = Calendar.current;
        
        //0600, 1800
        // 18시 10분 이후는 1800로 호출, 아니면 0600시로 호출 하게끔.
        let dateLimit18 = calendar.date(bySettingHour: 18, minute: 10, second: 0, of: dateNow);
        let dateLimit06 = calendar.date(bySettingHour: 06, minute: 10, second: 0, of: dateNow);
        
        var dateBaseToCall: Date?;
        
        if( dateNow > dateLimit18! ) {
            dateBaseToCall = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: dateNow);
        } else if( dateNow > dateLimit06! ) {
            dateBaseToCall = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: dateNow);
        } else {
            let temp = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: dateNow);
            dateBaseToCall = calendar.date(byAdding: .day, value: -1, to: temp!)
        }
        
        return dateBaseToCall!
    }
}
