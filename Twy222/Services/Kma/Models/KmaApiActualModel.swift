//
//  KmaApiCurrentModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaApiActualModel: IDate {
    public private(set) var date: Date;
    public private(set) var kmaXY: KmaXY;
    
    public private(set) var temperature: Double;
    
    
    init( dateBase: Date, kmaXY: KmaXY, temperature: Double ) {
        self.date = dateBase;
        self.kmaXY = kmaXY;
        self.temperature = temperature;
    }
}
