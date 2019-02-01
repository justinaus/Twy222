//
//  TodayViewController.swift
//  TwyTodayExt
//
//  Created by Bonkook Koo on 01/02/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print( 123 );
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        print( 456 );
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
