//
//  ApiBase.swift
//  Twy222
//
//  Created by Bonkook Koo on 19/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

class ApiBase {
    public func hasToCall( prevDateCalled: Date?, baseDateToCall: Date ) -> Bool {
        if( prevDateCalled == nil ) {
            return true;
        }
        
        return DateUtil.getIsSameDateAndMinute(date0: prevDateCalled!, date1: baseDateToCall);
    }
}


