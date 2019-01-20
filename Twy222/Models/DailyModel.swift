//
//  DailyModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 19/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class DailyModel {
    
    public private(set) var date: Date;
    public private(set) var temperatureMax: Double;
    public private(set) var temperatureMin: Double;
    public private(set) var skyStatusImageName: String;
    public private(set) var skyStatusText: String;
    public private(set) var diffFromYesterday: Double?;
    
    init( date: Date, temperatureMax: Double, temperatureMin: Double, skyStatusImageName:String, skyStatusText: String ) {
        self.date = date;
        self.temperatureMax = temperatureMax;
        self.temperatureMin = temperatureMin;
        self.skyStatusImageName = skyStatusImageName;
        self.skyStatusText = skyStatusText;
    }
    
    func setDiffFromYesterday( value: Double? ) {
        diffFromYesterday = value;
    }
}
