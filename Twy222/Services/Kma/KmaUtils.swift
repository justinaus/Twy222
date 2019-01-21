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
    
    public static func getStatusImageName( skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum, isDay:Bool ) -> String {
        switch ptyEnum {
        case KmaPtyEnum.RAINY:
            if( skyEnum == KmaSkyEnum.GOOD || skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "12" : "40";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return "21";
            } else {
                return "36";
            }
        case KmaPtyEnum.SNOWY:
            if( skyEnum == KmaSkyEnum.GOOD || skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "13" : "41";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return "32";
            } else {
                return "37";
            }
        case KmaPtyEnum.RAINY_AND_SNOWY:
            if( skyEnum == KmaSkyEnum.GOOD || skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "14" : "42";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return "04";
            } else {
                return "39";
            }
        default:
            if( skyEnum == KmaSkyEnum.GOOD ) {
                return isDay ? "01" : "08";
            } else if( skyEnum == KmaSkyEnum.LITTLE_CLOUDY ) {
                return isDay ? "02" : "09";
            } else if( skyEnum == KmaSkyEnum.QUITE_CLOUDY ) {
                return isDay ? "03" : "10";
            } else {
                return "18";
            }
        }
    }
    
    public static func getStatusImageName( skyEnum: KmaMidSkyStatusEnum, isDay:Bool ) -> String {
        switch skyEnum {
        case .GOOD:
            return isDay ? "01" : "08";
        case .LITTLE_CLOUDY:
            return isDay ? "02" : "09";
        case .QUITE_CLOUDY:
            return isDay ? "03" : "10";
        case .QUITE_CLOUDY_AND_RAINY:
            return "21";
        case .QUITE_CLOUDY_AND_SNOWY:
            return "32";
        case .QUITE_CLOUDY_AND_RAINY_OR_SNOWY:
            return "04";
        case .QUITE_CLOUDY_AND_RAINY_OR_SNOWY:
            return "04";
        case .CLOUDY:
            return "18";
        case .CLOUDY_AND_RAINY:
            return "36";
        case .CLOUDY_AND_SNOWY:
            return "37";
        case .CLOUDY_AND_RAINY_OR_SNOWY:
            return "39";
        case .CLOUDY_AND_SNOWY_OR_RAINY:
            return "39";
        default:
            return "18";
        }
    }
    
    public static func getSkyStatusText( skyEnum: KmaSkyEnum, ptyEnum: KmaPtyEnum ) -> String {
        if( ptyEnum != KmaPtyEnum.NONE ) {
            return ptyEnum.description;
        }
        
        return skyEnum.description;
    }
}
