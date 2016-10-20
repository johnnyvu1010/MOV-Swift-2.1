//
//  ItemDetailViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 06/05/15.
//  Copyright (c) 2016 Maksim M. All rights reserved.
//
import MediaPlayer
import UIKit
import AVFoundation
import AVKit
import BBBadgeBarButtonItem
import IQKeyboardManager
import SVProgressHUD
import Branch
import AFNetworking
import TwitterKit
import FBSDKShareKit
import MessageUI
import PhotosUI
import AssetsLibrary

//@objc protocol TabBarTogglable {
//    func toggleTabbar()
//    func showTabbar()
//    func hideTabbar()
//}

protocol PopupVideoProfileDelegate:class
{
    //    func productLikeStateChanged(product : MVProduct)
    func onDismiss(id : Int)
    func popupPlay(flag : Int)
}

class PopupVideoProfile: UIViewController, UITableViewDataSource,MFMessageComposeViewControllerDelegate, UITableViewDelegate , UITextFieldDelegate, TTTAttributedLabelDelegate, MOVVItemCellDelegate, BranchDeepLinkingController, SharingViewControllerDelegate, MVCommentSuggestionViewDelegate , ItemDetailCommentCellDelegate {
    
    @IBOutlet var itemDetailsTable: UITableView!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var postView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var addCartButton: UIButton!
    @IBOutlet var uiView: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet var commentSuggestionContainerView: MVCommentSuggestionView!
    var shareImageURLString : NSString!
    private var badgeButtonItem: BBBadgeBarButtonItem!
    private var player:AVPlayer!
    private var playerController:AVPlayerViewController!
    private var playerIsPlaying : Bool = false
    private var shouldReturnProductToHomeScreen : Bool = false
    private var commentsArray:[MVComment]! = [MVComment]()
    var productDetail : MVProduct!
    weak var delegate : ItemDetailViewControllerDelegate? = nil
    weak var current_delegate : PopupVideoProfileDelegate? = nil
    private var visualEffectView:UIVisualEffectView?
    private var keyboardRect : CGRect!
    private var isPresentedViaDeepLink: Bool = false
    private var lastWordRange : NSRange!
    private var selectedUserArr = NSMutableArray()
    private var rangeArr = [NSRange]()
    private var currentCommentStr = NSString()
    private var lastCurserRange : NSRange!
    @IBOutlet var messageTextFieldConstrain: NSLayoutConstraint!
    var blurInt: Int! = 0
    
    let play_flag: Int = 1
    let back_flag: Int = 2
    let add_flag: Int = 3
    
    var images:UIImageView! = nil
    var btn : UIButton! = nil
    
    
    
    var blurEffect = UIBlurEffect()
    var effectView = UIVisualEffectView()
    var presentedVC = UIViewController()
    
    var productTitle : String!
    var shareUrl : String!
    var shareImg : UIImage!
    var imgLocalPath: NSURL!
    var imageMain : UIImageView!
    var documentController : UIDocumentInteractionController!
    var docController = UIDocumentInteractionController()
    var shareVideo: NSURL? = nil
    
    
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
        super.viewDidLoad()
        backButton.alpha = 0
        addCartButton.alpha = 0
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().enable = false
        if self.isPresentedViaDeepLink == false {
            self.fetchData()
        }
        viewContainer.layer.cornerRadius = 5
        viewContainer.layer.masksToBounds = true
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
        
        
        let swipeSelector : Selector = #selector(PopupVideoProfile.popupWindowDown(_:))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: swipeSelector)
        
        upSwipe.direction = UISwipeGestureRecognizerDirection.Down
        uiView.addGestureRecognizer(upSwipe)
        
        if (productDetail.isSold == 1){
            addCartButton.hidden = true
        }else{
            addCartButton.hidden = false
        }
        
        commentSuggestionContainerView.delegate = self
        commentSuggestionContainerView.item = productDetail
        presentedVC = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        
        blurEffect = UIBlurEffect(style: .Dark)
        effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = presentedVC.view.frame
        //        self.navigationController?.navigationBar.subviews[0].addSubview(effectView)
        self.view.addSubview(effectView)
        
        effectView.alpha = 0

        if productDetail.user.id == MVParameters.sharedInstance.currentMVUser.id
        {
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
        
    }
    
    
    func keyboardWillChange(notification : NSNotification)
    {
        self.keyboardRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.keyboardRect = self.view.convertRect(self.keyboardRect, fromView: nil)
    }
    
    
    func keyboardWillShow()
    {
        self.messageTextFieldConstrain.constant = self.keyboardRect.size.height + 5
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.postView.layoutIfNeeded()
        })
        
    }
    
    func keyboardWillHide()
    {
        self.messageTextFieldConstrain.constant = 5
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
        
        //        backButton.hidden = false
        //        addCartButton.hidden = false
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
            //            self.delegate?.productLikeStateChanged(self.productDetail)
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
                cell.itemName.text = productDetail.name
                cell.amountLabel.text = "$\(productDetail.price)"
                cell.likeCountLabel.text = "\(productDetail.numLikes)"
                cell.commentCountLabel.text = "\(productDetail.numComments)"
                if(self.productDetail.user.id != MVParameters.sharedInstance.currentMVUser.id){
                    cell.userProfileButton.tag = indexPath.row
                    cell.userProfileButton.addTarget(self, action: #selector(PopupVideoProfile.userProfileButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
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
                    cell.usernameLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
                    cell.usernameLabel.addLinkToURL(url, withRange: range)
                    cell.usernameLabel.attributedText = attributedString
                    cell.usernameLabel.delegate = self
                    cell.locationLabel.text = productDetail.user.location
                    
                    cell.userImage.setImageWithURL(NSURL(string: productDetail.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                    MVHelper.addMOVVCornerRadiusToView(cell.userImage)

                    images = UIImageView()
                    images.setImageWithURL(NSURL(string: self.productDetail.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                }
                cell.timeLabel.text = productDetail.uploadDate
                cell.tagsLabel.text = productDetail.tags
                btn = cell.likeButton
                cell.likeButton.addTarget(self, action: #selector(PopupVideoProfile.likeButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
                cell._shareButton.addTarget(self, action: #selector(PopupVideoProfile.onTouchShareButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//              cell._commentButton.addTarget(self, action: #selector(PopupVideoProfile.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell._heartButton.addTarget(self, action: #selector(PopupVideoProfile.likeButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                
                
                
                if(productDetail.isLiked as Bool)
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonSelectedAsset"), forState: UIControlState.Normal)
                }
                else
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonAsset"), forState: UIControlState.Normal)
                }
                
                } else {
                let alert = MOVVAlertViewController(title: "API needed", message: "Please provide the API for the content", preferredStyle: .Alert)
                self.presentViewController(alert, animated: true, completion: nil)
                MVHelper.delay(1, closure: { () -> () in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
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
                    cell.userProfileButton.addTarget(self, action: #selector(PopupVideoProfile.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    cell.userProfileButton.tag = indexPath.row
                }
                cell.setupCommentView(comment)
                //backButton.hidden = false
                //addCartButton.hidden = false
                cell.delegate = self
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
    
    
    @IBAction func onAddCartButton(sender: AnyObject) {
        if (productDetail.user.id == MVParameters.sharedInstance.currentMVUser.id){
//            let alert:UIAlertController = UIAlertController.init(title: "", message:"Tisk-tisk…You can’t buy your own item!"  as String, preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
//                });
//            self.presentViewController(alert, animated: true, completion: {
//            })

            if let viewController = MVEditProductViewController(nibName: "MVEditProductViewController", bundle: nil) as? MVEditProductViewController
            {
//                player!.pause()
//                playerIsPlaying = false
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
    
    @IBAction func onBackButton(sender: AnyObject) {
        NSLog("back Button")
        backButton.hidden = true
        addCartButton.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
        self.current_delegate?.popupPlay(back_flag)
    }
    @IBAction func popupWindowDown(sender: AnyObject){
        backButton.hidden = true
        addCartButton.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
        self.current_delegate?.popupPlay(play_flag)
    }
    
    //MARK: TTTAttributed Label Delegate Method
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = ("\(url)" as NSString).integerValue
        //        self.navigationController!.pushViewController(userProfileVC, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.current_delegate?.onDismiss(("\(url)" as NSString).integerValue)
    }
    
    
    //MARK: Textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onPlayButtonClick(sender: AnyObject) {
        backButton.hidden = true
        addCartButton.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
        self.current_delegate?.popupPlay(play_flag)
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newStr = NSString(optionalString : textField.text)!
        newStr = newStr.stringByReplacingCharactersInRange(range, withString: string)
        let currentWord = getCurrentWord(newStr, string:  string)
        if checkRangeLiesInSavedRange(range)
        {
            if string == "" && range.length > 0
            {
                var parentRange = getParentRange(range)
                let index = getParentRangeIndex(range)
                let subStr = currentCommentStr.substringWithRange(parentRange)
                let arr = subStr.componentsSeparatedByString(" ")
                if arr.count > 1
                {
                    let firstWordLength = (arr.first?.length)!
                    let lastWordLength = (arr.last?.length)!
                    var firstWordRange = parentRange
                    firstWordRange.length = firstWordLength
                    if firstWordRange.location <= range.location && (firstWordRange.location + firstWordRange.length ) >= range.location
                    {
                        currentCommentStr = currentCommentStr.stringByReplacingCharactersInRange(NSMakeRange(firstWordRange.location, firstWordLength + 1), withString: "")
                        parentRange.length = lastWordLength
                        rangeArr[index] = parentRange
                        updateAllRangesAfter(NSMakeRange(parentRange.location, firstWordLength+1),shouldIncrease: false)
                        lastCurserRange = NSMakeRange(parentRange.location + parentRange.length, 0)
                    }
                    else
                    {
                        
                        currentCommentStr = currentCommentStr.stringByReplacingCharactersInRange(NSMakeRange(parentRange.location + firstWordLength, lastWordLength + 1), withString: "")
                        parentRange.length = firstWordLength
                        rangeArr[index] = parentRange
                        updateAllRangesAfter(NSMakeRange(parentRange.location, lastWordLength+1),shouldIncrease: false)
                        lastCurserRange = NSMakeRange(parentRange.location + parentRange.length, 0)
                    }
                }
                else
                {
                    currentCommentStr = currentCommentStr.stringByReplacingCharactersInRange(parentRange, withString: "")
                    rangeArr.removeAtIndex(index)
                    selectedUserArr.removeObjectAtIndex(index)
                    updateAllRangesAfter(parentRange,shouldIncrease: false)
                    lastCurserRange = NSMakeRange(parentRange.location, 0)
                }
            }
            else
            {
                 currentCommentStr = newStr
                 updateRange(range, string: string)
            }
        }
        else
        {
            currentCommentStr = newStr
            updateRange(range, string: string)
        }
        commentSuggestionContainerView.showTableWithUserNamePrefix(currentWord)
        self.performSelector(#selector(PopupVideoProfile.updateTextField), withObject: nil, afterDelay: 0.01)
        return false
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        rangeArr.removeAll()
        selectedUserArr.removeAllObjects()
        lastWordRange = NSMakeRange(0, 0)
        lastCurserRange = NSMakeRange(0, 0)
        currentCommentStr = ""
        commentSuggestionContainerView.showTableWithUserNamePrefix("")
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
    
    func onCommentButton(sender:UIButton) {
        NSLog("onCommentButton")
    }
    
    func onShareButton(sender:UIButton) {
        NSLog("onShareButton")
    }
    
    func onHeartButton(sender:UIButton) {
        NSLog("onHeartButton")
    }
    
    func likeButtonTouched(sender:UIButton) {
        //let btn : UIButton = sender
        
        let cell:MOVVItemCell = sender.superview?.superview as! MOVVItemCell
        MVDataManager.likeProduct(self.productDetail.id, successBlock: { response in
            if(self.productDetail.isLiked as Bool) {
                self.btn.setBackgroundImage(UIImage(named: "likeButtonAsset"), forState: UIControlState.Normal)
                self.productDetail.isLiked = false
                self.productDetail.numLikes = self.productDetail.numLikes - 1
                cell.likeCountLabel.text = "\(self.productDetail.numLikes)"
            }
            else
            {
                self.btn.setBackgroundImage(UIImage(named: "likeButtonSelectedAsset"), forState: UIControlState.Normal)
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
            var arr = [AnyObject]()
            for user in selectedUserArr
            {
                if let userObj = user as? MVUser
                {
                    arr.append("\(userObj.id)")
                }
            }
            MVDataManager.commentProduct(self.productDetail.id, comment: createCommentText(), mentionedUser: arr,  successBlock: { result in
                self.fetchData()
                self.textFieldShouldClear(self.commentTextField)
                }, failureBlock: { failure in
                    print(failure)
            })
            
            
            self.commentTextField.text = ""
        }
        
    }
    
    func createCommentText() -> String
    {
        let mutableStr = NSMutableString(string : currentCommentStr)
        var index = mutableStr.length
        for i in 0..<rangeArr.count
        {
            let rangeIndex = getMaxRangeWithIndex(index)
            let range = rangeArr[rangeIndex]
            if let user = selectedUserArr[rangeIndex] as? MVUser
            {
                 mutableStr.replaceCharactersInRange(range, withString: "user_data_$_#_\(user.id!)")
            }
            index = range.location
        }
        return mutableStr as String
    }
    
    func userProfileButtonTouched(sender : UIButton) {
//        self.commentTextField.becomeFirstResponder()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        var _id : Int = 0;
        if(sender.tag == 0)
        {
            _id = self.productDetail.user.id
            userProfileVC.userProfileId = self.productDetail.user.id
        }
        else
        {
            userProfileVC.userProfileId = self.commentsArray[sender.tag - 1].user.id
            _id = self.commentsArray[sender.tag - 1].user.id
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        self.current_delegate?.onDismiss(_id)
        
        self.presentViewController(UINavigationController.init(rootViewController: userProfileVC), animated: true, completion: nil)
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
            
            let doneBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ItemDetailViewController.closePressed))
            
            self.navigationItem.setRightBarButtonItem(doneBarButtonItem, animated: true)
            
        } else {
            self.navigationItem.setRightBarButtonItem(self.badgeButtonItem, animated: true)
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
            
            UIView.animateWithDuration(2, animations: {
//                self.backButton.hidden = false
//                self.addCartButton.hidden = false
                
                self.backButton.alpha = 1
                self.addCartButton.alpha = 1
            })
            
            
            
        }) { failure in
            
            print(failure)
            SVProgressHUD.dismiss()
            
        }
        
    }
    
    
    func addBlur() {
        UIView.animateWithDuration(0.8) {
            self.effectView.alpha = 1.0
        }
    }
    
    func removeBlur() {
        UIView.animateWithDuration(0.8) {
            self.effectView.alpha = 0.0
            
        }
    }
    
    // Cancel
    func dismissViewCon(viewCon: SharingViewController) {
        viewCon.dismissViewControllerAnimated(true, completion: nil)
        
        removeBlur()
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
//            self.doneinstagram()
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
            //            var size = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform)
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
            
            //            layerinstruction.setTransform(CGAffineTransformMakeRotation(90), atTime: vid_duration)
            
            //            let t1 = CGAffineTransformMakeTranslation(0, 0);
            //            let t2 = CGAffineTransformRotate(t1, CGFloat(M_PI_2));
            //
            //            layerinstruction.setTransform(t2, atTime: kCMTimeZero)
            //            layerinstruction.setOpacity(0.0, atTime: vid_duration)
            //            instruction.layerInstructions = [layerinstruction]
            //            layercomposition.instructions = [instruction]
            
            
            //            var videoAssetOrientation = UIImageOrientation.Up
            //            var isVideoAssetPortrait = false
            //            let videoTransform = videotrack.preferredTransform
            //
            //            if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)
            //            {
            //                videoAssetOrientation = UIImageOrientation.Right
            //                isVideoAssetPortrait = true
            //            }
            //            if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)
            //            {
            //                videoAssetOrientation =  UIImageOrientation.Left
            //                isVideoAssetPortrait = true
            //            }
            //            if(videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)
            //            {
            //                videoAssetOrientation =  UIImageOrientation.Up
            //            }
            //            if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0)
            //            {
            //                videoAssetOrientation = UIImageOrientation.Down
            //            }
            //
            //            var FirstAssetScaleToFitRatio = 320.0 / videotrack.naturalSize.width
            //
            //
            //
            //            if(isVideoAssetPortrait) {
            //                FirstAssetScaleToFitRatio = 320.0/videotrack.naturalSize.height
            //
            //                let FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio)
            //                layerinstruction.setTransform(CGAffineTransformConcat(videotrack.preferredTransform, FirstAssetScaleFactor), atTime: kCMTimeZero)
            //
            //            }else{
            //                let FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio)
            //                layerinstruction.setTransform(CGAffineTransformConcat(CGAffineTransformConcat(videotrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 320)), atTime: kCMTimeZero)
            //            }
            //            layerinstruction.setOpacity(0.0, atTime: vid_duration)
            //
            
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
            //            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(NSURL.init(string: path), completionBlock: nil)
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
            let url = NSURL(string: "instagram://library?AssetPath=\(self.shareVideo!.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!)")
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
            }
        } else {
            let alert: MOVVAlertViewController = MOVVAlertViewController(title: "Instagram not installed", message: "Please install instagram application for this feature", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("no instagram found")
        }
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
        UINavigationBar.appearance().barTintColor = UIColor.greenAppColor()
        self.removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadImage(self.shareImageURLString as String) { result in
                self.shareImg = result
                self.donemessage()
            }
        })
    }
    func donemessage() {
        
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

    
    
    
    // MARK: Delegate
    func onTouchShareButton(cell: UITableViewCell) {

        addBlur()
        
//        let product: MVProduct = productsArray![self.tableView.indexPathForCell(cell)!.row]
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let sharingVC              = mainSt.instantiateViewControllerWithIdentifier("SharingVC")  as! SharingViewController
        sharingVC.delegate = self
        self.productTitle = productDetail.name
        self.shareUrl = productDetail.shareLink
        self.shareVideo = NSURL(string: productDetail.videoFile)
        self.shareImageURLString = productDetail.previewImage
        self.presentViewController(sharingVC, animated: true, completion: nil)
        
    }
    
    func onTouchOfferButton(cell: UITableViewCell) {
        
    }
    
    func tapGestureLikeRecognizer(sender: UITapGestureRecognizer) {
        
    }
    
    func tapGestureShowDetailsRecognizer(sender: UITapGestureRecognizer) {
        
    }
    func likeCountTapped(tag: Int) {
        self.navigationController?.pushViewController(MVLikesViewController.getLikeViewController(productDetail), animated: true)
    }

    
//MARK:- MVComment user delegate
    
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
        let attributedString = NSMutableAttributedString(string: NSString(string: userStr).capitalizedString as String)
        attributedString.addAttributes([NSFontAttributeName : commentTextField.font!,NSForegroundColorAttributeName : MOVVGreen, NSBackgroundColorAttributeName : UIColor.bt_colorFromHex("0xEEEEEE", alpha: 1)], range: NSMakeRange(0, attributedString.length))
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
        //        self.navigationController!.pushViewController(userProfileVC, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.current_delegate?.onDismiss(("\(user.id)" as NSString).integerValue)
    }
    
}
