//
//  GridModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class GridModel {
    public private(set) var latitude:String;
    public private(set) var longitude:String;
    
    // 구분 키 값
    public private(set) var id: String;
    
    public private(set) var dongName: String;
    
    public private(set) var nowModel: NowModel?;
    
    init( id: String, lat: String, lon: String, dongName: String ) {
        self.id = id;
        self.latitude = lat;
        self.longitude = lon;
        self.dongName = dongName;
    }
    
    public func setNowModel( value: NowModel ) {
        nowModel = value;
    }
    
//    public func resetAll() {
//        nowModel = NowModel();
//    }
    
    
}
