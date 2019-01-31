//
//  AkApiAirModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 27/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class AkApiAirPmModel: ApiModelBase {
    public private(set) var dateCalled: Date;
    public private(set) var stationName: String;
    
    public private(set) var pm10: Int;
    public private(set) var pm25: Int;
    
    init( dateCalled: Date, stationName: String, pm10: Int, pm25: Int ) {
        self.dateCalled = dateCalled;
        self.stationName = stationName;
        self.pm10 = pm10;
        self.pm25 = pm25;
    }
}
