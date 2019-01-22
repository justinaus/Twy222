//
//  KmaMidApiBase.swift
//  Twy222
//
//  Created by Bonkook Koo on 13/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiMidBase {
    
    public func makeCall( serviceName: String, baseDate: Date, regId: String, callback:@escaping ( [String:Any]? ) -> Void ) {
        let url = getUrl(serviceName: serviceName, baseDate: baseDate, regId: regId);
        
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
                
                let dictItem = self.getItemDictionary( anyJson: json );
                callback( dictItem );
            }
        }
        
        currentTask.resume();
    }
    
    private func getUrl( serviceName: String, baseDate: Date, regId: String ) -> String {
        let RESULT_TYPE = "json"
        let NUM_OF_ROWS = 999
        
        let baseDateAndBaseTime = KmaUtils.getBaseDateAndBaseTime(date: baseDate);
        
        let url = "\(KmaApiUrlStruct.URL_ROOT)\(KmaApiUrlStruct.URL_MID_FORECAST)\(serviceName)?ServiceKey=\(DataGoKrConfig.APP_KEY)&tmFc=\(baseDateAndBaseTime.baseDate)\(baseDateAndBaseTime.baseTime)&regId=\(regId)&_type=\(RESULT_TYPE)&numOfRows=\(NUM_OF_ROWS)"
        
        return url;
    }
    
    private func getItemDictionary( anyJson: Any ) -> [ String : Any ]? {
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
        guard let item = items[ "item" ] as? [ String : Any ] else {
            return nil;
        }
        
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
