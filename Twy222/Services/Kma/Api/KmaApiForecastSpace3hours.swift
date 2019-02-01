//
//  KmaApiForecastSpace3hours.swift
//  Twy222
//
//  Created by Bonkook Koo on 10/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import SwiftyJSON

final class KmaApiForecastSpace3hours: KmaApiShortBase {
    static let shared = KmaApiForecastSpace3hours();
    
    public func getData( dateBase:Date, kmaXY: KmaXY, callbackComplete:@escaping (KmaApiForecastSpace3hoursModel) -> Void, callbackError:@escaping (ErrorModel) -> Void ) {
        let URL_SERVICE = "ForecastSpaceData";
        
//        print( "3시간 예보 call base time", DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( arrItem: Array<JSON> ) {
            guard let model = makeModel( dateBase: dateBase, kmaXY: kmaXY, arrItem: arrItem ) else {
                callbackError( ErrorModel() );
                return;
            }
            
            callbackComplete( model );
        }
        
        makeCall( serviceName: URL_SERVICE, baseDate: dateBase, kmaXY: kmaXY, callbackComplete: onComplete, callbackError: callbackError );
    }
    
    public func hasToCall( prevModel: KmaApiForecastSpace3hoursModel, newDateBase: Date, kmaXY: KmaXY) -> Bool {
        if( !DateUtil.getIsSameDateAndMinute(date0: prevModel.dateBaseCalled, date1: newDateBase) ) {
            return true;
        }
        
        if( prevModel.kmaXY.x != kmaXY.x || prevModel.kmaXY.y != kmaXY.y ) {
            return true;
        }
        
        return false;
    }
    
    public func getBaseDate( dateNow: Date ) -> Date {
        //0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300
        let arrBaseHour = [ 2, 5, 8, 11, 14, 17, 20, 23 ];
        let LIMIT_MINUTES = 10;
        
        let calendar = Calendar.current;
        let componentNow = calendar.dateComponents([.hour,.minute], from: dateNow);
        
        var dateBaseToCall: Date?;
        
        for ( index, hour ) in arrBaseHour.enumerated() {
            if( componentNow.hour! < hour ) {
                if( index == 0 ) {
                    dateBaseToCall = calendar.date(bySettingHour: arrBaseHour.last!, minute: 0, second: 0, of: dateNow);
                    dateBaseToCall = calendar.date(byAdding: .day, value: -1, to: dateBaseToCall!);
                } else {
                    dateBaseToCall = calendar.date(bySettingHour: arrBaseHour[ index - 1 ], minute: 0, second: 0, of: dateNow);
                }
                
                break;
            } else if( componentNow.hour == hour ) {
                dateBaseToCall = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateNow);
                
                if( componentNow.minute! <= LIMIT_MINUTES ) {
                    dateBaseToCall = calendar.date(byAdding: .hour, value: -3, to: dateBaseToCall!);
                }
                break;
            }
        }
        
        return dateBaseToCall!
    }
    
    private func makeModel( dateBase: Date, kmaXY: KmaXY, arrItem: Array<JSON> ) -> KmaApiForecastSpace3hoursModel? {
        if( arrItem.count < 1 ) {
            return nil;
        }
        let objStart = arrItem[ 0 ];
        guard let dateStart = KmaUtils.getDateByDateAndTimeJSON(anyDate: objStart["fcstDate"], anyTime: objStart["fcstTime"]) else {
            return nil;
        }
        
        var dateFcst: Date = dateStart;
        
        let modelList = KmaApiForecastSpace3hoursModel(dateBaseToCall: dateBase, kmaXY: kmaXY)
        
        var arrTemp: Array<JSON> = [];
        
        for obj in arrItem {
            guard let dateForecast = KmaUtils.getDateByDateAndTimeJSON(anyDate: obj["fcstDate"], anyTime: obj["fcstTime"]) else {
                continue;
            }
            
            if( dateFcst != dateForecast ) {
                // 날짜가 달라짐.
                // 지금까지 모은 데이터로 모델 만들기.
                let model = makeHourlyModel(dateFcst: dateFcst, arrItem: arrTemp);
                
                if( model != nil ) {
                    modelList.list.append( model! );
                }
                
                dateFcst = dateForecast;
                arrTemp = [];
            }
            
            arrTemp.append(obj);
        }
        
        return modelList;
    }
    
    private func makeHourlyModel( dateFcst:Date, arrItem: Array<JSON> ) -> KmaHourlyModel? {
        var temperature: Double?;
        var skyEnum: KmaSkyEnum?;
        var ptyEnum: KmaPtyEnum?;
        var temperatureMax: Double?;
        var temperatureMin: Double?;
        
        for obj in arrItem {
            guard let category = obj[ "category" ].string else {
                continue;
            }
            
            switch( category ) {
            case KmaCategoryCodeEnum.T3H.rawValue:
                guard let fcstValue = obj[ "fcstValue" ].double else {
                    continue;
                }
                
                temperature = fcstValue;
                
                break;
            case KmaCategoryCodeEnum.PTY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ].int else {
                    continue;
                }
                guard let ptyEnumTemp = KmaPtyEnum(rawValue: fcstValue) else {
                    continue;
                }
                
                ptyEnum = ptyEnumTemp;
                
                break;
            case KmaCategoryCodeEnum.SKY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ].int else {
                    continue;
                }
                guard let skyEnumTemp = KmaSkyEnum(rawValue: fcstValue) else {
                    continue;
                }
                
                skyEnum = skyEnumTemp;
                break;
            case KmaCategoryCodeEnum.TMX.rawValue:
                guard let fcstValue = obj[ "fcstValue" ].double else {
                    continue;
                }
                
                temperatureMax = fcstValue;
                
                break;
            case KmaCategoryCodeEnum.TMN.rawValue:
                guard let fcstValue = obj[ "fcstValue" ].double else {
                    continue;
                }
                
                temperatureMin = fcstValue;
                
                break;
            default:
                continue;
            }
        }
        
        if( temperature == nil || skyEnum == nil || ptyEnum == nil ) {
            return nil;
        }
        
        let model: KmaHourlyModel = KmaHourlyModel(date: dateFcst, temperature3H: temperature!, skyEnum: skyEnum!, ptyEnum: ptyEnum!);
        
        if( temperatureMax != nil ) {
            model.setTemperatureMax(value: temperatureMax!)
        }
        if( temperatureMin != nil ) {
            model.setTemperatureMin(value: temperatureMin!)
        }
        
        return model;
    }
}
