//
//  AppDelegate.swift
//  MOVV
//
//  Created by Martino Mamic on 28/04/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//
import UIKit
import AWSS3
import Branch
import AFNetworking
import FBSDKLoginKit
import Appsee
import SVProgressHUD
import Fabric
import Crashlytics
import Mixpanel
import Siren


let StripePublishableKey : String! = "pk_test_UsRTCCi2N87Lhpg4cgqcOxHq"

var enteredApp = false
var adress:String?
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var mixpanel : Mixpanel?
    var window: UIWindow?
    var backgroundDownloadSessionCompletionHandler: ()?
    var backgroundUploadSessionCompletionHandler: ()?
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        if identifier == BackgroundSessionUploadIdentifier {
            self.backgroundUploadSessionCompletionHandler = completionHandler()
        } else if identifier == BackgroundSessionDownloadIdentifier {
            self.backgroundDownloadSessionCompletionHandler = completionHandler()
        }
    }

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        mixpanel = Mixpanel.sharedInstanceWithToken("19cf133da4ed8e4c9548e99447c85964")
        mixpanel?.track("run the app")
        mixpanel?.checkForSurveysOnActive = true
        mixpanel?.showSurveyOnActive = true
        mixpanel?.checkForNotificationsOnActive = true
        
        NSUserDefaults.standardUserDefaults().setValue("http://api.mymov.co/test/", forKey: kGDNetworkToolsBaseURLStringKey)
//        NSUserDefaults.standardUserDefaults().setValue("http://api.mymov.co/dev/", forKey: kGDNetworkToolsBaseURLStringKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setForegroundColor(UIColor.greenAppColor())
        SVProgressHUD.setBackgroundColor(UIColor.whiteColor())
        SVProgressHUD.setDefaultMaskType(.Gradient)
        
        //MARK: -AppSee
        Appsee.start("fb95e5d0744649819adf2f558915da6d")
        
        // MARK: -Branch initialisation
        let branch: Branch = Branch.getInstance()
        branch.initSessionWithLaunchOptions(launchOptions, andRegisterDeepLinkHandler: { params, error in
            if (error == nil) {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                // ... insert custom logic here ...
                NSLog("params: %@", params.description)
            }
        })
        let controller = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("detailVC")
        branch.registerDeepLinkController(controller, forKey: "product_id")
        branch.initSessionWithLaunchOptions(launchOptions, automaticallyDisplayDeepLinkController: true)
        
        // MAKR: -Cache
        let cacheSizeMemory = 20 * 1024 * 1024
        let cacheSizeDisk = 100 * 1024 * 1024
        let sharedCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache)
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock{(status: AFNetworkReachabilityStatus)          in
            
            switch status.rawValue{
            case AFNetworkReachabilityStatus.NotReachable.rawValue, AFNetworkReachabilityStatus.Unknown.rawValue:
                    MVHelper.showAlertWithMessageAndTitle("Network not reachable", title: AlertTitle.Warning.rawValue)
            case AFNetworkReachabilityStatus.ReachableViaWiFi.rawValue , AFNetworkReachabilityStatus.ReachableViaWWAN.rawValue:
                if( MVHelper.isNetworkAvailable()){
                    if(MVHelper.sharedInstance.enteredApp){
//                        MVHelper.showAlertWithMessageAndTitle("Network is reachable", title: AlertTitle.Info.rawValue)
                    }
                } else {
                   // MVHelper.showAlertWithMessageAndTitle("Connected to network but server not reachable. ", title: AlertTitle.Warning.rawValue)
                }
            default:
                print("Unknown status")
            }
        }
        
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        // MARK: -AWS upload
        let credentialProvider = AWSCognitoCredentialsProvider(
            regionType: CognitoRegionType,
            identityPoolId: CognitoIdentityPoolId)
        
        let configuration = AWSServiceConfiguration(
            region: DefaultServiceRegionType,
            credentialsProvider: credentialProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("userLoggedIn") != nil) {
            if(NSUserDefaults.standardUserDefaults().objectForKey("userLoggedIn") as! Bool == true) {
                if(NSUserDefaults.standardUserDefaults().objectForKey("user") != nil){
                    MVParameters.sharedInstance.currentMVUser = MVUser.loadSavedUser()
                    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewControllerWithIdentifier("tabBarVC") as! CustomTabBarController
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
            }
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Siren.sharedInstance.updaterWindow?.hidden = true
        Siren.sharedInstance.updaterWindow = nil
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let siren = Siren.sharedInstance
        siren.alertType = .Force
        siren.checkVersion(.Immediately)
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        Branch.getInstance().handleDeepLink(url);
        
        // You can add your app-specific url handling code here if needed
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        return Branch.getInstance().continueUserActivity(userActivity)
    }
    
    // MARK: - Push notifs
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        NSUserDefaults.standardUserDefaults().setValue(tokenString, forKey: movDeviceToken)
        print("Device Token:", tokenString)
            let mixpanel:Mixpanel = Mixpanel.sharedInstance()
            mixpanel.identify(mixpanel.distinctId)
            mixpanel.people.addPushDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
        
}

