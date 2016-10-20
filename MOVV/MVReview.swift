//
//  MVReview.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 10.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

class MVReview: NSObject {
    
    var id :  Int!
    var rating : Int!
    var comment : String!

    init(dictionary:NSDictionary)
    {
        self.id = dictionary.objectForKey("id") != nil ? (dictionary.valueForKey("id") as! NSString).integerValue : 0
        self.rating = dictionary.objectForKey("rating") != nil ? (dictionary.valueForKey("rating") as! NSString).integerValue : 0
        self.comment = dictionary.objectForKey("review") != nil  ? dictionary.valueForKey("review") as! String : ""
    }
   
}
