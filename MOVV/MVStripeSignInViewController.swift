//
//  MVStripeSignInViewController.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 14.08.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

@objc protocol MVStripeSignInViewControllerDelegate
{
    func backButtonTouched()
    
}
@objc class MVStripeSignInViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var responseMessageLabel: UILabel!
    weak var delegate : MVStripeSignInViewControllerDelegate? = nil
    var visualEffectView : UIVisualEffectView!
    var responseMessage : String!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            addBlurEffect()
        }
        
        self.responseMessageLabel.textColor = MOVVGreen

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {

        let image : UIImage = UIImage(named: "navbarVideo")!
        self.navigationController!.navigationBar.setBackgroundImage(image,forBarMetrics: .Default)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
        //TODO: replace MOVV test publishable_key with live key
        let address : String = "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_6nH0lrRPpqmjiyTqZ48TRgmk9WWEC9VD&scope=read_write"
        
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string:  address)!))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if (self.navigationController != nil) {
            self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.delegate?.backButtonTouched()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: WebView
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        
        print("response \(request) \n")
        
        
        if (request.URL!.absoluteString.rangeOfString("The+user+denied+your+request") != nil) {
            self.navigationController?.popViewControllerAnimated(true)
            return false

        }
        else if ((request.URL!.absoluteString.rangeOfString("http://dev.flip.hr") != nil))// && (request.URL!.absoluteString!.rangeOfString("token?client_secret=") == nil))
        {

            let serverUrl : String! = request.URL!.absoluteString
       
            let manager = AFHTTPRequestOperationManager()
            manager.responseSerializer.acceptableContentTypes = NSSet(objects:"application/json", "text/json", "text/javascript", "text/html") as Set<NSObject>
            manager.POST( serverUrl,
                parameters: nil,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    print(responseObject)

                    self.responseMessage = (responseObject as! NSDictionary)["message"] as? String
                    self.sendUserDataToDatabase(responseObject as! NSDictionary)
                },
                failure: { (operation: AFHTTPRequestOperation?,error: NSError!) in
                    print(error)
                    SVProgressHUD.popActivity()
            })
            
            
            return false
        }
        
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.popActivity()
    }
    
    func displayResponseMessage(message : String)
    {
        self.responseMessageLabel.hidden = false
        self.webView.hidden = true
        self.responseMessageLabel.text = message
    }
    
    func sendUserDataToDatabase(response : NSDictionary)
    {
        if((response["status"] as! NSString).integerValue == 1)
        {
            let publishableKey : String! = response["publishable_key"] as? String
            let accessToken : String! = response["access_token"] as? String
            let stripeUserId : String! = response["stripe_user_id"] as? String
            
            MVDataManager.stripeAddUserPublishableKey(MVParameters.sharedInstance.currentMVUser.id, publishableKey: publishableKey, accessToken: accessToken, stripeUserID : stripeUserId, successBlock: { response in
                print(response)
                self.displayResponseMessage(self.responseMessage)
                SVProgressHUD.popActivity()
                
            }, failureBlock: { failure in
                print(failure)
                SVProgressHUD.popActivity()
            })
        }
    }
    
    func addBlurEffect() {
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        self.visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        self.visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
        
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
