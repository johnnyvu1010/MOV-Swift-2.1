//
//  MVLikedUser.swift
//  MOVV
//
//  Created by Yuki on 31/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVLikedUser: NSObject {

    var username : String!
    var profileImage : String!
    var likedOn = ""
    var displayName = ""
    var location = ""
    var fullName = ""
    var id = ""
    init(dictionary:NSDictionary)
    {
        self.username = dictionary.objectForKey("username") != nil  ? dictionary.valueForKey("username") as! String : ""
        self.profileImage = dictionary.objectForKey("profile_image") != nil ? dictionary.valueForKey("profile_image") as! String : ""
    }

    class func getLikedUser(dict:NSDictionary) -> [MVLikedUser] {
        var arr = [MVLikedUser]()

        if let likes = dict["likes"] as? NSArray {
            for temp in likes{
                let userObj = MVLikedUser(dictionary: NSDictionary())
                userObj.likedOn = temp["liked_on"] as? String ?? ""
                if let obj = temp["user"] as? NSDictionary {
                    userObj.username = obj["username"] as? String ?? ""
                    userObj.profileImage = obj["profile_image"] as? String ?? ""
                    userObj.displayName = obj["display_name"] as? String ?? ""
                    userObj.fullName = obj["full_name"] as? String ?? ""
                    userObj.username = obj["username"] as? String ?? ""
                    userObj.id = obj["id"] as? String ?? ""
                }
                arr.append(userObj)
            }
        }
        return arr
    }
}
