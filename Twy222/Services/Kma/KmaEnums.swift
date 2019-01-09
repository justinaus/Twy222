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
}


public enum KmaPtyEnum : Int {
    // 없음
    case NONE = 0;
    // 비 1 / 비/눈(진눈개비) 2 / 눈 3
    case RAINY, RAINY_AND_SNOWY, SNOWY;
}
