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
    private var apiTimeVeryShortModel: KmaApiForecastTimeVeryShortModel?;
    private var apiSpace3HoursModel: KmaApiForecastSpace3hoursModel?;
    
    private var space3HourYesterdayList: Array<KmaApiActualModel>?;
    
    private var apiMidTemperatureModel: KmaApiMidTemperatureModel?;
    private var apiMidLandModel: KmaApiMidLandModel?;
    
    
    public func getNowData( dateNow: Date, lat: Double, lon: Double, callbackComplete:@escaping (NowModel?) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        var nowModel: NowModel?
        
        let kmaXY = KmaUtils.getKmaXY(lat: lat, lon: lon);
        
        func onCompleteVeryShort( model: KmaApiForecastTimeVeryShortModel? ) {
            guard let modelNotNil = model else {
                callbackComplete( nil );
                return;
            }
            
            let hour = Calendar.current.component(.hour, from: modelNotNil.dateForecast);
            let isDay = TwyUtils.getIsDay(hour: hour);
            let skyImage = KmaUtils.getStatusImageName(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum, isDay: isDay);
            let skyText = KmaUtils.getSkyStatusText(skyEnum: modelNotNil.skyEnum, ptyEnum: modelNotNil.ptyEnum);
            
            nowModel = NowModel(dateBase: modelNotNil.dateBaseCalled, dateForecast: modelNotNil.dateForecast, temperature: modelNotNil.temperature, skyStatusImageName: skyImage, skyStatusText: skyText);
            
            apiTimeVeryShortModel = model;
            
            let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: modelNotNil.dateForecast)!;
            getActualData(dateBase: dateYesterday, kmaXY: kmaXY, callbackComplete: onCompleteYesterday, callbackError: callbackError );
        }
        
        func onCompleteYesterday( model: KmaApiActualModel ) {
            let resultDiff = nowModel!.temperature - model.temperature;
            nowModel!.setDiffFromYesterday(value: resultDiff);
            
            callbackComplete( nowModel );
        }
        
        getForecastVeryShort(dateNow: dateNow, kmaXY: kmaXY, callbackComplete: onCompleteVeryShort, callbackError: callbackError);
    }
    
    public func getForecastHourlyData( dateNow: Date, callbackComplete:@escaping (ForecastHourListModel?) -> Void, callbackYesterdayAll:@escaping () -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = KmaApiForecastSpace3hours.shared;
        let dateBase = api.getBaseDate(dateNow: dateNow);
        let prevModel = apiSpace3HoursModel;
        let kmaXY = apiTimeVeryShortModel!.kmaXY;
        
        let hasToCall: Bool = prevModel == nil ? true : api.hasToCall(prevModel: prevModel!, newDateBase: dateBase, kmaXY: kmaXY);
        if( !hasToCall ) {
            callbackComplete( nil );
            return;
        }
        
        space3HourYesterdayList = [];
        var nYesterdayCompleteCount = 0;
        
        func onComplete( modelNotNil: KmaApiForecastSpace3hoursModel ) {
            apiSpace3HoursModel = modelNotNil;
            
            let retModel = ForecastHourListModel(dateBase: modelNotNil.dateBaseCalled);
            var model: HourlyModel;
        
            for ( index, kmaModel ) in modelNotNil.list.enumerated() {
                // 개수를 조절한다. 왜냐면 그 숫자만큼 어제 실황을 콜해야 하니깐...
                // 7개 제공하자.
                if( index > Settings.HOURLY_DATA_COUNT - 1 ) {
                    break;
                }
                
                model = changeToCommonHourlyModel(kmaModel: kmaModel);
                retModel.list.append(model);
                
                getYesterdayData(standardModel: model, kmaXY: kmaXY, callbackComplete: onCompleteYesterday);
            }

            callbackComplete( retModel );
        }
        
        func onCompleteYesterday() {
            nYesterdayCompleteCount += 1;
            
            if( nYesterdayCompleteCount == Settings.HOURLY_DATA_COUNT ) {
                callbackYesterdayAll();
            }
        }
        
        api.getData(dateBase: dateBase, kmaXY: kmaXY, callbackComplete: onComplete, callbackError: callbackError);
    }
    
    private func getForecastVeryShort( dateNow: Date, kmaXY: KmaXY, callbackComplete:@escaping (KmaApiForecastTimeVeryShortModel?) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = KmaApiForecastTimeVeryShort.shared;
        let dateBase = api.getBaseDate(dateNow: dateNow);
        let prevModel = apiTimeVeryShortModel;
        
        let hasToCall: Bool = prevModel == nil ? true : api.hasToCall(prevModel: prevModel!, newDateBase: dateBase, kmaXY: kmaXY);
        if( !hasToCall ) {
            callbackComplete( nil );
            return;
        }
        
        api.getData(dateNow: dateNow, dateBase: dateBase, kmaXY: kmaXY, callbackComplete: callbackComplete, callbackError: callbackError);
    }
    
    private func getActualData( dateBase: Date, kmaXY: KmaXY, callbackComplete:@escaping (KmaApiActualModel) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = KmaApiActual.shared;
        
        api.getData(dateBase: dateBase, kmaXY: kmaXY, callbackComplete: callbackComplete, callbackError: callbackError);
    }
    
    public func getForecastMidData( dateNow: Date, callbackComplete:@escaping (ForecastMidListModel?) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        guard let gridModel = GridManager.shared.getCurrentGridModel() else {
            callbackError( ErrorModel() );
            return ;
        }
        
        var modelTemperature: KmaApiMidTemperatureModel?
        
        func onCompleteTemperature( model: KmaApiMidTemperatureModel? ) {
            guard let modelNotNil = model else {
                callbackComplete( nil );
                return;
            }
            
            modelTemperature = modelNotNil;
            
            getForecastMidLand(dateNow: dateNow, addressSiDo: gridModel.addressModel?.addressSiDo, addressGu: gridModel.addressModel?.addressGu, callbackComplete: onCompleteLand, callbackError: callbackError);
        }
        
        func onCompleteLand( model: KmaApiMidLandModel? ) {
            guard let modelNotNil = model else {
                callbackComplete( nil );
                return;
            }
            
            apiMidTemperatureModel = modelTemperature!;
            apiMidLandModel = modelNotNil;
            
            let retMidModel = ForecastMidListModel(dateBase: modelNotNil.dateBaseCalled);
            
            let arrMidAfter3days = makeMidAfter3dayList(modelTemperature: modelTemperature!, modelLand: modelNotNil );
            
            var arrFromYesterday: [IDate] = space3HourYesterdayList!;
            let arrSpace: [IDate] = apiSpace3HoursModel!.list;
            arrFromYesterday.append(contentsOf: arrSpace);
            
            // 현재 날짜 이전은 사용 안함. 가공하는 부분은 일단 눈에 보이는 게 싫어서... 유틸에 옮겨 둠.
            let arrDualByDay = KmaUtils.makeDualArrayByDay(dateNow: dateNow, arrOrigin: arrFromYesterday);
            let dailyModelBefore3days = KmaUtils.makeDailyModelList(arrDual: arrDualByDay);
            
            let result = KmaUtils.concatNotOverlap(arrBase: arrMidAfter3days, arrAdd: dailyModelBefore3days);
            retMidModel.list = result;
            
//            for item in result {
//                print( "\(DateUtil.getStringByDate(date: item.date))" )
//            }
            
            callbackComplete( retMidModel );
        }
        
        getForecastMidTemperature(dateNow: dateNow, addressSiDo: gridModel.addressModel?.addressSiDo, addressGu: gridModel.addressModel?.addressGu, callbackComplete: onCompleteTemperature, callbackError: callbackError);
    }
    
    private func makeMidAfter3dayList( modelTemperature: KmaApiMidTemperatureModel, modelLand: KmaApiMidLandModel ) -> Array<DailyModel> {
        var arrRet = Array<DailyModel>();
        
        for i in 0 ..< 5 {
            let temperature = modelTemperature.list[ i ];
            let skyEnum = modelLand.list[ i ];

            let skyStatusImageName = KmaApiMidLand.shared.getStatusImageName(skyEnum: skyEnum, isDay: true);

            let date = Calendar.current.date(byAdding: .day, value: i + 3, to: modelTemperature.dateBaseCalled )!;

            let dailyModel = DailyModel(date: date, temperatureMax: temperature.max, temperatureMin: temperature.min, skyStatusImageName: skyStatusImageName, skyStatusText: skyEnum.rawValue)

            arrRet.append(dailyModel);
        }
        
        return arrRet;
    }
    
    private func getYesterdayData( standardModel: HourlyModel, kmaXY: KmaXY, callbackComplete:@escaping () -> Void ) {
        let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: standardModel.date)!;
        
        func onComplete( model: KmaApiActualModel ) {
            space3HourYesterdayList!.append(model);
            
            let yesterdayTemperature = model.temperature;
            let resultDiff = standardModel.temperature - yesterdayTemperature;
            
            standardModel.setDiffFromYesterday(value: resultDiff );
            
            callbackComplete();
        }
        
        func onError( errorModel: ErrorModel ) {
            // 이거는 그냥 에러는 발생시키지 말자..
            callbackComplete();
        }
        
        getActualData(dateBase: dateYesterday, kmaXY: kmaXY, callbackComplete: onComplete, callbackError:  onError);
    }
    
    private func getForecastMidTemperature( dateNow:Date, addressSiDo: String?, addressGu: String?, callbackComplete:@escaping (KmaApiMidTemperatureModel?) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = KmaApiMidTemperature.shared;
        
        guard let regId = api.getRegionId(addressSiDo: addressSiDo, addressGu: addressGu) else {
            callbackError( ErrorModel() );
            return ;
        }
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        
        let prevModel = apiMidTemperatureModel;
        
        let hasToCall: Bool = prevModel == nil ? true : api.hasToCall(prevModel: prevModel!, newDateBase: dateBase, newRegId: regId);
        if( !hasToCall ) {
            callbackComplete( nil );
            return;
        }
        
        api.getData(dateBase: dateBase, regionId: regId, callbackComplete: callbackComplete, callbackError: callbackError);
    }
    
    private func getForecastMidLand( dateNow:Date, addressSiDo: String?, addressGu: String?, callbackComplete:@escaping (KmaApiMidLandModel?) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let api = KmaApiMidLand.shared;
        
        guard let regId = api.getRegionId(addressSiDo: addressSiDo, addressGu: addressGu) else {
            callbackError( ErrorModel() );
            return ;
        }
        
        let dateBase = api.getBaseDate(dateNow: dateNow);
        // 이건 그냥 hasToCall 체크 안하겠다.
        
        api.getData(dateBase: dateBase, regionId: regId, callbackComplete: callbackComplete, callbackError: callbackError)
    }
    
    // 서비스에 종속적이지 않은 모델로 변환.
    private func changeToCommonHourlyModel( kmaModel: KmaHourlyModel ) -> HourlyModel {
        let hour = Calendar.current.component(.hour, from: kmaModel.date);
        let isDay = TwyUtils.getIsDay(hour: hour);
        let skyImage = KmaUtils.getStatusImageName(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum, isDay: isDay);
        let skyText = KmaUtils.getSkyStatusText(skyEnum: kmaModel.skyEnum, ptyEnum: kmaModel.ptyEnum);
        
        let model = HourlyModel( date: kmaModel.date, temperature: kmaModel.temperature3H, skyStatusImageName: skyImage, skyStatusText: skyText)

        return model;
    }
}
