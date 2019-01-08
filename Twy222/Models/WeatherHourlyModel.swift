//
//  WeatherHourlyModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 05/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class WeatherHourlyModel {
    public private(set) var date:Date;
    
    public private(set) var temperature:Double;
    
    public private(set) var skyStatusImageName:String;
    
    // 구분 키 값
    //    public private(set) var id: String;
    
    init( date: Date, temperature: Double, skyStatusImageName: String ) {
        self.date = date;
        self.temperature = temperature;
        self.skyStatusImageName = skyStatusImageName;
    }
}
