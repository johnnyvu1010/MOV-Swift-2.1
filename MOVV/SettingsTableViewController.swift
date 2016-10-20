//
//  SettingsTableViewController.swift
//  MOVV
//
//  Created by Petar Bandov on 08/06/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import FBSDKShareKit
import SVProgressHUD
import FBSDKLoginKit

protocol SettingsTableViewControllerDelegate:class
{
    func userImageChanged()
}

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,  FBSDKAppInviteDialogDelegate, MVAwsUploadDelegate {

    @IBOutlet var profileButton: UIButton!
    @IBOutlet var backgroundImageButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var avatarOverlayView: UIImageView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    var profileUpdateActive = false
    var avatarFilePath, avatarFileName, coverFileName, coverFilePath:String?
    var imagePicker:UIImagePickerController!
    var uploadImage : MVAwsUpload! = nil
    var isUploadingCoverImage : Bool = false
    var visualEffectView:UIVisualEffectView?
    var coverImage : UIImage!
    var profileImage : UIImage!
    weak var delegate : SettingsTableViewControllerDelegate? = nil
    var urlString : String!
    
    
    var poptip : ABPopTip!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uploadImage = MVAwsUpload()
        self.uploadImage.delegate = self
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        if(visualEffectView == nil){
            addBlurEffect()
        }
        
        self.backgroundImageView.image = self.coverImage
        self.avatarOverlayView.image = self.profileImage
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String

        self.versionLabel.text = "Version: \(version) Build: \(build)"
        
        //ToolTip Init
        ABPopTip.appearance().font = UIFont(name: "Avenir-Medium", size: 15)
        poptip = ABPopTip()
        poptip.shouldDismissOnTap = true
        poptip.edgeMargin = 5
        poptip.offset = 2
        poptip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if(self.navigationController?.navigationBarHidden == false)
        {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
//        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if(userImage != nil){
            avatarOverlayView.image = userImage
        }
        
        profileButton.layer.cornerRadius = CGRectGetHeight(profileButton.frame)/2
        avatarOverlayView.layer.borderColor = MOVVGreen.CGColor
        avatarOverlayView.layer.borderWidth = 2
        profileButton.clipsToBounds = true
        avatarOverlayView.layer.cornerRadius = CGRectGetHeight(profileButton.frame)/2
        avatarOverlayView.clipsToBounds = true
        avatarOverlayView.userInteractionEnabled = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: TableView delegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 8) {
            let inviteContent = FBSDKAppInviteContent()
            inviteContent.appLinkURL = NSURL(string: "http://appleStoreLink.com")
            inviteContent.appInvitePreviewImageURL = NSURL(string: "http://movv.com/images/main_banner.jpg")
            FBSDKAppInviteDialog.showFromViewController(self, withContent: inviteContent, delegate: self)//(inviteContent, delegate: self)
        } else if(indexPath.row == 14){
            FBSDKLoginManager().logOut()
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "userLoggedIn")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.performSegueWithIdentifier("logoutSegue", sender: nil)
        } else if(indexPath.row == 12){
            self.urlString = "http://mymov.co/app/terms.php"
            self.performSegueWithIdentifier("showWebContentSegue", sender: nil)
        } else if(indexPath.row == 2){
            let alert:UIAlertView = UIAlertView(title: "This feature is not available yet.", message: nil, delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        } else if(indexPath.row == 3){
            let alert:UIAlertView = UIAlertView(title: "This feature is not available yet", message: nil, delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        }
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "StripeSegue") {
            SVProgressHUD.show()
        } else if (segue.identifier == "showWebContentSegue") {
            let webContentVC: MVShowWebContentViewController = segue.destinationViewController as! MVShowWebContentViewController
            webContentVC.urlString = self.urlString
        } else if (segue.identifier == "changepw"){
            print("not available")
        } else if (segue.identifier == "changeaddr"){
            print("not available")
        } else if (segue.identifier == "gotoContacts"){
            
        }
    }
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let tempImage: UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        if(!profileUpdateActive){
            let image = tempImage.resizeImageInAspectRatio(800)
            self.backgroundImageView.image = image
            coverFileName = "cover_" + MVHelper.generateIdentifierWithLength(15)
            coverFilePath = MVHelper.saveFileToDocumentsDirectoryWithNameAndExtension(image, filename:"/\(coverFileName!)" , ext: "jpg")
            let coverFilePathURL : NSURL! = NSURL(fileURLWithPath: coverFilePath!)
            self.coverFileName = coverFileName! + ".jpg"
            SVProgressHUD.show()
            self.uploadImage.startUpload(coverFilePathURL, bucketName: Buckets.Image)
            self.isUploadingCoverImage = true
            self.type2(ABPopTipDirection.Down)
        } else {
            let image = tempImage.resizeImageInAspectRatio(600)
           // self.profileButton.setImage(image, forState: UIControlState.Normal)
            self.avatarOverlayView.image = image
            avatarFileName = "profile_" + MVHelper.generateIdentifierWithLength(15)
            avatarFilePath = MVHelper.saveFileToDocumentsDirectoryWithNameAndExtension(image, filename: "/\(avatarFileName!)", ext: "jpg")
            let avatarFilePathURL : NSURL! = NSURL(fileURLWithPath: avatarFilePath!)
            self.avatarFileName = avatarFileName! + ".jpg"
            SVProgressHUD.show()
            print(avatarFilePathURL)
            self.uploadImage.startUpload(avatarFilePathURL, bucketName: Buckets.Image)
            profileUpdateActive = false
            self.type1(ABPopTipDirection.Up)
        }
        
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func type1(TYPE:ABPopTipDirection){
        
        self.poptip.showText("Your profile picture will be updated within 5 minutes",direction:TYPE ,maxWidth: 200, inView: self.view, fromFrame:profileButton.frame, duration:7)
        
    }
    
    func type2(TYPE:ABPopTipDirection){
        
        self.poptip.showText("Your background picture will be updated within 5 minutes",direction:TYPE ,maxWidth: 200, inView: self.view, fromFrame:backgroundImageButton.frame, duration:7)
        
    }
    
    //MARK: Action methods
    
    @IBAction func getPicture(sender: UIButton) {
        
        if(sender == profileButton){
            profileUpdateActive = true
        }
        let alertController = MOVVAlertViewController(title: nil, message: "Choose photo or take new", preferredStyle: .ActionSheet)
        alertController.shouldAutorotate()
        let oneAction = UIAlertAction(title: "Choose from library", style: .Default) { (_) in
            let imagePicker = CameraViewController()
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:MOVVGreen]
            UIBarButtonItem.appearance().tintColor = MOVVGreen
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            imagePicker.sourceType = .SavedPhotosAlbum
            imagePicker.navigationItem.title = "Choose photo"
            self.navigationController!.presentViewController(imagePicker, animated: true, completion: nil)
        }

        let twoAction = UIAlertAction(title: "Take new picture", style: .Default) { (_) in
            let imagePicker = CameraViewController()
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            imagePicker.sourceType = .Camera
            imagePicker.navigationItem.title = "Take new picture"
            imagePicker.navigationController?.setNeedsStatusBarAppearanceUpdate()
            self.navigationController!.presentViewController(imagePicker, animated: true, completion: nil)
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        alertController.addAction(oneAction)
        alertController.addAction(twoAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) {
        }
        
    }

    
    
    // MARK: Facebook Friends Cell
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("yay")
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("booo")
    }
    
    
    //MARK: Screen setup
    
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    func returnProgress(progress : Float) {
        print(progress)
    }
    
    func returnStatus(status : String) {
        print(status)
    }
    
    func returnProgressAndStatus(progress: Float, status: String) {
         SVProgressHUD.showProgress(progress, status: status)
    }
    
    func uploadCompletedSuccessfully(bucket:Buckets) {
        if(self.isUploadingCoverImage)
        {
            MVDataManager.updateUserCoverImage(MVParameters.sharedInstance.currentMVUser.id, imageName: self.coverFileName, successBlock: { response in
                
                print("Update cover image success message: \(response)")

                SVProgressHUD.popActivity()
                }, failureBlock: { failure in
                    
                    print("Update cover image failure message: \(failure)")
                     SVProgressHUD.popActivity()
            })
            self.isUploadingCoverImage = false
            
        }
        else
        {
            MVDataManager.updateUserProfileImage(MVParameters.sharedInstance.currentMVUser.id, imageName: self.avatarFileName, successBlock: { response in
                
                print("Update profile image success message: \(response)")
                    SVProgressHUD.popActivity()
                
                }, failureBlock: { failure in
                    
                    print("Update profile image failure message: \(failure)")
                     SVProgressHUD.popActivity()
            })
        }
        
        
        
    }
    
    func uploadFailedMisserably() {
        
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
    
    @IBAction func onBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    
}
