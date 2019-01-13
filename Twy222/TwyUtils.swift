//
//  Utils.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class TwyUtils {
    /// 해당 시간이 낮인지 여부를 리턴.
    /// 낮 기준을 06 ~ 18시로 잡겠다.
    public static func getIsDay( hour: Int ) -> Bool {
        // 낮 기준 06 ~ 18
        // 밤 기준 19 ~ 05
        let DAY_START = 6;
        let DAY_END = 18;
        
        return hour >= DAY_START && hour <= DAY_END;
    }
    
    public static func prnt(_ items: Any...) {
        if( !Settings.PRINTABLE ) {
            return;
        }
        
        for item in items {
            print("\(item) ", separator:" ", terminator:"")
        }
        
        print("");
    }
}

