//
//  CameraViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 16/06/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class CameraViewController: UIImagePickerController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prefersStatusBarHidden()
        self.preferredStatusBarStyle()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        debugPrint(self.navigationController?.navigationBar.frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidDisappear(animated: Bool) {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
    }
    


}
