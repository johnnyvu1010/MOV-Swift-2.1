//
//  MVProduct.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 06.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit
import SwiftyJSON

class MVProduct: NSObject {
    
    var id :  Int!
    var name : String!
    var numComments : Int!
    var numLikes : Int!
    var previewImage: String!
    var price: Int!
    var uploadDate: String!
    var purchaseDate: String!
    var videoFile: String!
    var tags: String!
    var isLiked : Bool!
    var user : MVUser!
    var shareLink:String!
    var isSold:Int!
    var topicId:String!
    var categoryId:String!
    var parcelSizeId :String!
    init(dictionary:NSDictionary) {
        super.init()
        self.setParamsWithDict(dictionary as! [String : AnyObject])
    }

    init(initWithProductId productId: String) {
        // TODO: Api call to get product data
    }
    
    private func setParamsWithDict(dict: [String: AnyObject]) {
        let json = JSON(dict)
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.numComments = json["num_comments"].intValue
        self.numLikes = json["num_likes"].intValue
        self.previewImage = json["preview_image"].stringValue
        self.price = json["price"].intValue
        self.uploadDate = json["upload_date"].stringValue
        self.purchaseDate = json["purchase_date"].stringValue
        self.videoFile = json["video_file"].stringValue
        self.tags = json["tags"].stringValue
        self.isLiked = json["is_liked"].boolValue
        self.isSold = json["is_sold"].intValue
        if let topic = json["topic_id"].string{
            self.topicId = topic
        }else{
            self.topicId = json["offer_id"].stringValue
        }
        self.categoryId = json["category_id"].stringValue
        self.parcelSizeId = json["parcel_size_id"].stringValue
        let userDict = json["user"].dictionaryObject
        if userDict != nil {
            self.user = MVUser(dictionary: userDict!)
        }
        self.shareLink = json["share_url"].stringValue
    }
}
