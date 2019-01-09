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
        
        func onCompleteApiForecastTimeVeryShort( model: KmaApiForecastTimeVeryShortModel? ) {
            guard let modelNotNil = model else {
                callback( NowModel() );
                return;
            }
            
            retNowModel.setTemperature(value: model!.temperature)
            
            let hour = Calendar.current.component(.hour, from: modelNotNil.dateForecast)
            
            let skyStatusImageName = KmaUtils.getStatusImageName(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum, isDay: Utils.getIsDay(hour: hour));
            
            retNowModel.setSkyStatusImageName(value: skyStatusImageName);
            
            let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: modelNotNil.dateForecast)!;
            
            KmaApiActual.shared.getDataByDateBase(dateBase: dateYesterday, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiYesterday);
        }
        
        func onCompleteApiYesterday( model: KmaApiActualModel? ) {
            if( model == nil ) {
                callback( retNowModel );
                return;
            }
            
            let yesterdayTemperature = model!.temperature;
            let resultDiff = retNowModel.temperature! - yesterdayTemperature;
            let intDiff = Int( resultDiff.rounded() );
            
            retNowModel.setDiffFromYesterday(value: intDiff );
            
            callback( retNowModel );
        }
        
        KmaApiForecastTimeVeryShort.shared.getData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiForecastTimeVeryShort);
    }
}
