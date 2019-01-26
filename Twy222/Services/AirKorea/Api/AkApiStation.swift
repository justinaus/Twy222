//
//  AkApiStation.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class AkApiStation: AkApiBase {
    static let shared = AkApiStation();
    
    public func getData( dateNow: Date, tmX: Double, tmY: Double, callback:@escaping ( AkApiStationModel? ) -> Void ) {
        let url = getUrl(tmX: tmX, tmY: tmY);
        
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
    
    private func makeModel( dateNow: Date, json: [String:Any] ) -> AkApiStationModel? {
        guard let list = json[ "list" ] as? Array< [ String : Any ] > else {
            return nil;
        }
        
        let model = AkApiStationModel(dateCalled: dateNow);
        
        for item in list {
            guard let stationName = item[ "stationName" ] as? String else {
                continue;
            }
            
            
            let stationModel = AkStationModel(stationName: stationName);
            
            if let tm = item[ "tm" ] as? Double {
                stationModel.setDistance(value: tm);
            }
            
            model.list.append(stationModel);
        }
        
        return model;
    }
    
    private func getUrl( tmX: Double, tmY: Double ) -> String {
        let URL_SERVICE = "getNearbyMsrstnList";
        
        //http://openapi.airkorea.or.kr/openapi/services/rest/MsrstnInfoInqireSvc/getNearbyMsrstnList?serviceKey=it2bUsi%2BviI1KGItdbbUb46%2FssExfJqOAOPPODbKcA8Ytkkol1LIg5SG06Zd%2FzxmRH1Giyz%2FjWfDw1EMWEveDA%3D%3D&tmX=210035.68627433991&tmY=428925.15454860451
        
        let url = "\(AkApiUrlStruct.URL_ROOT)\(AkApiUrlStruct.URL_STAION_INFO)\(URL_SERVICE)?ServiceKey=\(DataGoKrConfig.APP_KEY)&tmX=\(tmX)&tmY=\(tmY)&_returnType=json";
        
        return url;
    }
}
