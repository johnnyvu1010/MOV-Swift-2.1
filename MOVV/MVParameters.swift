//
//  MVParameters.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 06.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

class MVParameters: NSObject {
    
    var currentMVUser : MVUser!
    lazy var devicePushToken: String? = {
       
        return NSUserDefaults.standardUserDefaults().stringForKey(movDeviceToken)
        
    }()
//    var pushDeviceToken : NSData!
    
    class var sharedInstance: MVParameters {
        struct Static {
            static var instance: MVParameters?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = MVParameters()
        }
        return Static.instance!
    }
    
    class func sharedManager() -> MVParameters {
        return MVParameters.sharedInstance
    }
}
