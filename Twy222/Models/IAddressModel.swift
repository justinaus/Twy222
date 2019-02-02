//
//  IAddressModel.swift
//  Twy222
//
//  Created by Bonkook Koo on 26/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

protocol IAddressModel {
    var dateCalled: Date { get };
    
    var addressFull: String? { get };
    var addressSiDo: String? { get };
    var addressGu: String? { get };
    var addressDong: String? { get };
    
//    func getAddressTitle() -> String?;
}
