//
//  KmaDailyModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 19/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaDailyModel {
    public private(set) var date:Date;
    
    public private(set) var temperatureMax:Double;
    public private(set) var temperatureMin:Double;
    
    public private(set) var skyEnum:KmaSkyEnum;
    public private(set) var ptyEnum:KmaPtyEnum;
    
    
    init( date: Date, temperatureMax: Double, temperatureMin: Double, skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum ) {
        self.date = date;
        self.temperatureMax = temperatureMax;
        self.temperatureMin = temperatureMin;
        self.skyEnum = skyEnum;
        self.ptyEnum = ptyEnum;
    }
}
