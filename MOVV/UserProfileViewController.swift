//
//  UserProfileViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 12/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.


import UIKit
import BBBadgeBarButtonItem
//import SDWebImage
import CSStickyHeaderFlowLayout
import SVProgressHUD
import AFNetworking
import TwitterKit
import FBSDKShareKit
import MessageUI
import AssetsLibrary

protocol UserProfileViewControllerDelegate:class{
    func userFollowStateChanged(followState : Bool)
}

class UserProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,SharingViewControllerDelegate, UICollectionViewDelegateFlowLayout, ItemDetailViewControllerDelegate, MFMessageComposeViewControllerDelegate,TTTAttributedLabelDelegate, ProfileCollectionViewCellDelegate
{
    
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
    var shareImageURLString : NSString!
    
    
    var isFromTabBar:Bool?
    var userProfile : MVUserProfile!
    var userProfileId : Int?
    var reviewsArray:[MVReview]! = [MVReview]()
    var isCurrentUser : Bool!
    var badgeButtonItem: BBBadgeBarButtonItem!
    var selectedProductIndex : Int!
    var reviewsIsSelected : Bool = false
    weak var delegate : UserProfileViewControllerDelegate? = nil
    var dataIsAvailable : Bool = false
    
    var coverImage : UIImage!
    var profileImage :  UIImage!

    var nib:UINib!
    enum ScrollDirection:Int {
        case Up = 0, Down, None
    }
    
    @IBOutlet var collectionView: UICollectionView!
    var initialOffset:CGPoint!
    var selectors = ["showMyItemsList", "showMyReviews", "showMyFollowers", "showTimeLine"]
    
    @IBOutlet var backbutton: UIButton!
    
    //MARK: Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nib = UINib(nibName: "CSAlwaysOnTopHeader", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backbutton.hidden = false
        
        if(self.userProfileId == nil)
        {
            self.userProfileId = MVParameters.sharedInstance.currentMVUser.id
            backbutton.hidden = true
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
        }
        //fetchData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserProfileViewController.showMyFollowers), name: "followers", object: nil)
        
        setupCollectionView()
        presentedVC = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        
        
        blurEffect = UIBlurEffect(style: .Dark)
        effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = presentedVC.view.frame
        //        self.navigationController?.navigationBar.subviews[0].addSubview(effectView)
        presentedVC.view.addSubview(effectView)
        
        effectView.alpha = 0
        self.fetchData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        if(self.userProfileId == MVParameters.sharedInstance.currentMVUser.id)
        {
            NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
            addRightNavItemOnView()
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
        }
        if !self.view.userInteractionEnabled {
            self.view.userInteractionEnabled = true
            if collectionView.numberOfItemsInSection(0) > 0{
                self.fetchData()
                collectionView.scrollToItemAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: .Bottom, animated: false)
            }
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        for var i=0;i<self.navigationController?.navigationBar.subviews[0].subviews.count;i += 1 {
            self.navigationController?.navigationBar.subviews[0].subviews[i].removeFromSuperview()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        self.backbutton.hidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.userInteractionEnabled = true
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        self.preferredStatusBarStyle()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: ScrollView delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        initialOffset = scrollView.contentOffset
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        initialOffset = scrollView.contentOffset
    }

    
    //MARK: UICollectionViewDelegate methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = CGRectGetWidth(collectionView.bounds)
        if(collectionView.tag == 0)
        {
            var height = CGFloat()
            if(self.dataIsAvailable)
            {
                if(CGRectGetWidth(self.view.frame) == 320){
                    height  = 480
                } else if(CGRectGetWidth(self.view.frame) == 375){
                    height = 510
                } else {
                    height = 580
                }
            }
            else
            {
                height = 50
            }
            return CGSize(width: screenWidth, height: height)
        }
        else
        {
            var contentHeight = CGFloat()
            if(self.dataIsAvailable)
            {

            }
            else
            {
                contentHeight = 50
            }
            return CGSize(width: screenWidth, height: contentHeight)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(self.reviewsIsSelected)
        {
            if(self.reviewsArray.count > 0)
            {
                self.dataIsAvailable = true
            }
            else
            {
                self.dataIsAvailable = false
            }
            if(self.dataIsAvailable)
            {
            return self.reviewsArray.count
            }
            else
            {
                return 1
            }
        }
        else
        {
            if(self.userProfile != nil)
            {
                if(self.userProfile.timelineArray!.count > 0)
                {
                    self.dataIsAvailable = true
                }
                else
                {
                    self.dataIsAvailable = false
                }
                if(self.dataIsAvailable)
                {
                return self.userProfile.timelineArray!.count
                }
                else
                {
                    return 1
                }
            }
            else
            {
                return 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        var identifier:String!
        if(self.dataIsAvailable)
        {
            if(collectionView.tag == 0){
                identifier = "itemCollectionCell"
            } else {
                identifier = "reviewCollectionCell"
            }
        }
        else
        {
            identifier = "noDataCell"
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ProfileCollectionViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        if(self.dataIsAvailable)
        {
            let timeLine:MVTimeline = self.userProfile.timelineArray[indexPath.row]
            if(collectionView.tag == 0){
                
                cell.itemName.text = timeLine.product.name
                cell.itemImage.setImageWithURL(NSURL(string: timeLine.product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                cell.itemImage.clipsToBounds = true
                cell.amountLabel.text = "$\(timeLine.product.price)"
                cell.likeCountLabel.text = "\(timeLine.product.numLikes)"
                cell.commentCountLabel.text = "\(timeLine.product.numComments)"
                cell.itemTagsLabel.text = timeLine.product.tags
                cell.timeLabel.text = timeLine.product.uploadDate
                
                let greenBoldedFontUserName = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]
                var concatenatedString:String = "@" + self.userProfile.timelineArray[indexPath.row].product.user.username + "                        "
                var string = concatenatedString as NSString
                var attributedString = NSMutableAttributedString(string: string as String)
                var range : NSRange!
                
                range = string.rangeOfString("@" + timeLine.product.user.username)
                attributedString.addAttributes(greenBoldedFontUserName, range: range)
                
                cell.userName.attributedText = attributedString
                var url : NSURL! = NSURL(string: "\(timeLine.product.user.id)")
                
                cell.userName.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
                cell.userName.addLinkToURL(url, withRange: range)
                cell.userName.delegate = self
                
                cell.locationLabel.text = timeLine.product.user.location
                cell.userProfileImage.setImageWithURL(NSURL(string: timeLine.product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userProfileImage)
                cell.likeButton.addTarget(self, action: #selector(UserProfileViewController.likeButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
                cell.likeButton.tag = indexPath.row
                if(timeLine.product.isLiked as Bool)
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonSelectedAsset"), forState: UIControlState.Normal)
                }
                else
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonAsset"), forState: UIControlState.Normal)
                }
                if(timeLine.product.user.id != MVParameters.sharedInstance.currentMVUser.id){
                    cell.profileButton.addTarget(self, action: #selector(UserProfileViewController.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    cell.profileButton.tag = indexPath.row
                }
                
                let user = "@" + (timeLine.product.user.username as NSString).stringByReplacingOccurrencesOfString(" ", withString: "")
                let actionUser = "@" + (timeLine.actionUser.username as NSString).stringByReplacingOccurrencesOfString(" ", withString: "")
                
                switch(timeLine.action as MVTimelineAction){
                    
                case MVTimelineAction.Like:
                    concatenatedString = "\(actionUser) liked \(user) item"
                    //cell.actionImage.image = UIImage(named: "likeButton.png")
                case MVTimelineAction.Comment:
                    concatenatedString = "\(actionUser) commented on \(user) item"
                    //cell.actionImage.image = UIImage(named: "commentButton.png")
                }
                
                string = (concatenatedString as NSString).stringByReplacingOccurrencesOfString("  ", withString: " ") as NSString
                attributedString = NSMutableAttributedString(string: string as String)
                attributedString.addAttributes(normalFont, range: string.rangeOfString((concatenatedString as NSString).stringByReplacingOccurrencesOfString("  ", withString: " ")))
                attributedString.addAttribute(NSParagraphStyleAttributeName, value: lineSpacing, range: string.rangeOfString(string as String))
                
                let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(16)]
                range = string.rangeOfString(actionUser)
                attributedString.addAttributes(greenBoldedFont, range:range)
                url = NSURL(string: "\(timeLine.actionUser.id)")
                cell.actionLabel.addLinkToURL(url, withRange: range)
                cell.actionLabel.attributedText = attributedString
                
                
                
                range  = string.rangeOfString(user, options: NSStringCompareOptions.CaseInsensitiveSearch , range: NSMakeRange(range.location + range.length, string.length - range.length))
                attributedString.addAttributes(greenBoldedFont, range:range)
                url  = NSURL(string: "\(timeLine.product.user.id)")
                cell.actionLabel.addLinkToURL(url, withRange: range)
                cell.actionLabel.attributedText = attributedString
                
                cell.actionLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
                cell.actionLabel.delegate = self
                cell.actionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                
                cell.playButton.addTarget(self, action: #selector(UserProfileViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                cell.itemDetailsButton.addTarget(self, action: #selector(UserProfileViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.itemDetailsButton.tag = indexPath.row
                cell.commentButton.addTarget(self, action: #selector(UserProfileViewController.showDetailsCom(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.commentButton.tag = indexPath.row
                
            } else {
                let review : MVReview = self.reviewsArray[indexPath.row]
                cell.reviewLabel.text = review.comment
                
                for i : Int in 0 ..< review.rating
                {
                    let button : UIButton = cell.viewWithTag(100+i) as! UIButton
                    button.setBackgroundImage((UIImage(named: "starFilled.png")), forState: UIControlState.Normal)
                }
                
                
                cell.reviewLabel.accessibilityLabel = "Quote Content"
                cell.reviewLabel.accessibilityValue = review.comment
                cell.reviewLabel.preferredMaxLayoutWidth = self.view.frame.size.width
                cell.reviewLabel.sizeToFit()
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
        }
        else
        {
            
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
       
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! CSAlwaysOnTopHeader
        if(self.userProfileId == MVParameters.sharedInstance.currentMVUser.id)
        {
            cell.editButtonAction! .addTarget(self, action: #selector(UserProfileViewController.showSettings), forControlEvents: .TouchUpInside)
            //cell.editButtonAction!.setTitle("EDIT", forState: .Normal)
        }
        else
        {
            if(self.userProfile != nil)
            {
                if(self.userProfile.isFollowed!)
                {
                    cell.editButtonAction!.setBackgroundImage(UIImage(named: "unfollowButton"), forState: .Normal)
                }
                else
                {
                    cell.editButtonAction!.setBackgroundImage(UIImage(named: "followButton"), forState: .Normal)
                }
            }
            //cell.editButtonAction!.setTitle("", forState: .Normal)
            cell.editButtonAction! .addTarget(self, action: #selector(UserProfileViewController.followUser), forControlEvents: .TouchUpInside)
        }
        
        
        //        cell.userPicButton.addTarget(self, action: Selector("playVideo"), forControlEvents: .TouchUpInside)
        if(self.userProfile != nil){
            
            cell.userPicButton.setImage(MVHelper.getImageFromURL(self.userProfile.profileImage), forState: .Normal)
            
            let imageURL:NSURL = NSURL(string: self.userProfile.coverImage)!
            SDWebImageManager.sharedManager().downloadImageWithURL(imageURL, options: SDWebImageOptions(), progress: nil, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, finished:Bool, imageURL:NSURL!) -> Void in
                cell.coverImage.image = image
                self.coverImage = image
            })
            
            self.profileImage = cell.userPicButton.imageView?.image
            
            cell.titleLabel!.text = self.userProfile.displayName
            cell.username.text = "@\(self.userProfile.username)"
            cell.location.text = self.userProfile.location
            cell.numberOfFollowers.text = "\(self.userProfile.numFollowers)"
            cell.numberOfReviews.text = "\(self.userProfile.numReviews)"
            cell.numberOfSelling.text = "\(self.userProfile.numSelling)"
            cell.setRatingStars(Int32(self.userProfile.userRating))
            
        }
        
        setupRecognizers(cell.newsView)
        setupRecognizers(cell.itemsView)
        setupRecognizers(cell.followersView)
        setupRecognizers(cell.reviewsView)
        return cell
    }
    
    
    //MARK: TTTAttributed Label Delegate Method
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(self.userProfileId == MVParameters.sharedInstance.currentMVUser.id)
        {
            let main = UIStoryboard(name: "Main", bundle: nil)
            let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
            
            
            
            userProfileVC.userProfileId = ("\(url)" as NSString).integerValue
            self.navigationController!.pushViewController(userProfileVC, animated: true)
        }
        else
        {
            self.userProfileId = ("\(url)" as NSString).integerValue
            self.fetchData()
        }
    }
    
    
    //MARK: fetch logic
    
    func fetchData() {
        SVProgressHUD.show()
        
        if(self.userProfileId == MVParameters.sharedInstance.currentMVUser.id)
        {
            MVDataManager.getUserProfile(self.userProfileId, currentUserID:0, successBlock: { response in
                self.userProfile = response as! MVUserProfile
                self.collectionView.reloadData()
                MVParameters.sharedInstance.currentMVUser.location = self.userProfile.location
                MVParameters.sharedInstance.currentMVUser.profileImage = self.userProfile.profileImage
                SVProgressHUD.popActivity()
                }) { failure in
                    print(failure)
                    SVProgressHUD.popActivity()
            }
        }
        else
        {
            MVDataManager.getUserProfile(self.userProfileId, currentUserID:MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
                self.userProfile = response as! MVUserProfile
                self.collectionView.reloadData()
                SVProgressHUD.popActivity()
                }) { failure in
                    print(failure)
                    SVProgressHUD.popActivity()
            }
        }
        
        MVDataManager.getUserReviews(self.userProfileId, successBlock: { response in
            self.reviewsArray = response as! [MVReview]
            }, failureBlock: { failure in
                
        })
        
    }
    
    func refreshData() {
        startedDataRefresh = true
        
        
        MVDataManager.getProductComments(self.userProfileId, successBlock: { response in
            self.userProfile = response as! MVUserProfile
            self.collectionView.reloadData()
            startedDataRefresh = false
            }) { failure -> Void in
                print(failure)
                startedDataRefresh = false
        }
        
    }
    
    
    //MARK: Action methods
    
    @IBAction func onBackButton(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    func likeButtonTouched(sender:UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let btn:UIButton = sender
        
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath:NSIndexPath  = self.collectionView.indexPathForCell(cell)!
        
        let timeLine:MVTimeline = self.userProfile.timelineArray[indexPath.row]
        SVProgressHUD.show()
        MVDataManager.likeProduct(timeLine.product.id, successBlock: { response in
            
            if(timeLine.product.isLiked as Bool)
            {
                appDelegate.mixpanel?.track("Unlike",properties: ["item": timeLine.product.name])
                btn.setBackgroundImage(UIImage(named: "likeButtonAssets"), forState: UIControlState.Normal)
                timeLine.product.isLiked = false
                timeLine.product.numLikes = timeLine.product.numLikes - 1
            }
            else
            {
                appDelegate.mixpanel?.track("Like",properties: ["item": timeLine.product.name])
                btn.setImage(UIImage(named: "likeButtonSelectedAssets"), forState: UIControlState.Normal)
                timeLine.product.isLiked = true
                timeLine.product.numLikes = timeLine.product.numLikes + 1
            }
            SVProgressHUD.popActivity()
            
            self.collectionView.reloadData()
            
            }) { failure in
                
                print(failure)
                SVProgressHUD.popActivity()
        }
    }
    
    func productLikeStateChanged(product : MVProduct) {
        self.userProfile.timelineArray[self.selectedProductIndex].product = product
        self.collectionView.reloadData()
    }
    
    func userProfileButtonTouched(sender : UIButton) {
        
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath:NSIndexPath  = self.collectionView.indexPathForCell(cell)!
        
        if(self.userProfileId == MVParameters.sharedInstance.currentMVUser.id)
        {
            let main = UIStoryboard(name: "Main", bundle: nil)
            let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
            userProfileVC.userProfileId = self.userProfile.timelineArray[indexPath.row].product.user.id
            self.navigationController!.pushViewController(userProfileVC, animated: true)
        }
        else
        {
            self.userProfileId = self.userProfile.timelineArray[indexPath.row].product.user.id
            self.fetchData()
        }
    }
    
    func inboxButtonPressed(sender:UIButton!) {
//        let mainSt = UIStoryboard(name: "Main", bundle: nil)
//        let inboxVC = mainSt.instantiateViewControllerWithIdentifier("inboxVC")  as! InboxViewController
//        inboxVC.isUserProfile = true
//        self.navigationController?.pushViewController(inboxVC, animated: true)
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let myCartViewController = mainSt.instantiateViewControllerWithIdentifier("MyCartViewController")  as! MyCartViewController
        self.navigationController?.pushViewController(myCartViewController, animated: true)
    }
    
    func showSettings() {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = mainSt.instantiateViewControllerWithIdentifier("settingsVC")  as! SettingsTableViewController
        settingsVC.coverImage = self.coverImage
        settingsVC.profileImage = self.profileImage
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func followUser() {
        if(self.userProfile.isFollowed!)
        {
            MVDataManager.unfollowUser(self.userProfileId, successBlock: { response in
                
                self.userProfile.isFollowed = false
                self.collectionView.reloadData()
                self.delegate?.userFollowStateChanged(self.userProfile.isFollowed)
                
                }, failureBlock: { failure in
                    
                    print(failure)
            })
        }
        else
        {
            MVDataManager.followUser(self.userProfileId, successBlock: { response in
                
                self.userProfile.isFollowed = true
                self.collectionView.reloadData()
                self.delegate?.userFollowStateChanged(self.userProfile.isFollowed)
                
                }, failureBlock: { failure in
                    
                    print(failure)
            })
        }
    }
    func showDetailsCom(sender:UIButton){
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath:NSIndexPath  = self.collectionView.indexPathForCell(cell)!
        
        
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        
        detailVC.productDetail      = self.userProfile.timelineArray![indexPath.row].product
        detailVC.commentFlag        = 1
        self.selectedProductIndex   = indexPath.row
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    func showDetails(sender:UIButton) {
        
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath:NSIndexPath  = self.collectionView.indexPathForCell(cell)!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let product : MVProduct! = self.userProfile.timelineArray![indexPath.row].product;
        appDelegate.mixpanel?.track("Comment", properties: ["item" : product.name])
        
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        
        detailVC.productDetail = product
        self.selectedProductIndex = indexPath.row
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    

    
    //MARK: Setup
    
    func showMyItemsList() {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let itemsVC = mainSt.instantiateViewControllerWithIdentifier("itemsVC")  as! ItemsViewController
        itemsVC.userProfile = self.userProfile
        //        itemsVC.userProfileId = self.userProfileId
        self.navigationController?.pushViewController(itemsVC, animated: true)
    }
    
    func showMyFollowers() {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let friendsVC = mainSt.instantiateViewControllerWithIdentifier("friendsVC")  as! FriendsViewController
        friendsVC.selectedUserID = self.userProfileId
        if(self.userProfileId == MVParameters.sharedInstance.currentMVUser.id)
        {
            friendsVC.shouldDisplayFollowUnfollowButtons = false
        }
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
    
    func showMyReviews() {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let reviewVC = mainSt.instantiateViewControllerWithIdentifier("MVUserReviewVC")  as! MVUserReviewViewController
        reviewVC.userProfile = self.userProfile
        reviewVC.userProfileId = self.userProfileId
        self.navigationController?.pushViewController(reviewVC, animated: true)
        
//        self.reviewsIsSelected = true
//        NSNotificationCenter .defaultCenter().postNotificationName("changeView", object: nil)
//        self.collectionView.tag = 1
//        let indexSet = NSIndexSet(index: 0)
//        self.collectionView.reloadSections(indexSet)
        
    }
    
    func showTimeLine() {
        self.reviewsIsSelected = false
        NSNotificationCenter .defaultCenter().postNotificationName("changeView", object: nil)
        self.collectionView.tag = 0
        let indexSet = NSIndexSet(index: 0)
        self.collectionView.reloadSections(indexSet)
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func setupRecognizers(receivingView:UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector(selectors[receivingView.tag]))
        receivingView.addGestureRecognizer(tapGesture)
    }
    
    func setupCollectionView() {
        let layout = CSStickyHeaderFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, CGRectGetHeight(self.view.bounds)*0.6)
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 235)
        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height)
        layout.parallaxHeaderAlwaysOnTop = true
        layout.disableStickyHeaders = true
        
        if(self.collectionView.bounds.height < CGRectGetHeight(self.view.bounds)){
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0,  CGRectGetHeight(self.view.bounds) - self.collectionView.bounds.height, 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0,  self.collectionView.bounds.height - CGRectGetHeight(self.view.bounds) + 15, 0)
        }
   
        self.collectionView.userInteractionEnabled = true
        self.collectionView.collectionViewLayout = layout
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.collectionView.registerNib(nib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "header")
    }
    
    func addRightNavItemOnView() {
        let inboxButton: UIButton = UIButton(type: UIButtonType.Custom)
        inboxButton.frame = CGRectMake(0, 0, 25, 20)
        inboxButton.setImage(UIImage(named:"inboxButton.png"), forState: UIControlState.Normal)
        inboxButton.addTarget(self, action: #selector(UserProfileViewController.inboxButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func onTouchShareButton(cell: UICollectionViewCell) {
        let timeline: MVTimeline = self.userProfile.timelineArray[self.collectionView.indexPathForCell(cell)!.row]
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let sharingVC              = mainSt.instantiateViewControllerWithIdentifier("SharingVC")  as! SharingViewController
        sharingVC.delegate = self
        self.productTitle = timeline.product.name
        self.shareUrl = timeline.product.shareLink
        self.shareVideo = NSURL(string: timeline.product.videoFile)
        self.shareImageURLString = timeline.product.previewImage
        self.presentViewController(sharingVC, animated: true, completion: nil)
    }

    func likesCountTapped(tag: Int) {
        let product = self.userProfile.timelineArray[tag].product
        self.navigationController?.pushViewController(MVLikesViewController.getLikeViewController(product), animated: true)
    }
    
    // Mark SharingViewControllerDelegate
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
            if  let image = self.shareImg{
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
    
}
