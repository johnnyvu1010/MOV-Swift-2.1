//
//  VideoPlayViewController.swift
//  MOVV
//
//  Created by My Star on 6/7/16.
//  Copyright © 2016 Maksim M. All rights reserved.
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

protocol VideoPlayViewControllerDelegate:class
{
    func productLikeStateChanged(product : MVProduct)
}


class VideoPlayViewController: UIViewController, UIPopoverPresentationControllerDelegate, PopupVideoProfileDelegate, AVPlayerViewControllerDelegate, AVPictureInPictureControllerDelegate {
    
    private var player:AVPlayer!
    private var playerIsPlaying : Bool = false
    private var playerDone : Bool = false
    var productDetail : MVProduct!
    var selectedProductIndex : Int!
    var path : String = ""
    private var playerController:AVPlayerViewController!
    var timer: NSTimer!
    var blurInt: Int! = 0
    var commentFlag: Int! = 0
    
    weak var delegate : VideoPlayViewControllerDelegate? = nil
    
    
    @IBOutlet var myView: UIView!
    @IBOutlet var imageViewPlay: UIImageView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var addCartButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet weak var slideupImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressBar.progress = 0.0
        
        let swipeSelector : Selector = #selector(VideoPlayViewController.popupWindowView(_:))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: swipeSelector)
        
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        imageViewPlay.addGestureRecognizer(upSwipe)
        
        
        self.nameLabel.text = productDetail.name
        self.priceLabel.text = "$\(productDetail.price)"
        addCartButton.hidden = (productDetail.isSold == 1)
        

       if productDetail.user.id == MVParameters.sharedInstance.currentMVUser.id{
            addCartButton.tintColor = UIColor.whiteColor()
            addCartButton.hidden = false
            addCartButton.setTitle("EDIT", forState: UIControlState.Normal)
            addCartButton.enabled = true
            addCartButton .setBackgroundImage(nil, forState: .Normal)
            addCartButton .setImage(nil, forState: .Normal)
            addCartButton .setBackgroundImage(nil, forState: .Selected)
            addCartButton .setImage(nil, forState: .Selected)
            addCartButton .setBackgroundImage(nil, forState: .Highlighted)
            addCartButton .setImage(nil, forState: .Highlighted)
            addCartButton .setBackgroundImage(nil, forState: .Disabled)
            addCartButton .setImage(nil, forState: .Disabled)
            addCartButton.backgroundColor = UIColor(red: 63/255.0, green:  216/255.0, blue:  63/255.0, alpha:  1)
            addCartButton.clipsToBounds = true
            addCartButton.layer.cornerRadius = addCartButton.frame.size.height/2
        }
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (playerDone) {
            let second : Int64 = 0
            let preferredTimeScale : Int32 = 1
            let seekTime : CMTime = CMTimeMake(second, preferredTimeScale)
            
            player!.seekToTime(seekTime)
            self.blinkOnSlideImageView()
            
            player!.play()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
                // report for an error
            }
            playButton.hidden = true
            self.playerIsPlaying = true
            playerDone = false
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoPlayViewController.ProgressFunc), userInfo: nil, repeats: true)
            
            return
            
        }
        playVideo()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        if(self.player != nil)
        {
            self.player.pause()
        }
        self.timer.invalidate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        playButton.hidden = true
        playButton.enabled = false
        UIApplication.sharedApplication().statusBarHidden = true
        self.blurInt = 1
        HiddenNavigationTabbar()
        backButton.hidden = false
        if(playerIsPlaying)
        {
            self.player.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoPlayViewController.ProgressFunc), userInfo: nil, repeats: true)
            return
        }
        playVideoUrl()
        if(commentFlag == 1){
            popupSubFunc()
        }
        
    }
    
    @IBAction func onBackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onAddCartButton(sender: AnyObject) {
        if (productDetail.user.id == MVParameters.sharedInstance.currentMVUser.id){
           if let viewController = MVEditProductViewController(nibName: "MVEditProductViewController", bundle: nil) as? MVEditProductViewController
           {
                player!.pause()
                playerIsPlaying = false
                let navigationController = UINavigationController(rootViewController: viewController)
                viewController.item = productDetail
                navigationController.modalPresentationStyle = .OverCurrentContext
                viewController.modalPresentationStyle = .OverCurrentContext
                self.presentViewController(navigationController, animated: true, completion: nil)
            }
        }else{
            let main = UIStoryboard(name: "Main", bundle: nil)
            offerPriceVC = main.instantiateViewControllerWithIdentifier("OfferPriceViewController")  as! OfferPriceViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            offerPriceVC.view.translatesAutoresizingMaskIntoConstraints = true
            offerPriceVC.view.frame = UIScreen.mainScreen().bounds
            offerPriceVC.view.alpha = 0;
            offerPriceVC.product = productDetail
            appDelegate.window?.addSubview(offerPriceVC.view)
            UIView.animateWithDuration(0.3) {
                offerPriceVC.view.alpha = 1;
            }
        }
    }
    
    @IBAction func onPlayButton(sender: AnyObject) {
        if (playerDone) {
            let second : Int64 = 0
            let preferredTimeScale : Int32 = 1
            let seekTime : CMTime = CMTimeMake(second, preferredTimeScale)
            
            
            player!.seekToTime(seekTime)
            self.blinkOnSlideImageView()
            
            player!.play()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
                // report for an error
            }
            playButton.hidden = true
            self.playerIsPlaying = true
            playerDone = false
            if(self.timer != nil){
                self.timer.invalidate()
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoPlayViewController.ProgressFunc), userInfo: nil, repeats: true)
            
            return
        }
        playVideo()
    }
    func playVideo(){
        if (player.rate != 0 && player.error == nil){
            if(playerIsPlaying)
            {
                self.blinkOffSlideImageView()
                player!.pause()
                let image = UIImage(named: "playButton.png")
                playButton.setBackgroundImage(image, forState: UIControlState.Normal)
                if(self.timer != nil){
                    self.timer.invalidate()
                }
                playButton.hidden = false
                self.playerIsPlaying = false
            }
            else{
                self.blinkOnSlideImageView()
                player!.play()
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                }
                catch {
                    // report for an error
                }
                if(self.timer != nil){
                    self.timer.invalidate()
                }
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoPlayViewController.ProgressFunc), userInfo: nil, repeats: true)
                playButton.hidden = true
                self.playerIsPlaying = true
            }
            return
            
        }
        if(self.player != nil)
        {
            if(!playerIsPlaying)
            {
                self.blinkOnSlideImageView()
                player!.play()
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                }
                catch {
                    // report for an error
                }
                playButton.hidden = true;
                self.playerIsPlaying = true
                if(self.timer != nil){
                    self.timer.invalidate()
                }
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoPlayViewController.ProgressFunc), userInfo: nil, repeats: true)
            }
        }
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
    
    
    @IBAction func popupWindowView(sender: AnyObject){
        popupSubFunc()
    }
    func popupSubFunc(){
        NSLog("****************************************")
        self.playerIsPlaying = true
        playVideo()
        self.playerIsPlaying = false
        
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("popupVideo")  as! PopupVideoProfile
        
        detailVC.current_delegate = self
        detailVC.productDetail = productDetail
        
//        sleep(2)
        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    func onDismiss(id : Int){
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = id
        self.navigationController!.pushViewController(userProfileVC, animated: true)
        NSLog("************** Delegate **************")
    }
    func popupPlay(flag: Int) {
        if (flag == 1){
            playerIsPlaying = false
            playVideo()
            playerIsPlaying = true
        }
        else if(flag == 2){
            navigationController?.popViewControllerAnimated(true)
        }
        else if(flag == 3){
            let mainSt = UIStoryboard(name: "Main", bundle: nil)
            let inboxVC = mainSt.instantiateViewControllerWithIdentifier("inboxVC")  as! InboxViewController
            inboxVC.isUserProfile = false
            inboxVC.blurInt = self.blurInt
            self.navigationController?.pushViewController(inboxVC, animated: true)
        }
    }
    
    func playVideoUrl(){
        if(productDetail.videoFile != nil){
            path  = productDetail.videoFile.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
            if(path.length > 0){
//                path = "https://s3.amazonaws.com/movv.user-videos/chris_test.m3u8"
                if let url : NSURL = NSURL(string:  path) {
                    
                    if(!playerIsPlaying)
                    {
                        self.blinkOnSlideImageView()
                        player = AVPlayer(URL: url)
                        
                        player?.actionAtItemEnd = .None
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayViewController.playerDidFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
                        
                        if(player != nil){
                            playerController = AVPlayerViewController()
                            playerController!.player = player
                            self.addChildViewController(playerController!)
                            playerController!.view.alpha = 0
                            
                            playerController!.view.frame = CGRectMake(0, 0, CGRectGetWidth(imageViewPlay.frame), CGRectGetHeight(imageViewPlay.frame))
                            imageViewPlay?.addSubview(playerController.view)
                            imageViewPlay.userInteractionEnabled = true
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
                            
                            progressBar.progress = 0.0
                            if(self.timer != nil){
                                self.timer.invalidate()
                            }
                            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoPlayViewController.ProgressFunc), userInfo: nil, repeats: true)
                            //ProgressFunc()
                        }
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.playerController!.view.alpha = 1
                            
                        })
                    }
                }
            }
        }
    }
    func ProgressFunc(){
        let currentItem = self.player.currentItem
        NSLog("Timer Progress")
        if((self.player.currentItem) == nil)
        {
            self.timer.invalidate()
            NSLog("Video file Loading error")
            self.progressBar.progress = 0
            return
        }
        
        let duration: Float = Float(CMTimeGetSeconds((currentItem?.asset.duration)!))
        let currentTime: Float = Float(CMTimeGetSeconds(self.player.currentTime()))
        
        self.progressBar.progress = currentTime/duration
        if (currentTime > duration) {
            self.timer.invalidate()
        }
        //NSLog("Timer Progress")
    }
    func playerDidFinishPlaying(){
        self.blinkOffSlideImageView()
        playerDone = true
        let image = UIImage(named: "playButton.png")
        playButton.setBackgroundImage(image, forState: UIControlState.Normal)
        playButton.hidden = false
        self.timer.invalidate()
        NSLog("#################################")
        self.onPlayButton(playButton)
    }
    
    func blinkOnSlideImageView() {
        UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.Repeat, animations: {
            self.slideupImageView.alpha = 0.0
        }, completion: nil)
    }
    
    func blinkOffSlideImageView() {
        UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.slideupImageView.alpha = 1.0
            }, completion: nil)
    }
}
