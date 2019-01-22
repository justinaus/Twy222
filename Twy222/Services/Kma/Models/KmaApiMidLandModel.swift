//
//  KmaApiMidLandModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 20/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiMidLandModel {
    public private(set) var dateBaseCalled:Date;
    public private(set) var regId:String;
    
    public var list: Array<KmaMidSkyStatusEnum> = [];
    
    init( dateBase: Date, regId: String ) {
        self.dateBaseCalled = dateBase;
        self.regId = regId;
    }
}
