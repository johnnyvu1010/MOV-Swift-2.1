//
//  SearchResultTag.swift
//  MOVV
//
//  Created by Vineet Choudhary on 29/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class SearchResultTag: NSObject {
    var count:String!
    var tagName:String!
    init(serverResponse:NSDictionary) {
        self.count = serverResponse.valueForKey("count") != nil ? serverResponse.valueForKey("count") as? String : nil
        self.tagName = serverResponse.valueForKey("tags") != nil ? serverResponse.valueForKey("tags") as? String : nil
    }
}
