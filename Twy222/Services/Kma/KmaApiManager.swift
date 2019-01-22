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
    
    // 나중에 로컬 디비로 사용.
    var apiTimeVeryShortModel: KmaApiForecastTimeVeryShortModel?;
    var apiSpace3HoursModel: KmaApiForecastSpace3hoursModel?;
    var apiMidTemperatureModel: KmaApiMidTemperatureModel?;
    var apiMidLandModel: KmaApiMidLandModel?;
    
    
    public func getNowData( dateNow: Date, kmaXY: KmaXY, callback:@escaping ( NowModel? ) -> Void ) {
        var nowModel: NowModel?
        
        func onCompleteVeryShort( model: KmaApiForecastTimeVeryShortModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            let hour = Calendar.current.component(.hour, from: modelNotNil.dateForecast);
            let isDay = TwyUtils.getIsDay(hour: hour);
            let skyImage = KmaApiForecastTimeVeryShort.shared.getStatusImageName(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum, isDay: isDay);
            let skyText = KmaApiForecastTimeVeryShort.shared.getSkyStatusText(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum);
            
            nowModel = NowModel(dateBase: modelNotNil.dateBaseCalled, dateForecast: modelNotNil.dateForecast, temperature: modelNotNil.temperature, skyStatusImageName: skyImage, skyStatusText: skyText);
            
            apiTimeVeryShortModel = model;
            
            let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: modelNotNil.dateForecast)!;
            getActualData(dateBase: dateYesterday, kmaXY: kmaXY, callback: onCompleteYesterday);
        }
        
        func onCompleteYesterday( model: KmaApiActualModel? ) {
            guard let modelNotNil = model else {
                callback( nowModel );
                return;
            }
            
            let resultDiff = nowModel!.temperature - modelNotNil.temperature;
            nowModel!.setDiffFromYesterday(value: resultDiff);
            
            callback( nowModel );
        }
        
        getForecastVeryShort(dateNow: dateNow, kmaXY: kmaXY, callback: onCompleteVeryShort);
    }
    
    public func getForecastHourlyData( dateNow: Date, kmaXY: KmaXY, callback:@escaping ( ForecastHourListModel? ) -> Void ) {
        let api = KmaApiForecastSpace3hours.shared;
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        
        let prevModel = apiSpace3HoursModel;
        
        let hasToCall: Bool = prevModel == nil ? true : api.hasToCall(prevModel: prevModel!, newDateBase: dateBase, kmaXY: kmaXY);
        if( !hasToCall ) {
            callback( nil );
            return;
        }
        
        func onComplete( model: KmaApiForecastSpace3hoursModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            apiSpace3HoursModel = modelNotNil;
            
            let retModel = ForecastHourListModel(dateBase: modelNotNil.dateBaseCalled);

            var model: HourlyModel;

            for kmaModel in modelNotNil.list {
                model = changeToCommonHourlyModel(kmaModel: kmaModel);
                retModel.list.append(model);
            }

            callback( retModel );
        }
        
        api.getData(dateBase: dateBase, kmaXY: kmaXY, callback: onComplete);
    }
    
    public func getYesterdayData( dateStandard: Date, kmaXY: KmaXY, callback:@escaping ( Double? ) -> Void ) {
        let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: dateStandard)!;
        
        func onComplete( model: KmaApiActualModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            callback( modelNotNil.temperature);
        }
        
        getActualData(dateBase: dateYesterday, kmaXY: kmaXY, callback: onComplete);
    }
    
    public func getForecastMidData( dateNow: Date, callback:@escaping ( ForecastMidListModel? ) -> Void ) {
        guard let currentGridModel = GridManager.shared.getCurrentGridModel() else {
            callback( nil );
            return ;
        }
        
        var modelTemperature: KmaApiMidTemperatureModel?
        
        func onCompleteTemperature( model: KmaApiMidTemperatureModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            modelTemperature = modelNotNil;
            
            getForecastMidLand(dateNow: dateNow, addressSiDo: currentGridModel.addressSiDo, addressGu: currentGridModel.addressGu, callback: onCompleteLand);
        }
        
        func onCompleteLand( model: KmaApiMidLandModel? ) {
            guard let modelNotNil = model else {
                callback( nil );
                return;
            }
            
            apiMidTemperatureModel = modelTemperature!;
            apiMidLandModel = modelNotNil;
            
            let retModel = ForecastMidListModel(dateBase: modelNotNil.dateBaseCalled);

            for i in 0 ..< 5 {
                let temperature = modelTemperature!.list[ i ];
                let skyEnum = modelNotNil.list[ i ];

                let skyStatusImageName = KmaApiMidLand.shared.getStatusImageName(skyEnum: skyEnum, isDay: true);

                let date = Calendar.current.date(byAdding: .day, value: i + 1, to: modelTemperature!.dateBaseCalled )!;

                let dailyModel = DailyModel(date: date, temperatureMax: temperature.max, temperatureMin: temperature.min, skyStatusImageName: skyStatusImageName, skyStatusText: skyEnum.rawValue)

                retModel.list.append(dailyModel);
            }

            callback( retModel );
        }
        
        getForecastMidTemperature(dateNow: dateNow, addressSiDo: currentGridModel.addressSiDo, addressGu: currentGridModel.addressGu, callback: onCompleteTemperature);
    }
    
    private func getForecastVeryShort( dateNow: Date, kmaXY: KmaXY, callback:@escaping ( KmaApiForecastTimeVeryShortModel? ) -> Void ) {
        let api = KmaApiForecastTimeVeryShort.shared;
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        
        let prevModel = apiTimeVeryShortModel;
        
        let hasToCall: Bool = prevModel == nil ? true : api.hasToCall(prevModel: prevModel!, newDateBase: dateBase, kmaXY: kmaXY);
        if( !hasToCall ) {
            callback( nil );
            return;
        }
        
        func onComplete( model: KmaApiForecastTimeVeryShortModel? ) {
            callback( model );
        }
        
        api.getData(dateNow: dateNow, dateBase: dateBase, kmaXY: kmaXY, callback: onComplete);
    }
    
    private func getActualData( dateBase: Date, kmaXY: KmaXY, callback:@escaping ( KmaApiActualModel? ) -> Void ) {
        let api = KmaApiActual.shared;
        
        func onComplete( model: KmaApiActualModel? ) {
            callback( model );
        }
        
        api.getData(dateBase: dateBase, kmaXY: kmaXY, callback: onComplete);
    }
    
    private func getForecastMidTemperature( dateNow:Date, addressSiDo: String?, addressGu: String?, callback:@escaping ( KmaApiMidTemperatureModel? ) -> Void ) {
        let api = KmaApiMidTemperature.shared;
        
        guard let regId = api.getRegionId(addressSiDo: addressSiDo, addressGu: addressGu) else {
            callback( nil );
            return ;
        }
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        
        let prevModel = apiMidTemperatureModel;
        
        let hasToCall: Bool = prevModel == nil ? true : api.hasToCall(prevModel: prevModel!, newDateBase: dateBase, newRegId: regId);
        if( !hasToCall ) {
            callback( nil );
            return;
        }
        
        func onComplete( model: KmaApiMidTemperatureModel? ) {
            callback( model );
        }
        
        api.getData(dateBase: dateBase, regionId: regId, callback: onComplete);
    }
    
    private func getForecastMidLand( dateNow:Date, addressSiDo: String?, addressGu: String?, callback:@escaping ( KmaApiMidLandModel? ) -> Void ) {
        let api = KmaApiMidLand.shared;
        
        guard let regId = api.getRegionId(addressSiDo: addressSiDo, addressGu: addressGu) else {
            callback( nil );
            return ;
        }
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        // 이건 그냥 hasToCall 체크 안하겠다.
        
        func onComplete( model: KmaApiMidLandModel? ) {
            callback( model );
        }
        
        api.getData(dateBase: dateBase, regionId: regId, callback: onComplete)
    }
    
    // 서비스에 종속적이지 않은 모델로 변환.
    private func changeToCommonHourlyModel( kmaModel: KmaHourlyModel ) -> HourlyModel {
        let hour = Calendar.current.component(.hour, from: kmaModel.date);
        let isDay = TwyUtils.getIsDay(hour: hour);
        let skyImage = KmaApiForecastSpace3hours.shared.getStatusImageName(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum, isDay: isDay);
        let skyText = KmaApiForecastSpace3hours.shared.getSkyStatusText(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum);
        
        let model = HourlyModel( date: kmaModel.date, temperature: kmaModel.temperature, skyStatusImageName: skyImage, skyStatusText: skyText)

        return model;
    }
}
