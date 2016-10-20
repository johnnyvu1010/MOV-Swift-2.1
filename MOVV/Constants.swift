/*
* Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit
import Foundation
import AWSS3

//WARNING: To run this sample correctly, you must set the following constants.
let CognitoRegionType = AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.USEast1
let CognitoIdentityPoolId: String = "us-east-1:4b773b53-2feb-4e9f-9f30-4a0fa6cf2bfd"

//let S3BucketName: String = "movv.user-videos"
let S3DownloadKeyName: String = "YourDownloadKeyName"

//let S3UploadKeyName: String = "test.txt"

let BackgroundSessionUploadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.uploadSession"
let BackgroundSessionDownloadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.downloadSession"

let movDeviceToken: String = "MOVtoken"

extension UIColor {

    class func greenAppColor() -> UIColor {
        return UIColor(red: 57/255, green: 165/255, blue: 53/255, alpha: 1)
    }
}

extension UIImage{
    func resizeImageInAspectRatio(maxDimension:CGFloat) -> UIImage {
        let size = self.size
        var newWidth = size.width
        var newHeight = size.height

        if size.width > size.height && size.width > maxDimension{
            newWidth = maxDimension
            newHeight = newWidth * (size.height/size.width)
        }else if size.height > maxDimension{
            newHeight = maxDimension
            newWidth = newHeight * (size.width/size.height)
        }else{
            return self
        }

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.drawInRect(CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
let MOVVGreen = UIColor(red: 57/255, green: 165/255, blue: 53/255, alpha: 1)

let cellIdentitfiers = ["previewCell", "titleCell", "brandCell", "categoryCell", "priceCell", "tagsCell", "tagsTitleCell", "shippingOptionsCell" , "postCell"]

enum AlertTitle : String {
    case Warning = "Warning"
    case Error = "Error"
    case Info = "Info"
}

enum ProductTags : String {
    case Men = "Men"
    case Women = "Women"
    case Clothes = "Clothes"
    case Technology = "Technology"
    case Education = "Education"
    case Sport = "Sport"
    case Furniture = "Furniture"
    case Art = "Art"
    
    static let allValues = [Men, Women, Clothes, Technology,Education, Sport,Furniture, Art]
    
}


enum ProductCategory : Int {
    case All = 0
    case Animals = 1
    case Books = 2
    case Clothes = 3
    case Furniture = 4
    case Home = 5
    case Music = 6
    case Sports = 7
    case Technology = 8
    case Other = 9
    case Transportation = 10
    
    var stringValue : String!{
        switch self {
        case .All:
            return "All"
        case .Animals:
            return "Animals"
        case .Books:
            return "Books"
        case .Clothes:
            return "Clothes"
        case .Furniture:
            return "Furniture"
        case .Home:
            return "Home"
        case .Music:
            return "Music"
        case .Sports:
            return "Sports"
        case .Technology:
            return "Technology"
        case .Other:
            return "Other"
        case .Transportation:
            return "Transportation"
        }
    }
    
    static let allCategories = [All, Animals, Books, Clothes, Furniture, Home, Music, Sports, Technology, Transportation, Other]
    static let categories = [Animals, Books, Clothes, Furniture, Home, Music, Sports, Technology, Transportation, Other]
}


enum EditProductFieldType : Int
{
    case Title = 0
    case Category = 1
    case Tags = 2

    var errorMsg : String!
    {
        switch self
        {
            case .Title:
                return "Title is required."
            
            case .Category:
                return "Category is required."
            
            case .Tags:
                return "Tags is required."
        }
    }
    
    var desc : String!
    {
        switch self
        {
            case .Title:
                return "Title"
            
            case .Category:
                return "Category"
            
            case .Tags:
                return "Tags"
        }
    }
}


let showTabbarNotification:NSNotification = NSNotification(name: "showTabbar", object: nil)
let hideTabbarNotification:NSNotification = NSNotification(name: "hideTabbar", object: nil)
let enableScreenRotation:NSNotification = NSNotification(name: "enableScreenRotation", object: nil)
let disableScreenRotation:NSNotification = NSNotification(name: "enableScreenRotation", object: nil)

let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(13)]
let boldedFont = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor()]
let normalFont = [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.lightGrayColor()]
let lineSpacing = NSMutableParagraphStyle()