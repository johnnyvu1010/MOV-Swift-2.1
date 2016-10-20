//
//  FacebookUser.swift
//  MOVV
//
//  Created by Martino Mamic on 23/07/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit


var facebookUser:MVFacebookUser?

class MVFacebookUser {
    convenience init(dictionary:NSDictionary!){
        self.init()
        self.facebookID = dictionary.objectForKey("id") != nil ? dictionary.valueForKey("id") as! String! : ""
        self.username =  dictionary.objectForKey("name") != nil ? dictionary.valueForKey("name") as! String : ""
        self.email = dictionary.objectForKey("email") != nil ? dictionary.valueForKey("email") as! String : ""
        self.firstName = username?.componentsSeparatedByString(" ").first
        self.lastName = username?.componentsSeparatedByString(" ").last
    }
    
    
    
    var facebookID:String?
    var username:String?
    var firstName:String?
    var lastName:String?
    var email:String?
    var facebookUserImage:UIImage?
}
