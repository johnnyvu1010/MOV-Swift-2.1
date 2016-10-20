//
//  MVTimerOptionsViewController.swift
//  MOVV
//
//  Created by Ivan Barisic on 31/08/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

protocol MVTimerOptionsDelegate {
    func onTouchTimerButtonSetInterval(durationInterval: Int)
}

class MVTimerOptionsViewController: UIViewController {

    var delegate: MVTimerOptionsDelegate? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disables popover corner radius
        self.view.superview?.layer.cornerRadius = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func onTouch5secButton(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.onTouchTimerButtonSetInterval(5)
        } else {
            print("Delegate MVTimerOptionsDelegate method onTouchTimerButtonSetInterval(5) not initialized")
        }
    }

    @IBAction func onTouch10secButton(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.onTouchTimerButtonSetInterval(10)
        } else {
            print("Delegate MVTimerOptionsDelegate method onTouchTimerButtonSetInterval(10) not initialized")
        }
    }

}
