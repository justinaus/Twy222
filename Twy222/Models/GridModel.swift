//
//  GridModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class GridModel {
    public private(set) var latitude: Double;
    public private(set) var longitude: Double;
    
    public private(set) var addressModel: IAddressModel?;
    public private(set) var nowModel: NowModel?;
    public private(set) var forecastHourList: ForecastHourListModel?;
    public private(set) var forecastMidList: ForecastMidListModel?;
    public private(set) var airModel: AirModel?;
    
    init( lat: Double, lon: Double ) {
        self.latitude = lat;
        self.longitude = lon;
    }
    
    public func setAddressModel( value: IAddressModel ) {
        addressModel = value;
    }
    public func setNowModel( value: NowModel ) {
        nowModel = value;
    }
    public func setForecastHourListModel( value: ForecastHourListModel ) {
        forecastHourList = value;
    }
    public func setForecastMidListModel( value: ForecastMidListModel ) {
        forecastMidList = value;
    }
    public func setAirModel( value: AirModel ) {
        airModel = value;
    }
    
//    public func resetAll() {
//        nowModel = NowModel();
//    }
    
    
}
