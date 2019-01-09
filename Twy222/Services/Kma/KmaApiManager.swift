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
        
        func onCompleteApiCurrent( model: KmaApiCurrentModel? ) {
            if( model == nil ) {
                callback( retNowModel );
                return;
            }
            
            retNowModel.setTemperature(value: model!.temperature)
            
            KmaApiForecastTimeVeryShort.shared.getData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiForecastTimeVeryShort);
        }
        
        func onCompleteApiForecastTimeVeryShort( model: KmaApiForecastTimeVeryShortModel? ) {
            guard let modelNotNil = model else {
                callback( NowModel() );
                return;
            }
            
            let hour = Calendar.current.component(.hour, from: modelNotNil.dateForecast)
            
            let skyStatusImageName = KmaUtils.getStatusImageName(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum, isDay: Utils.getIsDay(hour: hour));
            
            retNowModel.setSkyStatusImageName(value: skyStatusImageName);
            
            // call yesterday ..
        }
        
        KmaApiCurrent.shared.getData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiCurrent);
    }
}
