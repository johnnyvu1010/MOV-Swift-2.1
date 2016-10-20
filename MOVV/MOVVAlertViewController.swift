//
//  MOVVAlertViewController.swift
//  MOVV
//
//  Created by Petar Bandov on 17/06/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class MOVVAlertViewController: UIAlertController {

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let subview : UIView = self.view.subviews.first!
        let alertContentView = subview.subviews.first
        alertContentView!.backgroundColor = MOVVGreen
        alertContentView!.layer.cornerRadius = 5
        self.view.tintColor = UIColor.blackColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func shouldAutorotate() -> Bool {
        return false
    }
}
