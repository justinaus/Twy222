//
//  KmaApiForecastSpace3hoursModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 10/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiForecastSpace3hoursModel {
    public private(set) var dateBaseToCall:Date;
    
    public var list: Array<KmaHourlyModel> = [];
    
    
    init( dateBaseToCall: Date ) {
        self.dateBaseToCall = dateBaseToCall;
    }
}

