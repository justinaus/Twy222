//
//  KmaApiMidLandModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 20/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiMidLandModel {
    public private(set) var dateBaseToCall:Date;
    
    public var list: Array<KmaMidSkyStatusEnum> = [];
    
    
    init( dateBaseToCall: Date ) {
        self.dateBaseToCall = dateBaseToCall;
    }
}
