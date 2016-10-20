//
//  MVHelper.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 05.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

class MVHelper: NSObject {
    
    var cameraPresented = false
    var cameraRecording = false
    var enteredApp = false
    var shouldAutorotate:Bool = false
    
    class var sharedInstance: MVHelper {
        struct Static {
            static var instance: MVHelper?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = MVHelper()
        }
        return Static.instance!
    }

    
    
    class func getImageFromURL(imageString : String) -> UIImage
    {
        let url:NSURL? = NSURL(string: imageString)
        let data:NSData? = NSData(contentsOfURL : url!)

        if (data != nil)
        {
            let image = UIImage(data : data!)
            if(image != nil)
            {
                return image!
            }
            else
            {
                let image : UIImage = UIImage(named: "main_product_placeholder small")!
                return image
            }
        }
        else
        {
            let image : UIImage = UIImage(named: "main_product_placeholder small")!
            return image
        }
    }
    
    
    
    
    class func addMOVVCornerRadiusToView(squareView:UIView){
        squareView.layer.cornerRadius = CGRectGetHeight(squareView.frame)/2
        squareView.layer.borderColor = MOVVGreen.CGColor
        squareView.layer.borderWidth = 2
        squareView.clipsToBounds = true
    }
    
    
   class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func isNetworkAvailable()->Bool{
        var networkStatus:Bool = false
        let url = NSURL(string: "http://dev.flip.hr/movv/api/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        let response: NSURLResponse? = nil
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                networkStatus = true
            }
        }
        return networkStatus
    }
    
    class func showAlertWithMessageAndTitle(message:String, title:String) {
        let alert = MOVVAlertViewController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(alertAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func showCommonErrorAlert(){
        let alert:UIAlertController = UIAlertController.init(title: "", message:"Something goes wrong. Please try again."  as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in});
        UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(alert, animated: true, completion: {})
    }
    
    class func getGIFForVideoURL(urlString:String){
        let memoryCache = NSCache()
        memoryCache.name = "VideoCache"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { 
            let url = NSURL(string: urlString)
            let downloadedData = NSData.init(contentsOfURL: url!)
            if downloadedData != nil{
                let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
                let file = cachesDirectory.stringByAppendingString("/\(urlString)")
                downloadedData!.writeToFile(file, atomically: true)
                memoryCache.setObject(downloadedData!, forKey: urlString)
            }
        }
    }
    
    
   class func addBlurEffectToNavbar(navBar:UINavigationBar?) {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        
        visualEffectView.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView.userInteractionEnabled = true
        
        navBar!.subviews[0].addSubview(visualEffectView)
    }
    
    class func generateIdentifierWithLength(len:Int)->String{
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789" as NSString
        let randomString = NSMutableString(capacity: len)
        
        for _ in 0 ..< len {
            randomString.appendFormat("%C", letters.characterAtIndex(Int( arc4random_uniform(UInt32(letters.length)))))
        }
        
        return randomString as String
    }
   
   class func saveFileToDocumentsDirectoryWithNameAndExtension(file:AnyObject,filename:String, ext:String)->String{
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let writePath = documents.stringByAppendingString(filename + "." + ext)
    
    if(file.isKindOfClass(UIImage)){
        let imageData = UIImageJPEGRepresentation(file as! UIImage, 0.2)
        imageData!.writeToFile(writePath, atomically: false)
    }
    
        return writePath
    }
    
    // MARK: Label size calculation
    class func heightForText(text:NSString, forFont font:UIFont, andWidth width:CGFloat) -> CGFloat {
        
        let constraint:CGSize = CGSizeMake(width, 20000.0)
        let boundingBox:CGSize = text.boundingRectWithSize(constraint, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        
        return CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height)).height
    }
    

    
}
