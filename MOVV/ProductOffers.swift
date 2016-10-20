//
//  ProductOffers.swift
//  MOVV
//
//  Created by Vineet Choudhary on 23/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

enum DeliveryOption:String {
    case MeetInPerson = "meet_in_person"
    case Ship = "ship"
}

class ProductOffer: NSObject {
    var offerId:String!
    var buyerId:String!
    var sellerId:String!
    var offerPrice:String!
    var offerUserFullName:String!
    var offerUserProfileImage:String!
    var offerDeliveryOption:DeliveryOption!
    
    init(serverResponse:NSDictionary) {

        print(serverResponse)
        self.offerId = (serverResponse.valueForKey("id") == nil) ? nil : serverResponse.valueForKey("id") as? String
        self.buyerId = (serverResponse.valueForKey("buyer_id") == nil) ? nil : serverResponse.valueForKey("buyer_id") as? String
        self.sellerId = (serverResponse.valueForKey("seller_id") == nil) ? nil : serverResponse.valueForKey("seller_id") as? String
        self.offerPrice = (serverResponse.valueForKey("offer_price") == nil) ? nil : serverResponse.valueForKey("offer_price") as? String
        self.offerUserFullName = (serverResponse.valueForKey("user_full_name") == nil) ? nil : serverResponse.valueForKey("user_full_name") as? String
        self.offerUserProfileImage = (serverResponse.valueForKey("user_profile_image") == nil) ? nil : serverResponse.valueForKey("user_profile_image") as? String
        self.offerDeliveryOption = DeliveryOption(rawValue:serverResponse.valueForKey("delivery_option") as! String)
    }
}


class ProductOffers: NSObject {
    var productName:String!
    var productPrice:String!
    var productImage:String!
    var productOffers:NSMutableArray! = NSMutableArray()
    
    init(serverResponse:NSDictionary) {
        super.init()
        let products = (serverResponse.valueForKey("product") as! NSArray)
        if products.count > 0 {
            let product = (serverResponse.valueForKey("product") as! NSArray).firstObject as! NSDictionary
            self.productName = (product.valueForKey("name") == nil) ? nil : product.valueForKey("name") as! String
            self.productPrice = (product.valueForKey("price") == nil) ? nil : product.valueForKey("price") as! String
            self.productImage = (product.valueForKey("preview_image") == nil) ? nil : product.valueForKey("preview_image") as! String
            let offers:NSArray = product.valueForKey("offers") as! NSArray
            offers.enumerateObjectsUsingBlock({ (offerObj, idx, stop) in
                let productOffer:ProductOffer = ProductOffer.init(serverResponse: offerObj as! NSDictionary)
                self.productOffers.addObject(productOffer)
            })
        }
    }
}
