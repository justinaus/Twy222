//
//  VCAir.swift
//  Twy222
//
//  Created by Bonkook Koo on 27/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit

class VCAir: UIViewController {
    @IBOutlet var labelPm10Value: UILabel!
    @IBOutlet var labelPm25Value: UILabel!
    @IBOutlet var labelPm10Grade: UILabel!
    @IBOutlet var labelPm25Grade: UILabel!
    
    @IBOutlet var labelStation: UILabel!
    
    
    @IBAction func myActionMethod(_ sender: UIGestureRecognizer) {
        performSegue(withIdentifier: "unwindToRight", sender: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        guard let airModel = GridManager.shared.getCurrentGridModel()?.airModel else {
            return;
        }
        
        labelStation.text = "측정소 : \(airModel.stationName)";
        
        let pm10Grade = FineDustUtils.getFineDustGrade(fineDustType: .pm10, value: airModel.pm10Value);
        let pm25Grade = FineDustUtils.getFineDustGrade(fineDustType: .pm25, value: airModel.pm25Value);
        
        labelPm10Value.textColor = pm10Grade.color;
        labelPm10Grade.textColor = pm10Grade.color;
        
        labelPm25Value.textColor = pm25Grade.color;
        labelPm25Grade.textColor = pm25Grade.color;
            
        labelPm10Value.text = "\(airModel.pm10Value)";
        labelPm25Value.text = "\(airModel.pm25Value)";
        
        labelPm10Grade.text = "\(pm10Grade.text)";
        labelPm25Grade.text = "\(pm25Grade.text)";
    }
}
