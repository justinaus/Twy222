//
//  KmaUtils.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KmaUtils {
    public static func createDate( kmaDate: Int, kmaTime: Int ) -> Date? {
        // "fcstDate":20190107,"fcstTime":"0700"
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMdd HHmm"
        let dateRet = formatter.date(from: "\(kmaDate) \(kmaTime)");
        
        return dateRet;
    }
}
