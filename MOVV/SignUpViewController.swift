//
//  SignUpViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 28/04/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import AFNetworking
import IQKeyboardManager
//import SDWebImage
import SVProgressHUD
import FLAnimatedImage
import CoreLocation

class SignUpViewController: UIViewController, MVAwsUploadDelegate, CLLocationManagerDelegate {
    
    
    var isSignUp = true
    
    var isFacebookSignUp = false
    
    var fields:NSMutableArray?
    var userCoordinate : CLLocationCoordinate2D! = CLLocationCoordinate2D()
    let locationManager : CLLocationManager! = CLLocationManager()
    
    @IBOutlet var animatedImageView: FLAnimatedImageView!
    @IBOutlet var usernameField: TextFieldValidator!
    @IBOutlet var emailField: TextFieldValidator!
    @IBOutlet var passwordField: TextFieldValidator!
    @IBOutlet var nameField: TextFieldValidator!
//    @IBOutlet var lastNameField: TextFieldValidator!
//    @IBOutlet var invitationCodeField: TextFieldValidator!
//    @IBOutlet var loginLabel: UILabel!
//    @IBOutlet var registerButton:UIButton!
//    @IBOutlet var loginButton:UIButton!
//    @IBOutlet var triangleLeading: NSLayoutConstraint!
    
//    @IBOutlet var triangleView: UIImageView!
//    @IBOutlet var registerLabel: UILabel!
    
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var nameLine: UIView!
    @IBOutlet var firstNameLine: UIView!
//    @IBOutlet var lastNameLine: UIView!
    @IBOutlet var invitationLine: UIView!
    @IBOutlet var textFieldsView: UIView!
    @IBOutlet var presentInViewConstrain: NSLayoutConstraint!
    @IBOutlet var presentInView: UIView!
    
    
    @IBOutlet var emailImageHeightConstrain: NSLayoutConstraint!
    @IBOutlet var emailFieldHeightConstrain: NSLayoutConstraint!
    @IBOutlet var firstNameHeightConstrain: NSLayoutConstraint!
    @IBOutlet var firstNameFieldConstrain: NSLayoutConstraint!
    @IBOutlet var lastNameHeightConstrain: NSLayoutConstraint!
    @IBOutlet var lastNameFieldHeightConstrain: NSLayoutConstraint!
    @IBOutlet var usernameHeightConstrain: NSLayoutConstraint!
    @IBOutlet var usernameFieldHeightConstrain: NSLayoutConstraint!
    @IBOutlet var invitationHeightConstrain: NSLayoutConstraint!
    @IBOutlet var invitationFieldHeightConstrain: NSLayoutConstraint!
    
    
    var fbEmail : String!
    var fbFirstName : String!
    var fbFacebookID : String!
    var fbLastName : String!
    var fbAccessToken : String!
    var fbImageUrl : NSURL!
    var avatarFileName : String!
    var uploadFBImage : MVAwsUpload! = nil
    var keyboardRect : CGRect!
    var scrollUpDistance : CGFloat! = 0
    var locationSuccessfulySent : Bool = false


    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        

        
        if(UIScreen.mainScreen().bounds.height == 480)
        {
            self.setConstrainsFor4S()
        }
        
        self.submitButton.layer.borderWidth  = 1.0
        self.submitButton.layer.cornerRadius = 3.0
        self.submitButton.layer.borderColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        
        
        self.uploadFBImage = MVAwsUpload()
        self.uploadFBImage.delegate = self
        self.preferredStatusBarStyle()
        fields = NSMutableArray()
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        setupFields()
        setupButtons()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        

//        self.navigationController! .setNavigationBarHidden(false, animated: false)
        
        navigationItem.title = "SignUp";
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//            triangleLeading.constant = loginButton.center.x-5
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func setupFields(){

        
        if(emailField != nil){
            fields?.addObject(emailField)
            
            fields?.addObject(nameField)
            
            //fields?.addObject(lastNameField)
            
            fields?.addObject(usernameField)
            
            
            fields?.addObject(nameField)
            emailField.addRegx("[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}", withMsg: "Use proper email please")
            usernameField.addRegx("[A-Za-z0-9]{2,18}", withMsg: "Only alphanumeric please")
        }
        
    }

    func setupButtons(){
        
        self.emailField.isMandatory = false

        self.nameField.isMandatory = false
        self.usernameField.isMandatory = false
        self.passwordField.isMandatory = false
        
        self.emailField.validate()
        self.nameField.validate()
        self.usernameField.validate()
        self.passwordField.validate()
        self.view.endEditing(true)
    
        self.emailField.text = self.fbEmail.length > 0 ? self.fbEmail : ""
        self.emailField.userInteractionEnabled = true
        self.nameField.text = self.fbFirstName
        self.usernameField.text = ""
        self.passwordField.text = ""
        
        self.emailField.isMandatory = true
        self.nameField.isMandatory = true
        self.usernameField.isMandatory = true
        self.passwordField.isMandatory = true
        
        
        if(isSignUp == false){
//            nameField.hidden = true
//            nameLine.hidden = true
//            emailField.hidden = true
//            emailLine.hidden = true

//            lastNameField.hidden = true
//            lastNameLine.hidden = true
//            registerLabel.textColor = UIColor.blackColor()
//            triangleLeading.constant = loginButton.center.x-2
            
            if(fields?.count > 2){
                fields?.removeLastObject()
                passwordField.returnKeyType = .Go
            }
        } else if(isSignUp == true){
//            nameField.hidden = false
//            nameLine.hidden = false
//            emailField.hidden = false
//            emailLine.hidden = false

//            lastNameField.hidden = false
//            registerLabel.textColor = UIColor.whiteColor()
//            triangleLeading.constant = registerButton.center.x-2
            
            if(fields?.count == 2){
                fields?.addObject(emailField)
            }
            
            passwordField.returnKeyType = .Next
            nameField.returnKeyType = .Next
            emailField.returnKeyType = .Next
            usernameField.returnKeyType = .Go
            
            
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func textFieldBasicSetup(textfield:UITextField){
        textfield.leftViewMode = UITextFieldViewMode.Always
        textfield.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
    }
    
    //MARK: Textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let index = fields?.indexOfObject(textField)
        if(textField.returnKeyType == UIReturnKeyType.Go){
            return self.validateFieldsAndLoginUser(textField)
        } else {
//            println(fields?.count)
            fields?.objectAtIndex(index!+1) .becomeFirstResponder()
            return false
        }
    }
    
    func validateFieldsAndLoginUser(textField : UITextField) -> Bool
    {
        if(usernameField.validate() /*&& invitationCodeField.validate()*/){
            textField .resignFirstResponder()
            var userDict = NSMutableDictionary()
            if((usernameField.text!.characters.count>2)){
                
                userDict = NSMutableDictionary(objects: [usernameField!.text!, "12345"/*invitationCodeField!.text!*/], forKeys: ["username",  "invitationCode"])
                
                if(emailField.text!.characters.count > 6){
                    userDict .setObject(emailField.text!, forKey: "email")
                }
            }
            
            NSUserDefaults.standardUserDefaults() .setObject(userDict, forKey: "userDictionary")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if(self.isSignUp)
            {
                if(emailField.validate() && nameField.validate()){
                    self.view.endEditing(true)
                    
//                    MVDataManager.facebookRegister(self.firstNameField.text!, lastName: self.lastNameField.text!, email: self.emailField.text!, facebookToken: self.fbAccessToken, facebookID: self.fbFacebookID, username: self.usernameField.text!, invitationCode: "12345"/*self.invitationCodeField.text!*/, successBlock: { response in
                MVDataManager.facebookRegister(self.fbFirstName, lastName: self.fbLastName, email: self.emailField.text!, facebookToken: self.fbAccessToken, facebookID: self.fbFacebookID, username: self.usernameField.text!, invitationCode: "12345"/*self.invitationCodeField.text!*/, successBlock: { response in
                    SVProgressHUD.dismiss()
                        
                        
                        let responseMessage : NSDictionary! = response as! NSDictionary
                        let userDict : NSDictionary! = (responseMessage.objectForKey("user") as! NSArray).firstObject as! NSDictionary
                        let user : MVUser! = MVUser(dictionary: userDict)
                        MVParameters.sharedInstance.currentMVUser = user
                        user.save()
                        

                        
                        if CLLocationManager.locationServicesEnabled() {
                            self.locationManager.delegate = self
                            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                            self.locationManager.startUpdatingLocation()
                        }
                        

                        
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userRegistered")
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userLoggedIn")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.uploadFBImageToAWS(self.fbImageUrl)
                        self.sendPushDeviceToken()
                        self.showHome()
                    
                    
                        }, failureBlock: { failure in
                            
                            self.showAlertWithMessage(failure as! String)
                            SVProgressHUD.dismiss()
                    })
                } else {
                    self.showAlertWithMessage("Please fill in all fields")
                }
                
            }
            else
            {
                SVProgressHUD.show()
                MVDataManager.getUserLoginData(usernameField.text!, password: passwordField.text!,  successBlock: { response in
                    SVProgressHUD.dismiss()
                    let user : MVUser = response as! MVUser
                    user.save()
                    MVParameters.sharedInstance.currentMVUser = user
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userLoggedIn")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.sendPushDeviceToken()
                    self.showHome()
                    }) { failure -> Void in
                        let failureMessage : String! = failure as! String
                        self.showAlertWithMessage(failureMessage)
                        SVProgressHUD.dismiss()
                }
            }
            
            return true
        } else {
            return false
        }
    }
    
    func showAlertWithMessage(message:String){
        let alert = MOVVAlertViewController(title: "", message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func showHome(){
        // show a preview page.
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        PreviewVideoController *controller = [storyboard instantiateViewControllerWithIdentifier:@"viewPreviewVC"];// onboardingVC
//        controller.modalPresentationStyle = UIModalPresentationPopover;
//        [self presentViewController:controller animated:YES completion:nil];
//        if(NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") != nil){
//            if(NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") as! Bool == false){
//                NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
//                NSUserDefaults.standardUserDefaults().synchronize()
//                self.performSegueWithIdentifier("showOnboarding", sender: nil)
//            } else {
//                self.performSegueWithIdentifier("showRoot", sender: nil)
//            }
//        } else {
//            NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
//            NSUserDefaults.standardUserDefaults().synchronize()
//            self.performSegueWithIdentifier("showOnboarding", sender: nil)
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("tabBarVC") as! CustomTabBarController
        self.presentViewController(initialViewController, animated: true, completion: {
            if self.isSignUp{
                if let check = NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") as? Bool{
                    if !check{
                        self.showOnBoarding(initialViewController)
                    }
                }else{
                    self.showOnBoarding(initialViewController)
                }
            }else{
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    }
    
    func showOnBoarding(initialViewController:CustomTabBarController){
        initialViewController.insNew = true
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
        NSUserDefaults.standardUserDefaults().synchronize()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("viewPreviewVC") as! PreviewVideoController
        controller.modalPresentationStyle = .Popover
        initialViewController.presentViewController(controller, animated: true, completion: nil);
    }
    
//    @IBAction func loginButtonPressed(sender: AnyObject) {
//        isSignUp = false
//        setupButtons()
//    }
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        isSignUp = true
        setupButtons()
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        var userDict = NSMutableDictionary()
        if((usernameField.text!.characters.count>2) && passwordField.text!.characters.count > 6){
//            userDict = NSMutableDictionary(objectsAndKeys: usernameField.text, "username", passwordField.text, "password")
            
            userDict = NSMutableDictionary(objects: [usernameField!.text!, passwordField!.text!], forKeys: ["username",  "password"])
            
            if(emailField.text!.characters.count > 6){
                userDict .setObject(emailField.text!, forKey: "email")
            }
        }
        
        print(userDict)
        
        let manager = AFHTTPRequestOperationManager()
        manager.POST("", parameters: userDict, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
            print(response)
            self.showHome()
            }) { (operation:AFHTTPRequestOperation?, error:NSError!) -> Void in
                print(error)
                self.showHome()
        }
    }
    
    func sendPushDeviceToken()
    {
        guard let token = MVParameters.sharedInstance.devicePushToken else {
            print("Error, token is nil")
            return
        }
        
        MVDataManager.registerForNotifications(MVParameters.sharedInstance.currentMVUser.id, token: token, successBlock: { response in
            print(response)
        }) { failure in
            print(failure)
        }
    }
    
    func uploadFBImageToAWS(url : NSURL!)
    {
        
        SDWebImageManager.sharedManager().downloadImageWithURL(url!, options: SDWebImageOptions(), progress: nil, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, finished:Bool, url:NSURL!) -> Void in
            
            let fileManager = NSFileManager.defaultManager()
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            self.avatarFileName = "profile_" + MVHelper.generateIdentifierWithLength(15) + ".jpg"
            let filePathToWrite = "\(paths)/\(self.avatarFileName)"
            let imageData: NSData = UIImagePNGRepresentation(image)!
            fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
            let getImagePath = paths.stringByAppendingString("/\(self.avatarFileName)")
            
            
            if (fileManager.fileExistsAtPath(getImagePath))
            {
                self.uploadFBImage.startUpload( NSURL(fileURLWithPath: getImagePath), bucketName: Buckets.Image)
            }
            else
            {
                print("FILE NOT AVAILABLE");
                
            }
            
        })
    }
    
    func uploadCompletedSuccessfully(bucket:Buckets)
    {
        MVDataManager.updateUserProfileImage(MVParameters.sharedInstance.currentMVUser.id, imageName: self.avatarFileName, successBlock: { response in
            
            print("Update profile image success message: \(response)")
            
            }, failureBlock: { failure in
                
                print("Update profile image failure message: \(failure)")
        })
    }
    
    func uploadFailedMisserably() {
        
    }
    
    func returnProgress(progress : Float)
    {
        
    }
    func returnStatus(status : String)
    {
        
    }
    
    func returnProgressAndStatus (progress : Float, status : String)
    {
        print("progress: \(progress)")
    }
    
    
    @IBAction func submitButtonTouched(sender: AnyObject)
    {
        self.validateFieldsAndLoginUser(self.usernameField)
    }
    
    @IBAction func onBackButton(sender: AnyObject) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKindOfClass(UserAccessViewController) {
                self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }

    }
    
    func setConstrainsFor4S()
    {
        self.emailImageHeightConstrain?.constant = 40
        self.emailFieldHeightConstrain?.constant = 40
        self.firstNameHeightConstrain?.constant = 40
        self.firstNameFieldConstrain?.constant = 40
        self.lastNameHeightConstrain?.constant = 40
        self.lastNameFieldHeightConstrain?.constant = 40
        self.usernameHeightConstrain?.constant = 40
        self.usernameFieldHeightConstrain?.constant = 40
        self.invitationHeightConstrain?.constant = 40
        self.invitationFieldHeightConstrain?.constant = 40
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userCoordinate = manager.location!.coordinate
        
        if (!self.locationSuccessfulySent)
        {
            MVDataManager.userAutoLocation(MVParameters.sharedInstance.currentMVUser.id, latitude: self.userCoordinate.latitude, longitude: self.userCoordinate.longitude, successBlock: { response in
                print(response)
                self.locationSuccessfulySent = true
                self.locationManager.stopUpdatingLocation()
                }, failureBlock: { failure  in
                    print(failure)
            })
        }
    }
    
    
    
    
    
}
