//
//  MVUserAddress.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 23.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

class MVUserAddress: NSObject {
    
    var street :  String!
    var city : String!
    var postalCode : Int!
    var state : String!
    var country : String!
    var number : String!
    
    init(dictionary:NSDictionary)
    {
        self.street = dictionary.objectForKey("street") != nil ? dictionary.valueForKey("street") as! String : ""
        self.city =  dictionary.objectForKey("city") != nil ? dictionary.valueForKey("city") as! String : ""
        self.postalCode = dictionary.objectForKey("postal_code") != nil ? (dictionary.valueForKey("postal_code") as! NSString).integerValue : 0
        self.state =  dictionary.objectForKey("state") != nil ? dictionary.valueForKey("state") as! String : ""
        self.country = dictionary.objectForKey("country") != nil ? dictionary.valueForKey("country") as! String : ""
        self.number = dictionary.objectForKey("phone_number") != nil ? dictionary.valueForKey("phone_number") as! String : ""
    }

   
}
