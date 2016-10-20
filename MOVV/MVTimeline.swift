//
//  MVTimeline.swift
//  MOVV
//
//  Created by Hrvoje Gasparovic on 01/09/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

enum MVTimelineAction:String{
    case Comment = "comment"
    case Like = "like"
}

class MVTimeline: NSObject {

    var action:MVTimelineAction!
    var actionUser:MVUser!
    var product:MVProduct!
    var timestamp:String!
    
    init(dictionary:NSDictionary){
        self.action = MVTimelineAction(rawValue: dictionary.valueForKey("action") as! String)
        self.actionUser =  dictionary.valueForKey("action_user") != nil ? MVUser(dictionary: dictionary.valueForKey("action_user") as! NSDictionary) : nil
        self.product = dictionary.valueForKey("product") != nil ? MVProduct(dictionary: dictionary.valueForKey("product") as! NSDictionary) : nil
        self.timestamp = dictionary.valueForKey("timestamp") != nil ? dictionary.valueForKey("timestamp") as! String: ""
    }
}
