//
//  MVNews.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 16.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

enum MVNewsAction : Int {
    case NotDefined = 0
    case Friends = 1
    case Comment = 2
    case Like = 3
    case Bought = 4
    case Sold = 5
    case Purchase = 6
    case Selling = 7
}

class MVNews: NSObject {
    

    var action : String!
    var actionType : MVNewsAction!
    var timestamp : String!
    var user : MVUser!
    
    var product : MVProduct!
    var buyer : MVUser!
    
    init(dictionary:NSDictionary)
    {
        self.action = dictionary.objectForKey("action") != nil  ? dictionary.valueForKey("action") as! String : ""
        self.timestamp = dictionary.objectForKey("timestamp") != nil  ? dictionary.valueForKey("timestamp") as! String : ""
        self.user = dictionary.valueForKey("action_user") != nil ? MVUser(dictionary: dictionary.valueForKey("action_user") as! NSDictionary) : dictionary.valueForKey("action_user") != nil ? MVUser(dictionary: dictionary.valueForKey("action_user") as! NSDictionary) : nil
        
        self.buyer = dictionary.valueForKey("buyer") != nil ? MVUser(dictionary: dictionary.valueForKey("buyer") as! NSDictionary) : nil
        self.product = dictionary.valueForKey("product") != nil ? MVProduct(dictionary: dictionary.valueForKey("product") as! NSDictionary) : nil
        
        //OVO JE TEMP DOK VEDRAN NE RIJEŠI INTEGER ACTION
        
        var actionInt : Int = 0
        if (self.action == "friends")
        {
            actionInt = 1
        }
        else if (self.action == "comment")
        {
            actionInt = 2
        }
        else if (self.action == "like")
        {
            actionInt = 3
        }
        else if (self.action == "bought")
        {
            actionInt = 4
        }
        else if (self.action == "sold")
        {
            actionInt = 5
        }
        else if (self.action == "purchase")
        {
            actionInt = 6
        }
        else if (self.action == "selling")
        {
            actionInt = 7
        }

        self.actionType = dictionary.objectForKey("action") != nil  ? MVNewsAction(rawValue: actionInt)! : nil
        
//        if(self.product != nil)
//        {
//            self.product.user = self.user
//        }
    }
   
}
