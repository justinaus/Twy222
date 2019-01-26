//
//  AkUtils.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit

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

final class AkUtils {
    static let shared = AkUtils();
    
    private let pm10WHORangeList =                          [ Range( 0,30 ), Range(31,50), Range(51,100), Range(101,999) ];
    private let pm25WHORangeList =                          [ Range( 0,15 ), Range(16,25), Range(26,50), Range(51,999) ];
    
//    private let pm10KoreaMinistryOfEnvironmentRangeList =   [ Range( 0,30 ), Range(31,80), Range(81,150), Range(151,999) ];
//    private let pm25KoreaMinistryOfEnvironmentRangeList =   [ Range( 0,15 ), Range(16,35), Range(36,75), Range(76,999) ];
    
    public func getFineDustGrade( fineDustType: FineDustTypeEnum, value: Int ) -> FineDustGradeEnum {
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

public enum AkApiErrorCode : String {
    case OK = "00";
    
    case Application_Error = "01";
    case DB_Error = "02";
    case No_Data = "03";
    case HTTP_Error = "04";
    case service_time_out = "05";
    
    case CODE_10 = "10";// 잘못된 요청 파라미터 에러
    case CODE_11 = "11";// 필수 요청 파라미터 없음
    case CODE_12 = "12";//해당 오픈API 서비스가 없거나 폐기됨
    
    case CODE_20 = "20";//서비스 접근 거부
    case CODE_22 = "22";//서비스 요청 제한 횟수 초과 에러
    
    case CODE_30 = "30";//등록하지 않은 서비스키
    case CODE_31 = "31";//서비스키 사용기간 만료
    case CODE_32 = "32";//등록하지 않은 도메인명 또는 IP주소
    
    var description: String {
        switch self {
        case .CODE_22:
            return "하루 트래픽 제한을 초과하였습니다."
        default :
            return "서비스 제공 상태가 원활하지 않습니다."
        }
    }
    
    var code: String {
        return "ak error code: \(self.rawValue)";
    }
}

