//
//  PreviewVideoController.swift
//  MOVV
//
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

class PreviewVideoController: UIViewController, AVPlayerViewControllerDelegate {
    
    private var player:AVPlayer!
    var path : String = ""
    private var playerController:AVPlayerViewController!
    var timer: NSTimer!
    
    
    @IBOutlet var imageViewPlay: UIImageView!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var doneButton: UIView!
    @IBOutlet var doneBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneBt.layer.borderWidth = 1
        doneBt.layer.borderColor = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        doneBt.layer.cornerRadius = 3
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        //        self.player.pause()
    }
    //
    override func viewWillAppear(animated: Bool) {
        HiddenNavigationTabbar()
        playVideoUrl()
    }
    
    @IBAction func onDoneButton(sender: AnyObject) {
        self.player.pause()
        self.timer.invalidate()
        self.timer = nil
        NSNotificationCenter.defaultCenter().postNotificationName("previewDone", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func playVideoUrl(){
        let path = NSBundle.mainBundle().pathForResource("preview", ofType:"mp4")
        let url = NSURL.fileURLWithPath(path!)
        
        
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
            
            progress.progress = 0.0
            //self.timer.invalidate()
            self.timer = nil
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoPlayViewController.ProgressFunc), userInfo: nil, repeats: true)
            
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.playerController!.view.alpha = 1
            
        })
        
    }
    
    func playerDidFinishPlaying(){
        NSLog("Video End")
        self.timer.invalidate()
        self.timer = nil
        NSNotificationCenter.defaultCenter().postNotificationName("previewDone", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func ProgressFunc(){
        let currentItem = self.player.currentItem
        
        if((self.player.currentItem) == nil)
        {
            NSLog("Video file Loading error")
            self.progress.progress = 0
            return
        }
        NSLog("Timer Progress")
        let duration: Float = Float(CMTimeGetSeconds((currentItem?.asset.duration)!))
        let currentTime: Float = Float(CMTimeGetSeconds(self.player.currentTime()))
        
        self.progress.progress = currentTime/duration
        if (currentTime > duration) {
            self.timer.invalidate()
        }
    }
}

