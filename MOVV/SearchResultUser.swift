//
//  SearchResultUser.swift
//  MOVV
//
//  Created by Vineet Choudhary on 29/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class SearchResultUser: NSObject {
    var id:String!
    var firstName:String!
    var lastName:String!
    var username:String!
    var userProfileImage:String!
    
    init(serverResponse:NSDictionary) {
        self.id = serverResponse.valueForKey("id") != nil ? serverResponse.valueForKey("id") as? String : nil
        self.firstName = serverResponse.valueForKey("first_name") != nil ? serverResponse.valueForKey("first_name") as? String : nil
        self.lastName = serverResponse.valueForKey("last_name") != nil ? serverResponse.valueForKey("last_name") as? String : nil
        self.username = serverResponse.valueForKey("username") != nil ? serverResponse.valueForKey("username") as? String : nil
        self.userProfileImage = serverResponse.valueForKey("user_profile_image") != nil ? serverResponse.valueForKey("user_profile_image") as? String : nil
    }
}
