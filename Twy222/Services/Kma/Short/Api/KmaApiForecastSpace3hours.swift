//
//  KmaApiForecastSpace3hours.swift
//  Twy222
//
//  Created by Bonkook Koo on 10/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiForecastSpace3hours: KmaApiBase {
    static let shared = KmaApiForecastSpace3hours();
    
    public func getData( dateNow: Date, dateBase:Date, kmaX: Int, kmaY: Int, callback:@escaping ( KmaApiForecastSpace3hoursModel? ) -> Void ) {
        let URL_SERVICE = "ForecastSpaceData";
        
//        print( "3시간 예보 call base time", DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( arrItem: Array<[String:Any]>? ) {
            if( arrItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( dateNow: dateNow, dateBase: dateBase, arrItem: arrItem! );
            callback( model );
        }
        
        makeCall( serviceName: URL_SERVICE, baseDate: dateBase, kmaX: kmaX, kmaY: kmaY, callback: onComplete );
    }
    
    public func getBaseDate( dateNow: Date ) -> Date {
        //0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300
        let arrBaseHour = [ 2, 5, 8, 11, 14, 17, 20, 23 ];
        let LIMIT_MINUTES = 10;
        
        let calendar = Calendar.current;
        let component = calendar.dateComponents([.hour,.minute], from: dateNow);
        
        let nowHour = calendar.component(.hour, from: dateNow);
        
        var dateBaseToCall: Date?;
        
        for ( index, hour ) in arrBaseHour.enumerated() {
            if( nowHour < hour ) {
                if( index == 0 ) {
                    dateBaseToCall = calendar.date(bySettingHour: arrBaseHour.last!, minute: 0, second: 0, of: dateNow);
                    dateBaseToCall = calendar.date(byAdding: .day, value: -1, to: dateBaseToCall!);
                } else {
                    dateBaseToCall = calendar.date(bySettingHour: arrBaseHour[ index - 1 ], minute: 0, second: 0, of: dateNow);
                }
                
                break;
            } else if( nowHour == hour ) {
                dateBaseToCall = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateNow);
                
                if( component.minute! <= LIMIT_MINUTES ) {
                    dateBaseToCall = calendar.date(byAdding: .hour, value: -3, to: dateBaseToCall!);
                }
                break;
            }
        }
        
        return dateBaseToCall!
    }
    
    public func hasToCall( prevDateCalled: Date?, baseDateToCall: Date ) -> Bool {
        if( prevDateCalled == nil ) {
            return true;
        }
        
        return DateUtil.getIsSameDateAndMinute(date0: prevDateCalled!, date1: baseDateToCall);
    }
    
    private func makeModel( dateNow:Date, dateBase: Date, arrItem: Array<[ String : Any ]> ) -> KmaApiForecastSpace3hoursModel? {
        if( arrItem.count < 1 ) {
            return nil;
        }
        let objStart = arrItem[ 0 ];
        guard let dateStart = KmaUtils.getDateByDateAndTime(anyDate: objStart["fcstDate"], anyTime: objStart["fcstTime"]) else {
            return nil;
        }
        
        var dateFcst: Date = dateStart;
        
        let modelList = KmaApiForecastSpace3hoursModel(dateBaseToCall: dateBase);
        
        var arrTemp: Array<[ String : Any ]> = [];
        
        for obj in arrItem {
            guard let dateForecast = KmaUtils.getDateByDateAndTime(anyDate: obj["fcstDate"], anyTime: obj["fcstTime"]) else {
                continue;
            }
            
            if( dateFcst != dateForecast ) {
                // 날짜가 달라짐.
                // 지금까지 모은 데이터로 모델 만들기.
                let model = makeHourlyModel(dateFcst: dateFcst, arrItem: arrTemp);
                
                if( model != nil ) {
                    modelList.list.append( model! );
                    
                    // 개수를 조절한다. 왜냐면 그 숫자만큼 어제 실황을 콜해야 하니깐...
                    // 8개 제공하자.
                    if( modelList.list.count >= Settings.HOURLY_DATA_COUNT ) {
                        break;
                    }
                }
                
                dateFcst = dateForecast;
                arrTemp = [];
            }
            
            arrTemp.append(obj);
        }
        
        return modelList;
    }
    
    private func makeHourlyModel( dateFcst:Date, arrItem: Array<[ String : Any ]> ) -> KmaHourlyModel? {
        var temperature: Double?;
        var skyEnum: KmaSkyEnum?;
        var ptyEnum: KmaPtyEnum?;
        
        for obj in arrItem {
            guard let category = obj[ "category" ] as? String else {
                continue;
            }
            
            switch( category ) {
            case KmaCategoryCodeEnum.T3H.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Double else {
                    continue;
                }
                
                temperature = fcstValue;
                
                break;
            case KmaCategoryCodeEnum.PTY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Int else {
                    continue;
                }
                guard let ptyEnumTemp = KmaPtyEnum(rawValue: fcstValue) else {
                    continue;
                }
                
                ptyEnum = ptyEnumTemp;
                
                break;
            case KmaCategoryCodeEnum.SKY.rawValue:
                guard let fcstValue = obj[ "fcstValue" ] as? Int else {
                    continue;
                }
                guard let skyEnumTemp = KmaSkyEnum(rawValue: fcstValue) else {
                    continue;
                }
                
                skyEnum = skyEnumTemp;
                break;
            default:
                continue;
            }
        }
        
        if( temperature == nil || skyEnum == nil || ptyEnum == nil ) {
            return nil;
        }
        
//        print( "3시간 예보 받은 값", DateUtil.getStringByDate(date: dateFcst) );
//        print( temperature!, skyEnum!, ptyEnum! )
        
        let model: KmaHourlyModel = KmaHourlyModel(date: dateFcst, temperature: temperature!, skyEnum: skyEnum!, ptyEnum: ptyEnum!)
        
        return model;
    }
}
