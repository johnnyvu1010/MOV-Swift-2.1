//
//  LoginViewController.swift
//  MOVV
//
//  Created by Mac on 5/16/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import AFNetworking
import IQKeyboardManager
import SVProgressHUD
import FLAnimatedImage
import CoreLocation

class LoginViewController: UIViewController {


    @IBOutlet var animatedImageView: FLAnimatedImageView!
    @IBOutlet var usernameField: TextFieldValidator!
    @IBOutlet var passwordField: TextFieldValidator!

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginWithFacebookButton: UIButton!
    
    @IBOutlet var usernameHeightConstrain: NSLayoutConstraint!
    @IBOutlet var usernameFieldHeightConstrain: NSLayoutConstraint!
    @IBOutlet var passwordHeightConstrain: NSLayoutConstraint!
    @IBOutlet var passwordFieldHeightConstrain: NSLayoutConstraint!
    
    var fields:NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UIScreen.mainScreen().bounds.height == 480)
        {
            self.setConstrainsFor4S()
        }
        
        self.loginButton.layer.borderWidth  = 1.0
        self.loginButton.layer.cornerRadius = 3.0
        self.loginButton.layer.borderColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor

        
        self.preferredStatusBarStyle()
        fields = NSMutableArray()
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        setupFields()
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //self.navigationController! .setNavigationBarHidden(false, animated: false)
        
        navigationItem.title = "Login";
        setupButtons()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "signUpSegue"){
            let signUpVC = segue.destinationViewController as! SignUpViewController
            signUpVC.isFacebookSignUp = false;
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.setBackButtonBackgroundImage (UIImage (named: "back"), forState: .Normal, barMetrics: .Default);
            navigationItem.backBarButtonItem = backItem
            navigationItem.title = "SignUp"
        }
    }
    
    // MARK: Layout
    func setupFields(){
        
        usernameField.addRegx("[A-Za-z0-9]{2,18}", withMsg: "Only alphanumeric please")
    }
    
    func setupButtons() {
        passwordField.returnKeyType = .Next
        usernameField.returnKeyType = .Go
    }
    
    func setConstrainsFor4S()
    {

        self.usernameHeightConstrain.constant = 40
        self.usernameFieldHeightConstrain.constant = 40
        self.passwordHeightConstrain.constant = 40
        self.passwordFieldHeightConstrain.constant = 40
    }
    
    func showHome(){
        if(NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") != nil){
            if(NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") as! Bool == false){
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.performSegueWithIdentifier("showOnboarding", sender: nil)
            } else {
                self.performSegueWithIdentifier("showRoot", sender: nil)
            }
        } else {
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.performSegueWithIdentifier("showOnboarding", sender: nil)
        }
    }
    
    @IBAction func onBackButton(sender: AnyObject) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKindOfClass(UserAccessViewController) {
                self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("signUpSegue", sender: nil)
    }
    @IBAction func loginButtonPressed(sender: AnyObject) {

    }
    
    @IBAction func loginWithFacebookButtonPressed(sender: AnyObject) {
        
    }

}