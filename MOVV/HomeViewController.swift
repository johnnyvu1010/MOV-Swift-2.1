//
//  HomeViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 28/04/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import MobileCoreServices
import AVKit
import AVFoundation
import Accelerate
import BBBadgeBarButtonItem
import AssetsLibrary
//import UIActivityIndicator_for_SDWebImage
import SVProgressHUD
import CoreLocation
import AFNetworking
import PhotosUI

import TwitterKit
import FBSDKShareKit
import MessageUI



//var notificationsArray:NSArray?
var startedDataRefresh:Bool! = false
var tempProductsArray:[MVProduct]?
var offerPriceVC : OfferPriceViewController!

class HomeViewController: UIViewController , UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, ItemDetailViewControllerDelegate, TTTAttributedLabelDelegate, MOVVItemCellDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate, VideoPlayViewControllerDelegate, UIDocumentInteractionControllerDelegate, SharingViewControllerDelegate {
    
    @IBOutlet weak var navbar: UIImageView!
    @IBOutlet var tabBar: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notificationButton: UIButton!
    @IBOutlet var showDetailGesture: UITapGestureRecognizer!
    
    var blurEffect = UIBlurEffect()
    var effectView = UIVisualEffectView()

    var productTitle : String!
    var shareUrl : String!
    var shareImg : UIImage!
    var shareImageURLString : NSString!
    var imgLocalPath: NSURL!
    var imageMain : UIImageView!
    var documentController : UIDocumentInteractionController!
    var docController = UIDocumentInteractionController()
    var shareVideo: NSURL? = nil
    
    
    var logoImageView: UIImageView! = UIImageView(frame: CGRectMake(0, 0, 80, 21))
    var badgeButtonItem: BBBadgeBarButtonItem!
    var identifiersArray:NSMutableArray?
    var stack:Array<UIViewController> = []
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var productsArray:[MVProduct]? = [MVProduct]()
    var selectedProductIndex : Int!
    var indicatorView:UIImageView?
    var dataFetched:Bool?
    var hasNews:Bool?
    var hasSearch:Bool?
    var hasProfile:Bool?
    var visualEffectView:UIVisualEffectView?
    let hintImageView = UIImageView(image: UIImage(named: "popup1.png"));
    
    var playerIsPlaying : Bool = false
    var isDoubleTapRecognized: Bool = false
    var isLikeRequestOngoing:Bool = false
    
    var popUpMenuViewController: PopUpMenuViewController!
    
    var backViewController : UIViewController? {
        stack = self.navigationController!.viewControllers 
        for (var i = self.navigationController!.viewControllers.count-1 ; i > 0; i -= 1) {
            if (self.navigationController!.viewControllers[i] == self) {
                return self.navigationController!.viewControllers[i-1]
            }
        }
        return nil
    }
    
    

    //MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        MVHelper.sharedInstance.enteredApp = true
        self.tableView.addPullToRefreshWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(2)
                self.refreshData({ (finished) -> Void in
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.stopPullToRefresh()
                        self.tableView.reloadData()
                    }
                })
            }
        }, withAnimator: BeatAnimator())
        self.preferredStatusBarStyle()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        blurEffect = UIBlurEffect(style: .Dark)
        effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.productUploaded), name: "dismissCameraView", object: nil)
        self.fetchData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !self.view.userInteractionEnabled {
            self.view.userInteractionEnabled = true
            if tableView.numberOfRowsInSection(0) > 0{
                self.fetchData()
                tableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: .Bottom, animated: false);
            }
        }
        NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navbarVideo"), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.hidesBackButton = false
        self.logoImageView.image = UIImage(named: "navbarLogo.png")
        self.logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        let titleView:UIView = UIView(frame: CGRectMake(0, 0, 80, 21))
        titleView.addSubview(self.logoImageView)
        self.navigationItem.titleView = titleView
        self.addRightNavItemOnView()
        if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            addBlurEffect()
        }
        
        MVDataManager.getUnreadMessagesForLoggedUser({ (response:String) -> Void in
            if self.navigationItem.rightBarButtonItem != nil {
                self.badgeButtonItem.badgeValue = response
            }}, failureBlock: { (response) -> Void in
                if self.navigationItem.rightBarButtonItem != nil {
                    self.badgeButtonItem.badgeValue = "0"
                }
        })

        //send push token again
        guard let token = MVParameters.sharedInstance.devicePushToken else {
            print("Error, token is nil")
            return
        }
        MVDataManager.registerForNotifications(MVParameters.sharedInstance.currentMVUser.id, token: token, successBlock: { response in
            print(response)
        }) { failure in
            print(failure)
        }
    }
    
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
    }
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
        if self.isMovingToParentViewController() {
            visualEffectView?.removeFromSuperview()
            visualEffectView = nil
        }
    }
    
    
    //MARK: Table View Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView .dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! MOVVItemCell
        let product : MVProduct = productsArray![indexPath.row]
        cell.tag = indexPath.row
        cell.homeBuyButton.tag = indexPath.row
        cell.homeBuyButton.addTarget(self, action: #selector(HomeViewController.buyItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        if (product.isSold == 1){
            cell.homeBuyButton.setTitle("SOLD", forState: UIControlState.Normal)
            cell.homeBuyButton.enabled = false
            cell.homeBuyButton.backgroundColor = UIColor(red: 177/255.0, green:  180/255.0, blue:  187/255.0, alpha:  1)
        }else{
            cell.homeBuyButton.setTitle("OFFER", forState: UIControlState.Normal)
            cell.homeBuyButton.enabled = true
            cell.homeBuyButton.backgroundColor = UIColor(red: 63/255.0, green:  216/255.0, blue:  63/255.0, alpha:  1)
        }
        cell.itemDetailsButton.tag = indexPath.row
        cell.itemDetailsButton.addTarget(self, action: #selector(HomeViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(HomeViewController.likeButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
        cell.likeButton.setBackgroundImage(UIImage(named: (product.isLiked as Bool) ? "likeButtonSelectedAsset" : "likeButtonAsset"), forState: UIControlState.Normal)
        cell.itemImage.tag = indexPath.row
        cell.itemImage.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        cell.amountLabel.text = "$\(product.price)"
        cell.likeCountLabel.text = "\(product.numLikes)"
        cell.commentCountLabel.text = "\(product.numComments)"
        cell.timeLabel.text = product.uploadDate
        cell.tagsLabel.text = product.tags
        cell.titleLabel.text = product.name
        let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]
        let concatenatedString:String = "@" + product.user.username + "                        "
        let string = concatenatedString as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString("@" + product.user.username))
        let range : NSRange! = string.rangeOfString("@" + product.user.username)
        let url : NSURL! = NSURL(string: "\(product.user.id)")
        cell.usernameLabel.attributedText = attributedString
        cell.usernameLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
        cell.usernameLabel.addLinkToURL(url, withRange: range)
        cell.usernameLabel.delegate = self
        cell.locationLabel.text = product.user.location
        cell.userImage.setImageWithURL(NSURL(string: product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        cell.userProfileButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        cell.playButton.tag = indexPath.row
        cell.userProfileButton.addTarget(self, action: #selector(HomeViewController.userProfileTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
        MVHelper.addMOVVCornerRadiusToView(cell.userImage)
        cell.commentButton.addTarget(self, action: #selector(HomeViewController.showDetailsCom(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.playButton.addTarget(self, action: #selector(HomeViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 524
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 302
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productsArray!.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50))
        footerView.alpha = 0
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: TTTAttributed Label Delegate Method
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!){
        removeItemHint()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = ("\(url)" as NSString).integerValue
        self.navigationController!.pushViewController(userProfileVC, animated: true)
        
    }
    
    //MARK: Fetch logic
    func fetchData() {
        SVProgressHUD.show()
        MVDataManager.getHomeScreenData({ response in
            self.dataFetched = true
            self.productsArray = response as! NSArray as? [MVProduct]
            tempProductsArray = self.productsArray
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            }, failureBlock: { response in
                SVProgressHUD.dismiss()
        })
        
    }
    
    func refreshData(finished:(AnyObject!) -> Void) {
        startedDataRefresh = true
        MVDataManager.getHomeScreenData({ response in
            self.dataFetched = true
            self.productsArray = response as! NSArray as? [MVProduct]
            finished(response)
            startedDataRefresh = false
            }, failureBlock: { response in
                startedDataRefresh = false
                finished(response)
        })
    }
    
    func addBlur() {
        UIView.animateWithDuration(0.8) {
            self.effectView.alpha = 1.0
        }
    }
    
    // Cancel
    func dismissViewCon(viewCon: SharingViewController) {
        viewCon.dismissViewControllerAnimated(true, completion: nil)
        removeBlur()
    }
    
    func removeBlur() {
        UIView.animateWithDuration(0.8) {
            self.effectView.alpha = 0.0
        }
    }
    
    // Copy Share Link Part
    func copysharelink(viewCon: SharingViewController) {
        removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.donecopysharelink()
        })
    }
    
    func donecopysharelink() {
        let pasteboard : UIPasteboard! = UIPasteboard.generalPasteboard()
        if(self.shareUrl != nil)
        {
            pasteboard.URL = NSURL(string: "\(shareUrl)")!
            let alertView : UIAlertController = UIAlertController(title: "", message: "Share URL is copied to clipoard!", preferredStyle: UIAlertControllerStyle.Alert)
            let action : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertView.addAction(action)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    // Instagram Share
    func sharetoinstagram(viewCon: SharingViewController) {
        removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadVideo()
        })
    }
    func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        return documentsFolderPath
    }
    
    func downloadVideo() {
        SVProgressHUD.show()
        let request = NSURLRequest.init(URL:self.shareVideo!)
        let operation = AFHTTPRequestOperation.init(request: request)
        let title = productTitle.componentsSeparatedByString(" ").joinWithSeparator("")
        let path = self.documentsDirectory().stringByAppendingString("/\(title).mp4")
        operation.outputStream = NSOutputStream.init(toFileAtPath: path, append: false)
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) in
                print("success")
            print(NSURL.init(string: path))
            
            //            let path = NSBundle.mainBundle().pathForResource("sample_movie", ofType:"mp4")
            let fileURL = NSURL(fileURLWithPath: path)
            
            let composition = AVMutableComposition()
            let vidAsset = AVURLAsset(URL: fileURL, options: nil)

            // get video track
            let vtrack =  vidAsset.tracksWithMediaType(AVMediaTypeVideo)
            let videoTrack:AVAssetTrack = vtrack[0]
            let vid_duration = videoTrack.timeRange.duration
            let vid_timerange = CMTimeRangeMake(kCMTimeZero, vidAsset.duration)

            do {

                let compositionvideoTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
                try compositionvideoTrack.insertTimeRange(vid_timerange, ofTrack: videoTrack, atTime: kCMTimeZero)
                compositionvideoTrack.preferredTransform = videoTrack.preferredTransform

                // get audio track
                let clipAudioTrack = vidAsset.tracksWithMediaType(AVMediaTypeAudio)[0]
                let compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
                try  compositionAudioTrack.insertTimeRange(vid_timerange, ofTrack: clipAudioTrack, atTime: kCMTimeZero)

            } catch {
                print(error)
            }
            
            
            // Watermark Effect
            let size = videoTrack.naturalSize
            //            var size =
            CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform)
            //            size = CGSizeMake(fabs(size.width), fabs(size.height))
            
            let imglogo = UIImage(named: "watermark.png")
            let imglayer = CALayer()
            imglayer.contents = imglogo?.CGImage
            imglayer.frame = CGRectMake(20, size.height - imglogo!.size.height - 20, imglogo!.size.width, imglogo!.size.height)
            //            imglayer.opacity = 0.6
            
            let videolayer = CALayer()
            videolayer.frame = CGRectMake(0, 0, size.width, size.height)
            
            let parentlayer = CALayer()
            parentlayer.frame = CGRectMake(0, 0, size.width, size.height)
            parentlayer.addSublayer(videolayer)
            parentlayer.addSublayer(imglayer)
            
            let layercomposition = AVMutableVideoComposition()
            layercomposition.frameDuration = CMTimeMake(1, 30)
            layercomposition.renderSize = size
            layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, inLayer: parentlayer)
            
            // instruction for watermark
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
            let videotrack = composition.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
            let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
            instruction.layerInstructions = NSArray(object: layerinstruction) as! [AVVideoCompositionLayerInstruction]
            layercomposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
            
            //  create new file to receive data
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir: AnyObject = dirPaths[0]
            let movieFilePath = docsDir.stringByAppendingPathComponent("result.mp4")
            let movieDestinationUrl = NSURL(fileURLWithPath: movieFilePath)
            
            _ = try? NSFileManager().removeItemAtURL(movieDestinationUrl)
            
            // use AVAssetExportSession to export video
            let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality)
            assetExport!.outputFileType = AVFileTypeMPEG4
            assetExport!.outputURL = movieDestinationUrl
            assetExport?.videoComposition = layercomposition
            assetExport!.exportAsynchronouslyWithCompletionHandler({
                switch assetExport!.status{
                case  AVAssetExportSessionStatus.Failed:
                    print("failed \(assetExport!.error)")
                case AVAssetExportSessionStatus.Cancelled:
                    print("cancelled \(assetExport!.error)")
                default:
                    print("Movie complete")
                    ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(movieDestinationUrl, completionBlock: nil)
                }
            })
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
                    SVProgressHUD.popActivity()
                    self.doneinstagram()
                }
            }) { (operation, error) in
                SVProgressHUD.popActivity()
                print("failed")
        }
        operation.start()
    }
    
    func doneinstagram() {
        if self.shareVideo!.isValid() {
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

    
    //Twitter Share
    func sharetotwitter(viewCon: SharingViewController) {
        self.removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadImage(self.shareImageURLString as String) { result in
                self.shareImg = result
                self.donetwitter()
            }
        })
    }
    func donetwitter() {
        let composer = TWTRComposer()
        composer.setText("Hey guys! \nCheck out \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)")
        if let image = self.shareImg{
            composer.setImage(image)
        }
        composer.showFromViewController(self) { (result) in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
        }
        
    }

    //Facebook Share
    func sharetofacebook(viewCon: SharingViewController) {
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadImage(self.shareImageURLString as String) { result in
                self.shareImg = result
                self.donefacebook()
            }
        })
    }
    func donefacebook() {
        print("Facebook sharing")
        let content = FBSDKShareLinkContent()
        content.contentTitle = "\(self.productTitle)"
        content.contentDescription = "Hey guys! \nCheck out \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)"
        content.contentURL = NSURL(string: shareUrl)
        
        let dialog = FBSDKShareDialog.init()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = .Automatic
        dialog.show()
    }
    
    //Message Share
    func sharetomessage(viewCon: SharingViewController) {
        self.removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadImage(self.shareImageURLString as String) { result in
                self.shareImg = result
                self.donemessage()
            }
        })
    }
    func donemessage() {
        UINavigationBar.appearance().barTintColor = UIColor.greenAppColor()
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hey guys! \nCheck out \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)"
            if let image = self.shareImg{
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                controller.addAttachmentData(imageData!, typeIdentifier: "image/jpeg", filename: "\(self.productTitle).jpeg")
            }
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //Report
    func report(viewCon: SharingViewController) {
        viewCon.dismissViewControllerAnimated(true, completion: nil)
        removeBlur()
        donereport(viewCon.product)
    }
    func donereport(product:MVProduct) {
        let request : String! = "product-report"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "product_id":"\(product.id)"]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            UIAlertView(title: "Thank you for reporting!", message: "We investigate every report.", delegate: self, cancelButtonTitle: "Ok").show()
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:failure, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: {
            })
        }
    }
    
    @IBAction func gotoLikeView(sender: UIButton) {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let likeviewVC = mainSt.instantiateViewControllerWithIdentifier("MVVideoLikesVC")  as! MVVideoLikesViewController
        self.navigationController?.pushViewController(likeviewVC, animated: true)
    }
    
    // MARK: Delegate
    func onTouchShareButton(cell: UITableViewCell) {
        let product: MVProduct = productsArray![self.tableView.indexPathForCell(cell)!.row]
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let sharingVC = mainSt.instantiateViewControllerWithIdentifier("SharingVC")  as! SharingViewController
        sharingVC.delegate = self
        sharingVC.product = product
        self.productTitle = product.name
        self.shareUrl = product.shareLink
        self.shareVideo = NSURL(string: product.videoFile)
        self.shareImageURLString = product.previewImage
        self.presentViewController(sharingVC, animated: true, completion: nil)
    }
    
    func downloadImage(urlString:String, shareImage:(UIImage)->Void){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            dispatch_async(dispatch_get_main_queue(), { 
                SVProgressHUD.show()
            })
            let url = NSURL(string: urlString)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            let img = UIImage(data: data!)
            let rect = CGRect(x: 0, y: 0, width: img!.size.width, height: img!.size.height)
            UIGraphicsBeginImageContextWithOptions(img!.size, true, 0)
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextFillRect(context, rect)
            img!.drawInRect(rect, blendMode: .Normal, alpha: 1)
            let watermark = UIImage(named: "watermark.png")
            watermark!.drawInRect(CGRectMake(20,20,watermark!.size.width,watermark!.size.height), blendMode: .Normal, alpha: 1)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            dispatch_async(dispatch_get_main_queue(), {
                SVProgressHUD.dismiss()
                shareImage(result)
            })
            
        }
    }
    
    func onTouchOfferButton(cell: UITableViewCell) {
        let productDetail:MVProduct = productsArray![(tableView.indexPathForCell(cell)?.row)!]
        if (productDetail.user.id == MVParameters.sharedInstance.currentMVUser.id){
            let alert:UIAlertController = UIAlertController.init(title: "", message:"Tisk-tisk…You can’t buy your own item!"  as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: {
            })
        }else{
            let main = UIStoryboard(name: "Main", bundle: nil)
            offerPriceVC = main.instantiateViewControllerWithIdentifier("OfferPriceViewController")  as! OfferPriceViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            offerPriceVC.view.translatesAutoresizingMaskIntoConstraints = true
            offerPriceVC.view.frame = UIScreen.mainScreen().bounds
            offerPriceVC.view.alpha = 0
            offerPriceVC.product = productDetail
            appDelegate.window?.addSubview(offerPriceVC.view)
            UIView.animateWithDuration(0.3) {
                offerPriceVC.view.alpha = 1;
            }
        }
    }

    func likeCountTapped(tag: Int) {
        if let product = productsArray?[tag]{
            self.navigationController?.pushViewController(MVLikesViewController.getLikeViewController(product), animated: true)
        }
    }
    
    // MARK: Action methods
    func showDetailsCom(sender:UIButton){
        removeItemHint()
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        self.selectedProductIndex = sender.tag
        
        detailVC.productDetail    = productsArray![self.selectedProductIndex]
        detailVC.delegate         = self
        detailVC.commentFlag      = 1
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func showDetails(sender:UIButton) {
        removeItemHint()
        let product : MVProduct! = productsArray![sender.tag];
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mixpanel?.track("Comment", properties: ["item" : product.name])
        
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let detailVC              = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        self.selectedProductIndex = sender.tag
        detailVC.productDetail    = product
        detailVC.delegate         = self 
        self.navigationController!.pushViewController(detailVC, animated: true)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popUpMenuSegue" {
            self.popUpMenuViewController = segue.destinationViewController as? PopUpMenuViewController
            self.popUpMenuViewController.popoverPresentationController!.delegate = self
            self.popUpMenuViewController.preferredContentSize = CGSize(width: 200, height: 150)
            //self.popUpMenuViewController.delegate = self
        }
    
    }
    
    func buyItem(sender : UIButton)
    {
        
    }

    
    func likeButtonTouched(sender:UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let btn : UIButton        = sender
        let product : MVProduct   = productsArray![sender.tag]
        
        isLikeRequestOngoing = true
        MVDataManager.likeProduct(product.id, successBlock: { response in
            self.isLikeRequestOngoing = false
            if(product.isLiked as Bool)
            {
                appDelegate.mixpanel?.track("Unlike",properties: ["item": product.name])
                btn.setImage(UIImage(named: "likeButtonAssets"), forState: UIControlState.Normal)
                self.productsArray![sender.tag].isLiked  = false
                self.productsArray![sender.tag].numLikes = self.productsArray![sender.tag].numLikes - 1
            }
            else
            {
                appDelegate.mixpanel?.track("Like",properties: ["item": product.name])
                btn.setImage(UIImage(named: "likeButtonSelectedAssets"), forState: UIControlState.Normal)
                self.productsArray![sender.tag].isLiked  = true
                self.productsArray![sender.tag].numLikes = self.productsArray![sender.tag].numLikes + 1
            }
            
            self.tableView.reloadData()
            
            }) { failure in
                self.isLikeRequestOngoing = false
                print(failure)
                
        }
    }
    
    func tapGestureLikeRecognizer(sender: UITapGestureRecognizer) {
        let product : MVProduct   = productsArray![sender.view!.tag]
        if sender.state == UIGestureRecognizerState.Recognized && !isLikeRequestOngoing{
            self.isDoubleTapRecognized = true
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.view!.tag, inSection: 0)) as! MOVVItemCell
            if !(product.isLiked as Bool){
                isLikeRequestOngoing = true
                MVDataManager.likeProduct(product.id, successBlock: { response in
                    self.isLikeRequestOngoing = false
                    appDelegate.mixpanel?.track("Like",properties: ["item": product.name])
                    cell.likeButton.setImage(UIImage(named: "likeButtonSelectedAssets"), forState: UIControlState.Normal)
                    self.productsArray![sender.view!.tag].isLiked  = true
                    self.productsArray![sender.view!.tag].numLikes = self.productsArray![sender.view!.tag].numLikes + 1
                    self.tableView.reloadData()
                }) { failure in
                    self.isLikeRequestOngoing = false
                    print(failure)
                }                
            }
            let point = sender.locationInView(sender.view)
            let likeImage = UIImageView(frame: CGRectMake(point.x-50, point.y-50, 100, 100))
            likeImage.contentMode = .ScaleAspectFill
            likeImage.sd_setImageWithURL(NSBundle.mainBundle().URLForResource("Liked", withExtension: "gif"))
            likeImage.startAnimating()
            let width = UIScreen.mainScreen().bounds.width
            likeImage.transform = CGAffineTransformMakeRotation((point.x < (width/2-30)) ? -0.8 : (point.x > (width/2+30)) ? 0.8 : 0)
            sender.view!.addSubview(likeImage)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.isDoubleTapRecognized = false
                likeImage.removeFromSuperview()
            })
        }
    }
    
    func tapGestureShowDetailsRecognizer(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Recognized){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                if !self.isDoubleTapRecognized{
                    let product : MVProduct! = self.productsArray![sender.view!.tag];
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.mixpanel?.track("Comment", properties: ["item" : product.name])
                    let mainSt                = UIStoryboard(name: "Main", bundle: nil)
                    let detailVC              = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                    self.selectedProductIndex = sender.view!.tag
                    detailVC.productDetail    = product
                    detailVC.delegate         = self
                    self.navigationController!.pushViewController(detailVC, animated: true)
                }
            }
        }
    }
    
    
    func userProfileTouched(sender:UIButton)
    {
        removeItemHint()
        let main                            = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC                   = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId         = productsArray![sender.tag].user.id
        self.navigationItem.hidesBackButton = false
        
        
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    func productLikeStateChanged(product: MVProduct) {
        
        self.productsArray?.removeAtIndex(self.selectedProductIndex)
        self.productsArray?.insert(product, atIndex: self.selectedProductIndex)
        self.tableView.reloadData()
        
    }
    
    //MARK: Screen setup
    func addRightNavItemOnView() {
        let inboxButton: UIButton = UIButton(type: UIButtonType.Custom)
        inboxButton.frame = CGRectMake(0, 0, 25, 20)
        inboxButton.setImage(UIImage(named:"inboxButton.png"), forState: UIControlState.Normal)
        inboxButton.addTarget(self, action: #selector(HomeViewController.inboxButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        self.navigationItem.setRightBarButtonItem(self.badgeButtonItem, animated: true)
    }
    
    func productUploaded() {
        self.performSelector(#selector(HomeViewController.addItemHint), withObject: nil, afterDelay: 1)
    }
    
    func addItemHint(){
        let x = UIScreen.mainScreen().bounds.size.width - 207
        self.hintImageView.frame = CGRectMake(x, 55, 200, 40)
        self.navigationController?.view.addSubview(hintImageView)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
            self.removeItemHint()
        }
        UIView.animateWithDuration(0.5, delay: 0, options: [.Repeat, .Autoreverse] , animations: {
            self.hintImageView.frame = CGRectMake(x, 65, 200, 40);
        }) { (completed) in
            
        }
    }
    
    func removeItemHint(){
        self.hintImageView.removeFromSuperview()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Actions
    func inboxButtonPressed(sender:UIButton!) {
        removeItemHint()
        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let showEditItemView:Bool = false
        if showEditItemView {
            let myCartViewController = mainSt.instantiateViewControllerWithIdentifier("editVC")  as! EditItemViewController
            myCartViewController.uploadImageFileURL = NSURL.fileURLWithPath("file:///var/mobile/Containers/Data/Application/AD7518CE-13F5-4387-9F95-550CA629CB12/Documents/112koq0zh1le3ocyrn.jpg")
            myCartViewController.uploadVideoFileURL = NSURL.fileURLWithPath("private/var/mobile/Containers/Data/Application/AD7518CE-13F5-4387-9F95-550CA629CB12/tmp/112koq0zh1le3ocyrn.mp4")
            self.navigationController?.pushViewController(myCartViewController, animated: true)
        }else{
            let myCartViewController = mainSt.instantiateViewControllerWithIdentifier("MyCartViewController")  as! MyCartViewController
            self.navigationController?.pushViewController(myCartViewController, animated: true)
        }
    }
    
}


