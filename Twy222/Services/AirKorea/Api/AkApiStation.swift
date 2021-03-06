//
//  AkApiStation.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import SwiftyJSON

final class AkApiStation: AkApiBase {
    static let shared = AkApiStation();
    
    public func getData( dateNow: Date, tmX: Double, tmY: Double, callbackComplete:@escaping (AkApiStationModel) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let url = getUrl(tmX: tmX, tmY: tmY);
        
//        func onComplete( json: [String:Any] ) {
        func onComplete( json: JSON ) {
            guard let model = makeModel(dateNow: dateNow, json: json) else {
                callbackError( ErrorModel() );
                return;
            }
            
            callbackComplete( model );
        }
        
        makeCall(url: url, callbackComplete: onComplete, callbackError: callbackError)
    }
    
    private func makeModel( dateNow: Date, json: JSON ) -> AkApiStationModel? {
        guard let list = json[ "list" ].array else {
            return nil;
        }
        
        let model = AkApiStationModel(dateCalled: dateNow);
        
        for item in list {
            guard let stationName = item[ "stationName" ].string else {
                continue;
            }
            
            let stationModel = AkStationModel(stationName: stationName);
            
            if let tm = item[ "tm" ].double {
                stationModel.setDistance(value: tm);
            }
            
            model.list.append(stationModel);
        }
        
        return model;
    }
    
    private func getUrl( tmX: Double, tmY: Double ) -> String {
        let URL_SERVICE = "getNearbyMsrstnList";
        
        //http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/getNearbyMsrstnList?serviceKey=it2bUsi%2BviI1KGItdbbUb46%2FssExfJqOAOPPODbKcA8Ytkkol1LIg5SG06Zd%2FzxmRH1Giyz%2FjWfDw1EMWEveDA%3D%3D&tmX=210035.68627433991&tmY=428925.15454860451
        
        let url = "\(AkApiUrlStruct.URL_ROOT)\(AkApiUrlStruct.URL_STAION_INFO)\(URL_SERVICE)?tmX=\(tmX)&tmY=\(tmY)&_returnType=json";
        
        return url;
    }
}
