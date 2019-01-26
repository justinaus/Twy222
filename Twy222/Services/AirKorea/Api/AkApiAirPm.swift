//
//  AkApiAir.swift
//  Twy222
//
//  Created by Bonkook Koo on 27/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class AkApiAirPm: AkApiBase {
    static let shared = AkApiAirPm();
    
    public func getData( dateNow: Date, stationName: String, callback:@escaping ( AkApiAirPmModel? ) -> Void ) {
        let url = getUrl(stationName: stationName);
        
        func onComplete( json: [String:Any]? ) {
            guard let jsonNotNil = json else {
                callback( nil );
                return;
            }
            
            let model = makeModel(dateNow: dateNow, json: jsonNotNil);
            callback( model );
        }
        
        makeCall(url: url, callback: onComplete)
    }
    
    private func makeModel( dateNow: Date, json: [String:Any] ) -> AkApiAirPmModel? {
        guard let list = json[ "list" ] as? Array< [ String : Any ] > else {
            return nil;
        }
        
        for item in list {
            guard let pm10Value = item[ "pm10Value" ] as? String else {
                continue;
            }
            guard let pm25Value = item[ "pm25Value" ] as? String else {
                continue;
            }
            guard let intPm10 = NumberUtil.roundToInt(value: pm10Value) else {
                continue;
            }
            guard let intPm25 = NumberUtil.roundToInt(value: pm25Value) else {
                continue;
            }
            
            // 제일 먼저 것만 쓰겠다.
            let model = AkApiAirPmModel(dateCalled: dateNow, pm10: intPm10, pm25: intPm25);
            return model;
        }
        
        return nil;
    }
    
    private func getUrl( stationName: String ) -> String {
        let URL_SERVICE = "getMsrstnAcctoRltmMesureDnsty";
        
        // numOfRows X, 일단 나는 제일 가까운 시간 한개만 사용하겠다.
        let url = "\(AkApiUrlStruct.URL_ROOT)\(AkApiUrlStruct.URL_AIR_INFO)\(URL_SERVICE)?stationName=\(stationName)&dataTerm=DAILY&ver=1.3&_returnType=json";
        
        return url;
    }
}