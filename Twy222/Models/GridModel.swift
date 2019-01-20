//
//  GridModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class GridModel {
    public private(set) var latitude:String;
    public private(set) var longitude:String;
    
    // 구분 키 값
    public private(set) var id: String;
    
//    public private(set) var dongName: String;
    
    public private(set) var nowModel: NowModel?;
    public private(set) var forecastHourList: ForecastHourListModel?;
    public private(set) var forecastMidList: ForecastMidListModel?;
    
    public private(set) var addressFull: String?;
    //(바다지역시 존재안함)
    public private(set) var addressSiDo: String?;
    //(바다지역시 존재안함)
    public private(set) var addressGu: String?;
    //(바다지역시 존재안함)
    public private(set) var addressDong: String?;
    //region_type 이 법정동이며, 리 영역인 경우만 존재
    public private(set) var addressRi: String?;
    
    
    init( id: String, lat: String, lon: String ) {
        self.id = id;
        self.latitude = lat;
        self.longitude = lon;
    }
    
    public func getAddressTitle() -> String? {
        var strRet: String?;
        
        if( addressDong != nil ) {
            strRet = addressDong;
        } else if( addressGu != nil ) {
            strRet = addressGu;
        } else if( addressSiDo != nil ) {
            strRet = addressSiDo;
        } else if( addressFull != nil ) {
            strRet = addressFull;
        }
        
        return strRet;
    }
    
    public func setAddressFull( value: String ) {
        addressFull = value;
    }
    public func setAddressSido( value: String ) {
        addressSiDo = value;
    }
    public func setAddressGu( value: String ) {
        addressGu = value;
    }
    public func setAddressDong( value: String ) {
        addressDong = value;
    }
    public func setAddressRi( value: String ) {
        addressRi = value;
    }
    
    public func setNowModel( value: NowModel ) {
        nowModel = value;
    }
    public func setForecastHourListModel( value: ForecastHourListModel ) {
        forecastHourList = value;
    }
    public func setForecastHourListModel( value: ForecastMidListModel ) {
        forecastMidList = value;
    }
    
//    public func resetAll() {
//        nowModel = NowModel();
//    }
    
    
}
