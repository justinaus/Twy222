//
//  SegueUnwindToRight.swift
//  TwySwift3
//
//  Created by Bonkook Koo on 2017. 6. 20..
//  Copyright © 2017년 justinaus. All rights reserved.
//

import Foundation
import UIKit

class SegueUnwindToRight: UIStoryboardSegue
{
    
    override open func perform() {
        let viewPop = source.view!;
        let viewMain = destination.view!;
        
        let window = UIApplication.shared.delegate!.window!!
        
        window.insertSubview(viewMain, at: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        viewPop.transform = CGAffineTransform(translationX: viewPop.frame.size.width, y: 0);
                }, completion: { finished in
                    self.destination.dismiss(animated: false, completion: nil);
                });
    }
}
