//
//  CollectionViewCellMid.swift
//  Twy222
//
//  Created by Bonkook Koo on 22/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit

public class CollectionViewCellMid : UICollectionViewCell {
    @IBOutlet var labelWeekday: UILabel!
    @IBOutlet var imageSky: UIImageView!
    @IBOutlet var labelTemperatureMaxMin: UILabel!
    
    public func setLabelWeekday( str:String ) {
        labelWeekday.text = str;
    }
    
    public func setLabelTemperatureMaxMin( str:String ) {
        labelTemperatureMaxMin.text = str;
    }
    
    public func setImageSkyByFileName( imageFileName:String ) {
        guard let image = UIImage(named: imageFileName) else {
            return;
        }
        
        imageSky.image = image;
    }
    
    public func setData( weekday:String, temperatureMaxMin:String, imageFileName:String ) {
        setLabelWeekday( str: weekday );
        setLabelTemperatureMaxMin(str: temperatureMaxMin);
        setImageSkyByFileName(imageFileName: imageFileName)
    }
}
