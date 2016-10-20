//
//  PopUpMenuViewController.swift
//  MOVV
//
//  Created by Mac on 5/16/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

protocol PopUpMenuViewDelegate {
    func onTouchTimerButtonSetInterval(durationInterval: Int)
}

class PopUpMenuViewController: UIViewController {
    
    var delegate: PopUpMenuViewDelegate? = nil

    @IBOutlet var meetButton: UIButton!
    @IBOutlet var shipButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMeetButton(sender: AnyObject) {
    }
    
    @IBOutlet var onShipButton: UIButton!
}

