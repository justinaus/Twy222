//
//  KmaApiMidLand.swift
//  Twy222
//
//  Created by Bonkook Koo on 20/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

final class KmaApiMidLand: KmaApiMidBase {
    static let shared = KmaApiMidLand();
    
    public func getData( dateBase:Date, regionId: String, callback:@escaping ( KmaApiMidLandModel? ) -> Void ) {
        let URL_SERVICE = "getMiddleLandWeather";
        
//        print("중기 육상 상태 call basetime   " + DateUtil.getStringByDate(date: dateBase) );
        
        func onComplete( dictItem: [String:Any]? ) {
            if( dictItem == nil ) {
                callback( nil );
                return;
            }
            
            let model = makeModel( dateBase: dateBase, regId: regionId, dictItem: dictItem! );
            callback( model );
        }
        
        makeCall(serviceName: URL_SERVICE, baseDate: dateBase, regId: regionId, callback: onComplete);
    }
    
    public func hasToCall( prevModel: KmaApiMidLandModel, newDateBase: Date, newRegId: String) -> Bool {
        if( !DateUtil.getIsSameDateAndMinute(date0: prevModel.dateBaseCalled, date1: newDateBase) ) {
            return true;
        }
        
        if( prevModel.regId != newRegId ) {
            return true;
        }
        
        return false;
    }
    
    private func makeModel( dateBase: Date, regId: String, dictItem: [String:Any] ) -> KmaApiMidLandModel? {
        let model = KmaApiMidLandModel(dateBase: dateBase, regId: regId);
        
        for i in 2 ..< 7 {
            guard let am = dictItem[ "wf\(i+1)Am" ] as? String else {
                return nil;
            }
            guard let pm = dictItem[ "wf\(i+1)Pm" ] as? String else {
                return nil;
            }
            
            guard let amEnum = KmaMidSkyStatusEnum(rawValue: am) else {
                return nil;
            }
            guard let pmEnum = KmaMidSkyStatusEnum(rawValue: pm) else {
                return nil;
            }
            
            let skyStatusEnum:KmaMidSkyStatusEnum = getSkyStatus(amEnum: amEnum, pmEnum: pmEnum);
            
            model.list.append( skyStatusEnum );
        }
        
        return model;
    }
    
    public func getRegionId( addressSiDo: String?, addressGu: String? ) -> String? {
        var regionId: String?;
        
        if( addressSiDo != nil ) {
            regionId = getCode(strDosi: addressSiDo!);
        }
        
        if( regionId == nil && addressGu != nil ) {
            regionId = getCode(strDosi: addressGu!);
        }
        
        return regionId;
    }
    
    // 눈/비 우선, 오후 날씨 우선.
    private func getSkyStatus( amEnum: KmaMidSkyStatusEnum, pmEnum: KmaMidSkyStatusEnum ) -> KmaMidSkyStatusEnum {
        if( getIsRainyOrSnowy(skyEnum: pmEnum) ) {
            return pmEnum;
        } else if( getIsRainyOrSnowy(skyEnum: amEnum) ) {
            return amEnum;
        }
        
        return pmEnum;
    }
    
    private func getIsRainyOrSnowy( skyEnum: KmaMidSkyStatusEnum ) -> Bool {
        switch skyEnum {
        case .QUITE_CLOUDY_AND_RAINY: return true;
        case .QUITE_CLOUDY_AND_SNOWY: return true;
        case .QUITE_CLOUDY_AND_RAINY_OR_SNOWY: return true;
        case .QUITE_CLOUDY_AND_SNOWY_OR_RAINY: return true;
        case .CLOUDY_AND_RAINY: return true;
        case .CLOUDY_AND_SNOWY: return true;
        case .CLOUDY_AND_RAINY_OR_SNOWY: return true;
        case .CLOUDY_AND_SNOWY_OR_RAINY: return true;
        default:    return false;
        }
    }
    
    private func getCode( strDosi: String ) -> String {
        if( strDosi.contains("서울") || strDosi.contains("인천") || strDosi.contains("경기") ) {
            return "11B00000";
        } else if( strDosi.contains("영서") ) {
            return "11D10000";
        } else if( strDosi.contains("영동") ) {
            return "11D20000";
        } else if( strDosi.contains("대전") || strDosi.contains("세종") || strDosi.contains("충남") || strDosi.contains("충청남도") ) {
            return "11C20000";
        } else if( strDosi.contains("충북") || strDosi.contains("충청북도") ) {
            return "11C10000";
        } else if( strDosi.contains("광주") || strDosi.contains("전라남도") || strDosi.contains("전남") ) {
            return "11F20000";
        } else if( strDosi.contains("전북") || strDosi.contains("전라북도") ) {
            return "11F10000";
        } else if( strDosi.contains("대구") || strDosi.contains("경상북도") || strDosi.contains("경북") ) {
            return "11H10000";
        } else if( strDosi.contains("부산") || strDosi.contains("울산") || strDosi.contains("경상남도") || strDosi.contains("경남") ) {
            return "11H20000";
        } else if( strDosi.contains("제주") ) {
            return "11G00000";
        }
        
        return "11B00000";
    }
    
    public func getStatusImageName( skyEnum: KmaMidSkyStatusEnum, isDay:Bool ) -> String {
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
        case .QUITE_CLOUDY_AND_SNOWY_OR_RAINY:
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
        }
    }
}

public enum KmaMidSkyStatusEnum : String {
    case GOOD = "맑음";
    case LITTLE_CLOUDY = "구름조금";
    case QUITE_CLOUDY = "구름많음";
    case QUITE_CLOUDY_AND_RAINY = "구름많고 비";
    case QUITE_CLOUDY_AND_SNOWY = "구름많고 눈";
    case QUITE_CLOUDY_AND_RAINY_OR_SNOWY = "구름많고 비/눈";
    case QUITE_CLOUDY_AND_SNOWY_OR_RAINY = "구름많고 눈/비";
    case CLOUDY = "흐림";
    case CLOUDY_AND_RAINY = "흐리고 비";
    case CLOUDY_AND_SNOWY = "흐리고 눈";
    case CLOUDY_AND_RAINY_OR_SNOWY = "흐리고 비/눈";
    case CLOUDY_AND_SNOWY_OR_RAINY = "흐리고 눈/비";
}
