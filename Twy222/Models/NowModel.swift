//
//  NowModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class NowModel {
    public private(set) var dateBaseToCall:Date;
    public private(set) var dateForecast:Date;
    
    public private(set) var temperature:Double;
    public private(set) var skyStatusImageName:String;
    public private(set) var skyStatusText:String;
    public private(set) var diffFromYesterday:Double?;
    
    init( dateBase: Date, dateForecast: Date, temperature: Double, skyStatusImageName:String, skyStatusText: String ) {
        self.dateBaseToCall = dateBase;
        self.dateForecast = dateForecast;
        self.temperature = temperature;
        self.skyStatusImageName = skyStatusImageName;
        self.skyStatusText = skyStatusText;
    }
    
    func setDiffFromYesterday( value: Double? ) {
        diffFromYesterday = value;
    }
}

