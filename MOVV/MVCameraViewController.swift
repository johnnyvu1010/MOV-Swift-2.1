
//  MVCameraViewController.swift
//  MOVV
//
//  Created by Ivan Barisic on 28/08/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import Foundation
import SCRecorder
import SVProgressHUD
import QuartzCore
import AVKit



extension SCRecorder {
    
    private func _videoConnection() -> AVCaptureConnection? {
        
        if let _outputs = self.captureSession?.outputs {
            
            for output in _outputs {
                if let _captureOutput = output as? AVCaptureVideoDataOutput {
                    
                    for connection in _captureOutput.connections {
                        if let captureConnection = connection as? AVCaptureConnection {
                            
                            for port in captureConnection.inputPorts {
                                if let _port = port as? AVCaptureInputPort {
                                    if _port.mediaType == AVMediaTypeVideo {
                                        return captureConnection
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        return nil
        
    }
    
    func attemptTurnOffVideoStabilization() {
        
        self.beginConfiguration()
        
        let videoConnection = self._videoConnection()
        if let connection = videoConnection {
            
            if connection.supportsVideoStabilization {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Off
            }
            
        }
        
        self.commitConfiguration()
        
    }
    
}


enum MVCameraType : String {
    case Video = "Item Video"
    case FirstStep = "Video required!"
    case SecondStep = "Take preview image!"
}

class MVCameraViewController: UIViewController, UIPopoverPresentationControllerDelegate, MVStripeSignInViewControllerDelegate,
MVInfoMessageViewControllerDelegate,MVNextInfoMessageViewControllerDelegate, SCRecorderDelegate, MVTimerOptionsDelegate, MVEditItemDelegate, SCRecorderToolsViewDelegate, UIImagePickerControllerDelegate, PopupMessageViewControllerDelegate{
    
    // MARK: Outlets
    @IBOutlet weak var timerCountdownLabel: UILabel!
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordButtonLandscape: UIButton!
    
    //    @IBOutlet weak var videoPreviewView: SCImageView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var deletaLastSegmentButton: UIButton!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var actionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeTrackingWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var timerLeftSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dismissButtonLandscape: UIButton!
    @IBOutlet weak var flashButtonLandscape: UIButton!
    @IBOutlet weak var cameraSwitchButtonLandscape: UIButton!
    @IBOutlet weak var deleteLastSegmentBottonSpacingConstraint: NSLayoutConstraint!
    @IBOutlet var popoverView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var focusRectangleView: UIView!
    
    @IBOutlet var swipe1: UILabel!
    @IBOutlet var swipe2: UILabel!
    
    @IBOutlet var doneButton: UIButton!
    
    ///////////////
    var player1:AVPlayer?
    var playerGesture:UIGestureRecognizer?
    var playerController:AVPlayerViewController?
    var preview:UIImageView?
    var buttonFlag: Bool! = true
    
    var filterList: Dictionary<Int, String>! = nil
    var context: CIContext!
    var filter: CIFilter!
    var beginImage: CIImage!
    var orientation: UIImageOrientation = .Up //New
    
    //    var pinchZoomGesture: UIPinchGestureRecognizer
    ///////////////mju
    
    // MARK: Variables
    var visualEffectView:UIVisualEffectView?
    var popoverController: MVInfoMessageViewController!
    //    var nextpopoverController: MVNextInfoMessageViewController!
    var timerOptionsViewController: MVTimerOptionsViewController!
    var editItemViewController :  EditItemViewController!
    var recorder:SCRecorder! = SCRecorder()
    var recordSession:SCRecordSession = SCRecordSession()
    var timerDurationInterval: Int = 0
    var deleteView:UIView? = nil
    var messageStatus:MVCameraType = MVCameraType.Video
    var imageUrl : NSURL!
    var filename : String!
    var recordStarted : Bool = false
    var uploadVideoFileURL : NSURL! = NSURL()
    var uploadImageFileURL: NSURL! = NSURL()
    
    var scimageview : SCFilterImageView!
    
    private var myContext = 0
    
    
    var testFilterView: SCRecorderToolsView!
    
    func swipeableFilterView(swipeableFilterView: SCSwipeableFilterView, didScrollToFilter filter: SCFilter?) {
        
        
        NSLog("***********************************************")
        print(filter?.name ?? "")
        NSLog("***********************************************")
        
        
    }
    func initSettingRecode(){
        self.focusRectangleView.backgroundColor = UIColor.clearColor()
        self.focusRectangleView.layer.borderColor = MOVVGreen.CGColor
        self.focusRectangleView.layer.borderWidth = 1.0
        
        let screenBounds : CGRect! = UIScreen.mainScreen().bounds
        self.videoPreviewView.frame = CGRectMake(0, 0, screenBounds.width, screenBounds.height)
        self.testFilterView = SCRecorderToolsView(frame: CGRectMake(0, 0, screenBounds.width, screenBounds.height))
        self.videoPreviewView.addSubview(self.testFilterView)
        //self.videoPreviewView.
        
        //        self.videoPreviewView.CIImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 1))
        
        self.recorder.previewView = self.videoPreviewView
        //        self.recorder.SCImageView = self.videoPreviewView
        self.recorder.SCImageView?.frame = CGRectMake(0, 0, screenBounds.width, screenBounds.height)
        
        self.recorder.captureSessionPreset = AVCaptureSessionPresetiFrame1280x720
        self.recorder.videoConfiguration
        self.prepareSession()
        
        self.recorder.videoOrientation = AVCaptureVideoOrientation.Portrait
        self.recorder.maxRecordDuration = CMTimeMake(15, 1)
        self.recorder.delegate = self
        self.recorder.videoZoomFactor = 1
        
        self.recorder.flashMode = SCFlashMode.Auto
        
        
        //self.testFilterView.frame = CGRectMake(0, 0, screenBounds.width, screenBounds.height)
        self.testFilterView.delegate = self
        self.recorder.mirrorOnFrontCamera = true
        self.testFilterView.recorder = self.recorder
        
        self.testFilterView.tapToFocusEnabled = true
        self.testFilterView.pinchToZoomEnabled = true
        
    }
    
    func recorderToolsView(recorderToolsView: SCRecorderToolsView, didTapToFocusWithGestureRecognizer gestureRecognizer: UIGestureRecognizer) {
        
        self.focusRectangleView.hidden = false
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            self.focusRectangleView.hidden = true
        }
    }
    
    
    
    
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initSettingRecode()
        self.deletaLastSegmentButton.hidden = true
        self.doneButton.hidden = true
        statusLabel.hidden = true
        
        
        let image = UIImage(named: "done.png")
        doneButton.setBackgroundImage(image, forState: UIControlState.Normal)
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("popupMessageView")  as! PopupMessageViewController
        detailVC.delegate         = self
        self.presentViewController(detailVC, animated: true, completion: nil)
        
    }
    
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        print("buffer")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navbarVideo"), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        if(self.visualEffectView == nil || !self.visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            self.addBlurEffect()
            
        }
        
        
        self.filename = "\(MVParameters.sharedInstance.currentMVUser.id)\(MVHelper.generateIdentifierWithLength(15))"
        MVHelper.sharedInstance.shouldAutorotate = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.recorder.startRunning()
        self.recorder.attemptTurnOffVideoStabilization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        super.viewWillDisappear(animated)
        MVHelper.sharedInstance.shouldAutorotate = false
        
        self.recorder.stopRunning()
        self.recorder.flashMode = SCFlashMode.Off
        self.videoPreviewView = nil
    }
    
    
    override func viewWillLayoutSubviews() {
        //        if(self.popoverController != nil)
        //        {
        //            let screenSize: CGRect = UIScreen.mainScreen().bounds
        //            let screenWidth = screenSize.width
        //            let screenHeight = screenSize.height
        //            self.popoverController.popoverPresentationController?.sourceRect = CGRectMake(screenWidth/2-117, screenHeight/2-57, 235, 115);
        //
        //        }
    }
    
    // MARK: Orientation
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if (toInterfaceOrientation == UIInterfaceOrientation.Portrait) {
            let newMultiplier:CGFloat = UIApplication.sharedApplication().keyWindow!.frame.width < UIApplication.sharedApplication().keyWindow!.frame.height ? UIApplication.sharedApplication().keyWindow!.frame.width / 15 : UIApplication.sharedApplication().keyWindow!.frame.height / 15;
            
            let oldMultiplier:CGFloat = UIApplication.sharedApplication().keyWindow!.frame.width > UIApplication.sharedApplication().keyWindow!.frame.height ? UIApplication.sharedApplication().keyWindow!.frame.width / 15 : UIApplication.sharedApplication().keyWindow!.frame.height / 15;
            
            self.timeTrackingWidthConstraint.constant = CGFloat(CMTimeGetSeconds(self.recorder.session!.duration)) * newMultiplier
            
            for i: Int in 0 ..< self.progressView.subviews.count {
                let separatorView:UIView = self.progressView.subviews[i]
                separatorView.frame = CGRectMake((separatorView.frame.origin.x + 1) / oldMultiplier * newMultiplier - 1, 0, 1, 3)
            }
            
            self.actionViewHeightConstraint.constant = 148
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            self.recordButton.hidden = false
            self.recordButtonLandscape.hidden = true
            self.timerLeftSpacingConstraint.constant = 8
            self.deleteLastSegmentBottonSpacingConstraint.constant = 1
            self.dismissButtonLandscape.hidden = true
            self.flashButtonLandscape.hidden = true
            self.cameraSwitchButtonLandscape.hidden = true
            
            if (self.recorder.session!.segments.count == 0) {
                self.recorder.videoOrientation = AVCaptureVideoOrientation.Portrait
            }
            
        } else if (toInterfaceOrientation == UIInterfaceOrientation.LandscapeLeft || toInterfaceOrientation == UIInterfaceOrientation.LandscapeRight) {
            let newMultiplier:CGFloat = UIApplication.sharedApplication().keyWindow!.frame.width > UIApplication.sharedApplication().keyWindow!.frame.height ? UIApplication.sharedApplication().keyWindow!.frame.width / 15 : UIApplication.sharedApplication().keyWindow!.frame.height / 15;
            
            let oldMultiplier:CGFloat = UIApplication.sharedApplication().keyWindow!.frame.width < UIApplication.sharedApplication().keyWindow!.frame.height ? UIApplication.sharedApplication().keyWindow!.frame.width / 15 : UIApplication.sharedApplication().keyWindow!.frame.height / 15;
            
            self.timeTrackingWidthConstraint.constant = CGFloat(CMTimeGetSeconds(self.recorder.session!.duration)) * newMultiplier
            for i: Int in 0 ..< self.progressView.subviews.count {
                let separatorView:UIView = self.progressView.subviews[i]
                separatorView.frame = CGRectMake((separatorView.frame.origin.x + 1) / oldMultiplier * newMultiplier - 1, 0, 1, 3)
            }
            
            self.actionViewHeightConstraint.constant = 80
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            self.recordButton.hidden = true
            self.recordButtonLandscape.hidden = false
            self.timerLeftSpacingConstraint.constant = newMultiplier * 15 / 2 - newMultiplier
            self.deleteLastSegmentBottonSpacingConstraint.constant = 25
            
            self.dismissButtonLandscape.hidden = false
            self.flashButtonLandscape.hidden = false
            self.cameraSwitchButtonLandscape.hidden = false
            
            if (self.recorder.session!.segments.count == 0) {
                if (toInterfaceOrientation == UIInterfaceOrientation.LandscapeLeft) {
                    self.recorder.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                } else {
                    self.recorder.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                }
            }
        }
        
        UIView.animateWithDuration(0.0015, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.recorder.previewViewFrameChanged()
        self.onTouchOKButton()
        
    }
    
    // MARK: Screen setup
    func addBlurEffect() {
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        self.visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        self.visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(self.visualEffectView!)
    }
    
    func prepareSession() {
        if (self.recorder.session == nil) {
            self.recordSession = SCRecordSession()
            self.recordSession.fileType = AVFileTypeQuickTimeMovie;
            self.recorder.session = self.recordSession
        }
    }
    
    // MARK: STRIPE check
    func checkUserStripeAccount() {
        MVDataManager.userValidateStripe({ (success) -> Void in
            let dict: NSDictionary = success as! NSDictionary
            if (dict["status"] as! String == "0") {
                let alertController:MVAlertController = MVAlertController(title: dict["message"] as? String, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                let yesAction:UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let stripeViewController: MVStripeSignInViewController = storyboard.instantiateViewControllerWithIdentifier("stripeSignInViewController") as! MVStripeSignInViewController
                    stripeViewController.delegate = self
                    SVProgressHUD.show()
                    self.navigationController?.pushViewController(stripeViewController, animated: true)
                })
                
                let noAction:UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("FirstStepPopoverSegue", sender: self)
                    self.messageStatus = MVCameraType.FirstStep
                })
            }
            }, failureBlock: { (failure) -> Void in
                print("Error checking STRIPE account: \(failure)")
        })
    }
    
    //    func checkUserVenmoAccount()
    //    {
    //        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
    //
    //        MVDataManager.venmoValidate({ response in
    //
    //            SVProgressHUD.popActivity()
    //
    //            }) { failure in
    //                Venmo.sharedInstance().requestPermissions([VENPermissionMakePayments, VENPermissionAccessProfile, VENPermissionAccessPhone, VENPermissionAccessEmail]) { (success, error) -> Void in
    //                    if (success)
    //                    {
    //
    //                        MVDataManager.venmoConnect(Venmo.sharedInstance().session.user.externalId, accessToken: Venmo.sharedInstance().session.accessToken, refreshToken: Venmo.sharedInstance().session.refreshToken, expiresIn: Venmo.sharedInstance().session.expirationDate, successBlock: { response in
    //
    //                            let alert:UIAlertView = UIAlertView(title: "", message: "\(response)", delegate: self, cancelButtonTitle: "OK")
    //                            alert.show()
    //                            SVProgressHUD.popActivity()
    //
    //                            }, failureBlock: { failure in
    //
    //                                let alert:UIAlertView = UIAlertView(title: "", message: "\(failure)", delegate: self, cancelButtonTitle: "OK")
    //                                alert.show()
    //                                SVProgressHUD.popActivity()
    //                        })
    //                        print(success)
    //                    }
    //                    else
    //                    {
    //
    //                        print(error)
    //                        self.dismissViewControllerAnimated(true, completion: nil)
    //                        SVProgressHUD.popActivity()
    //                    }
    //                }
    //        }
    //
    //    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FirstStepPopoverSegue"
        {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            self.popoverController = segue.destinationViewController as? MVInfoMessageViewController
            self.popoverController.popoverPresentationController!.delegate = self
            self.popoverController.preferredContentSize = CGSize(width: 235, height: 115)
            self.popoverController.popoverPresentationController!.sourceRect = CGRectMake(screenWidth/2-117, screenHeight/2-57, 235, 115);
            self.popoverController.messageStatus = self.messageStatus
            self.popoverController.delegate = self
            self.popoverController.modalPresentationStyle = UIModalPresentationStyle.Popover
            
        }
        else if (segue.identifier == "TimerOptionsSegue")
        {
            self.timerOptionsViewController = segue.destinationViewController as? MVTimerOptionsViewController
            self.timerOptionsViewController.popoverPresentationController!.delegate = self
            self.timerOptionsViewController.preferredContentSize = CGSize(width: 80, height: 40)
            self.timerOptionsViewController.delegate = self
        }
        else if (segue.identifier == "addItemSegue")
        {
            MVHelper.sharedInstance.shouldAutorotate = true
            
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            
            self.editItemViewController = segue.destinationViewController as? EditItemViewController
            self.editItemViewController.uploadVideoFileURL = self.uploadVideoFileURL
            self.editItemViewController.uploadImageFileURL = self.uploadImageFileURL
            self.editItemViewController.delegate = self
        }
    }
    
    
    
    // MARK: UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // MARK: Recorder delegates
    func recorder(recorder: SCRecorder, didBeginSegmentInSession session: SCRecordSession, error: NSError?)
    {
        self.recordStarted = true
        self.recordButton.setImage(UIImage(named: "cameraRecording"), forState: UIControlState.Normal)
        self.confirmButton.enabled = false
        self.dismissButton.enabled = false
        self.cameraSwitchButton.enabled = false
        self.deletaLastSegmentButton.enabled = false
        self.deletaLastSegmentButton.hidden = self.recorder.session!.segments.count == 0
        MVHelper.sharedInstance.shouldAutorotate = self.recorder.session!.segments.count == 0
        
        self.deletaLastSegmentButton.selected = false
        
        self.recordButtonLandscape.setImage(UIImage(named: "cameraRecording"), forState: UIControlState.Normal)
        self.dismissButtonLandscape.enabled = false
        self.cameraSwitchButtonLandscape.enabled = false
        if (self.deleteView != nil) {
            self.deleteView = nil
        }
    }
    
    func backWindow() {
        self.statusLabel.hidden = false
        
        self.statusLabel.layer.masksToBounds = true
        self.statusLabel.layer.cornerRadius = 5
        
        UIView.animateWithDuration(2, animations: {
            self.statusLabel.alpha = 0
        })
        
        //        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        //        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("nextInfoMessageView")  as! MVNextInfoMessageViewController
        //        detailVC.delegate         = self
        //        self.presentViewController(detailVC, animated: true, completion: nil)
        
    }
    
    @IBAction func onDoneButtonClick(sender: AnyObject) {
        
        let image = UIImage(named: "done.png")
        doneButton.setBackgroundImage(image, forState: UIControlState.Normal)
        self.deletaLastSegmentButton.hidden = true
        buttonFlag = true
        //self.nextRecodeView()
        
        self.saveVideofile()
        
        /*        if(buttonFlag == true){
         buttonFlag = false
         self.nextRecodeView()
         
         let image = UIImage(named: "done.png")
         doneButton.setBackgroundImage(image, forState: UIControlState.Normal)
         }
         else{
         
         self.timerButton.hidden = true
         self.deletaLastSegmentButton.hidden = true
         buttonFlag = true
         self.nextRecodeView()
         
         self.saveVideofile()
         }
         */
        
    }
    func saveVideofile(){
        SVProgressHUD.show()
        
        let asset:AVAsset = self.recorder.session!.assetRepresentingSegments()
        let assetExportSession:SCAssetExportSession = SCAssetExportSession(asset: asset)
        assetExportSession.outputUrl = recordSession.outputUrl
        assetExportSession.outputFileType = AVFileTypeMPEG4
        
        let bwFilter : SCFilter! = SCFilter(CIFilterName: "CIColorControls")
        bwFilter.setParameterValue(0, forKey: "inputSaturation")
        
        //        assetExportSession.videoConfiguration.preset = SCPresetMediumQuality
        assetExportSession.audioConfiguration.preset = SCPresetHighestQuality
        assetExportSession.videoConfiguration.maxFrameRate = 30
        
        assetExportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            print(assetExportSession.error)
            
            let filePath = assetExportSession.outputUrl!.path
            var fileSize : UInt64 = 0
            var freeSpace : Int64 = 0
            do {
                let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath!)
                
                if let _attr = attr {
                    fileSize = _attr.fileSize();
                }
            } catch {
                print("Error: \(error)")
            }
            print(fileSize)
            //Convert UInt64 to Int64
            let convertedfilesize = 10 * Int64(fileSize) // 10,000
            
            freeSpace = self.deviceRemainingFreeSpaceInBytes()!
            if (freeSpace < convertedfilesize)
            {
                // Add Alert!
                let alert: MOVVAlertViewController = MOVVAlertViewController(title: "", message: "You don't have enough space on your phone!", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                UISaveVideoAtPathToSavedPhotosAlbum(assetExportSession.outputUrl!.path!, self, #selector(MVCameraViewController.video(_:didFinishSavingWithError:contextInfo:)), nil)
                self.renameVideoFile()
                self.doneButton.hidden = true
                self.deletaLastSegmentButton.hidden = true
                self.recordButton.enabled = true
                self.performSegueWithIdentifier("addItemSegue", sender: self)
//                self.messageStatus = MVCameraType.SecondStep//mju
//                self.performSegueWithIdentifier("FirstStepPopoverSegue", sender: self)
            }
//            if (assetExportSession.error == nil) {
//                UISaveVideoAtPathToSavedPhotosAlbum(assetExportSession.outputUrl!.path!, self, #selector(MVCameraViewController.video(_:didFinishSavingWithError:contextInfo:)), nil)
//                self.renameVideoFile()
//                self.doneButton.hidden = true
//                self.deletaLastSegmentButton.hidden = true
//                self.recordButton.enabled = true
//                self.messageStatus = MVCameraType.SecondStep//mju
//                self.performSegueWithIdentifier("FirstStepPopoverSegue", sender: self)//mju
//                
//                //self.performSegueWithIdentifier("addItemSegue", sender: self)
//                
//            } else {
//                print("Error: \(assetExportSession.error)")
//                SVProgressHUD.popActivity()
//                let alertController:MVAlertController = MVAlertController(title: "Error saving video", message: "“if video can’t save to phone” because not enough storage on phone", preferredStyle: UIAlertControllerStyle.Alert)
//                let okAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
//                
//                alertController.addAction(okAction)
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                    
//                })
//            }
        })
        
    }
    func nextRecodeView(){
        SVProgressHUD.show()
        
        self.recorder.capturePhoto({ (error, image:UIImage?) -> Void in
            if (image != nil) {
                let imagePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent("\(self.filename).jpg")
                self.imageUrl = NSURL(fileURLWithPath: imagePath)
                self.uploadImageFileURL = self.imageUrl
                
                UIImageJPEGRepresentation(image!, 0.2)!.writeToFile(imagePath, atomically: false)
                
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil);
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.popActivity()
                })
                
            } else {
                print("Error: \(error?.localizedDescription)")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.popActivity()
                })
            }
        })
        
    }
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession session: SCRecordSession, error: NSError?) {
        
        self.recordButton.setImage(UIImage(named: "camera.png"), forState: UIControlState.Normal)
        let separatorView:UIView = UIView(frame: CGRectMake(self.timeTrackingWidthConstraint.constant - 1, 0, 1, 3))
        separatorView.backgroundColor = UIColor.blackColor()
        self.progressView.addSubview(separatorView)
        self.confirmButton.enabled = true
        self.dismissButton.enabled = true
        self.cameraSwitchButton.enabled = true
        self.deletaLastSegmentButton.enabled = true
        self.deletaLastSegmentButton.hidden = self.recorder.session!.segments.count == 0
        MVHelper.sharedInstance.shouldAutorotate = self.recorder.session!.segments.count == 0
        
        
        self.recordButtonLandscape.setImage(UIImage(named: "camera.png"), forState: UIControlState.Normal)
        self.dismissButtonLandscape.enabled = true
        self.cameraSwitchButtonLandscape.enabled = true
        
        if (CMTimeGetSeconds(self.recorder.session!.duration) >= 15) {
            self.doneButton.hidden = false
            self.doneButton.setBackgroundImage(UIImage(named: "done.png"), forState: .Normal)
            self.recordButton.enabled = false
            
            
            
            //           self.messageStatus = MVCameraType.SecondStep
            //            self.performSegueWithIdentifier("FirstStepPopoverSegue", sender: self)//mju
            
            //            var player: SCPlayer
            //
            //            player = SCPlayer()
            //
            //            player.setItemByAsset(self.recorder.session!.assetRepresentingSegments())
            //
            //            player.play()
            //
            //            let closeButton:UIButton = UIButton(frame: CGRectMake(CGRectGetWidth(self.view.frame)-40, 70 , 30, 30))
            //            closeButton.setImage(UIImage(named: "video_Close.png"), forState: .Normal)
            //            closeButton.addTarget(self, action:#selector(MVCameraViewController.dismissPreview), forControlEvents: UIControlEvents.TouchUpInside)
            //            closeButton.tag = 101
            //
            //            self.playerGesture = UIGestureRecognizer(target: self, action: Selector("playVideo"))
            //
            //            self.player1 = AVPlayer(URL: self.uploadVideoFileURL)
            //            if(self.player1 != nil){
            //                self.playerController = AVPlayerViewController()
            //
            //                self.playerController!.player = player1
            //                self.addChildViewController(self.playerController!)
            //                self.playerController!.view.alpha = 0
            //                closeButton.alpha = 0
            //                self.playerController!.view.frame = self.view.frame
            //                self.view.addSubview(self.playerController!.view)
            //                self.playerController?.didMoveToParentViewController(self)
            //
            //                self.player1!.play()
            //                self.view.addSubview(closeButton)
            //                UIView.animateWithDuration(0.3, animations: { () -> Void in
            //                    self.playerController!.view.alpha = 1
            //                    closeButton.alpha = 1
            //                })
            //
            //            }
            
            
            
            
            
            
            
            //            self.timerButton.hidden = true
            //            self.deletaLastSegmentButton.hidden = true
            //
            //            SVProgressHUD.show()
            //
            //            let asset:AVAsset = self.recorder.session!.assetRepresentingSegments()
            //            let assetExportSession:SCAssetExportSession = SCAssetExportSession(asset: asset)
            //            assetExportSession.outputUrl = recordSession.outputUrl
            //            assetExportSession.outputFileType = AVFileTypeMPEG4
            //
            //
            //
            //            let bwFilter : SCFilter! = SCFilter(CIFilterName: "CIColorControls")
            //            bwFilter.setParameterValue(0, forKey: "inputSaturation")
            //
            //
            //            assetExportSession.videoConfiguration.filter = /*bwFilter*/ SCFilter(CIFilterName: "CIPhotoEffectInstant")
            //            assetExportSession.videoConfiguration.preset = SCPresetMediumQuality
            //            assetExportSession.audioConfiguration.preset = SCPresetMediumQuality
            //            assetExportSession.videoConfiguration.maxFrameRate = 30
            //
            //            assetExportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            //                if (assetExportSession.error == nil) {
            //                    UISaveVideoAtPathToSavedPhotosAlbum(assetExportSession.outputUrl!.path!, self, #selector(MVCameraViewController.video(_:didFinishSavingWithError:contextInfo:)), nil)
            //                    self.renameVideoFile()
            //
            //                } else {
            //                    print("Error: \(assetExportSession.error)")
            //                    SVProgressHUD.popActivity()
            //                    let alertController:MVAlertController = MVAlertController(title: "Error saving video", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            //                    let okAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            //
            //                    alertController.addAction(okAction)
            //                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //                        self.presentViewController(alertController, animated: true, completion: nil)
            //
            //                    })
            //                }
            //            })
            
        }
    }
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession session: SCRecordSession) {
        
        let multiplier:CGFloat = self.view.bounds.size.width / 15;
        self.timeTrackingWidthConstraint.constant = CGFloat(CMTimeGetSeconds(self.recorder.session!.duration)) * multiplier
        
        UIView.animateWithDuration(0.0015, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
        })
    }
    
    
    
    // MARK: Multimedia processing
    func video(videoPath: String, didFinishSavingWithError error: NSError?, contextInfo info: UnsafeMutablePointer<Void>) {
        SVProgressHUD.popActivity()
        
        if (error != nil) {
            print("Error: \(error?.localizedDescription)")
            let alertController:MVAlertController = MVAlertController(title: "Error saving video", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(okAction)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(alertController, animated: true, completion: nil)
                
            })
        } else {
            //self.doneButton.hidden = false
            //self.deletaLastSegmentButton.hidden = false
            //self.messageStatus = MVCameraType.SecondStep//mju
            //self.performSegueWithIdentifier("FirstStepPopoverSegue", sender: self)//mju
        }
    }
    // MARK: Delegates
    func onTouchOK() {
        
        //        self.nextpopoverController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Delegates
    func onTouchOKButton() {
        self.popoverController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func onTouchTimerButtonSetInterval(durationInterval: Int) {
        self.timerOptionsViewController.dismissViewControllerAnimated(true, completion: nil)
        self.timerDurationInterval = durationInterval
    }
    
    func backButtonTouched() {
        self.onTouchDismissBarButtonItem(self)
    }
    
    func userDidDeselectedVideo() {
        self.recorder.session!.removeAllSegments()
        self.recordSession = self.recorder.session!
        self.progressView.removeAllSubviews()
        self.timeTrackingWidthConstraint.constant = 0
        self.recorder.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        self.deletaLastSegmentButton.hidden = true
        UIView.animateWithDuration(0.0015, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        self.prepareSession()
        self.messageStatus = MVCameraType.FirstStep
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("popupMessageView")  as! PopupMessageViewController
        detailVC.delegate         = self
        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    
    func userDidDeselectedImage() {
        self.messageStatus = MVCameraType.SecondStep
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("FirstStepPopoverSegue", sender: self)
        }
    }
    
    // MARK: Actions
    @IBAction func onTouchDismissBarButtonItem(sender: AnyObject) {
        //        UIApplication.sharedApplication().statusBarHidden = false
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTouchSwitchCameraButton(sender: AnyObject) {
        if (!self.recorder.isRecording) {
            if (self.recorder.device == AVCaptureDevicePosition.Back) {
                self.flashButton.setTitle("Auto", forState: UIControlState.Normal)
                self.recorder.flashMode = SCFlashMode.Auto
                self.flashButton.enabled = false
                self.recorder.device = AVCaptureDevicePosition.Front
                self.cameraSwitchButton.setImage(UIImage(named: "video_Face_Camera"), forState: UIControlState.Normal)
            } else {
                self.recorder.device = AVCaptureDevicePosition.Back
                self.flashButton.enabled = true
                self.cameraSwitchButton.setImage(UIImage(named: "video_Back_Camera"), forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func onTouchFlashModeButton(sender: UIButton) {
        if (self.recorder.flashMode == SCFlashMode.Auto) {
            self.recorder.flashMode = SCFlashMode.Light
            sender.setTitle("On", forState: UIControlState.Normal)
        } else if (self.recorder.flashMode == SCFlashMode.Light) {
            self.recorder.flashMode = SCFlashMode.Off
            sender.setTitle("Off", forState: UIControlState.Normal)
        } else {
            self.recorder.flashMode = SCFlashMode.Auto
            sender.setTitle("Auto", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func startRecording(sender: UIButton) {
        
        if (self.messageStatus == MVCameraType.SecondStep) {
            SVProgressHUD.show()
            
            self.recorder.capturePhoto({ (error, image:UIImage?) -> Void in
                if (image != nil) {
                    let imagePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent("\(self.filename).jpg")
                    self.imageUrl = NSURL(fileURLWithPath: imagePath)
                    self.uploadImageFileURL = self.imageUrl
                    let rect = CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)
                    
                    UIGraphicsBeginImageContextWithOptions(image!.size, true, 0)
                    let context = UIGraphicsGetCurrentContext()
                    
                    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                    CGContextFillRect(context, rect)
                    
                    image!.drawInRect(rect, blendMode: .Normal, alpha: 1)
                    let watermark = UIImage(named: "watermark.png")
                    
                    watermark!.drawInRect(CGRectMake(20,20,watermark!.size.width,watermark!.size.height), blendMode: .Normal, alpha: 1)
                    
                    let result = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    
                    UIImageJPEGRepresentation(result!, 0.2)!.writeToFile(imagePath, atomically: false)
                    UIImageWriteToSavedPhotosAlbum(result!, nil, nil, nil);
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        SVProgressHUD.popActivity()
                    })
                    self.performSegueWithIdentifier("addItemSegue", sender: self)
                } else {
                    print("Error: \(error?.localizedDescription)")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        SVProgressHUD.popActivity()
                    })
                }
            })//mju
        } else {
            if (self.timerDurationInterval > 0) {
                if (!self.recorder.isRecording) {
                    self.activateTimer(self.timerDurationInterval)
                } else {
                    self.timerDurationInterval = 0
                    self.recorder.pause()
                }
            } else {
                //                2 sec interval recording
                //                self.recorder.record()
                //                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
                //                dispatch_after(delayTime, dispatch_get_main_queue()) {
                //
                //                    self.recorder.pause()
                //                }
                //
            }
        }
    }
    
    @IBAction func onTouchDeleteLastSegment(sender: UIButton) {
        if (self.recorder.session?.segments.count > 0) {
            if (sender.selected == false) {
                sender.selected = true
                
                self.deleteView = UIView(frame: CGRectMake(self.progressView.subviews[self.progressView.subviews.count - 2].frame.origin.x, 0, self.progressView.subviews[self.progressView.subviews.count - 1].frame.origin.x - self.progressView.subviews[self.progressView.subviews.count - 2].frame.origin.x, 3))
                self.deleteView!.backgroundColor = UIColor.redColor()
                self.progressView.addSubview(self.deleteView!)
                

                if(self.recorder.session?.segments.count == 1) {
                    self.recordStarted = false
                }
                
                sender.selected = false
                self.deleteView?.removeFromSuperview()
                if (self.deleteView != nil) {
                    self.deleteView = nil
                }
                self.doneButton.hidden = true
                self.recordButton.enabled = true
                let image = UIImage(named: "photo.png")
                doneButton.setBackgroundImage(image, forState: UIControlState.Normal)
                buttonFlag = true
                
                self.recorder.session!.removeSegmentAtIndex(self.recorder.session!.segments.count - 1, deleteFile: true)
                self.recordSession = self.recorder.session!
                
                self.progressView.subviews.last!.removeFromSuperview()
                
                self.messageStatus = MVCameraType.FirstStep//mju
                
                let multiplier:CGFloat = self.view.bounds.size.width / 15;
                self.timeTrackingWidthConstraint.constant = CGFloat(CMTimeGetSeconds(self.recorder.session!.duration)) * multiplier
                self.deletaLastSegmentButton.hidden = self.recorder.session!.segments.count == 0
                MVHelper.sharedInstance.shouldAutorotate = self.recorder.session!.segments.count == 0
                UIView.animateWithDuration(0.0015, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            } else {
            }
        }
    }
    
    @IBAction func onTouchConfirmButton(sender: AnyObject) {
        self.performSegueWithIdentifier("FirstStepPopoverSegue", sender: self)
    }
    
    func activateTimer(durationInterval: Int) {
        
        var j : Int = durationInterval
        let currentFlashMode: SCFlashMode = self.recorder.flashMode
        
        for (var i : Int = durationInterval; i >= 0; i -= 1) {
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(i) * NSEC_PER_SEC))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.timerCountdownLabel.alpha = 1
                    self.recorder.flashMode = SCFlashMode.Light
                    self.timerCountdownLabel.text = "\(j)"
                    }, completion: { (finished:Bool) -> Void in
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.timerCountdownLabel.alpha = 0
                            self.recorder.flashMode = SCFlashMode.Off
                            j -= 1
                            }, completion: { (finished:Bool) -> Void in
                                if (j == 0) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                                        self.recorder.flashMode = currentFlashMode
                                        self.recorder.record()
                                    }
                                }
                        })
                })
            }
        }
    }
    
    // MARK: Gesture recognizers
    @IBAction func longPressRecordGestureRecognizer(sender: AnyObject) {
        if (self.messageStatus == MVCameraType.SecondStep) {
            return
        }
        
        if (sender.state == UIGestureRecognizerState.Began) {
            self.doneButton.hidden = true
            self.recorder.record()
        } else if (sender.state == UIGestureRecognizerState.Ended) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.recorder.pause()
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        
        return self.recorder.session!.segments.count == 0
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    func renameVideoFile() {
        
        let filePath =  self.recordSession.outputUrl.path!
        
        var stringsArray = filePath.componentsSeparatedByString("/")
        var originPath : String = ""
        var destinationPath : String = ""
        
        for i : Int in 1 ..< stringsArray.count {
            if (i == stringsArray.count - 1)
            {
                originPath = originPath + stringsArray[i]
            }
            else
            {
                originPath = originPath + stringsArray[i] + "/"
            }
        }
        
        for i : Int in 1 ..< stringsArray.count - 1 {
            destinationPath = destinationPath + stringsArray[i] + "/"
        }
        
        destinationPath =  destinationPath + self.filename + ".mp4"
        
        var moveError: NSError?
        let manager : NSFileManager = NSFileManager()
        do {
            try manager.moveItemAtPath(originPath, toPath: destinationPath)
            self.uploadVideoFileURL = NSURL(fileURLWithPath: destinationPath)
        } catch let error as NSError {
            moveError = error
            print(moveError!.localizedDescription)
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let touch = touches.first
        {
            let position : CGPoint = touch.locationInView(self.testFilterView)
            self.focusRectangleView.frame = CGRectMake(position.x - 40, position.y - 40, 80, 80)
            self.focusRectangleView.layer.cornerRadius = self.focusRectangleView.frame.size.width/2
        }
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(context == &myContext){
            NSLog("Context")
            
            self.statusLabel.alpha = 1
            UIView.animateWithDuration(2, animations: {
                self.statusLabel.alpha = 0
            })
        }
    }
    
    
    //    func dismissPreview() {
    //
    //        UIView.animateWithDuration(0.3, animations: { () -> Void in
    //            if((self.playerController) != nil){
    //                self.player1?.pause()
    //                self.player1 = nil
    //                self.playerController?.view.alpha = 0
    //
    //            }
    //
    //            self.preview?.alpha = 0
    //            self.view.viewWithTag(101)?.alpha = 0
    //
    //        }) { (Bool) -> Void in
    //            if((self.playerController) != nil){
    //                self.playerController?.view.removeFromSuperview()
    //            }
    //            self.preview?.removeFromSuperview()
    //            self.view.viewWithTag(101)?.removeFromSuperview()
    //            self.view.viewWithTag(101)?.removeFromSuperview()
    //        }
    //
    //    }
    
    //MARK: GET FREE SPACE
    func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let systemAttributes = try? NSFileManager.defaultManager().attributesOfFileSystemForPath(documentDirectoryPath.last!) {
            if let freeSize = systemAttributes[NSFileSystemFreeSize] as? NSNumber {
                print(freeSize.longLongValue)
                return freeSize.longLongValue
            }
        }
        // something failed
        return nil
    }
    
}
