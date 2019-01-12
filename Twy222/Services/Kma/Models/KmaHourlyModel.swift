//
//  KmaHourlyModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 12/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaHourlyModel {
    public private(set) var date:Date;
    
    public private(set) var temperature:Double;
    
    public private(set) var skyEnum:KmaSkyEnum;
    public private(set) var ptyEnum:KmaPtyEnum;
    
    
    init( date: Date, temperature: Double, skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum ) {
        self.date = date;
        self.temperature = temperature;
        self.skyEnum = skyEnum;
        self.ptyEnum = ptyEnum;
    }
}
