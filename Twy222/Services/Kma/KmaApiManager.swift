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
    
    public func getForecastHourlyData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( ForecastHourlyModel? ) -> Void ) {
        var retHourlyModel: ForecastHourlyModel;
        
        func onCompleteForecastHourly( model: KmaApiForecastSpace3hours? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            print(modelNotNil)
        }
        
        KmaApiForecastSpace3hours.shared.getData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onCompleteForecastHourly)
    }
    
    public func getNowData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( NowModel? ) -> Void ) {
        var retNowModel: NowModel?;
        
        func onCompleteApiForecastTimeVeryShort( model: KmaApiForecastTimeVeryShortModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            let hour = Calendar.current.component(.hour, from: modelNotNil.dateForecast)
            let skyStatusImageName = KmaUtils.getStatusImageName(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum, isDay: Utils.getIsDay(hour: hour));
            
            let skyStatusText = KmaUtils.getSkyStatusText(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum);
            
            retNowModel = NowModel(temperature: model!.temperature, skyStatusImageName: skyStatusImageName, skyStatusText: skyStatusText)
            
            let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: modelNotNil.dateForecast)!;
            
            KmaApiActual.shared.getDataByDateBase(dateBase: dateYesterday, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiYesterday);
        }
        
        func onCompleteApiYesterday( model: KmaApiActualModel? ) {
            if( model == nil ) {
                print("어제 날씨 실황 가져오기 실패.")
                callback( retNowModel );
                return;
            }
            
            let yesterdayTemperature = model!.temperature;
            let resultDiff = retNowModel!.temperature - yesterdayTemperature;
            retNowModel!.setDiffFromYesterday(value: resultDiff );
            
            callback( retNowModel );
        }
        
        KmaApiForecastTimeVeryShort.shared.getData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiForecastTimeVeryShort);
    }
}
