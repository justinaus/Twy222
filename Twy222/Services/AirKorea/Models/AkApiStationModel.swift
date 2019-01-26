//
//  AkApiStationModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class AkApiStationModel {
    public private(set) var dateCalled:Date;
    
    public var list: Array<AkStationModel> = [];
    
    
    init( dateCalled: Date ) {
        self.dateCalled = dateCalled;
    }
    
}
