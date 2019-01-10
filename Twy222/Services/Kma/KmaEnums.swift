//
//  KmaEnums.swift
//  Twy222
//
//  Created by Bonkook Koo on 09/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

public enum KmaCategoryCodeEnum : String {
    // 강수 형태
    case PTY = "PTY";
    
    // 하늘 상태
    case SKY = "SKY";
    
    // 기온
    case T1H = "T1H";
}


public enum KmaSkyEnum : Int {
    // 맑음
    case GOOD = 1;
    // 구름조금 2 / 구름많음 3 / 흐림 4
    case LITTLE_CLOUDY, QUITE_CLOUDY, CLOUDY;
    
    var description: String {
        switch self {
        case .GOOD:
            return "맑음"
        case .LITTLE_CLOUDY:
            return "구름조금"
        case .QUITE_CLOUDY:
            return "구름많음"
        case .CLOUDY:
            return "흐림"
        }
    }
}


public enum KmaPtyEnum : Int {
    // 없음
    case NONE = 0;
//    없음(0), 비(1), 비/눈(2), 눈(3)
    case RAINY, RAINY_AND_SNOWY, SNOWY;
    
    var description: String {
        switch self {
        case .NONE:
            return "없음"
        case .RAINY:
            return "비"
        case .RAINY_AND_SNOWY:
            return "비/눈"
        case .SNOWY:
            return "눈"
        }
    }
}
