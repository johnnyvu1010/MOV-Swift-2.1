//
//  MyCartOffers.swift
//  MOVV
//
//  Created by Vineet Choudhary on 22/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MyCartOffers: NSObject {
    var productId:String!
    var offerPrice:String!
    var offerName:String!
    var offerStatus:String!
    var offerImage:String!
    var offerCount:Int!
    var product : MVProduct!
    var unreadMsgCount : NSNumber!
    var offerId:String!
    var offerDeliveryOption:DeliveryOption!
    

    init(serverResponse:NSDictionary) {
        self.product = MVProduct(dictionary: serverResponse )
        self.offerDeliveryOption = (serverResponse.valueForKey("delivery_option") != nil) ? DeliveryOption(rawValue:serverResponse.valueForKey("delivery_option") as! String) : DeliveryOption.MeetInPerson
        self.productId = serverResponse.valueForKey("id") != nil ? serverResponse.valueForKey("id") as? String : nil
        self.offerName = serverResponse.valueForKey("name") != nil ? serverResponse.valueForKey("name") as? String : nil
        self.offerStatus = serverResponse.valueForKey("status") != nil ? serverResponse.valueForKey("status") as? String : nil
        self.offerId = (serverResponse.valueForKey("offer_id") == nil) ? nil : serverResponse.valueForKey("offer_id") as? String
        self.offerPrice = serverResponse.valueForKey("offer_price") != nil ? serverResponse.valueForKey("offer_price") as? String : nil
        if self.offerPrice == nil {
            self.offerPrice = serverResponse.valueForKey("price") != nil ? serverResponse.valueForKey("price") as? String : nil
        }
        self.offerImage = serverResponse.valueForKey("preview_image") != nil ? serverResponse.valueForKey("preview_image") as? String : nil
        self.offerCount = (serverResponse.valueForKey("count") != nil) ? serverResponse.valueForKey("count")?.integerValue : 0
        let count = (serverResponse.valueForKey("unread_message_count") != nil) ? serverResponse.valueForKey("unread_message_count")?.integerValue :0
        self.unreadMsgCount = NSNumber(integer: count!)
    }
}
