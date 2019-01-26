//
//  AkUtils.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

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



final class AkUtils {
    static let shared = AkUtils();
    
    
}
