//
//  KmaApiMidTemperatureModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 19/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiMidModel {
    public private(set) var dateBaseToCall:Date;
    
    public var list: Array<KmaDailyModel> = [];
    
    
    init( dateBaseToCall: Date ) {
        self.dateBaseToCall = dateBaseToCall;
    }
}
