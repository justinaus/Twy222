//
//  SegueFromRightToLeft.swift
//  TwySwift3
//
//  Created by Bonkook Koo on 2017. 6. 19..
//  Copyright © 2017년 justinaus. All rights reserved.
//

import Foundation
import UIKit

class SegueFromRightToLeft: UIStoryboardSegue
{
    
    override open func perform() {
        let viewPop = destination.view!;
        
        let window = UIApplication.shared.delegate!.window!!
        
        window.addSubview(viewPop);
        
        viewPop.transform = CGAffineTransform(translationX: source.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        viewPop.transform = CGAffineTransform.identity
        }, completion: { finished in
            self.source.present(self.destination, animated: false, completion: nil)
        });
    }
}
