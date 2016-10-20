//
//  MVComment.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 13.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

class MVComment: NSObject {
    
    var id :  Int!
    var comment : String!
    var commentDate : String!
    var user : MVUser!
    var mentioneduser = [MVUser]()
    init(dictionary:NSDictionary)
    {
        self.id = dictionary.objectForKey("id") != nil ? (dictionary.valueForKey("id") as! NSString).integerValue : 0
        self.comment = dictionary.objectForKey("comment") != nil  ? dictionary.valueForKey("comment") as! String : ""
        self.commentDate = dictionary.objectForKey("commented_on") != nil  ? dictionary.valueForKey("commented_on") as! String : ""
        self.user = MVUser(dictionary: dictionary.valueForKey("user") as! NSDictionary)
        
        if let arr = dictionary.objectForKey("mentions") as? [NSDictionary]
        {
            for dict in arr
            {
                mentioneduser.append(MVUser(dictionary: dict))
            }
        }
    }
}
