//
//  searchGifPlayViewController.swift
//  MOVV
//
//  Created by My Star on 9/2/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AVKit
import MediaPlayer

class searchGifPlayViewController: UIViewController {

    @IBOutlet var yesButton: UIButton!
    @IBOutlet var skipButton: UIButton!
    var manager: OneShotLocationManager?
    var moviePlayer : MPMoviePlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.skipButton.layer.borderWidth = 1
        self.skipButton.layer.borderColor = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        self.skipButton.layer.cornerRadius = 3
        self.yesButton.layer.borderWidth = 1
        self.yesButton.layer.borderColor = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        self.yesButton.layer.cornerRadius = 3
        self.startGifPlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startGifPlay(){
        let path = NSBundle.mainBundle().pathForResource("GeoGif", ofType:"mp4")
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
    
    @IBAction func onYesButton(sender: AnyObject) {
        self.moviePlayer.stop()
        
        // MARK: Location
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                let geoCoder = CLGeocoder()
                geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) -> Void in
                    if(error == nil){
                        
                        if let pm = placemarks?.first {
                            adress = "\(pm.locality!), \(pm.country!)"
                        }
                        
                    }
                })
            } else if let err = error {
                print(err)
            }
            
            // destroy the object immediately to save memory
            self.manager = nil
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSkipButton(sender: AnyObject) {
        self.moviePlayer.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
