//
//  KmaApiCurrentModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiActualModel {
    public private(set) var date:Date;
    
    public private(set) var temperature:Double;
    
    
    init( date: Date, temperature: Double ) {
        self.date = date;
        self.temperature = temperature;
    }
}
