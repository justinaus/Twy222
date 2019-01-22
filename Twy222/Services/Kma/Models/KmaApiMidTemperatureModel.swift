//
//  KmaApiMidTemperatureModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 20/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiMidTemperatureModel {
    public private(set) var dateBaseCalled:Date;
    public private(set) var regId:String;
    
    public var list: Array<DailyTemperatureMaxMinModel> = [];
    
    init( dateBase: Date, regId: String ) {
        self.dateBaseCalled = dateBase;
        self.regId = regId;
    }
}
