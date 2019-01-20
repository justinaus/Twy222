//
//  KmaApiManager.swift
//  Twy222
//  기상청 api 관리.
//  서비스에 종속적이지 않게끔 하려고 한다.
//  viewcontroller는 각 서비스의 매니져하고만 얘기하고.
//  각 서비스의 매니져는 종속적이지 않은 데이터로 리턴을 한다.
//  얘까지는 밖의 정보에 접근할 수 있도록 하자. ex gridmanager.
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiManager {
    static let shared = KmaApiManager();
    
    
    public func getForecastMidData( dateNow: Date, callback:@escaping ( ForecastMidListModel? ) -> Void ) {
        guard let currentGridModel = GridManager.shared.getCurrentGridModel() else {
            callback( nil );
            return ;
        }
        
        guard let regionId = getRegionId(gridModel: currentGridModel) else {
            callback( nil );
            return ;
        }
        
        let api = KmaApiMidTemperature.shared;
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        
        let prevModel = currentGridModel.forecastMidList;
        let hasToCall = api.hasToCall(prevDateCalled: prevModel?.dateBaseToCall, baseDateToCall: dateBase);
        if( !hasToCall )  {
            print("이미 해당 시간에 대한 데이터가 있음.");
            callback( nil );
            return;
        }

        func onCompleteMidTemperature( model: KmaApiMidModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            let retModelList = ForecastMidListModel(dateBase: modelNotNil.dateBaseToCall);
            
//            var model: HourlyModel;
//
//            for kmaModel in modelNotNil.list {
//                model = changeToCommonHourlyModel(kmaModel: kmaModel);
//                retModelList.list.append(model);
//            }
//
//            callback( retModelList );
        }
        
        api.getData(dateNow: dateNow, dateBase: dateBase, regionId: regionId, callback: onCompleteMidTemperature);
    }
    
    private func getRegionId( gridModel: GridModel ) -> String? {
        var regionId: String?;
        
        if let strSido = gridModel.addressSiDo {
            regionId = KmaApiMidTemperatureRegion.shared.getRegionCode(strDosi: strSido);
        }
        
        if( regionId == nil ) {
            if let strGu = gridModel.addressGu {
                regionId = KmaApiMidTemperatureRegion.shared.getRegionCode(strDosi: strGu);
            }
        }
        
        return regionId;
    }
    
    
    public func getNowData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( NowModel? ) -> Void ) {
        let api = KmaApiForecastTimeVeryShort.shared;
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        
        let prevModel = GridManager.shared.getCurrentGridModel()?.nowModel;
        let hasToCall = api.hasToCall(prevDateCalled: prevModel?.dateBaseToCall, baseDateToCall: dateBase);
        if( !hasToCall )  {
            print("이미 해당 시간에 대한 데이터가 있음.");
            callback( nil );
            return;
        }
        
        var retNowModel: NowModel?;
        
        func onCompleteApiForecastTimeVeryShort( model: KmaApiForecastTimeVeryShortModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            let hour = Calendar.current.component(.hour, from: modelNotNil.dateForecast)
            let skyStatusImageName = KmaUtils.getStatusImageName(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum, isDay: TwyUtils.getIsDay(hour: hour));
            
            let skyStatusText = KmaUtils.getSkyStatusText(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum);
            
            retNowModel = NowModel(dateBase: modelNotNil.dateBaseToCall, dateForecast: modelNotNil.dateForecast, temperature: modelNotNil.temperature
                , skyStatusImageName: skyStatusImageName, skyStatusText: skyStatusText)
            
            getYesterdayData(dateStandard: modelNotNil.dateForecast, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiYesterday);
        }
        
        func onCompleteApiYesterday( yesterdayTemperature: Double? ) {
            if( yesterdayTemperature == nil ) {
                callback( retNowModel );
                return;
            }
            
            let resultDiff = retNowModel!.temperature - yesterdayTemperature!;
            retNowModel!.setDiffFromYesterday(value: resultDiff );
            
            callback( retNowModel );
        }
        
        api.getData(dateNow: dateNow, dateBase: dateBase, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiForecastTimeVeryShort);
    }
    
    public func getForecastHourlyData( dateNow: Date, kmaX: Int, kmaY: Int, callback:@escaping ( ForecastHourListModel? ) -> Void ) {
        let api = KmaApiForecastSpace3hours.shared;
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        
        let prevModel = GridManager.shared.getCurrentGridModel()?.forecastHourList;
        let hasToCall = api.hasToCall(prevDateCalled: prevModel?.dateBaseToCall, baseDateToCall: dateBase);
        if( !hasToCall )  {
            print("이미 해당 시간에 대한 데이터가 있음.");
            callback( nil );
            return;
        }
        
        func onCompleteForecastHourly( model: KmaApiForecastSpace3hoursModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            let retModelList = ForecastHourListModel(dateBase: modelNotNil.dateBaseToCall);
            
            var model: HourlyModel;
            
            for kmaModel in modelNotNil.list {
                model = changeToCommonHourlyModel(kmaModel: kmaModel);
                retModelList.list.append(model);
            }
            
            callback( retModelList );
        }
        
        api.getData(dateNow: dateNow, dateBase: dateBase, kmaX: kmaX, kmaY: kmaY, callback: onCompleteForecastHourly);
    }
    
    public func getYesterdayData( dateStandard: Date, kmaX: Int, kmaY: Int, callback:@escaping ( Double? ) -> Void ) {
        let api = KmaApiActual.shared;
        
        func onCompleteApiYesterday( model: KmaApiActualModel? ) {
            if( model == nil ) {
                print("어제 날씨 실황 가져오기 실패.")
                callback( nil );
                return;
            }
            
            callback( model!.temperature );
        }
        
        let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: dateStandard)!;
        
        api.getData(dateBase: dateYesterday, kmaX: kmaX, kmaY: kmaY, callback: onCompleteApiYesterday);
    }
    
    // 서비스에 종속적이지 않은 모델로 변환.
    private func changeToCommonHourlyModel( kmaModel: KmaHourlyModel ) -> HourlyModel {
        let hour = Calendar.current.component(.hour, from: kmaModel.date)
        let skyStatusImageName = KmaUtils.getStatusImageName(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum, isDay: TwyUtils.getIsDay(hour: hour));
        
        let skyStatusText = KmaUtils.getSkyStatusText(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum);
        
        let model = HourlyModel( date: kmaModel.date, temperature: kmaModel.temperature, skyStatusImageName: skyStatusImageName, skyStatusText: skyStatusText)
        
        return model;
    }
}
