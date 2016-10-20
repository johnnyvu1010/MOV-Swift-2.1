//
//  MVShareViewController.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 14.10.2015..
//  Copyright © 2015. Martino Mamic. All rights reserved.
//

import UIKit
import TwitterKit
import FBSDKShareKit
import Photos
import IQKeyboardManager

import SVProgressHUD
import CoreLocation
import AFNetworking
import PhotosUI

import AVFoundation
import AVKit
import AssetsLibrary

protocol MVShareViewControllerDelegate {
    func dissmisCameraView()
}

class MVShareViewController: UIViewController, UIDocumentInteractionControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var copyURLButton: UIButton!
    @IBOutlet var facebookShareButton: UIButton!
    @IBOutlet var twiterShareButton: UIButton!
    @IBOutlet var instagramShareButton: UIButton!
    @IBOutlet var buttonDone: UIButton!
    @IBOutlet var labelSubTitle: UILabel!
    
    
    @IBOutlet weak var socialSharingView: UIView!
    @IBOutlet weak var instagramNameInputView: UIView!
    
    @IBOutlet weak var buttonInputDone: UIButton!
    @IBOutlet weak var textFieldInstagramName: UITextField!
    
    @IBOutlet weak var m_constraintSocialViewCenter: NSLayoutConstraint!
    @IBOutlet weak var m_constraintIGNameViewCenter: NSLayoutConstraint!
    
    
    var productTitle : String!
    var shareUrl : String!
    var shareImg : UIImage!
    var imgLocalPath: NSURL!
    var delegate : MVShareViewControllerDelegate! = nil
    var imageMain : UIImageView!
    var documentController : UIDocumentInteractionController!
    var docController = UIDocumentInteractionController()
    var shareVideo: NSURL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.copyURLButton.layer.borderColor = UIColor(red: 150/255.0, green: 235/255.0, blue: 98/255.0, alpha: 1).CGColor
        textFieldInstagramName.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        labelSubTitle.text = productTitle
    }
    
    @IBAction func facebookButtonSelected(sender: AnyObject) {
        let slComposeViewController:SLComposeViewController = SLComposeViewController.init(forServiceType: SLServiceTypeFacebook)
        slComposeViewController.setInitialText("Hey guys! \nCheck out this \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)")
        slComposeViewController.addURL(NSURL(string: "\(shareUrl)"))
        self.presentViewController(slComposeViewController, animated: true) {
        }
    }
    

    
    @IBAction func twiterShareButtonSelected(sender: AnyObject) {
        let slComposeViewController:SLComposeViewController = SLComposeViewController.init(forServiceType: SLServiceTypeTwitter)
        slComposeViewController.setInitialText("Hey guys! \nCheck out this \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)")
        slComposeViewController.addURL(NSURL(string: "\(shareUrl)"))
        self.presentViewController(slComposeViewController, animated: true) {
        }
    }
    
    
    @IBAction func copyURLButtonTouched(sender: AnyObject) {
        let pasteboard : UIPasteboard! = UIPasteboard.generalPasteboard()
        if(self.shareUrl != nil){
            pasteboard.URL = NSURL(string: "\(shareUrl)")!
            let alertView : UIAlertController = UIAlertController(title: "", message: "Share URL is copied to clipoard!", preferredStyle: UIAlertControllerStyle.Alert)
            let action : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertView.addAction(action)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        return documentsFolderPath
    }
    

    @IBAction func instagramShareButtonSelected(sender: AnyObject) {
//        UIView.animateWithDuration(1.0, delay: 0.0,
//                                   usingSpringWithDamping: 0.25,
//                                   initialSpringVelocity: 0.0,
//                                   options: [],
//                                   animations: {
////                                    self.socialSharingView.hidden = true
//                                    self.m_constraintIGNameViewCenter.constant = 0.0
//                                    self.m_constraintSocialViewCenter.constant = 400.0
//                                    self.view.layoutIfNeeded()
//                                    
//            }, completion: nil)

        /*
        UIView.animateWithDuration(1.0, delay: 0.0,
                                   usingSpringWithDamping: 0.25,
                                   initialSpringVelocity: 0.0,
                                   options: [],
                                   animations: {
                                    self.instagramNameInputView.layer.position.x += 400.0
            }, completion: nil)
    */
        UIView.animateWithDuration(0.5, animations: {
            self.view.alpha = 0
            }, completion: { (complete) in
                if complete{
                    self.view.removeFromSuperview()
                    self.delegate.dissmisCameraView()
                    let homeViewController = HomeViewController()
                    homeViewController.shareUrl = self.shareUrl
                    homeViewController.shareVideo = self.shareVideo
                    homeViewController.productTitle = self.productTitle
                    homeViewController.downloadVideo()
                }
        })

    }
    
    @IBAction func buttonDoneTapped(sender: UIButton) {
        UIView.animateWithDuration(0.5, animations: {
            self.view.alpha = 0
            }, completion: { (complete) in
                if complete{
                    self.view.removeFromSuperview()
                    self.delegate.dissmisCameraView()
                }
        })
    }

    @IBAction func buttonInputDoneTapped(sender: AnyObject) {
        let instagramURL = NSURL(string: "instagram://app")
        if(UIApplication.sharedApplication().canOpenURL(instagramURL!)) {
            let fullPath: String = (NSURL(string: documentsDirectory())?.URLByAppendingPathComponent("insta.igo").absoluteString)!
            UIImagePNGRepresentation(self.shareImg)!.writeToFile(fullPath, atomically: true)
            let rect = CGRectMake(0, 0, 0, 0)
            let igImageHookFile = NSURL(string: "file:/\(fullPath)")
            self.docController = UIDocumentInteractionController(URL: igImageHookFile!)
            self.docController.UTI = "com.instagram.exclusivegram"
            self.docController.delegate = self
            self.docController.annotation = ["InstagramCaption":"Text"]
            self.docController.presentOpenInMenuFromRect(rect, inView: self.view, animated: true)
        } else {
            print("no instagram found")
        }
        if (self.shareUrl != nil) {
            UIPasteboard.generalPasteboard().string = "Hey guys! \nCheck out this \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)"
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:false)]
            let fetchResult = PHAsset.fetchAssetsWithMediaType(.Video, options: fetchOptions)
            if let lastAsset = fetchResult.firstObject as? PHAsset {
                let url = NSURL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")
                if UIApplication.sharedApplication().canOpenURL(url!) {
                    UIApplication.sharedApplication().openURL(url!)
                }
            }
        } else {
            let alert: MOVVAlertViewController = MOVVAlertViewController(title: "Instagram not installed", message: "Please install instagram application for this feature", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("no instagram found")
        }
    }
    
    //MARK : UITEXTFIELD DELEGATE
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }

}
