//
//  KakaoApiAddressModel.swift
//  Twy222
//  법정동 주소만 사용하고, tm 좌표 체계로 넘겨 받는다.
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class KakaoApiAddressModel: IAddressModel {
    public private(set) var dateBaseCalled:Date;
    
    public private(set) var regionCode: String;
    
    public private(set) var addressFull: String?;
    //(바다지역시 존재안함)
    public private(set) var addressSiDo: String?;
    //(바다지역시 존재안함)
    public private(set) var addressGu: String?;
    //(바다지역시 존재안함)
    public private(set) var addressDong: String?;
    //region_type 이 법정동이며, 리 영역인 경우만 존재
//    public private(set) var addressRi: String?;
    
    public private(set) var tmX: Double;
    public private(set) var tmY: Double;
    
    
    init( dateBase: Date, regionCode:String, addressFull: String, tmX: Double, tmY: Double ) {
        self.dateBaseCalled = dateBase;
        self.regionCode = regionCode;
        self.addressFull = addressFull;
        self.tmX = tmX;
        self.tmY = tmY;
    }
    
    public func getAddressTitle() -> String? {
        var strRet: String?;
        
        if( addressDong != nil ) {
            strRet = addressDong;
        } else if( addressGu != nil ) {
            strRet = addressGu;
        } else if( addressSiDo != nil ) {
            strRet = addressSiDo;
        } else if( addressFull != nil ) {
            strRet = addressFull;
        }
        
        return strRet;
    }
    
    public func setAddressSido( value: String ) {
        addressSiDo = value;
    }
    public func setAddressGu( value: String ) {
        addressGu = value;
    }
    public func setAddressDong( value: String ) {
        addressDong = value;
    }
//    public func setAddressRi( value: String ) {
//        addressRi = value;
//    }
}
