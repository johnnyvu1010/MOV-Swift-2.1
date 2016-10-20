//
//  ItemDetailViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 06/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//
import MediaPlayer
import UIKit
import AVFoundation
import AVKit
import BBBadgeBarButtonItem
import IQKeyboardManager
import SVProgressHUD
import Branch

@objc protocol TabBarTogglable {
    func toggleTabbar()
    func showTabbar()
    func hideTabbar()
}

protocol MVItemDetailVCDelegate {
    func onTouchCloseButton()
}

protocol ItemDetailViewControllerDelegate:class
{
    func productLikeStateChanged(product : MVProduct)
}

//class ItemDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate, TTTAttributedLabelDelegate, MOVVItemCellDelegate,  {
class ItemDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate, TTTAttributedLabelDelegate, MOVVItemCellDelegate,MVCommentSuggestionViewDelegate,ItemDetailCommentCellDelegate,BranchDeepLinkingController {
      
        
    @IBOutlet var itemDetailsTable: UITableView!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var postView: UIView!
    @IBOutlet var commentSuggestionContainerView: MVCommentSuggestionView!
    
    private var badgeButtonItem: BBBadgeBarButtonItem!
    private var player:AVPlayer!
    private var playerController:AVPlayerViewController!
    private var playerIsPlaying : Bool = false
    private var shouldReturnProductToHomeScreen : Bool = false
    private var commentsArray:[MVComment]! = [MVComment]()
    var productDetail : MVProduct!
    weak var delegate : ItemDetailViewControllerDelegate? = nil
    private var visualEffectView:UIVisualEffectView?
    private var keyboardRect : CGRect!
    
    private var lastWordRange : NSRange!
    private var selectedUserArr = NSMutableArray()
    private var rangeArr = [NSRange]()
    private var currentCommentStr = NSString()
    private var lastCurserRange : NSRange!
//    private var isPresentedViaDeepLink: Bool = false
    var isPresentedViaDeepLink: Bool = false
    
    @IBOutlet var messageTextFieldConstrain: NSLayoutConstraint!
    var blurInt: Int! = 0
    var navControllerDelegate: MVItemDetailVCDelegate? = nil
    
    // MARK: Deeplinking
    var deepLinkingCompletionDelegate: BranchDeepLinkingControllerCompletionDelegate?
    
    func closePressed() {
        self.deepLinkingCompletionDelegate!.deepLinkingControllerCompleted()
    }
    
    func configureControlWithData(data: [NSObject : AnyObject]!) {
        
        print(data)
        guard let productId: String = data["product_id"] as? String else {
            print("Error while initializig")
            assertionFailure("Error while initializig app via deeplinking")
            return
        }

        self.isPresentedViaDeepLink = true
        self.productDetail = MVProduct(initWithProductId: productId)
        print("Item ID: \(productId)")
        // show the picture
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        if self.productDetail == nil {
            self.isPresentedViaDeepLink = true
        }

        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().enable = false
        super.viewDidLoad()
        if self.isPresentedViaDeepLink == false {
            self.fetchData()
        }
        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
        self.preferredStatusBarStyle()
        postView.layer.borderColor = UIColor.lightGrayColor().CGColor
        postView.layer.borderWidth = 0.5
        addRightNavItemOnView()
        
        self.itemDetailsTable.registerNib(UINib(nibName: "ItemDetailCommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ItemDetailViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ItemDetailViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ItemDetailViewController.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    
    }
    

    func keyboardWillChange(notification : NSNotification)
    {
        self.keyboardRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.keyboardRect = self.view.convertRect(self.keyboardRect, fromView: nil)
    }
    
    
    func keyboardWillShow()
    {
        self.messageTextFieldConstrain.constant = self.keyboardRect.size.height
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.postView.layoutIfNeeded()
        })
        
    }
    
    func keyboardWillHide()
    {
        self.messageTextFieldConstrain.constant = 0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.postView.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        MVHelper.sharedInstance.shouldAutorotate = true
        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
        NSNotificationCenter.defaultCenter().postNotification(enableScreenRotation)

        if(self.player != nil)
        {
            self.player.play()
        }
            
            if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
                addBlurEffect()
            }
        
        if self.isMovingToParentViewController() {
            
            if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
                addBlurEffect()
            }
        }
        
        if self.parentViewController?.title == "home" {
            
            self.blurInt = 1
        }
        
        MVDataManager.getUnreadMessagesForLoggedUser({ (response:String) -> Void in
            if self.navigationItem.rightBarButtonItem != nil {
                self.badgeButtonItem.badgeValue = response
            }
            }, failureBlock: { (response) -> Void in
                if self.navigationItem.rightBarButtonItem != nil {
                    self.badgeButtonItem.badgeValue = "0"
                }
                print("Error fetching unread messages")
        })
    }
    
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationItem.hidesBackButton = false
        self.navigationItem.title = "Item Details"
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()

    }
    
    override func viewWillDisappear(animated:Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().postNotification(disableScreenRotation)

        if(self.shouldReturnProductToHomeScreen)
        {
            self.delegate?.productLikeStateChanged(self.productDetail)
        }
        
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        MVHelper.sharedInstance.shouldAutorotate = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        if(self.player != nil)
        {
            self.player.pause()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Table View Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(self.commentsArray.count)
        if(self.commentsArray.count > 0){
            return  self.commentsArray.count + 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0)
        {
            let cell = tableView .dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! MOVVItemCell
            cell.delegate = self
            if(productDetail != nil){
                
                cell.buyButton.enabled = productDetail.user.id != MVParameters.sharedInstance.currentMVUser.id
                cell.itemName.text = productDetail.name
                cell.amountLabel.text = "$\(productDetail.price)"
                cell.likeCountLabel.text = "\(productDetail.numLikes)"
                cell.commentCountLabel.text = "\(productDetail.numComments)"
                cell.itemImage.setImageWithURL(NSURL(string: productDetail.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                if(self.productDetail.user.id != MVParameters.sharedInstance.currentMVUser.id){
                    cell.userProfileButton.tag = indexPath.row
                    cell.userProfileButton.addTarget(self, action: #selector(ItemDetailViewController.userProfileButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
                }
                
                if(productDetail.user != nil)
                {
                    let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]
                    let concatenatedString:String = "@" + productDetail.user.username + "                        "
                    let string = concatenatedString as NSString
                    let attributedString = NSMutableAttributedString(string: string as String)
                    attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString("@" + productDetail.user.username))

                    cell.usernameLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]

                    var range : NSRange!
                    range = string.rangeOfString("@" + productDetail.user.username)
                    let url : NSURL! = NSURL(string: "\(productDetail.user.id)")
                    cell.usernameLabel.attributedText = attributedString
                    cell.usernameLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
                    cell.usernameLabel.addLinkToURL(url, withRange: range)
                    cell.usernameLabel.delegate = self
                    cell.locationLabel.text = productDetail.user.location
                    cell.userImage.setImageWithURL(NSURL(string: productDetail.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                    MVHelper.addMOVVCornerRadiusToView(cell.userImage)
                }
                cell.timeLabel.text = productDetail.uploadDate
                cell.tagsLabel.text = productDetail.tags
                cell.likeButton.addTarget(self, action: #selector(ItemDetailViewController.likeButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
                if(productDetail.isLiked as Bool)
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonSelectedAsset"), forState: UIControlState.Normal)
                }
                else
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonAsset"), forState: UIControlState.Normal)
                }
            } else {
                if self.isPresentedViaDeepLink == false {
                       let alert = MOVVAlertViewController(title: "API needed", message: "Please provide the API for the content", preferredStyle: .Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
            
            
            
            return cell
        }
        else
        {
            if(commentsArray.count > 0){
                let cell = tableView .dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! ItemDetailCommentCell
                
                let comment : MVComment = self.commentsArray[indexPath.row - 1] as MVComment
                
                //                cell.usernameLabel.text = "@\(comment.user.username)"
                
                let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]
                let concatenatedString:String = "@" + comment.user.username + "                        "
                let string = concatenatedString as NSString
                let attributedString = NSMutableAttributedString(string: string as String)
                cell.usernameLabel.attributedText = attributedString

                var range : NSRange!
                range = string.rangeOfString("@" + comment.user.username)
                attributedString.addAttributes(greenBoldedFont, range: range)
                let url : NSURL! = NSURL(string: "\(comment.user.id)")
                cell.usernameLabel.addLinkToURL(url, withRange: range)
                cell.usernameLabel.attributedText = attributedString
                cell.usernameLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
                cell.usernameLabel.delegate = self
                
                cell.timeLabel.text = comment.commentDate
                cell.commentLabel.text = comment.comment
                cell.userImage.setImageWithURL(NSURL(string: comment.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userImage)
                if(comment.user.id != MVParameters.sharedInstance.currentMVUser.id){
                    cell.userProfileButton.addTarget(self, action: #selector(ItemDetailViewController.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    cell.userProfileButton.tag = indexPath.row
                }
                
                return cell
            } else {
                let cell = tableView .dequeueReusableCellWithIdentifier("noCommentsCell", forIndexPath: indexPath) 
                
                return cell
            }
        }
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 302
    }
    
    
    
    //MARK: TTTAttributed Label Delegate Method
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = ("\(url)" as NSString).integerValue
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    
    //MARK: Textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: Action methods
    @IBAction func togglePlay(sender: AnyObject?) {
        let cell = itemDetailsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MOVVItemCell
        if(player != nil) {
            if(player.rate != 0){
                cell.playButton.setBackgroundImage(UIImage(named: "playButton"), forState: .Normal)
                player.pause()
            } else {
                cell.playButton.setBackgroundImage(UIImage(named: ""), forState: .Normal)
                player.play()
            }
        }
        
    }
    
    @IBAction func inboxButtonPressed(sender:UIButton!) {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let inboxVC = mainSt.instantiateViewControllerWithIdentifier("inboxVC")  as! InboxViewController
        inboxVC.isUserProfile = false
        inboxVC.blurInt = self.blurInt
        self.navigationController?.pushViewController(inboxVC, animated: true)
    }
    
   
    func likeButtonTouched(sender:UIButton) {
        let btn : UIButton = sender
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let cell:MOVVItemCell = sender.superview?.superview as! MOVVItemCell
        MVDataManager.likeProduct(self.productDetail.id, successBlock: { response in
            if(self.productDetail.isLiked as Bool) {
                appDelegate.mixpanel?.track("Unlike",properties: ["item": self.productDetail.name])
                btn.setBackgroundImage(UIImage(named: "likeButtonAsset"), forState: UIControlState.Normal)
                self.productDetail.isLiked = false
                self.productDetail.numLikes = self.productDetail.numLikes - 1
                cell.likeCountLabel.text = "\(self.productDetail.numLikes)"
            }
            else
            {
                appDelegate.mixpanel?.track("Like",properties: ["item": self.productDetail.name])
                btn.setBackgroundImage(UIImage(named: "likeButtonSelectedAsset"), forState: UIControlState.Normal)
                self.productDetail.isLiked = true
                self.productDetail.numLikes = self.productDetail.numLikes + 1
                cell.likeCountLabel.text = "\(self.productDetail.numLikes)"
            }
            
            
            }) { failure in
                
                print(failure)
                
        }
        self.shouldReturnProductToHomeScreen = true
    }
    
    @IBAction func postButtonTouched(sender: AnyObject) {
        
        if(self.commentTextField.text!.length > 0)
        {
            self.view.endEditing(true)
//            var arr = [AnyObject]()
//            for user in selectedUserArr
//            {
//                if let userObj = user as? MVUser
//                {
//                    arr.append("\(userObj.id)")
//                }
//            }
            
            MVDataManager.commentProduct(self.productDetail.id, comment: self.commentTextField.text,mentionedUser: [], successBlock: { result in
                
                print(result)
                self.fetchData()
                }, failureBlock: { failure in
                    print(failure)
            })
            
            
            self.commentTextField.text = ""
        }
        
    }
    
    func userProfileButtonTouched(sender : UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        if(sender.tag == 0)
        {
            userProfileVC.userProfileId = self.productDetail.user.id
        }
        else
        {
            userProfileVC.userProfileId = self.commentsArray[sender.tag - 1].user.id
        }
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    @IBAction func buyItemButtonTouched(sender: AnyObject)
    {

//        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
//        MVDataManager.venmoValidate({ response in
        
            let mainSt = UIStoryboard(name: "Main", bundle: nil)
            
            let cardInfoVC:MVVenmoPaymentViewController = mainSt.instantiateViewControllerWithIdentifier("venmoPaymentViewController")  as! MVVenmoPaymentViewController
            //        let cardInfoVC:MVStripePaymentViewController = mainSt.instantiateViewControllerWithIdentifier("cardInfoViewController")  as! MVStripePaymentViewController
            cardInfoVC.itemPrice = self.productDetail.price
            cardInfoVC.product = self.productDetail
            
            self.navigationController!.pushViewController(cardInfoVC, animated: true)
            SVProgressHUD.popActivity()
            
//            }) { failure in
//                Venmo.sharedInstance().requestPermissions([VENPermissionMakePayments, VENPermissionAccessProfile, VENPermissionAccessPhone, VENPermissionAccessEmail]) { (success, error) -> Void in
//                    if (success)
//                    {
//                        //                        print("refreshToken:    " + Venmo.sharedInstance().session.refreshToken)
//                        //                        print("accessTken:      \(Venmo.sharedInstance().session.accessToken)")
//                        //                        print("expDate:         \(Venmo.sharedInstance().session.expirationDate)")
//                        //                        print("username:        " + Venmo.sharedInstance().session.user.username)
//                        //                        print("firstName:       " + Venmo.sharedInstance().session.user.firstName)
//                        //                        print("lastName:        " + Venmo.sharedInstance().session.user.lastName)
//                        //                        print("displayName:     " + Venmo.sharedInstance().session.user.displayName)
//                        //                        print("about:           " + Venmo.sharedInstance().session.user.about)
//                        //                        print("profileImageUrl: " + Venmo.sharedInstance().session.user.profileImageUrl)
//                        //                        print("primaryPhone:    " + Venmo.sharedInstance().session.user.primaryPhone)
//                        //                        print("primaryEmail:    " + Venmo.sharedInstance().session.user.primaryEmail)
//                        //                        print("externalID:      " + Venmo.sharedInstance().session.user.externalId)
//                        //                        print("dateJoined:      \(Venmo.sharedInstance().session.user.dateJoined)")
//                        //                print("internalID: " + Venmo.sharedInstance().session.user.internalId)
//                        
//                        MVDataManager.venmoConnect(Venmo.sharedInstance().session.user.externalId, accessToken: Venmo.sharedInstance().session.accessToken, refreshToken: Venmo.sharedInstance().session.refreshToken, expiresIn: Venmo.sharedInstance().session.expirationDate, successBlock: { response in
//                            
//                            let mainSt = UIStoryboard(name: "Main", bundle: nil)
//                            
//                            let cardInfoVC:MVVenmoPaymentViewController = mainSt.instantiateViewControllerWithIdentifier("venmoPaymentViewController")  as! MVVenmoPaymentViewController
//                            //        let cardInfoVC:MVStripePaymentViewController = mainSt.instantiateViewControllerWithIdentifier("cardInfoViewController")  as! MVStripePaymentViewController
//                            cardInfoVC.itemPrice = self.productDetail.price
//                            cardInfoVC.product = self.productDetail
//                            self.navigationController!.pushViewController(cardInfoVC, animated: true)
//                            
//                            let alert:UIAlertView = UIAlertView(title: "", message: "\(response)", delegate: self, cancelButtonTitle: "OK")
//                            alert.show()
//                            SVProgressHUD.popActivity()
//
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
//                        print(error)
//                        SVProgressHUD.popActivity()
//                    }
//                    
//                }
//                SVProgressHUD.popActivity()
//        }
//
        


    }
    
    //MARK: Screen setup
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    func addRightNavItemOnView() {
        let inboxButton: UIButton = UIButton(type: UIButtonType.Custom)
        inboxButton.frame = CGRectMake(0, 0, 25, 20)
        inboxButton.setImage(UIImage(named:"inboxButton.png"), forState: UIControlState.Normal)
        inboxButton.addTarget(self, action: #selector(ItemDetailViewController.inboxButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
         
            let doneBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ItemDetailViewController.closePressedRightNavItem))
            
            self.navigationItem.setRightBarButtonItem(doneBarButtonItem, animated: true)
            
        } else {
            self.navigationItem.setRightBarButtonItem(self.badgeButtonItem, animated: true)
        }
    }
    
    func closePressedRightNavItem() {
         if self.navControllerDelegate != nil {
            self.navControllerDelegate?.onTouchCloseButton()
        } else {
            print("Delegate navControllerDelegate not init")
        }
    }
    
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if(self.visualEffectView == nil){
            self.addBlurEffect()
        } else {
            visualEffectView?.removeFromSuperview()
            visualEffectView = nil
            self.addBlurEffect()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    //MARK: Fetc logic
    func fetchData() {
        SVProgressHUD.show()
        MVDataManager.getProductComments(self.productDetail.id, successBlock: { response in
            
            self.commentsArray = response as! [MVComment]
            
            SVProgressHUD.dismiss()
            self.itemDetailsTable.reloadData()
            
            }) { failure in
                
                print(failure)
                SVProgressHUD.dismiss()
                
        }
        
    }
    
    // MARK: Delegate
    func onTouchShareButton(cell: UITableViewCell) {
        
        let movCell:MOVVItemCell = cell as! MOVVItemCell
        let product: MVProduct = self.productDetail

        let text:String = "Hey guys! \nCheck out this \(movCell.itemName.text!) on Mov. Watch the full video here! \n\(product.shareLink)"
        //        var url:NSURL = NSURL(string: product.shareLink)!
        let image:UIImage = movCell.itemImage.image!
        
        let objectsToShare = [text, image]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            
            print("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        }
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:MOVVGreen]
        UIBarButtonItem.appearance().tintColor = MOVVGreen
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func onTouchOfferButton(cell: UITableViewCell) {
        
    }
    
    func tapGestureLikeRecognizer(sender: UITapGestureRecognizer) {
        
    }
    func likeCountTapped(tag: Int) {
        self.navigationController?.pushViewController(MVLikesViewController.getLikeViewController(productDetail), animated: true)
    }
    //MARK:- MVComment user delegate
    
    func tapGestureShowDetailsRecognizer(sender: UITapGestureRecognizer) {
        
    }
    func userSelected(user: MVUser) {
        if lastWordRange != nil
        {
            selectedUserArr.addObject(user)
            rangeArr.append(NSMakeRange(lastWordRange.location, user.displayName.length))
            let commentStr = NSString(optionalString: commentTextField.text)
            let updatedStr = commentStr!.stringByReplacingCharactersInRange(lastWordRange, withString:"\(user.displayName) ")
            currentCommentStr = updatedStr
            updateRange(lastWordRange, string: user.displayName)
            lastCurserRange = NSMakeRange((lastWordRange.location + user.displayName.length + 1), 0)
            updateTextField()
            commentSuggestionContainerView.showTableWithUserNamePrefix("")
            
        }
    }
    // MARK:- Facebook like usertag methods
    
    func updateTextField()
    {
        let attributedText = NSMutableAttributedString()
        var count = 0
        for subStr in currentCommentStr.componentsSeparatedByString(" ") {
            if count > 0
            {
                if checkSubStringLiesInRange(" ", startIndex : attributedText.length)
                {
                    attributedText.appendAttributedString(updateAccordingUser(" "))
                }
                else
                {
                    attributedText.appendAttributedString(updatePlainString(" "))
                }
            }
            if checkSubStringLiesInRange(subStr, startIndex : attributedText.length)
            {
                attributedText.appendAttributedString(updateAccordingUser(subStr))
            }
            else
            {
                attributedText.appendAttributedString(updatePlainString(subStr))
            }
            count += 1
        }
        
        commentTextField.attributedText = attributedText
        selectRange(lastCurserRange)
    }
    
    func checkSubStringLiesInRange(subString : String, startIndex : Int) -> Bool
    {
        let range = currentCommentStr.rangeOfString(subString, options:.CaseInsensitiveSearch, range: NSMakeRange(startIndex, subString.length))
        return checkRangeLiesInSavedRange(range)
    }
    
    func updateAccordingUser(userStr:String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: userStr)
        attributedString.addAttributes([NSFontAttributeName : commentTextField.font!,NSForegroundColorAttributeName : UIColor.blueColor(),NSBackgroundColorAttributeName : UIColor.lightGrayColor()], range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func updatePlainString(str : String) -> NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttributes([NSFontAttributeName : commentTextField.font!,NSForegroundColorAttributeName : UIColor.blackColor()], range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func selectRange(range : NSRange)
    {
        let newPosition = commentTextField.positionFromPosition(commentTextField.beginningOfDocument, offset: range.location)
        commentTextField.selectedTextRange = commentTextField.textRangeFromPosition(newPosition!, toPosition: newPosition!)
    }
    
    func updateRange(range : NSRange, string : String)
    {
        if range.length > string.length
        {
            updateAllRangesAfter(NSMakeRange(range.location, range.length - string.length),shouldIncrease: false)
        }
        else if range.length < string.length
        {
            updateAllRangesAfter(NSMakeRange(range.location, string.length - range.length),shouldIncrease: true)
        }
        lastCurserRange = NSMakeRange(range.location + string.length, 0)
    }
    
    func updateAllRangesAfter(range : NSRange, shouldIncrease: Bool)
    {
        var count = 0
        for savedRange in rangeArr
        {
            if savedRange.location > range.location
            {
                var newRange = savedRange
                if shouldIncrease
                {
                    newRange.location += range.length
                }
                else
                {
                    newRange.location -= range.length
                }
                rangeArr[count] = newRange
            }
            count += 1
        }
        
    }
    
    func checkRangeLiesInSavedRange(range : NSRange) -> Bool
    {
        for savedRange in rangeArr
        {
            if savedRange.location <= range.location && (savedRange.location + savedRange.length - 1) >= range.location
            {
                return true
            }
        }
        return false
    }
    
    func getParentRange(range : NSRange) -> NSRange
    {
        for savedRange in rangeArr
        {
            if savedRange.location <= range.location && (savedRange.location + savedRange.length - 1) >= range.location
            {
                return savedRange
            }
        }
        return NSMakeRange(0, 0)
    }
    
    func getParentRangeIndex(range : NSRange) -> Int
    {
        var count = 0
        for savedRange in rangeArr
        {
            if savedRange.location <= range.location && (savedRange.location + savedRange.length - 1) >= range.location
            {
                return count
            }
            count += 1
        }
        return -1
    }
    
    func getMaxRangeWithIndex(index : Int) -> Int
    {
        var count = 0
        var maxIndex = 0
        let currentRange = rangeArr[0]
        for savedRange in rangeArr
        {
            if savedRange.location > currentRange.location && savedRange.location < index
            {
                maxIndex = count
            }
            count += 1
        }
        return maxIndex
    }
    
    
    func getCurrentWord(newStr : NSString?, string : String) -> String
    {
        let textRange = commentTextField.selectedTextRange
        let textEndPosition = (textRange?.start)!
        let length = string.characters.count
        var currentOffset = commentTextField.offsetFromPosition(commentTextField.beginningOfDocument, toPosition: textEndPosition) + length
        if currentOffset > newStr?.length && newStr != nil
        {
            currentOffset = (newStr?.length)!
        }
        let subString = newStr?.substringToIndex(currentOffset)
        
        if let lastWord = subString?.componentsSeparatedByString(" ").last
        {
            lastWordRange = NSMakeRange((newStr?.rangeOfString(lastWord, options: .BackwardsSearch).location)!, lastWord.length)
            return lastWord as String
        }
        else
        {
            lastWordRange = nil
        }
        return ""
    }
    
    
    //MARK:- Item details cell  delegate methods
    func userSelectedAtList(user : MVUser)
    {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = ("\(user.id)" as NSString).integerValue
        self.navigationController!.pushViewController(userProfileVC, animated: true)

    }

    
    
}
