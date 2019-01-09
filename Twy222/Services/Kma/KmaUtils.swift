//
//  KmaUtils.swift
//  Twy222
//
//  Created by Bonkook Koo on 07/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

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
    
    public static func getDateBase( obj: [ String : Any ] ) -> Date? {
        var strBaseDate: String?;
        var strBaseTime: String?;
        
        // string으로 들어오는지 int로 들어오는지 뭔가 이상함. 둘 다 대응하겠다.
        if let baseDate = obj[ "baseDate" ] as? String {
            strBaseDate = baseDate;
        } else if let baseDate = obj[ "baseDate" ] as? Int {
            strBaseDate = String(baseDate);
        } else {
            return nil;
        }
        
        if let baseTime = obj[ "baseTime" ] as? String {
            strBaseTime = baseTime;
        } else if let baseTime = obj[ "baseTime" ] as? Int {
            strBaseTime = String(baseTime);
        } else {
            return nil;
        }
        
        if( strBaseDate == nil || strBaseTime == nil ) {
            return nil;
        }
        
        guard let dateBase = KmaUtils.createDate(kmaDate: strBaseDate!, kmaTime: strBaseTime!) else {
            return nil;
        }

        return dateBase;
    }
    
    public static func getStatusImageName( skyType: Int, ptyType: Int, isDay:Bool ) -> String {
        switch ptyType {
        case KmaPtyEnum.RAINY.rawValue:
            if( skyType == KmaSkyEnum.GOOD.rawValue || skyType == KmaSkyEnum.LITTLE_CLOUDY.rawValue ) {
                return isDay ? "12" : "40";
            } else if( skyType == KmaSkyEnum.QUITE_CLOUDY.rawValue ) {
                return "21";
            } else {
                return "36";
            }
        case KmaPtyEnum.SNOWY.rawValue:
            if( skyType == KmaSkyEnum.GOOD.rawValue || skyType == KmaSkyEnum.LITTLE_CLOUDY.rawValue ) {
                return isDay ? "13" : "41";
            } else if( skyType == KmaSkyEnum.QUITE_CLOUDY.rawValue ) {
                return "32";
            } else {
                return "37";
            }
        case KmaPtyEnum.RAINY_AND_SNOWY.rawValue:
            if( skyType == KmaSkyEnum.GOOD.rawValue || skyType == KmaSkyEnum.LITTLE_CLOUDY.rawValue ) {
                return isDay ? "14" : "42";
            } else if( skyType == KmaSkyEnum.QUITE_CLOUDY.rawValue ) {
                return "04";
            } else {
                return "39";
            }
        default:
            if( skyType == KmaSkyEnum.GOOD.rawValue ) {
                return isDay ? "01" : "08";
            } else if( skyType == KmaSkyEnum.LITTLE_CLOUDY.rawValue ) {
                return isDay ? "02" : "09";
            } else if( skyType == KmaSkyEnum.QUITE_CLOUDY.rawValue ) {
                return isDay ? "03" : "10";
            } else {
                return "18";
            }
        }
    }
}
