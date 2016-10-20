//
//  MVUserAction.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 03.09.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

enum MVUserAction:String{
    case Sold = "sold"
    case Bought = "bought"
}

class MVActionProduct: NSObject {
    
    var action : MVUserAction!
    var actionUser : MVUser!
    var product : MVProduct!
    var timestamp:String!
    var offerId:String!
    var offerPrice:String!
    var offerStatus:String!
    var offerDeliveryOption:DeliveryOption!
    var deliveryStatus:String!
    var unreadMessageCount:Int!
    
    init(dictionary:NSDictionary){
        self.action = MVUserAction(rawValue: dictionary.valueForKey("action") as! String)
        self.actionUser =  dictionary.valueForKey("action_user") != nil ? MVUser(dictionary: dictionary.valueForKey("action_user") as! NSDictionary) : nil
        self.product = dictionary.valueForKey("product") != nil ? MVProduct(dictionary: dictionary.valueForKey("product") as! NSDictionary) : nil
        self.timestamp = dictionary.valueForKey("timestamp") != nil ? dictionary.valueForKey("timestamp") as! String: ""
        if let offerDict = dictionary.valueForKey("offer") as? NSDictionary{
            self.offerId = (offerDict.valueForKey("id") == nil) ? nil : offerDict.valueForKey("id") as? String
            self.offerDeliveryOption = DeliveryOption(rawValue:offerDict.valueForKey("delivery_option") as! String)
            self.offerPrice = (offerDict.valueForKey("price") == nil) ? nil : offerDict.valueForKey("price") as? String
            self.offerStatus = (offerDict.valueForKey("offer_status") == nil) ? nil : offerDict.valueForKey("offer_status") as? String
            self.deliveryStatus = (offerDict.valueForKey("delivery_status") == nil) ? nil : offerDict.valueForKey("delivery_status") as? String
        }
        if dictionary.objectForKey("unread_messages") != nil {
            if let unreadMsg = dictionary.valueForKey("unread_messages") as? String{
                self.unreadMessageCount = Int(unreadMsg)
            }else{
                self.unreadMessageCount = 0
            }
        } else {
            self.unreadMessageCount = 0
        }
    }

    
    
   
}
