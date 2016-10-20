//
//  MOVVNavigationController.swift
//  MOVV
//
//  Created by Martino Mamic on 29/04/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class MOVVNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: UIBarMetrics.Compact)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
        self.navigationBar.backgroundColor = UIColor.clearColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    
}


extension UINavigationController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        if (self.viewControllers.first?.isKindOfClass(MVCameraViewController) != nil && self.viewControllers.count == 1) {
            
            
            return UIInterfaceOrientationMask.AllButUpsideDown
        }
        return UIInterfaceOrientationMask.Portrait
    }
    
    public override func shouldAutorotate() -> Bool {
        
        return MVHelper.sharedInstance.shouldAutorotate
        
//        if (self.viewControllers.first?.isKindOfClass(MVCameraViewController) != nil && self.viewControllers.count == 1) {
//            return true
//        }
//        return false
    }
}
