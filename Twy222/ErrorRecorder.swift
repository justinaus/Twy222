//
//  ErrorRecorder.swift
//  Twy222
//
//  Created by Bonkook Koo on 16/02/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import Crashlytics

final class ErrorRecorder {
    static let shared = ErrorRecorder();
    
    public func record( error: Error? = nil , additionalInfo: [String : Any]? = nil ) {
        Crashlytics.sharedInstance().recordError(error ?? ErrorModel(), withAdditionalUserInfo: additionalInfo);
    }
}
