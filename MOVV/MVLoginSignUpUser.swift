//
//  MVLoginSignUpUser.swift
//  MOVV
//
//  Created by Vineet Choudhary on 20/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVLoginSignUpUser: NSObject {
    var userName:String?
    var password:String?
    var email:String?
    var firstName:String?
    var lastName:String?

    func getDict() -> NSMutableDictionary {
         let dict = NSMutableDictionary()
        if userName != nil
        {
            dict.setObject(self.userName!, forKey: "username")
        }
        if firstName != nil
        {
            dict.setObject(self.firstName!, forKey: "first_name")
            
        }
        if lastName != nil
        {
            dict.setObject(self.lastName!, forKey: "last_name")
            
        }
        if password != nil
        {
            dict.setObject(self.password!, forKey: "password")
            
        }
        if email != nil
        {
            dict.setObject(self.email!, forKey: "email")
            
        }
        return dict
    }
}
