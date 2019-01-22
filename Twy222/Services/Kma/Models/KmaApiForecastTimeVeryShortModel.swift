//
//  KmaApiForecastTimeVeryShortModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiForecastTimeVeryShortModel {
    public private(set) var dateBaseCalled:Date;
    public private(set) var dateForecast:Date;
    public private(set) var kmaXY: KmaXY;
    
    public private(set) var temperature:Double;
    
    public private(set) var skyEnum:KmaSkyEnum;
    public private(set) var ptyEnum:KmaPtyEnum;
    
    
    init( dateBase: Date, dateForecast: Date, temperature: Double, kmaXY: KmaXY, skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum ) {
        self.dateBaseCalled = dateBase;
        self.dateForecast = dateForecast;
        self.kmaXY = kmaXY;
        
        self.temperature = temperature;
        self.skyEnum = skyEnum;
        self.ptyEnum = ptyEnum;
    }
}
