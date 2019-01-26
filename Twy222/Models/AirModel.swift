//
//  AirModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class AirModel {
    public private(set) var dateBaseToCall:Date;
    
    public private(set) var pm10Value: Int;
    public private(set) var pm25Value: Int;
    
    init( dateBase: Date, pm10Value: Int, pm25Value: Int ) {
        self.dateBaseToCall = dateBase;
        self.pm10Value = pm10Value;
        self.pm25Value = pm25Value;
    }
}
