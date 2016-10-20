//
//  UserAccessViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 28/04/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//
import MediaPlayer
import UIKit
import FBSDKLoginKit
import SVProgressHUD
import FLAnimatedImage

var userImage:UIImage!

class UserAccessViewController: UIViewController {
    
    @IBOutlet var firstImage: FLAnimatedImageView!
    @IBOutlet var background: UIImageView!
    @IBOutlet var gifView: UIWebView!
    @IBOutlet var termsAndPrivacyLabel: UILabel!
    @IBOutlet var privacyPolicyButton: UIButton!
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var fbLoginButton: UIButton!
    //    @IBOutlet var infoButton: UIButton!
    
    //    var uploadFBImage : MVAwsUpload! = nil
    var fbImageUrl : NSURL!
    //    var avatarFileName : String!
    
    var fbEmail : String!
    var fbFirstName : String!
    var fbFacebookID : String!
    var fbLastName : String!
    var fbAccessToken : String!
    var isTermsLink : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.uploadFBImage = MVAwsUpload()
        //        self.uploadFBImage.delegate = self
        MVHelper.sharedInstance.enteredApp = true
        self.preferredStatusBarStyle()
        //        infoButton.layer.cornerRadius = 8
        //        infoButton.clipsToBounds = true
        setupUnderlineForTerms()
        let animatedImage = FLAnimatedImage(animatedGIFData: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("AppIntro", ofType: "gif")!))
        firstImage.backgroundColor = UIColor.redColor()
        firstImage.animatedImage = animatedImage
        firstImage.startAnimating()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController! .setNavigationBarHidden(true, animated: false)
        NSNotificationCenter.defaultCenter().postNotificationName("hideTabbar", object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        self.showSignUp();
    }
    
    @IBAction func loginBtnTaped(sender: AnyObject) {
        if let viewController = MVLoginSignUpViewController(nibName: "MVLoginSignUpViewController", bundle: nil) as? MVLoginSignUpViewController
        {
            viewController.controllerType = ViewControllerDataType.Login
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    @IBAction func fbLoginButtonPressed(sender: AnyObject) {
        
        
        
        
        /*
         FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
         [login
         logInWithReadPermissions: @[@"public_profile"]
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
         NSLog(@"Process error");
         } else if (result.isCancelled) {
         NSLog(@"Cancelled");
         } else {
         NSLog(@"Logged in");
         }
         }];
         */
        //        var result = FBSDKLoginManagerLoginResult()
        //        var error = NSError()
        
        
        let permissions = ["email", "public_profile", "user_friends"]
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logInWithReadPermissions(permissions, fromViewController: self) { (result, error) -> Void in
            if ((error) != nil) {
                
            } else if (result.isCancelled) {
                // Handle cancellations
            } else {
                self.returnUserData()
                
                
            }
        }
        
        //        fbLoginManager.logInWithReadPermissions(permissions, handler: { (result, error) -> Void in
        //            if ((error) != nil) {
        //
        //            } else if (result.isCancelled) {
        //                // Handle cancellations
        //            } else {
        //                self.returnUserData()
        //
        //
        //            }
        //        })
        
        /*logInWithReadPermissions(permissions, handler: { (result, error) -> Void in
         if ((error) != nil) {
         
         } else if (result.isCancelled) {
         // Handle cancellations
         } else {
         self.returnUserData()
         
         
         }
         
         })*/
        
    }
    
    
    @IBAction func termButtonPressed(sender: AnyObject) {
        isTermsLink = true
        self.performSegueWithIdentifier("showWeb", sender: self)
    }
    
    @IBAction func privacyPolicyButtonPressed(sender: AnyObject) {
        isTermsLink = false
        self.performSegueWithIdentifier("showWeb", sender: self)
    }
    
    // MARK: Facebook delegate methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        if ((error) != nil) {
            print(error)
        }
        if result.isCancelled {
            print("cancelled")
        } else {
            
            returnUserData()
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData() {
        
        let parameters : NSMutableDictionary = NSMutableDictionary()
        parameters.setValue("id,name,first_name,last_name,email,picture", forKey: "fields")
        
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters as [NSObject : AnyObject])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            } else {
                
                print(result)
                
                facebookUser = MVFacebookUser(dictionary: result as! NSDictionary)
                self.fbImageUrl = NSURL(string: "https://graph.facebook.com/\(facebookUser!.facebookID!)/picture?type=large")
                
                let resultDictionary : NSDictionary! = result as! NSDictionary
                print(resultDictionary)
                self.fbEmail  = resultDictionary["email"] as! String!
                self.fbEmail = self.fbEmail == nil ? "" : self.fbEmail
                self.fbFirstName  = resultDictionary["first_name"] as! String!
                self.fbFacebookID = resultDictionary["id"] as! String!
                self.fbLastName  = resultDictionary["last_name"] as! String!
                self.fbAccessToken  = FBSDKAccessToken.currentAccessToken().tokenString
                print(self.fbFacebookID)
                
                SVProgressHUD.show()
                MVDataManager.facebookCheck(self.fbEmail, facebookID: self.fbFacebookID, successBlock: { response in
                    print(response)
                    let responseMessage : NSDictionary! = response as! NSDictionary
                    let status : Int = (responseMessage.objectForKey("registration_status") as! NSString).integerValue
                    SVProgressHUD.popActivity()
                    if(status == 1) {
                        let userDict : NSDictionary! = (responseMessage.objectForKey("user") as! NSArray).firstObject as! NSDictionary
                        let user : MVUser! = MVUser(dictionary: userDict)
                        MVParameters.sharedInstance.currentMVUser = user
                        user.save()
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userLoggedIn")
                        self.showHome()
                        
                        guard let token = MVParameters.sharedInstance.devicePushToken else {
                            print("Error, token is nil")
                            return
                        }
                        
                        MVDataManager.registerForNotifications(user.id, token: token, successBlock: { response in
                            print(response)
                        }) { failure in
                            print(failure)
                        }
                        
                    } else {
                        self.showSignUp()
                    }
                    
                    }, failureBlock: { failure in
                        
                        print("\(failure)")
                        SVProgressHUD.popActivity()
                })
            }
        })
    }
    
    func showHome(){
//        if(NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") != nil){
//            if(NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") as! Bool == false){
//                NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
//                NSUserDefaults.standardUserDefaults().synchronize()
//                self.performSegueWithIdentifier("showOnboarding", sender: nil)
//            } else {
//                //MARK: change "showOnboarding" in next line to "showRoot" in production build, "showOnboarding" is for development only to access onboarding screen after login
//                self.performSegueWithIdentifier("showRoot", sender: nil)
//                //                self.performSegueWithIdentifier("showOnboarding", sender: nil)
//            }
//        } else {
//            NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
//            NSUserDefaults.standardUserDefaults().synchronize()
//            
//            //MARK: change "showRoot" in next line to "showOnboarding", to display intro video screen
//            self.performSegueWithIdentifier("showOnboarding", sender: nil)
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("tabBarVC") as! CustomTabBarController
        if let check = NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") as? Bool{
            if !check{
                initialViewController.insNew = true
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }else{
            initialViewController.insNew = true
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        self.presentViewController(initialViewController, animated: true, completion: nil)
        
    }
    
    
    func showSignUp() {
        //        if(NSUserDefaults.standardUserDefaults().objectForKey("user") != nil){
        //            MVParameters.sharedInstance.currentMVUser = MVUser.loadSavedUser()
        //            self.performSegueWithIdentifier("showRoot", sender: nil)
        //        } else {
        self.performSegueWithIdentifier("signUpViaFacebookSegue", sender: nil)
        //        }
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "signUpViaFacebookSegue"){
            let signUpVC = segue.destinationViewController as! SignUpViewController
            
            signUpVC.isFacebookSignUp = true
            signUpVC.fbEmail = self.fbEmail
            signUpVC.fbFirstName = self.fbFirstName
            signUpVC.fbLastName = self.fbLastName
            signUpVC.fbFacebookID = self.fbFacebookID
            signUpVC.fbAccessToken = self.fbAccessToken
            signUpVC.fbImageUrl = self.fbImageUrl
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.setBackButtonBackgroundImage (UIImage (named: "back"), forState: .Normal, barMetrics: .Default);
//            navigationItem.backBarButtonItem = backItem
            navigationItem.title = "SignUp"
        }else if(segue.identifier == "showWeb"){
            let dest = segue.destinationViewController as! MVShowWebContentViewController
            dest.urlString = (isTermsLink == true) ? "http://mymov.co/app/terms.php" : "http://mymov.co/app/privacy.php"
            dest.title = "MOV"
        }
    }
    
    
    
    func setupUnderlineForTerms(){
        let string = "By Signing in You Agree to Our Terms of Use and Privacy Policy" as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        let underline = [NSUnderlineStyleAttributeName: 1]
        attributedString.addAttributes(underline, range: string.rangeOfString("Terms of Use"))
        attributedString.addAttributes(underline, range: string.rangeOfString("Privacy Policy"))
        termsAndPrivacyLabel.attributedText = attributedString
    }
    
    //    func uploadCompletedSuccessfully(bucket:Buckets)
    //    {
    //            MVDataManager.updateUserProfileImage(MVParameters.sharedInstance.currentMVUser.id, imageName: self.avatarFileName, successBlock: { response in
    //
    //                print("Update profile image success message: \(response)")
    //
    //                }, failureBlock: { failure in
    //
    //                    print("Update profile image failure message: \(failure)")
    //            })
    //    }
    //
    //    func uploadFailedMisserably() {
    //
    //    }
    //
    //    func returnProgress(progress : Float)
    //    {
    //
    //    }
    //    func returnStatus(status : String)
    //    {
    //
    //    }
    //
    //    func returnProgressAndStatus (progress : Float, status : String)
    //    {
    //        print("progress: \(progress)")
    //    }
    
    //    func uploadFBImageToAWS(url : NSURL!)
    //    {
    //
    //        SDWebImageManager.sharedManager().downloadImageWithURL(url!, options: SDWebImageOptions(), progress: nil, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, finished:Bool, url:NSURL!) -> Void in
    //
    //            let fileManager = NSFileManager.defaultManager()
    //            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    //            self.avatarFileName = "profile_" + MVHelper.generateIdentifierWithLength(15) + ".jpg"
    //            let filePathToWrite = "\(paths)/\(self.avatarFileName)"
    //            let imageData: NSData = UIImagePNGRepresentation(image)!
    //            fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
    //            let getImagePath = paths.stringByAppendingString("\(self.avatarFileName)")
    //            
    //            
    //            if (fileManager.fileExistsAtPath(getImagePath))
    //            {
    //                self.uploadFBImage.startUpload( NSURL(fileURLWithPath: getImagePath), bucketName: Buckets.Image)
    //            }
    //            else
    //            {
    //                print("FILE NOT AVAILABLE");
    //                
    //            }
    // 
    //        })
    //    }
    
    
    
}


