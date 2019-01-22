//
//  KmaUtils.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

struct KmaApiUrlStruct {
    static let URL_ROOT = "http://newsky2.kma.go.kr/service/"
    
    // (신)동네예보정보조회서비스
    static let URL_SHORT_FORECAST = "SecndSrtpdFrcstInfoService2/"
    
    static let URL_MID_FORECAST = "MiddleFrcstInfoService/";
}

enum KmaCategoryCodeEnum : String {
    // 강수 형태
    case PTY = "PTY";
    
    // 하늘 상태
    case SKY = "SKY";
    
    // 기온
    case T1H = "T1H";
    
    // 기온 3시간 단위.
    case T3H = "T3H";
}

class KmaUtils {
    public static func createDate( kmaDate: String, kmaTime: String ) -> Date? {
        // "fcstDate":20190107,"fcstTime":"0700"
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMdd HHmm"
        let dateRet = formatter.date(from: "\(kmaDate) \(kmaTime)");
        
        return dateRet;
    }
    
    public static func getBaseDateAndBaseTime( date: Date ) -> ( baseDate: String, baseTime: String ) {
        let formatter = DateFormatter();
        
        formatter.dateFormat = "yyyyMMdd";
        let baseDate = formatter.string(from: date);
        
        formatter.dateFormat = "HHmm";
        let baseTime = formatter.string(from: date);
        
        return ( baseDate: baseDate, baseTime: baseTime );
    }
    
    public static func getDateByDateAndTime( anyDate: Any?, anyTime: Any? ) -> Date? {
        var strDate: String?;
        var strTime: String?;
        
        // string으로 들어오는지 int로 들어오는지 뭔가 이상함. 둘 다 대응하겠다.
        if let baseDate = anyDate as? String {
            strDate = baseDate;
        } else if let baseDate = anyDate as? Int {
            strDate = String(baseDate);
        } else {
            return nil;
        }
        
        if let baseTime = anyTime as? String {
            strTime = baseTime;
        } else if let baseTime = anyTime as? Int {
            strTime = String(baseTime);
        } else {
            return nil;
        }
        
        if( strDate == nil || strTime == nil ) {
            return nil;
        }
        
        guard let dateBase = KmaUtils.createDate(kmaDate: strDate!, kmaTime: strTime!) else {
            return nil;
        }

        return dateBase;
    }
}
