//
//  HourlyModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class HourlyModel {
    public private(set) var date: Date;
    public private(set) var temperature: Double;
    public private(set) var skyStatusImageName: String;
    public private(set) var skyStatusText: String;
    public private(set) var diffFromYesterday: Double?;
    
    init( date: Date, temperature: Double, skyStatusImageName:String, skyStatusText: String ) {
        self.date = date;
        self.temperature = temperature;
        self.skyStatusImageName = skyStatusImageName;
        self.skyStatusText = skyStatusText;
    }
    
    func setDiffFromYesterday( value: Double? ) {
        diffFromYesterday = value;
    }
}
