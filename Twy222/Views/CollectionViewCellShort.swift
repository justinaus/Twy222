//
//  CollectionViewCellShort.swift
//  Twy222
//
//  Created by Bonkook Koo on 12/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCellShort : UICollectionViewCell {
    
    @IBOutlet var labelHour: UILabel!
    @IBOutlet var labelTemperature: UILabel!
    @IBOutlet var imageSky: UIImageView!
    
    
    public func setLabelHour( str:String ) {
        labelHour.text = str;
    }

    public func setLabelTemperature( str:String ) {
        labelTemperature.text = str;
    }

    public func setImageSkyByFileName( imageFileName:String ) {
        guard let image = UIImage(named: imageFileName) else {
            return;
        }

        imageSky.image = image;
    }

    public func setData( label:String, temperature:String, imageFileName:String ) {
        setLabelHour( str: label );
        setLabelTemperature(str: temperature);
        setImageSkyByFileName(imageFileName: imageFileName)
    }
    
}
