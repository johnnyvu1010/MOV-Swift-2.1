//
//  MVAlertView.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 07.09.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

class MVAlertView: UIAlertView {
    
    
     func shouldAutorotate() -> Bool {
        return true
    }
    
     func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
