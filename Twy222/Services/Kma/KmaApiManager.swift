//
//  KmaApiManager.swift
//  Twy222
//  기상청 api 관리.
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiManager {
    static let shared = KmaApiManager();
    
    public func getNowData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( NowModel ) -> Void ) {
        let retNowModel = NowModel();
        
        // api 3개 호출 해야 됨...
        // 실황 기온, 예보 skystatus, 어제 기온.
        
        func onCompleteApiCurrent( model : KmaApiCurrentModel? ) {
            if( model == nil ) {
                callback( retNowModel );
                return;
            }
            
            retNowModel.setTemperature(value: model!.temperature)
            
            // call forecast api
        }
        
        KmaApiCurrent.shared.getData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiCurrent);
        
        
        
        
//        let url = KmaApiForecastTimeVeryShort.shared.getUrl(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY);
//
//        func onComplete( json: Any? ) {
//            if( json == nil ) {
//                callback( nil );
//                return;
//            }
//
//            guard let arrItem = getItemArray( anyJson: json! ) else {
//                callback( nil );
//                return;
//            }
//
//            guard let model = KmaApiForecastTimeVeryShort.shared.makeModel(arrItem: arrItem) else {
//                callback( nil );
//                return;
//            }
//
//            callback( model );
//        }
//
//        getData( url: url, callback: onComplete );
    }
}
