//
//  SharingViewController.swift
//  MOVV
//
//  Created by Yuki on 30/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import FBSDKShareKit


protocol SharingViewControllerDelegate {
    func dismissViewCon(viewCon: SharingViewController)
    func copysharelink(viewCon:SharingViewController)
    func sharetoinstagram(viewCon: SharingViewController)
    func sharetotwitter(viewCon: SharingViewController)
    func sharetofacebook(viewCon: SharingViewController)
    func sharetomessage(viewCon: SharingViewController)
    func report(viewCon: SharingViewController)
}

class SharingViewController: UIViewController {
    var delegate: SharingViewControllerDelegate? = nil
    var VideoURLStr : String!
    var ThumbnailURLStr : String!
    var ShareLinkStr : String!
    var product:MVProduct!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancel_clicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.dismissViewCon(self)
        }
    }
    
    
    @IBAction func report_clicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.report(self)
        }
    }
    
    
    @IBAction func message_clicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.sharetomessage(self)
        }
    }
    
    
    @IBAction func facebook_clicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.sharetofacebook(self)
        }
    }
    
    
    @IBAction func twitter_clicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.sharetotwitter(self)
        }
    }
        
    
    @IBAction func instagram_clicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.sharetoinstagram(self)
        }
    }
    
    
    @IBAction func copysharelink_clicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.copysharelink(self)
        }
    }
    func showAlertFeatureNotAvailable()  {
        let alertController = MOVVAlertViewController(title: nil, message: "Not available at the moment”", preferredStyle: .Alert)
        alertController.shouldAutorotate()
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (_) in }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) {
        }
    }
}
