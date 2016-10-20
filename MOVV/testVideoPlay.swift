//
//  testVideoPlay.swift
//  MOVV
//
//  Created by My Star on 6/5/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit
import AVFoundation
import AVKit
import BBBadgeBarButtonItem
import IQKeyboardManager
import SVProgressHUD
import Branch




protocol testVideoPlayDelegate:class
{
    func productLikeStateChanged(product : MVProduct)
}




class testVideoPlay: UIViewController, UIPopoverPresentationControllerDelegate, PopupVideoProfileDelegate{
    
    
    private var player:AVPlayer!
    private var playerIsPlaying : Bool = false
    var productDetail : MVProduct!
    var selectedProductIndex : Int!
//    let g_Url : NSURL
    var path : String = ""
    
    private var badgeButtonItem: BBBadgeBarButtonItem!
    var blurInt: Int! = 0
    private var isPresentedViaDeepLink: Bool = false
    
    
    weak var delegate : testVideoPlayDelegate? = nil
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var imagePlayC: UIImageView!
    @IBOutlet var playStatuButton: UIButton!
    @IBOutlet var buttonAddBadge: UIButton!
    @IBOutlet var backButton: UIButton!
    private var playerController:AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(true)
        
//        if(self.player != nil)
//        {
//            self.player.play()
//        }
        
        //cell.itemDetailsButton.addTarget(self, action: #selector(HomeViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        HiddenNavigationTabbar()
        backButton.hidden = false
        playVideoUrl()
        self.preferredStatusBarStyle()
        //addRightNavItemOnView()
        //playVideoUrl()
        
//        let path : String = productDetail.videoFile.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
//        
//        if(path.length > 0){
//        }

    }
    func HiddenNavigationTabbar(){
        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        for var i=0;i<self.navigationController?.navigationBar.subviews[0].subviews.count;i += 1 {
            self.navigationController?.navigationBar.subviews[0].subviews[i].removeFromSuperview()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.userInteractionEnabled = true
        self.preferredStatusBarStyle()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        if(self.player != nil)
        {
            self.player.pause()
        }
    }
    
    @IBAction func backButtonClick(sender: UIBarButtonItem) {
        //navigationController?.popViewControllerAnimated(true)
        
        
//        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
//        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("popupVideo")  as! PopupVideoProfile
//        detailVC.modalPresentationStyle = UIModalPresentationStyle.Popover
//        let popover : UIPopoverPresentationController = detailVC.popoverPresentationController!
////        popover.barButtonItem = sender as! UIBarButtonItem
//        self.selectedProductIndex = sender.tag
//        detailVC.productDetail    = productDetail
//        self.navigationController!.pushViewController(detailVC, animated: true)
        
        
        
        
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("popupVideo")  as! PopupVideoProfile

        detailVC.current_delegate = self
        detailVC.productDetail = productDetail
        self.presentViewController(detailVC, animated: true, completion: nil)
        
        
        
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("popupVideo")
//        
//        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
//        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
//        popover.barButtonItem = sender
//        
//        popover.delegate = self
//        presentViewController(vc, animated: true, completion: nil)
    }
    
    func onDismiss(id : Int){
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = id
        self.navigationController!.pushViewController(userProfileVC, animated: true)
        
        NSLog("************** Delegate **************")
    }
    
    func popupPlay(flag: Int) {
        
    }
    
    
    
    
    
    @IBAction func onPlayButton(sender: AnyObject) {
        if(playerIsPlaying)
        {
            player!.pause()
            let image = UIImage(named: "playButton.png")
            playStatuButton.setBackgroundImage(image, forState: UIControlState.Normal)
            
            self.playerIsPlaying = false
        }
        else{
//            let time_1 = Float(self.player.currentTime().value)
//            let time_2 = Float(self.player.currentTime().timescale)
//            
//            let i = AVPlayerActionAtItemEnd.Advance
//            let i1 = AVPlayerActionAtItemEnd.Advance
//            let i11 = AVPlayerActionAtItemEnd.Advance
            
            player!.play()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
                // report for an error
            }
            let image = UIImage(named: "pauseButton.png")
            playStatuButton.setBackgroundImage(image, forState: UIControlState.Normal)
            
            self.playerIsPlaying = true
        }
    }
    @IBAction func addBadgeButtonClick(sender: AnyObject) {
        
        if(self.player != nil)
        {
            player!.pause()
            let image = UIImage(named: "playButton.png")
            playStatuButton.setBackgroundImage(image, forState: UIControlState.Normal)        }
        
        
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let inboxVC = mainSt.instantiateViewControllerWithIdentifier("inboxVC")  as! InboxViewController
        inboxVC.isUserProfile = false
        inboxVC.blurInt = self.blurInt
        self.navigationController?.pushViewController(inboxVC, animated: true)
    }
    func addRightNavItemOnView() {
        let inboxButton: UIButton = UIButton(type: UIButtonType.Custom)
        inboxButton.frame = CGRectMake(0, 0, 25, 20)
        inboxButton.setImage(UIImage(named:"inboxButton.png"), forState: UIControlState.Normal)
        inboxButton.addTarget(self, action: #selector(testVideoPlay.inboxButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.badgeButtonItem = BBBadgeBarButtonItem(customView: inboxButton)
        self.badgeButtonItem.badgeBGColor = UIColor.redColor()
        self.badgeButtonItem.badgeTextColor = UIColor.whiteColor()
        self.badgeButtonItem.shouldHideBadgeAtZero = true
        self.badgeButtonItem.badgeMinSize = 12
        self.badgeButtonItem.badgeOriginX = -5
        self.badgeButtonItem.badgeOriginY = -5
        self.badgeButtonItem.badgeFont = UIFont.systemFontOfSize(8)
        self.badgeButtonItem.badgeValue = "0"
        self.badgeButtonItem.shouldAnimateBadge = false
        
        if self.isPresentedViaDeepLink == true {
            
            let doneBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ItemDetailViewController.closePressed))
            
            self.navigationItem.setRightBarButtonItem(doneBarButtonItem, animated: true)
            
        } else {
            self.navigationItem.setRightBarButtonItem(self.badgeButtonItem, animated: true)
        }
        
        
    }
    
    
    
    @IBAction func inboxButtonPressed(sender:UIButton!) {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let inboxVC = mainSt.instantiateViewControllerWithIdentifier("inboxVC")  as! InboxViewController
        inboxVC.isUserProfile = false
        inboxVC.blurInt = self.blurInt
        self.navigationController?.pushViewController(inboxVC, animated: true)
    }
    
    func playVideoUrl(){
        if(productDetail.videoFile != nil){
            path  = productDetail.videoFile.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
            if(path.length > 0){
                
                if let url : NSURL = NSURL(string:  path) {
                    
                    if(!playerIsPlaying)
                    {
                        
                        player = AVPlayer(URL: url)
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying", name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
                        
                        if(player != nil){
                            playerController = AVPlayerViewController()
                            playerController!.player = player
                            self.addChildViewController(playerController!)
                            playerController!.view.alpha = 0
                            
                            playerController!.view.frame = CGRectMake(0, 0, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame))
                            imageView?.addSubview(playerController.view)
                            imageView.userInteractionEnabled = true
                            playerController?.didMoveToParentViewController(self)
                            player!.play()
                            do {
                                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                            }
                            catch {
                                // report for an error
                            }
                            playerController.showsPlaybackControls = false
                            playerIsPlaying = true
                        }
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.playerController!.view.alpha = 1
                            
                        })
                    }
                }
                
            }

        }
    }
       
    
}
