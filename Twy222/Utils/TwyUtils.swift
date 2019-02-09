//
//  Utils.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit

struct CharacterStruct {
    static let TEMPERATURE = "°";
}

public enum ColorEnum : UInt {
    case blue = 0x2980b9;
    case green = 0x579f2b;
    case orange = 0xe7963b;
    case red = 0xbe2813;
    
    case gray = 0xadb7be;
    //case gray = 0x666666;
}

public enum FineDustGradeEnum : Int {
    case good = 0;
    case notBad, bad, danger
    
    var text: String {
        switch self {
        case .good:
            return "좋음"
        case .notBad:
            return "보통"
        case .bad:
            return "나쁨"
        case .danger:
            return "매우나쁨"
        }
    }
    
    var color: UIColor {
        var uintColor: UInt
        
        switch self {
        case .good:
            uintColor = ColorEnum.blue.rawValue;
            break;
        case .notBad:
            uintColor = ColorEnum.green.rawValue;
            break;
        case .bad:
            uintColor = ColorEnum.orange.rawValue;
            break;
        case .danger:
            uintColor = ColorEnum.red.rawValue;
            break;
        }
        
        return ColorUtil.UIColorFromRGB(rgbValue: uintColor);
    }
}

public enum FineDustTypeEnum {
    case pm10
    case pm25
}

public enum AirInfoProviderEnum {
    // 환경부.
    case koreaMinistryOfEnvironment
    case WHO
}

class Range {
    public var start:Int = 0;
    public var end:Int = 0;
    
    init( _ start: Int, _ end : Int ) {
        self.start = start;
        self.end = end;
    }
}

class TwyUtils {
    public static let NUMBER_NIL_TEMP = 999;
    
    public static func getTextCompareWithYesterday( intTemperatureGap: Int ) -> String {
        let uintTemperatureGap = abs(intTemperatureGap);
        
        var strComment = "어제와 같음";
        
        if( intTemperatureGap > 0 ) {
            strComment = "어제보다 \(uintTemperatureGap)\(CharacterStruct.TEMPERATURE) 높음"
        } else if( intTemperatureGap < 0 ) {
            strComment = "어제보다 \(uintTemperatureGap)\(CharacterStruct.TEMPERATURE) 낮음"
        }
        
        return strComment;
    }
    
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

class FineDustUtils {
    private static let pm10WHORangeList =                          [ Range( 0,30 ), Range(31,50), Range(51,100), Range(101,999) ];
    private static let pm25WHORangeList =                          [ Range( 0,15 ), Range(16,25), Range(26,50), Range(51,999) ];
    
    //    private let pm10KoreaMinistryOfEnvironmentRangeList =   [ Range( 0,30 ), Range(31,80), Range(81,150), Range(151,999) ];
    //    private let pm25KoreaMinistryOfEnvironmentRangeList =   [ Range( 0,15 ), Range(16,35), Range(36,75), Range(76,999) ];
    
    public static func getFineDustGrade( fineDustType: FineDustTypeEnum, value: Int ) -> FineDustGradeEnum {
        let rangeList = fineDustType == .pm10 ? pm10WHORangeList : pm25WHORangeList;
        
        var grade = rangeList.count - 1;
        
        for ( i, range ) in rangeList.enumerated() {
            if( value >= range.start && value <= range.end ) {
                grade = i;
                
                break;
            }
        }
        
        let gradeEnum = FineDustGradeEnum(rawValue: grade)!;
        
        return gradeEnum;
    }
}

