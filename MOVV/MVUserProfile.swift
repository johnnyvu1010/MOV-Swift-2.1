//
//  MVUserProfile.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 09.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

class MVUserProfile: NSObject {
    
    var id :  Int!
    var username : String!
    var name : String!
    var displayName : String!
    var email : String!
    var unreadMessages: Int!
    var location : String!
    var profileImage : String!
    var coverImage : String!
    var userRating : Int!
    var numFollowers : Int!
    var numReviews : Int!
    var numSelling : Int!
    var isFollowed : Bool!
    
    var timelineArray:[MVTimeline]! = [MVTimeline]()
    
    init(dictionary:NSDictionary)
    {
        let userProfileDictionary : NSDictionary = ((dictionary["profile"] as! NSArray).firstObject) as! NSDictionary
        self.coverImage = userProfileDictionary.objectForKey("cover_image") != nil ? userProfileDictionary.valueForKey("cover_image") as! String : ""
        self.displayName =  userProfileDictionary.objectForKey("display_name") != nil ? userProfileDictionary.valueForKey("display_name") as! String : ""
        self.email = userProfileDictionary.objectForKey("email") != nil ? userProfileDictionary.valueForKey("email") as! String : ""
        self.name =  userProfileDictionary.objectForKey("full_name") != nil ? userProfileDictionary.valueForKey("full_name") as! String : ""
        self.id = userProfileDictionary.objectForKey("id") != nil ? (userProfileDictionary.valueForKey("id") as! NSString).integerValue : 0
        self.location =  userProfileDictionary.objectForKey("location") != nil ? userProfileDictionary.valueForKey("location") as! String : ""
        self.profileImage = userProfileDictionary.objectForKey("profile_image") != nil ? userProfileDictionary.valueForKey("profile_image") as! String : ""
        self.userRating = userProfileDictionary.objectForKey("user_rating") != nil ? (userProfileDictionary.valueForKey("user_rating") as! NSString).integerValue : 0
        self.username = userProfileDictionary.objectForKey("username") != nil  ? userProfileDictionary.valueForKey("username") as! String : ""
        self.numFollowers = userProfileDictionary.objectForKey("num_followers") != nil ? userProfileDictionary.valueForKey("num_followers") as! Int : 0
        self.numReviews = userProfileDictionary.objectForKey("num_reviews") != nil ? userProfileDictionary.valueForKey("num_reviews") as! Int : 0
        self.numSelling = userProfileDictionary.objectForKey("num_selling") != nil ? userProfileDictionary.valueForKey("num_selling") as! Int : 0
        self.isFollowed = userProfileDictionary.objectForKey("is_followed") != nil ? (userProfileDictionary.objectForKey("is_followed") as! NSString).boolValue : false
        
        let timelineDictionary : NSArray = dictionary["timeline"] as! NSArray
        for dict in timelineDictionary
        {
            if let data = dict as? NSDictionary{
                let timeLineDictionary : MVTimeline! = MVTimeline(dictionary: data)
                self.timelineArray!.append(timeLineDictionary)

            }
       }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
