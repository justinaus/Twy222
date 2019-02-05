//
//  AppManager.swift
//  Twy222
//
//  Created by Bonkook Koo on 03/02/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit

final class AppManager {
    static let shared = AppManager();
    
    public private(set) var isMainApp: Bool?;
    
    public func start( isMainApp: Bool ) {
        self.isMainApp = isMainApp;
    }
}
