//
//  AkStationModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class AkStationModel {
    public private(set) var stationName: String;
    
//    public private(set) var addressFull: String;
    public private(set) var distance: Double?;
    
    init( stationName: String ) {
        self.stationName = stationName;
    }
    
    public func setDistance( value: Double ) {
        distance = value;
    }
}
