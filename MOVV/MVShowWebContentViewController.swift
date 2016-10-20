//
//  MVHowItWorksViewController.swift
//  MOVV
//
//  Created by Ivan Barisic on 01/09/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class MVShowWebContentViewController: UIViewController, UIWebViewDelegate {
    //MARK: Outlets

    @IBOutlet weak var vewView: UIWebView!
    var urlString : String!
    
    
    
    //MARK: Variables
    var isDoItButtonHidden:Bool!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!urlString.isEmpty) {
            self.vewView.loadRequest(NSURLRequest(URL: NSURL(string: self.urlString)!))
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait]
        return orientation

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    //MARK:- UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView){
        SVProgressHUD.show()
    }
    func webViewDidFinishLoad(webView: UIWebView){
        SVProgressHUD.popActivity()

    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        SVProgressHUD.popActivity()
    }
}
