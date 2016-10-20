//
//  MVDataManager.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 05.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc class MVDataManager: NSObject {
    

    typealias SuccessBlock = (AnyObject!) -> Void
    typealias FailureBlock = (AnyObject!) -> Void
    
    
    //MARK: user-login
    class func getUserLoginData(username : String, password : String, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
//        if(MVHelper.isNetworkAvailable()){
        let request : String! = "user-login"
        let parameters :  NSDictionary! = ["username":"\(username)","password":"\(password)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
             
            let statusMessage : NSString! = resultDictionary["message"] as! NSString!
            
            let userArray : NSArray = resultDictionary["user"] as! NSArray
//            println(userArray)

            if (userArray.count > 0) {
                let userDictionary : NSDictionary! = (resultDictionary["user"] as! NSArray).firstObject as! NSDictionary
                let user : MVUser! = MVUser(dictionary: userDictionary)
                successBlock(user as AnyObject)

            } else {
                
                failureBlock(statusMessage)

            }
        }) { failure in
            
            failureBlock(failure)
            
        }
//        } else {
//            
//        }
        
    }
    
    //MARK: home-feed
    class func getHomeScreenData(successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "home-feed"
        
        let screenBounds : CGRect = UIScreen.mainScreen().bounds
        let screenWidth : CGFloat = screenBounds.width
        
        var thumbSize : String!
        if(screenWidth == 375)
        {
            thumbSize = "800x800"
        }
        else if(screenWidth == 320)
        {
            thumbSize = "700x800"
        }
        else
        {
            thumbSize = "880x800"
        }
        
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "thumb":"\(thumbSize)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            
//            println(response)
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
            
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for dict in productsArray
            {
                let product : MVProduct = MVProduct(dictionary: dict as! NSDictionary)
                returnArray.addObject(product)
            }

            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-register
    class func registerNewUser(email : String, password : String, username : String, firstName : String, lastName : String, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-register"
        let parameters :  NSDictionary! = ["email":"\(email)", "password":"\(password)", "username":"\(username)", "first_name":"\(firstName)", "last_name":"\(lastName)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            successBlock(resultDictionary)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-auto-location
    class func userAutoLocation(userID : Int!, latitude : Double!, longitude : Double!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-auto-location"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "geo_lat":"\(latitude)", "geo_long":"\(longitude)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            successBlock(resultDictionary)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: facebook-login
    class func facebookLogin(firstName : String, lastName : String, email : String, facebookToken : String, facebookID : Int, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "facebook-login"
        let parameters :  NSDictionary! = ["first_name":"\(firstName)", "last_name":"\(lastName)", "email":"\(email)", "facebook_token":"\(facebookToken)", "facebook_id":"\(facebookID)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            successBlock(resultDictionary)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: product-like
    class func likeProduct(productID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "product-like"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "product_id":"\(productID)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!
            
            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: product-comment
    class func commentProduct(productID : Int!, comment : String!, mentionedUser : [AnyObject], successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "product-comment"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "product_id":"\(productID)", "comment":"\(comment)","mentions":mentionedUser]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!
            
            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: product-comments
    class func getProductComments(productID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "product-comments"
        let parameters :  NSDictionary! = ["product_id":"\(productID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            
            print(resultDictionary)
            var commentsDictArray : NSArray! = resultDictionary["comments"] as! NSArray!
            
            commentsDictArray = commentsDictArray.reverse() as NSArray
            
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for i : Int in 0 ..< commentsDictArray.count
            {
                let user : MVComment! = MVComment(dictionary: commentsDictArray[i] as! NSDictionary)
                returnArray.addObject(user)
            }
            
            successBlock(returnArray)
            
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    
    //MARK: user-profile
    class func getUserProfile(userID : Int!, currentUserID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-profile"
        var parameters :  NSDictionary! 
        
        if (currentUserID == 0)
        {
            parameters = ["user_id":"\(userID)", "thumb":"640x0"]
        }
        else
        {
            parameters = ["user_id":"\(userID)", "current_user_id":"\(currentUserID)", "thumb":"800x800"]
        }
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
//            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
//
//            println(resultDictionary)
            
            let userProfile : MVUserProfile = MVUserProfile(dictionary: response as! NSDictionary)

            successBlock(userProfile)

            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-follow
    class func followUser(personID: Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-follow"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "person_id":"\(personID)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!

            
            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-unfollow
    class func unfollowUser(personID: Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-unfollow"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "person_id":"\(personID)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!
            
//            println(response)
            
            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-followers
    class func getUserFollowers(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-followers"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            
            let usersDictArray : NSArray! = resultDictionary["users"] as! NSArray!
            let returnArray : NSMutableArray! = NSMutableArray()
            
//            println(usersDictArray)
            
            for i : Int in 0 ..< usersDictArray.count
            {
                let user : MVUser! = MVUser(dictionary: usersDictArray[i] as! NSDictionary)
                returnArray.addObject(user)
            }

            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }


    //MARK: user-following
    class func getUserFollowing(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-following"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            
            let usersDictArray : NSArray! = resultDictionary["users"] as! NSArray!

            let returnArray : NSMutableArray! = NSMutableArray()
            
//            println(usersDictArray)
            
            for i : Int in 0 ..< usersDictArray.count
            {
                let user : MVUser! = MVUser(dictionary: usersDictArray[i] as! NSDictionary)
                returnArray.addObject(user)
            }
           
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-reviews
    class func getUserReviews(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-reviews"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            
            let reviewsDictArray : NSArray! = resultDictionary["reviews"] as! NSArray!
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for i : Int in 0 ..< reviewsDictArray.count
            {
                let review : MVReview! = MVReview(dictionary: reviewsDictArray[i] as! NSDictionary)
                returnArray.addObject(review)
            }
            
            successBlock(returnArray)

            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    
    //MARK: liked-users
    class func getLikedUsers(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "product-likes"
        let parameters : NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let reviewsDictArray : NSArray! = resultDictionary["likeduser"] as! NSArray!
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for i : Int in 0 ..< reviewsDictArray.count
            {
                let review : MVReview! = MVReview(dictionary: reviewsDictArray[i] as! NSDictionary)
                returnArray.addObject(review)
            }
            
            successBlock(returnArray)
            
            
        }) { failure in
            
            failureBlock(failure)
        }
        
    }
    
    
    //MARK: user-selling
    class func getUserSellingProducts(userProfile : MVUserProfile!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-selling"
        let parameters :  NSDictionary! = ["user_id":"\(userProfile.id)", "thumb":"640x0"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
            
            let emptyDictionary : NSMutableDictionary = NSMutableDictionary()
            emptyDictionary.setValue(0, forKey: "id")
            let user : MVUser! = MVUser(dictionary: emptyDictionary)
            user.username = userProfile.username
            user.id = userProfile.id
            user.location = userProfile.location
            user.profileImage = userProfile.profileImage
            
            
            let returnArray : NSMutableArray! = NSMutableArray()
            
//            println(response)
            
            for dict in productsArray
            {
                let product : MVProduct = MVProduct(dictionary: dict as! NSDictionary)
                product.user = user
                returnArray.addObject(product)
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-bought
    class func getUserBoughtProducts(userProfile : MVUserProfile!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-bought"
        let parameters :  NSDictionary! = ["user_id":"\(userProfile.id)", "thumb":"128x128"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
            
//            var emptyDictionary : NSMutableDictionary = NSMutableDictionary()

            let returnArray : NSMutableArray! = NSMutableArray()

            print(response)

            if(productsArray.count > 0)
            {
                for i :Int in 0 ..< productsArray.count
                {
                    let actionProduct : MVActionProduct = MVActionProduct(dictionary: productsArray[i]  as! NSDictionary)
                    returnArray.addObject(actionProduct)
                }
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-sold
    class func getUserSoldProducts(userProfile : MVUserProfile!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-sold"
        let parameters :  NSDictionary! = ["user_id":"\(userProfile.id)", "thumb":"128x128"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
//            var emptyDictionary : NSMutableDictionary = NSMutableDictionary()
            let returnArray : NSMutableArray! = NSMutableArray()

            if(productsArray.count > 0)
            {
                for i :Int in 0 ..< productsArray.count
                {
                    let actionProduct : MVActionProduct = MVActionProduct(dictionary: productsArray[i]  as! NSDictionary)
                    returnArray.addObject(actionProduct)
                }
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: search-products
    class func searchProducts(userID : Int!, searchQuery : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "search-products"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "q":"\(searchQuery)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
            
            let returnArray : NSMutableArray! = NSMutableArray()
            
//            println(productsArray)
            
            for dict in productsArray
            {
                let product : MVProduct = MVProduct(dictionary: dict as! NSDictionary)
                returnArray.addObject(product)
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure!)
        }
    }
    
    //MARK: search-people
    class func searchPeople(userID : Int!, searchQuery : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "search-people"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "q":"\(searchQuery)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let usersArray : NSArray = resultDictionary["users"] as! NSArray
            
//            print(usersArray)

            let returnArray : NSMutableArray! = NSMutableArray()
            
            for dict in usersArray
            {
                let product : MVUser = MVUser(dictionary: dict as! NSDictionary)
                returnArray.addObject(product)
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: explore-people
    class func explorePeople(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "explore-people"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let usersArray : NSArray = resultDictionary["users"] as! NSArray
            
            print(usersArray)
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for dict in usersArray
            {
                let user : MVUser = MVUser(dictionary: dict as! NSDictionary)
                returnArray.addObject(user)
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    
    //MARK: explore-products
    class func exploreProducts(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "explore-products"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
            
//            print(productsArray)
            
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for dict in productsArray
            {
                let product : MVProduct = MVProduct(dictionary: dict as! NSDictionary)
                returnArray.addObject(product)
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }

    //MARK: news-you
    class func getNewsYou(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "news-you"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            print(response)
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let newsArray : NSArray = resultDictionary["news"] as! NSArray
            
            
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for dict in newsArray
            {
                let news : MVNews = MVNews(dictionary: dict as! NSDictionary)
                returnArray.addObject(news)
            }

            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: news-following
    class func getNewsFollowing(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "news-following"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
//            print(response)
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let newsArray : NSArray = resultDictionary["news"] as! NSArray
            
            let returnArray : NSMutableArray! = NSMutableArray()
            
//            println("newsFollowingArray \(resultDictionary)")

            for dict in newsArray
            {
                let news : MVNews = MVNews(dictionary: dict as! NSDictionary)

                returnArray.addObject(news)
            }
            
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: user-address
    class func getUserAddress(userID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-address"
        let parameters :  NSDictionary! = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString! = resultDictionary["message"] as! NSString!
            let addressDict : NSDictionary = resultDictionary["address"] as! NSDictionary

            let address : MVUserAddress = MVUserAddress(dictionary: addressDict)

            successBlock(address)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: update-user-address
    class func updateUserAddress(userID : Int!, street : String!, postalCode : Int!, city : String!, country : String!, state : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "update-user-address"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "street":"\(street)", "postal_code":"\(postalCode)", "city":"\(city)", "country":"\(country)", "state":"\(state)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!

            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    
    
    //MARK: upload-product
    
//    latitude and longitude not user provided, should be collected automatically it should come in a standard latitude/longitude format.
//    preview_image should be uploaded to an S3 bucket called “movv.video-­thumbs”. Example: “faffewe2314423jfa.jpg”
//    video_file should be uploaded to an S3 bucket called “movv.user­-videos”. Example: “faffewe2314423jfa.mov”

    class func uploadProduct(userID : Int!, productName : String!, price : Int!, quantity : Int!, latitude : Double!, longitude : Double!, previewImage : String!, videoFile : String!, tags : String!, parcelSizeId : String!, categoryId : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "upload-product"
        let parameters :  NSDictionary! = ["user_id":"\(userID)" , "name":"\(productName)", "price":"\(price)", "quantity":"\(quantity)", "lat":"\(latitude)", "long":"\(longitude)", "preview_image":"\(previewImage)", "video_file":"\(videoFile)", "tags":"\(tags)", "parcel_size_id":"\(parcelSizeId)", "category_id":"\(categoryId)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let shareUrl : NSString! = resultDictionary["share_url"] as! NSString!
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.mixpanel?.track("Video", properties: ["item" : productName])
            
            successBlock(shareUrl)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    
    //MARK: update-user-cover-image
    
//    The image should be uploaded from the
//    APP to Amazon S3 using the given credentials. The imageName should start with
//    “cover_” and should be 15 characters long, only lowercase letters and numbers. The
//    imageName should also has the extension in the name, preferably JPG.
//    Example: “cover_fdsf342kjf5m9r3t.jpg”
    
    class func updateUserCoverImage(userID : Int!, imageName : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!) {
        let request : String! = "update-user-cover-image"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "cover_image":"\(imageName)" ]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!

            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    /// Gets unread messages for wanted user
    class func getUnreadMessagesForLoggedUser(successBlock: ((String) -> Void), failureBlock: FailureBlock!) {
        let request : String! = "user-unread-messages"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let messageCount : Int = resultDictionary["num_messages"] as! Int
            
            successBlock("\(messageCount)")
            
            }) { failure in
                
                failureBlock(failure)
        }
    }

    
    //MARK: update-user-profile-image
    
    //    The image should be uploaded from the
    //    APP to Amazon S3 using the given credentials. The imageName should start with
    //    “profile_” and should be 15 characters long, only lowercase letters and numbers. The
    //    imageName should also has the extension in the name, preferably JPG.
    //    Example: “profile_fdsf342kjf5m9r3t.jpg”
    
    class func updateUserProfileImage(userID : Int!, imageName : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "update-user-profile-image"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "profile_image":"\(imageName)" ]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!
            
            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: update-user-password
    class func updateUserPassword(userID : Int!, oldPassword : String!, newPassword : String!, confirmNewPassword : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "update-user-password"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "old_password":"\(oldPassword)", "new_password":"\(newPassword)", "confirm_new_password":"\(confirmNewPassword)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!
            
            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: stripe­-add-­user-­tokens
    class func stripeAddUserPublishableKey(userID : Int!, publishableKey : String!, accessToken : String!, stripeUserID : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-add-stripe-tokens"
        let parameters :  NSDictionary! = ["user_id":"\(userID)", "publishable_key":"\(publishableKey)", "access_token":"\(accessToken)", "stripe_user_id":"\(stripeUserID)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!
            
            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: product-buy
//    class func productBuy(buyerID : Int!, productID : Int!, paidPrice : Int!, stripeToken : STPToken!, deliveryOption : String!, discountCode : String! ,successBlock: SuccessBlock!, failureBlock: FailureBlock!)
//    {
//        let request : String! = "product-buy"
//        let parameters :  NSDictionary! = ["buyer_id":"\(buyerID)", "product_id":"\(productID)", "paid_price":"\(paidPrice)", "stripe_token":"\(stripeToken)", "delivery_option":"\(deliveryOption)", "discount_code":"\(discountCode)"]
//        
//        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
//            
//            let resultDictionary : NSDictionary! = response as! NSDictionary
////            var status : NSString! = resultDictionary["status"] as! NSString!
//            
//
////                var message : NSString! = resultDictionary["message"] as! NSString!
////                var topicID : Int! = resultDictionary["topic_id"] as! Int
//                successBlock(resultDictionary)
//
//            
//            }) { failure in
//                
//                failureBlock(failure)
//        }
//    }
    
    //MARK: user-validate-stripe
    @objc class func userValidateStripe(successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String!           = "user-validate-stripe"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)"]

        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString!              = resultDictionary["message"] as! NSString!

            successBlock(resultDictionary)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    class func userMessages(successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String!           = "user-messages"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)"]

        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
//            var message : NSString!              = resultDictionary["message"] as! NSString!
            let messageArray : NSArray           = resultDictionary["topics"] as! NSArray
            let returnArray : NSMutableArray!    = NSMutableArray()
            
            for dict in messageArray
            {
                let message : MVMessage = MVMessage(dictionary: dict as! NSDictionary)
                
                returnArray.addObject(message)
            }
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: message-topic
    class func getMessageTopic(topicID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String!           = "message-topic"
        let parameters :  NSDictionary! = ["topic_id" : "\(topicID)", "user_id":"\(MVParameters.sharedInstance.currentMVUser.id)"]

        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            print(resultDictionary)

//            var message : NSString!      = resultDictionary["message"] as! NSString!
            let messagesArray : NSArray! = resultDictionary["messages"] as! NSArray!
            let returnArray : NSMutableArray! = NSMutableArray()
            
            for dict in messagesArray
            {
                let messages : MVMessageDetails = MVMessageDetails(dictionary: dict as! NSDictionary)
                
                returnArray.addObject(messages)
            }
            successBlock(returnArray)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: send-message
    class func sendMessage(userID : Int!, topicID : Int!, message : String!, messageType : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String!           = "send-message"
        let parameters :  NSDictionary! = [ "user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "topic_id" : "\(topicID)", "message" : "\(message)", "message_type":"\(messageType)"]

        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in

            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString!              = resultDictionary["message"] as! NSString!
            
            print(message)

            successBlock(message)
            
            }) { failure in
                
                 print(failure)
                failureBlock(failure)
               
        }
    }
    
    //MARK: user-add-push-token
    class func registerForNotifications(userID : Int!, token : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String!           = "user-add-push-token"
        let parameters :  NSDictionary! = [ "user_id":"\(userID)", "token" : "\(token)"]

        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in

            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString!              = resultDictionary["message"] as! NSString!

            successBlock(message)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    
    //MARK: facebook-check
    class func facebookCheck(email : String, facebookID : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!) {
        let request : String! = "facebook-check"
        let parameters :  NSDictionary! = ["email":"\(email)", "facebook_id":"\(facebookID)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            successBlock(resultDictionary)
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: facebook-register
    class func facebookRegister(firstName : String, lastName : String, email : String, facebookToken : String, facebookID : String, username : String,  invitationCode : String,  successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "facebook-register"
        let parameters :  NSDictionary! = ["first_name":"\(firstName)", "last_name":"\(lastName)", "email":"\(email)", "facebook_token":"\(facebookToken)", "facebook_id":"\(facebookID)", "username":"\(username)", "login_code":"\(invitationCode)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let status : Int = (resultDictionary["status"] as! NSString).integerValue
            print(status)
            if(status == 0)
            {
                failureBlock(resultDictionary["message"] as! NSString)
            }
            else
            {
                successBlock(resultDictionary)
            }
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: venmo-connect
    class func venmoConnect(venmoUserID : String, accessToken : String, refreshToken : String, expiresIn : NSDate,  successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-add-venmo-tokens"
        let parameters :  NSDictionary! = [ "user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "venmo_user_id":"\(venmoUserID)", "venmo_access_token":"\(accessToken)", "venmo_refresh_token":"\(refreshToken)", "venmo_expires_in":"\(expiresIn)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let status : Int = (resultDictionary["status"] as! NSString).integerValue
            if(status == 0)
            {
                failureBlock(resultDictionary["message"] as! NSString)
            }
            else
            {
                successBlock(resultDictionary["message"] as! NSString)
            }
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: venmo-validate
    class func venmoValidate(successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-validate-venmo"
        let parameters :  NSDictionary! = [ "user_id":"\(MVParameters.sharedInstance.currentMVUser.id)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let status : Int = (resultDictionary["status"] as! NSString).integerValue
            if(status == 0)
            {
                failureBlock(resultDictionary["message"] as! NSString)
            }
            else
            {
                successBlock(resultDictionary["message"] as! NSString)
            }
            
            }) { failure in
                
                failureBlock(failure)
        }
    }
    
    //MARK: product-buy-venmo
    class func productBuyVenmo(buyerID : Int!, productID : Int!, paidPrice : Int!, deliveryOption : String!, nonce: String!, successBlock: ((_ json: JSON)->Void), failureBlock: ((error: NSError)->Void))
    {
        let request : String! = "product-buy"
        let parameters :  NSDictionary! = ["buyer_id":"\(buyerID)", "product_id":"\(productID)", "paid_price":"\(paidPrice)", "delivery_option":"\(deliveryOption)", "nonce": nonce]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let json = JSON(response)
            
            if json["status"].boolValue == true {
                successBlock(json: json)
            } else {
                failureBlock(error: NSError(domain: "CustomSetDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: json["message"].stringValue]))
            }
            
            
        }) { failure in
            
            failureBlock(error: NSError(domain: "CustomSetDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: failure]))
        }
    }
    
    // added
    
    //MARK: merchantaccount
    class func updateMerchantAccount(data: [String: String], successBlock: SuccessBlock!, failureBlock: FailureBlock!)
        //    class func updateUserPassword(userID : Int!, oldPassword : String!, newPassword : String!, confirmNewPassword : String!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "user-add-merchant-account"
        
        MVSyncManager.getDataFromServerUsingPOST(data, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let message : NSString! = resultDictionary["message"] as! NSString!
            
            successBlock(message)
            
        }) { failure in
            
            failureBlock(failure)
        }
    }

    class func getMerchantInfo(successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String!           = "user-merchant-account"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)"]
        
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            
            let resultDictionary : NSDictionary! = response as! NSDictionary
            //            var message : NSString!              = resultDictionary["message"] as! NSString!
            
            successBlock(resultDictionary)
            
        }) { failure in
            
            failureBlock(failure)
        }
    }
    
    class func generateVenmoToken(userID: Int, successBlock: ((_ json: JSON)->Void), failureBlock: ((errorString: String)-> Void)) {
        // http://api.mymov.co/generate-venmo-token/
        let request : String! = "generate-venmo-token"
        let parameters = ["user_id":"\(userID)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            
            let json = JSON(response)
            if json["status"].intValue == 1 {
                successBlock(json: json)
            } else {
                failureBlock(errorString: json["message"].stringValue)
            }
            
        }) { failure in
            
            failureBlock(errorString: failure)
        }
    }
 
    
    class func fetchProduct(productId : String, successBlock: ((MVProduct) -> Void), failureBlock: FailureBlock!)
    {
        
        let request: String = "product"
        let params: [String: String] = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "product_id": "\(productId)"]
        
        MVSyncManager.getDataFromServerUsingGET(params, request: request, successBlock: { response in
            print(response)
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let productsArray : NSArray = resultDictionary["product"] as! NSArray
            if productsArray.count > 0 {
                successBlock (MVProduct(dictionary: productsArray[0] as! NSDictionary))
            } else {
                failureBlock("Unable to initialize given product")
            }
            
        }) { failure in
            
            failureBlock(failure)
        }
    }

    //MARK: Product Likes
    class func getProductLikes(productID : Int!, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let request : String! = "product-likes/"
        let parameters :  NSDictionary! = ["product_id":"\(productID)"]

        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in

            let resultDictionary = response as! NSDictionary
            successBlock(resultDictionary)

        }) { failure in

            failureBlock(failure)
        }
    }

    
}


   

