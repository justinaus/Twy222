//
//  DailyTemperatureMaxMinModel
//  Twy222
//
//  Created by Bonkook Koo on 20/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class DailyTemperatureMaxMinModel {
    public private(set) var date: Date;
    public private(set) var max: Double;
    public private(set) var min: Double;
    
    init( date: Date, max: Double, min: Double ) {
        self.date = date;
        self.max = max;
        self.min = min;
    }
}
