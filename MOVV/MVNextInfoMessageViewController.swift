//
//  MVNextInfoMessageViewController.swift
//  MOVV
//
//  Created by Yuki on 07/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

protocol MVNextInfoMessageViewControllerDelegate {
    func onTouchOK()
}


class MVNextInfoMessageViewController: UIViewController {

    
    var delegate : MVNextInfoMessageViewControllerDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onTouchOK(sender: AnyObject) {
//        
//        if self.delegate != nil {
//            self.delegate?.onTouchOK()
//        } else {
//            print("Error")
//        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    

}
