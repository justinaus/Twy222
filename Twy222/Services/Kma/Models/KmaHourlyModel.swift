//
//  KmaHourlyModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 12/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaHourlyModel: IDate {
    public private(set) var date:Date;
    
    public private(set) var temperature3H:Double;
    
    public private(set) var skyEnum:KmaSkyEnum;
    public private(set) var ptyEnum:KmaPtyEnum;
    
    public private(set) var temperatureMax:Double?;
    public private(set) var temperatureMin:Double?;
    
    
    init( date: Date, temperature3H: Double, skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum ) {
        self.date = date;
        self.temperature3H = temperature3H;
        self.skyEnum = skyEnum;
        self.ptyEnum = ptyEnum;
    }
    
    public func setTemperatureMax( value: Double ) {
        temperatureMax = value;
    }
    public func setTemperatureMin( value: Double ) {
        temperatureMin = value;
    }
}
