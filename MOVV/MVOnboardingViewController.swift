//
//  MVOnboardingViewController.swift
//  MOVV
//
//  Created by Kresimir Retih on 21/03/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer



class MVOnboardingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var onboardingVideoView: UIView!
    
    @IBOutlet var skipButton: UIButton!
    var player : AVPlayer!
    
    var moviePlayer : MPMoviePlayerController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.skipButton.layer.borderWidth = 1
        self.skipButton.layer.borderColor = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        self.skipButton.layer.cornerRadius = 3
        

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "login_BG.png")!)
        

        //self.view.backgroundColor = UIColor.yellowColor()
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    func startOnboardingVideo()
    {

        
        let path = NSBundle.mainBundle().pathForResource("movvOndoarding", ofType:"mp4")
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
        
        


//        let filePath : NSURL! = NSBundle.mainBundle().URLForResource("movvOndoarding", withExtension: "mp4")
//        self.player = AVPlayer(URL: filePath)
//        let playerLayer = AVPlayerLayer(player: self.player)
//        
//        playerLayer.frame =  CGRectMake(0, 0, screenWidth, screenWidth*4/6)//self.onboardingVideoView.bounds
////        playerLayer.frame =  CGRectMake(0, 0, screenWidth, screenHeight)
//        self.onboardingVideoView.layer.addSublayer(playerLayer)
//        self.player.play()
    }
    
    
    @IBAction func skipButtonTouched(sender: AnyObject) {
        self.moviePlayer.pause()
        //self.player.pause()
        
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("homeSegue", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let signUpVC = segue.destinationViewController as! CustomTabBarController
        signUpVC.insNew = true
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = UITableViewCell()
        
        if(indexPath.row == 0)
        {
            cell = tableView.dequeueReusableCellWithIdentifier("firstCell")
        }
        else if(indexPath.row == 1)
        {
            cell = tableView.dequeueReusableCellWithIdentifier("secondCell")
        }
        else if(indexPath.row == 2)
        {
            cell = tableView.dequeueReusableCellWithIdentifier("thirdCell")
        }
        return cell
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
