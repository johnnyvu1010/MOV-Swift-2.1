//
//  TimerPopoverView.swift
//  MOVV
//
//  Created by Martino Mamic on 21/07/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class TimerPopoverView: UIView {

   
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
        
    }
    

}
