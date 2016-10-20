//
//  MVMessageTopic.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 24.08.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

enum MVMessageType : String {
    case Text = "text"
    case MeetInPerson = "meet_in_person"
    case ConfirmMeet = "confirm_meet"
    case DeclineMeet = "decline_meet"
    case ShippingCode = "shipping_code"
    case PinInput = "pin_input"
    case MovvPinCode = "movv_pin_code"
    case PinOK = "pin_ok"
    case ConfirmShipping = "confirm_shipping"
    case TrackingCode = "tracking_code"
    case EnterTrackingCode = "enter_tracking_code"
    case Review = "review"
    case ReviewScore = "review_score"
    case ReviewResult = "review_result"
    case MovvInstruction = "movv_instruction"
    case Ship = "ship"
    case KeepReturn = "keep_return"
    case ItemKeep = "item_keep"
    case ItemReturn = "item_return"
}



class MVMessageDetails: NSObject {
    
    var id :  Int!
    var message : String!
    var messageType : MVMessageType!
    var sentDate : String!
//    var numMessages : Int!
    var sentFromUser : MVUser!
    var sentToUser : MVUser!
    
    
    init(dictionary:NSDictionary)
    {
        self.id = dictionary.objectForKey("id") != nil ? (dictionary.valueForKey("id") as! NSString).integerValue : 0
        self.message = dictionary.objectForKey("message") != nil  ? dictionary.valueForKey("message") as! String : ""
        self.messageType = MVMessageType(rawValue: dictionary.valueForKey("message_type") as! String)
//        self.numMessages = dictionary.objectForKey("num_messages") != nil ? (dictionary.valueForKey("num_messages") as! Int) : 0
        self.sentDate = dictionary.objectForKey("sent_date") != nil  ? dictionary.valueForKey("sent_date") as! String : ""
        self.sentFromUser = MVUser(dictionary: dictionary.valueForKey("sent_from") as! NSDictionary)
        self.sentToUser = MVUser(dictionary: dictionary.valueForKey("sent_to") as! NSDictionary)
        

    }
   
}
