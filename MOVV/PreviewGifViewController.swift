//
//  PreviewGifViewController.swift
//  MOVV
//
//  Created by My Star on 9/2/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class PreviewGifViewController: UIViewController {

    @IBOutlet var skipButton: UIButton!
    @IBOutlet var yesButton: UIButton!
    
    
    var moviePlayer : MPMoviePlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.skipButton.layer.borderWidth = 1
        self.skipButton.layer.borderColor = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        self.skipButton.layer.cornerRadius = 3
        self.yesButton.layer.borderWidth = 1
        self.yesButton.layer.borderColor = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        self.yesButton.layer.cornerRadius = 3
        self.startOnboardingVideo()
    }
    
    func startOnboardingVideo()
    {
        
        let path = NSBundle.mainBundle().pathForResource("PushGif", ofType:"mp4")
        let url = NSURL.fileURLWithPath(path!)
        self.moviePlayer = MPMoviePlayerController(contentURL: url)
        if let player = self.moviePlayer {
            
            let xyz : CGFloat = self.view.frame.size.height/2 - self.view.frame.size.width*4/12
            //xy = self.view.frame.size.height*0.8
            player.view.frame = CGRect(x: 0, y: xyz, width: self.view.frame.size.width, height: self.view.frame.size.width*4/6)
            player.view.sizeToFit()
            player.scalingMode = MPMovieScalingMode.Fill
            player.fullscreen = true
            player.controlStyle = MPMovieControlStyle.None
            player.movieSourceType = MPMovieSourceType.File
            player.repeatMode = MPMovieRepeatMode.One
            player.play()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
                // report for an error
            }
            self.view.addSubview(player.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSkipButton(sender: AnyObject) {
        self.moviePlayer.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onYesButton(sender: AnyObject) {
        self.moviePlayer.stop()
        // MARK: Push registration
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        self.moviePlayer.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
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
