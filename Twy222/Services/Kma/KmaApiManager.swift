//
//  KmaApiManager.swift
//  Twy222
//  기상청 api 관리.
//  서비스에 종속적이지 않게끔 하려고 한다.
//  viewcontroller는 각 서비스의 매니져하고만 얘기하고.
//  각 서비스의 매니져는 종속적이지 않은 데이터로 리턴을 한다.
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiManager {
    static let shared = KmaApiManager();
    
    public func getForecastHourlyData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( ForecastHourListModel? ) -> Void ) {
        func onCompleteForecastHourly( model: KmaApiForecastSpace3hoursModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            // 일단 이거 그리는 것 부터.
            
            let retModelList = ForecastHourListModel();
            
            var model: HourlyModel;
            
            for kmaModel in modelNotNil.list {
                model = changeToCommonHourlyModel(kmaModel: kmaModel);
                retModelList.list.append(model);
            }
            
            callback( retModelList );
        }
        
        KmaApiForecastSpace3hours.shared.getData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onCompleteForecastHourly)
    }
    
    // 서비스에 종속적이지 않은 모델로 변환.
    private func changeToCommonHourlyModel( kmaModel: KmaHourlyModel ) -> HourlyModel {
        let hour = Calendar.current.component(.hour, from: kmaModel.date)
        let skyStatusImageName = KmaUtils.getStatusImageName(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum, isDay: Utils.getIsDay(hour: hour));
        
        let skyStatusText = KmaUtils.getSkyStatusText(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum);
        
        let model = HourlyModel( date: kmaModel.date, temperature: kmaModel.temperature, skyStatusImageName: skyStatusImageName, skyStatusText: skyStatusText)
        
        return model;
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
