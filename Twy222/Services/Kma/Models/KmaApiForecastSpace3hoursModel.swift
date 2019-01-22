//
//  KmaApiForecastSpace3hoursModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 10/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiForecastSpace3hoursModel {
    public private(set) var dateBaseCalled:Date;
    public private(set) var kmaXY: KmaXY;
    
    public var list: Array<KmaHourlyModel> = [];
    
    
    init( dateBaseToCall: Date, kmaXY: KmaXY  ) {
        self.dateBaseCalled = dateBaseToCall;
        self.kmaXY = kmaXY;
    }
}

