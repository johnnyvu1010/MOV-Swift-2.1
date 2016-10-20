//
//  MVMessage.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 19.08.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

enum MVUserRole : String {
    case Buyer = "buyer"
    case Seller = "seller"
}

class MVMessage: NSObject {
    
    var id :  Int!
    var message : String!
    var sentDate : String!
    var unreadMessages : Int!
    var product : MVProduct!
    var seller : MVUser!
    var buyer : MVUser!
    var userRole : MVUserRole!
    

    
    init(dictionary:NSDictionary)
    {
        self.id = dictionary.objectForKey("id") != nil ? (dictionary.valueForKey("id") as! NSString).integerValue : 0
        self.message = dictionary.objectForKey("message") != nil  ? dictionary.valueForKey("message") as! String : ""
        self.unreadMessages = dictionary.objectForKey("unread_messages") != nil ? (dictionary.valueForKey("unread_messages") as! Int) : 0
        self.sentDate = dictionary.objectForKey("sent_date") != nil  ? dictionary.valueForKey("sent_date") as! String : ""
        self.seller = MVUser(dictionary: dictionary.valueForKey("seller") as! NSDictionary)
        self.buyer = MVUser(dictionary: dictionary.valueForKey("buyer") as! NSDictionary)
        self.product = MVProduct(dictionary: dictionary.valueForKey("product") as! NSDictionary)
        
        if (dictionary.objectForKey("user_role") != nil)
        {
            if (dictionary.objectForKey("user_role") as! String == "buyer")
            {
                self.userRole = MVUserRole.Buyer
            }
            else if (dictionary.objectForKey("user_role") as! String == "seller")
            {
                self.userRole = MVUserRole.Seller
                
            }
        }

    }
   
}
