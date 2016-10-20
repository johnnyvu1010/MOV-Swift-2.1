//
//  MVUser.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 05.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//


import UIKit

class MVUser: NSObject, NSCoding {
    
    var id :  Int!
    var username : String!
    var name : String!
    var displayName : String!
    var fullName : String!
    var email : String!
    var unreadMessages: Int!
    var location : String!
    var profileImage : String!
    var isFollowingBack : Bool!
    var isFollowed : Bool! //flag if this user is followed by you (logged user)
    var stripePublishableKey : String!

    // added
    var can_sell: Bool = false

    
    init(dictionary:NSDictionary)
    {
        if(dictionary.objectForKey("id")!.isKindOfClass(NSNumber)){
            self.id = (dictionary.objectForKey("id") as! NSObject).isValid() ? (dictionary.valueForKey("id") as! NSNumber!).integerValue : 0
        } else {
            self.id = (dictionary.objectForKey("id") as! NSObject).isValid() ? (dictionary.valueForKey("id") as! NSString!).integerValue : 0
        }
        
        if dictionary.objectForKey("username") != nil {
            self.username = (dictionary.objectForKey("username") as! NSObject).isValid() ? dictionary.valueForKey("username") as! String : ""
        } else {
            self.username = ""
        }
        
        if dictionary.objectForKey("name") != nil {
            self.name =  (dictionary.objectForKey("name") as! NSObject).isValid() ? dictionary.valueForKey("name") as! String : ""
        } else {
            self.name = ""
        }
        
        if dictionary.objectForKey("display_name") != nil {
            self.displayName =  (dictionary.objectForKey("display_name") as! NSObject).isValid() ? dictionary.valueForKey("display_name") as! String : ""
        } else {
            self.displayName = ""
        }
        
        if dictionary.objectForKey("full_name") != nil {
            self.fullName =  (dictionary.objectForKey("full_name") as! NSObject).isValid() ? dictionary.valueForKey("full_name") as! String : ""
        } else {
            self.fullName = ""
        }
        
        if dictionary.objectForKey("email") != nil {
            self.email = (dictionary.objectForKey("email") as! NSObject).isValid() ? dictionary.valueForKey("email") as! String : ""
        } else {
            self.email = ""
        }
        
        if dictionary.objectForKey("unread_messages") != nil {
            if let unreadMsg = dictionary.valueForKey("unread_messages") as? String{
                self.unreadMessages = Int(unreadMsg)
            }else{
                self.unreadMessages = 0
            }
        } else {
            self.unreadMessages = 0
        }
        
        if dictionary.objectForKey("location") != nil {
            self.location =  (dictionary.objectForKey("location") as! NSObject).isValid() ? dictionary.valueForKey("location") as! String : ""
        } else {
            self.location = ""
        }
        
        if dictionary.objectForKey("profile_image") != nil {
            self.profileImage = (dictionary.objectForKey("profile_image") as! NSObject).isValid() ? dictionary.valueForKey("profile_image") as! String : ""
        } else {
            self.profileImage = ""
        }
        
        if dictionary.objectForKey("is_following_back") != nil {
            self.isFollowingBack = (dictionary.objectForKey("is_following_back") as! NSObject).isValid() ? (dictionary.objectForKey("is_following_back") as! NSString).boolValue : false
        } else {
            self.isFollowingBack = false
        }
        
        if dictionary.objectForKey("is_followed") != nil {
            self.isFollowed = (dictionary.objectForKey("is_followed") as! NSObject).isValid() ? (dictionary.objectForKey("is_followed") as! NSString).boolValue : false
        } else {
            self.isFollowed = false
        }
        
        if dictionary.objectForKey("stripe_publishable_key") != nil {
            self.stripePublishableKey = (dictionary.objectForKey("stripe_publishable_key") as! NSObject).isValid() ? dictionary.valueForKey("stripe_publishable_key") as! String : ""
        } else {
            self.stripePublishableKey = ""
        }
        
        // added
        if dictionary.objectForKey("can_sell") != nil {
            self.can_sell = (dictionary.objectForKey("can_sell") as! NSObject).isValid() ? (dictionary.objectForKey("can_sell") as! NSString).boolValue : false
        } else {
            self.can_sell = false
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.id = aDecoder.decodeObjectForKey("id") as! Int
        self.username = aDecoder.decodeObjectForKey("username") as! String
        self.name =  aDecoder.decodeObjectForKey("name") as? String
        self.displayName =  aDecoder.decodeObjectForKey("displayName") as? String
        self.fullName =  aDecoder.decodeObjectForKey("fullName") as? String
        self.email = aDecoder.decodeObjectForKey("email") as? String
        self.unreadMessages = aDecoder.decodeObjectForKey("unreadMessages") as? Int
        self.location =  aDecoder.decodeObjectForKey("location") as? String
        self.profileImage = aDecoder.decodeObjectForKey("profileImage") as? String
        
        // added
        self.can_sell = aDecoder.decodeObjectForKey("can_sell") as? Bool ?? false
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.displayName, forKey: "displayName")
        aCoder.encodeObject(self.fullName, forKey: "fullName")
        aCoder.encodeObject(self.unreadMessages, forKey: "unreadMessages")
        aCoder.encodeObject(self.email, forKey: "email")
        aCoder.encodeObject(self.location, forKey: "location")
        aCoder.encodeObject(self.profileImage, forKey: "profileImage")
        
        // added
        aCoder.encodeObject(self.can_sell, forKey: "can_sell")
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "user")
    }
    
    func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
    }
    
    class func loadSavedUser() -> MVUser? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? MVUser
        }
        return nil
    }
}
