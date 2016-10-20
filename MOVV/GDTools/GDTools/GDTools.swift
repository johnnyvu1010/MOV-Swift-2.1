//
//  GDNetworkTools.swift
//  GDNetworkTools
//
//  Created by Ivan Barisic on 17/02/16.
//  Copyright © 2016 Gauss Development. All rights reserved.
//

import UIKit
import AVFoundation

public enum GDToolsEnviroment: Int {
    case Default = 0
    case Development = 1
    case Production = 2
}

public var baseURL: String? = NSUserDefaults.standardUserDefaults().stringForKey(kGDNetworkToolsBaseURLStringKey)
public var sharedAppKey: String? = nil
public let kGDNetworkToolsBaseURLStringKey: String = "kGDNetworkToolsBaseURLStringKey"
public let kGDToolsAppSettingsKey: String = "kGDToolsAppSettingsKey"

public class GDTools: NSObject {
    
    /**
     Method used to fetch base url string for given appKey
     
     - parameter appKey:                    String indicating appKey
     - parameter success:                   Block triggered in case of success, returns base url value
     - parameter failure:                   Block triggered in case of failure, returns NSError object and stored String object indicating base URL used in previous sessions
     - parameter forceProductionEnviroment: Bool indicating if app should force production enviroment URL
     */
    public class func getBaseURLString(forAppKey appKey: String, enviroment: GDToolsEnviroment, setBaseURLIfError urlIfError: String, finished: ((_ isFinishedSuccessfully: Bool) -> Void)?) {
        
        print("Documents directory path: " + NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!)
        
        sharedAppKey = appKey
        
        if baseURL == nil {
            baseURL = urlIfError
        }
        
        if (NSUserDefaults.standardUserDefaults().objectForKey(kGDToolsAppSettingsKey) == nil) {
            NSUserDefaults.standardUserDefaults().setObject([:] as Dictionary<String, String>, forKey: kGDToolsAppSettingsKey)
        }
        
        let fetchURL: String = "http://provision.gauss.hr/setup/app/" + appKey
        
        let sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.HTTPAdditionalHeaders = ["Accept": "application/json"]
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.HTTPMaximumConnectionsPerHost = 1
        
        let session: NSURLSession = NSURLSession(configuration: sessionConfig)
        
        session.dataTaskWithURL(NSURL(string: fetchURL)!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if data != nil && error == nil {
                do {
                    var dict: Dictionary<String, String> = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as! Dictionary<String, String>
                    
                    if enviroment == GDToolsEnviroment.Production {
                        if (dict["prod_url"] != nil && dict["prod_url"] != "") {
                            NSUserDefaults.standardUserDefaults().setValue(dict["prod_url"]!, forKey: kGDNetworkToolsBaseURLStringKey)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            baseURL = dict["prod_url"]!
                        }
                    } else if enviroment == GDToolsEnviroment.Development {
                        if (dict["dev_url"] != nil && dict["dev_url"] != "") {
                            NSUserDefaults.standardUserDefaults().setValue(dict["dev_url"]!, forKey: kGDNetworkToolsBaseURLStringKey)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            baseURL = dict["dev_url"]!
                        }
                    } else {
                        #if DEBUG
                            if (dict["dev_url"] != nil && dict["dev_url"] != "") {
                                NSUserDefaults.standardUserDefaults().setValue(dict["dev_url"]!, forKey: kGDNetworkToolsBaseURLStringKey)
                                NSUserDefaults.standardUserDefaults().synchronize()
                                baseURL = dict["dev_url"]!
                            }
                        #else
                            if (dict["prod_url"] != nil && dict["prod_url"] != "") {
                                NSUserDefaults.standardUserDefaults().setValue(dict["prod_url"]!, forKey: kGDNetworkToolsBaseURLStringKey)
                                NSUserDefaults.standardUserDefaults().synchronize()
                                baseURL = dict["prod_url"]!
                            }
                        #endif
                    }
                    
                    dict.removeValueForKey("prod_url")
                    dict.removeValueForKey("dev_url")
                    
                    self.saveDictionary(dict)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        finished?(isFinishedSuccessfully: true)
                    })
                    
                } catch let catchError as NSError {
                    print(catchError.localizedDescription)
                    dispatch_async(dispatch_get_main_queue(), {
                        finished?(isFinishedSuccessfully: false)
                    })
                }
            } else {
                print(error!.localizedDescription)
                dispatch_async(dispatch_get_main_queue(), {
                    finished?(isFinishedSuccessfully: false)
                })
            }
            }.resume()
    }
    
    private class func saveDictionary(dict: Dictionary<String, String>) {
        var oldAppSettings: Dictionary<String, String> = NSUserDefaults.standardUserDefaults().objectForKey(kGDToolsAppSettingsKey) as! Dictionary<String, String>
        
        for newItem in dict.keys {
            if (!oldAppSettings.keys.contains(newItem)) {
                oldAppSettings[newItem] = dict[newItem]
            } else if (oldAppSettings[newItem] != dict[newItem]) {
                oldAppSettings[newItem] = dict[newItem]
            }
        }
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kGDToolsAppSettingsKey)
        NSUserDefaults.standardUserDefaults().setObject(oldAppSettings, forKey: kGDToolsAppSettingsKey)
    }
    
    /**
     Used to get value for app settings such as facebook id,
     
     - parameter key: key for desired value
     
     - returns: value for key
     */
    public class func getValueFromAppSettingsDictionaryForKey(key: String) -> String {
        guard let appSettingsDict = NSUserDefaults.standardUserDefaults().objectForKey(kGDToolsAppSettingsKey) as? Dictionary<String, String>
            else {
                print("NSUserDefaults does not have object for key kGDToolsAppSettingsKey")
                return ""
        }
        
        if (appSettingsDict[key] != nil) {
            return appSettingsDict[key]!
        }
        print("Value for key: \(key), in appSettingsDictionary, does not exist.")
        return ""
    }
    
    // MARK: Date manipulation
    
    /**
     Used to get NSDate object from string, if dateFomat is nil date format to be used is yyyy-MM-dd'T'HH:mm:ss.SSSZ
     
     - parameter dateString: String to format to date
     - parameter dateFormat: String to use as date format
     
     - returns: NSDate object
     */
    public class func dateFromString(dateString: String, dateFormat: String?) -> NSDate? {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        if dateFormat == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = dateFormat!
        }
        
        return dateFormatter.dateFromString(dateString)
    }
    
    
    /**
     Used to fetch string for given date format, if no format is set medium style will be used.
     
     - parameter dateFormat: String indicating date format
     - parameter date:       NSDate to format
     
     - returns: String object
     */
    public func stringForDateInFormat(dateFormat: String?, forDate date: NSDate) -> String? {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        if dateFormat == nil {
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        } else {
            dateFormatter.dateFormat = dateFormat!
        }
        
        return dateFormatter.stringFromDate(date)
    }
    
    public class func getFirstImageFromVideoWithUrl(url: String, successBlock: ((image: UIImage) -> Void), failureBlock: ((error: NSError) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let asset: AVURLAsset = AVURLAsset(URL: NSURL(string: url)!)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMake(1, 1)
            
            do {
                let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    successBlock(image: UIImage(CGImage: imageRef))
                })
                
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    failureBlock(error: error)
                })
            }
            
        })
    }
}
