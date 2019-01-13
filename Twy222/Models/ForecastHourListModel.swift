//
//  ForecastHourlyModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class ForecastHourListModel {
    public private(set) var dateBaseToCall:Date;
    
    public var list:Array<HourlyModel> = [];
    
    init( dateBase: Date ) {
        self.dateBaseToCall = dateBase;
    }
    
}
