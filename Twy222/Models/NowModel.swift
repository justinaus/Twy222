//
//  NowModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class NowModel {
//    public private(set) var date:Date;
    
    public private(set) var temperature:Double?;
    public private(set) var skyStatusImageName:String?;
    public private(set) var diffFromYesterday:Int?; // math.round.
    
    
    func setTemperature( value: Double? ) {
        temperature = value;
    }
    func setSkyStatusImageName( value: String? ) {
        skyStatusImageName = value;
    }
    func setDiffFromYesterday( value: Int? ) {
        diffFromYesterday = value;
    }
}

