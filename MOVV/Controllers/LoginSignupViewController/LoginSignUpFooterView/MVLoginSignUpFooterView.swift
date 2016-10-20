//
//  MVLoginSignUpFooterView.swift
//  MOVV
//
//  Created by Vineet Choudhary on 20/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVLoginSignUpFooterView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet  var signUpBtn: UIButton!
    @IBOutlet  var loginBtn: UIButton!
    
    class func getInstance() -> MVLoginSignUpFooterView?
    {
        let arr = NSBundle.mainBundle().loadNibNamed("MVLoginSignUpFooterView", owner: nil, options: nil)
        for view in arr {
            if view.isKindOfClass(MVLoginSignUpFooterView)
            {
                return view as? MVLoginSignUpFooterView
            }
        }
        return nil
    }

}
