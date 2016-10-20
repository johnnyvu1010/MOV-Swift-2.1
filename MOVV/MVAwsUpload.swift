//
//  MVAwsUpload.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 23.07.2015..
//  Copyright (c) 2015. Kresimir Retih. All rights reserved.
//

//      To start upload you should do something like this:
//
//      var uploadVideo : MVAwsUpload = MVAwsUpload()
//      uploadVideo.delegate = self
//      uploadVideo.startUpload(uploadFileURL, bucketName)
//
//      uploadFileURL is NSURL to your video file stored localy on your device!



import UIKit
import AWSS3
import SVProgressHUD

protocol MVAwsUploadDelegate:class
{
    func returnProgress(progress : Float)
    func returnStatus(status : String)
    func uploadCompletedSuccessfully(bucket:Buckets)
    func uploadFailedMisserably()
    func returnProgressAndStatus (progress : Float, status : String)
}

enum Buckets:String{
    case Video = "movv.user-videos"
    case VideoThumb = "movv.video-thumbs"
    case Image = "movv.user-images"
}

class MVAwsUpload: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
    
    var session: NSURLSession?
    var uploadTask: NSURLSessionUploadTask?
    var uploadFileURL: NSURL! = NSURL()
    var S3UploadBucket : Buckets!
    weak var delegate : MVAwsUploadDelegate? = nil

    func startUpload(fileUrl : NSURL, bucketName : Buckets!) {
        self.S3UploadBucket = bucketName
        self.uploadFileURL = fileUrl

        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest.bucket = self.S3UploadBucket.rawValue
        uploadRequest.key =  self.uploadFileURL.lastPathComponent
        uploadRequest.body = self.uploadFileURL
        
        uploadRequest.uploadProgress = { (bytesSent:Int64, totalBytesSent:Int64,  totalBytesExpectedToSend:Int64) -> Void in
            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                print("Upload \(self.S3UploadBucket.rawValue) progress: \(progress)")
                dispatch_async(dispatch_get_main_queue()) {
                    
                    //self.delegate?.returnProgress(progress)
                    if (self.S3UploadBucket == Buckets.Video)
                    {
                        self.delegate?.returnProgressAndStatus(progress, status: "Uploading video...")
                    }
                    else
                    {
                        self.delegate?.returnProgressAndStatus(progress, status: "Uploading image...")
                    }
                }

            })
        }

        let task = transferManager.upload(uploadRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)")
                self.delegate?.uploadFailedMisserably()
                SVProgressHUD.popActivity()
            } else {
                print("Upload successful")
                self.delegate?.returnProgressAndStatus(0, status: "Upload completed succesfully")
                self.delegate?.uploadCompletedSuccessfully(self.S3UploadBucket)
                SVProgressHUD.popActivity()
            }
            return nil
        }

        /*
        self.S3UploadBucket = bucketName
        self.uploadFileURL = fileUrl
        struct Static {
            static var session: NSURLSession?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(BackgroundSessionUploadIdentifier)
            Static.session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        self.session = Static.session;
        
        if (self.uploadTask != nil) {
            return;
        }
        
        var getPreSignedURLRequest:AWSS3GetPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.bucket = bucketName.rawValue
        
        
        getPreSignedURLRequest.key = self.uploadFileURL.path?.lastPathComponent
        getPreSignedURLRequest.HTTPMethod = AWSHTTPMethod.PUT
        getPreSignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600)
        
        //Important: must set contentType for PUT request
        let fileContentTypeStr = "text/plain"
        getPreSignedURLRequest.contentType = fileContentTypeStr
        
        AWSS3PreSignedURLBuilder.defaultS3PreSignedURLBuilder().getPreSignedURL(getPreSignedURLRequest).continueWithBlock { (task:AWSTask!) -> (AnyObject!) in
            
            if (task.error != nil) {
                NSLog("Error: %@", task.error)
                SVProgressHUD.dismiss()
            } else {
                let presignedURL = task.result as! NSURL!
                if (presignedURL != nil) {
//                    NSLog("upload presignedURL is: \n%@", presignedURL)
                    var request = NSMutableURLRequest(URL: presignedURL)
                    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
                    request.HTTPMethod = "PUT"
                    //contentType in the URLRequest must be the same as the one in getPresignedURLRequest
                    request .setValue(fileContentTypeStr, forHTTPHeaderField: "Content-Type")
//                    println(self.uploadFileURL)
                    self.uploadTask = self.session?.uploadTaskWithRequest(request, fromFile: self.uploadFileURL!)
                    self.uploadTask?.resume()
                }
            }
            return nil;
        }
*/
    }
    
    class func cancelAllTask(){
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.cancelAll()
    }
    
    //MARK: URLSession Delegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        NSLog("UploadTask progress: %lf", progress)
        
        dispatch_async(dispatch_get_main_queue()) {
            
            //self.delegate?.returnProgress(progress)
            if (self.S3UploadBucket == Buckets.Video)
            {
                self.delegate?.returnProgressAndStatus(progress, status: "Uploading video...")
                //self.delegate?.returnStatus("Uploading video...")
            }
            else
            {
                self.delegate?.returnProgressAndStatus(progress, status: "Uploading image...")
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        self.uploadTask = nil
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.returnProgressAndStatus(0, status: "Upload completed succesfully")
                self.delegate?.uploadCompletedSuccessfully(self.S3UploadBucket)
            }
            NSLog("S3 UploadTask: %@ completed successfully", task);
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.returnProgressAndStatus(0, status: "Upload failed")
                self.delegate?.uploadFailedMisserably()
            }
            NSLog("S3 UploadTask: %@ completed with error: %@", task, error!.localizedDescription);
        }
//        dispatch_async(dispatch_get_main_queue()) {
//            self.delegate?.returnProgress(Float(task.countOfBytesSent) / Float(task.countOfBytesExpectedToSend))
//        }
        
       dispatch_async(dispatch_get_main_queue(), { () -> Void in
        SVProgressHUD.popActivity()
       })
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if ((appDelegate.backgroundUploadSessionCompletionHandler) != nil) {
            let completionHandler:() = appDelegate.backgroundUploadSessionCompletionHandler!;
            appDelegate.backgroundUploadSessionCompletionHandler = nil
            completionHandler
        }
        NSLog("Completion Handler has been invoked, background upload task has finished.");
    }
}
