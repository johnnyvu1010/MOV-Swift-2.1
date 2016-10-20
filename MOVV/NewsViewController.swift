//
//  NewsViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 12/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import MediaPlayer
import UIKit
import BBBadgeBarButtonItem
import SVProgressHUD
//import SDWebImage

var loadedNews:Bool!

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, NewsFollovingTableViewCellDelegate {
    
    @IBOutlet var newsTableView: UITableView!
    var badgeButtonItem: BBBadgeBarButtonItem!
    var newsYouArray:[MVNews]! = [MVNews]()
    var newsFollowingArray:[MVNews]! = [MVNews]()
    var visualEffectView:UIVisualEffectView?
    var segmentView:FriendsSectionHeaderView? = nil
    var dataIsAvailable : Bool = false
    var itemIsExist : Bool = true
    var isFromTabBar:Bool?
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredStatusBarStyle()
        self.newsTableView.addPullToRefreshAboveSegmentControlWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(2)
                self.fetchData()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.newsTableView.stopPullToRefresh()
                    
                }
            }
            }, withAnimator: BeatAnimator())
        
        self.title = "Activity"
        self.fetchData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if !self.view.userInteractionEnabled {
            self.view.userInteractionEnabled = true
            if newsTableView.numberOfRowsInSection(0) > 0{
                self.fetchData()
                newsTableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: .Bottom, animated: false);
            }
        }
        NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navbarVideo"), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationItem.title = "Activity"
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        addRightNavItemOnView()
        
        if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            addBlurEffect()
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
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
            visualEffectView?.removeFromSuperview()
            visualEffectView = nil
        
        if self.isMovingToParentViewController() {
            
            visualEffectView?.removeFromSuperview()
            visualEffectView = nil
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        

        var cell:NewsFollowingTableViewCell!
        
        var news : MVNews!
        if (self.segmentView?.segmentedControl.selectedSegmentIndex == 0) {
            if(self.newsFollowingArray.count == 0)
            {
                cell = tableView.dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! NewsFollowingTableViewCell
                return cell
            }
            else
            {
                cell = tableView.dequeueReusableCellWithIdentifier("followingCell", forIndexPath: indexPath) as! NewsFollowingTableViewCell
                news = self.newsFollowingArray[indexPath.row]
            }
            
            
        } else {
            if(self.newsYouArray.count == 0)
            {
                cell = tableView.dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! NewsFollowingTableViewCell
                return cell
            }
            else
            {
                cell = tableView.dequeueReusableCellWithIdentifier("followingCell", forIndexPath: indexPath) as! NewsFollowingTableViewCell
                news = self.newsYouArray[indexPath.row]
            }
        }
        

        if(news.actionType != MVNewsAction.Friends){
            if news.product.previewImage.isEmpty {
                itemIsExist = false
            }
            let imageURL:NSURL = NSURL(string: news.product.previewImage)!
            SDWebImageManager.sharedManager().downloadImageWithURL(imageURL, options: SDWebImageOptions(), progress: nil, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, finished:Bool, imageURL:NSURL!) -> Void in
                cell.itemImageButton.setImage(image, forState: UIControlState.Normal)
                cell.itemImageButton.imageView!.layer.cornerRadius = 4
                cell.itemImageButton.imageView!.layer.borderColor = MOVVGreen.CGColor
                cell.itemImageButton.imageView!.layer.borderWidth = 1
            })
            
        } else {
            cell.itemImageButton.setImage(nil, forState: UIControlState.Normal)
            itemIsExist = false
        }
        cell.userImage.setImageWithURL(NSURL(string: news.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        cell.userImage!.layer.cornerRadius = 20
        cell.userImage!.layer.masksToBounds = true
        cell.userImage!.layer.borderColor = MOVVGreen.CGColor
        cell.userImage!.layer.borderWidth = 1
        cell.constarintImageHeight.constant = (news.product == nil) ? 0 : 60
        cell.timeLabel.text = news.timestamp
        lineSpacing.lineSpacing = 3
        //let actionString = setActionImageAndString(news.actionType, button: cell.commentButton)
        let actionString = setActionImageAndString(news.actionType)
        
        var concatenatedString:String
        
        let formattedUsername = "@\(news.user.username)"
        
        if(news.actionType == MVNewsAction.Friends) {
            concatenatedString =  formattedUsername + " started following you!"
        } else {
            if(news.user.id == MVParameters.sharedInstance.currentMVUser.id){
                if(news.buyer == nil){
                    concatenatedString = "You" + actionString + " " + news.product.name + " from " + formattedUsername

                } else {
                    concatenatedString = "@" + news.buyer.username  + actionString + news.product.name + " from " + formattedUsername
                }
            } else {
                if(news.buyer != nil){
                    concatenatedString = "@" + news.buyer.username  + actionString + news.product.name + " from " + formattedUsername
                } else {
                    concatenatedString = "@" + news.user.username  + actionString + news.product.name
                }
                
                if(news.actionType == MVNewsAction.Bought || news.actionType == MVNewsAction.Purchase && news.buyer == nil){
                    if(news.product.user.id == MVParameters.sharedInstance.currentMVUser.id)
                    {
                        concatenatedString = formattedUsername + actionString + " " + news.product.name + " from you"
                    }
                    else
                    {
                        concatenatedString = formattedUsername + actionString + " " + news.product.name + " from " + news.product.user.username
                    }
//                    concatenatedString = "You" + actionString + " " + news.product.name + " from " + formattedUsername + " \n" + news.timestamp + " ago"
                }
            }
        }
        
        let string = (concatenatedString as NSString).stringByReplacingOccurrencesOfString("  ", withString: " ") as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        
        attributedString.addAttributes(normalFont, range: string.rangeOfString((concatenatedString as NSString).stringByReplacingOccurrencesOfString("  ", withString: " ")))
        
        if(news.actionType != MVNewsAction.Friends){
            attributedString.addAttributes(boldedFont, range: string.rangeOfString(news.product.name))
        }
        
        let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(14)]
        attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString(formattedUsername))
        if(news.buyer != nil){
            attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString("@" + news.buyer.username))
        }
      
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: lineSpacing, range: string.rangeOfString(string as String))
        
        cell.userInfoLabel.attributedText = attributedString
        cell.userInfoLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        if (news.user != nil){
            self.addLinkToLabel(string, label: cell.userInfoLabel, user: news.user)
        }
        
        if (news.buyer != nil) {
            self.addLinkToLabel(string, label: cell.userInfoLabel, user: news.buyer)
        }
        
        cell.userInfoLabel.attributedText = attributedString
        cell.userInfoLabel.delegate = self
        cell.userInfoLabel.userInteractionEnabled = true
        cell.delegate = self
        
        return cell

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (self.segmentView == nil) {
            self.segmentView = NSBundle.mainBundle().loadNibNamed("FriendsSectionHeaderView", owner: self, options: nil)[0] as? FriendsSectionHeaderView
            self.segmentView!.segmentedControl.addTarget(self, action: #selector(NewsViewController.segmentValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            self.segmentView!.segmentedControl.setTitle("Following", forSegmentAtIndex: 0)
            self.segmentView!.segmentedControl.setTitle("You", forSegmentAtIndex: 1)
            self.segmentView!.segmentedControl.selectedSegmentIndex = 1
            self.segmentView!.frame = CGRectMake(0, 0, tableView.frame.size.width, 48)
        }
        return segmentView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.segmentView!.segmentedControl.selectedSegmentIndex == 0) {
            if self.newsFollowingArray.count > 0{
                if let product = self.newsFollowingArray[indexPath.row].product {
                    let mainSt = UIStoryboard(name: "Main", bundle: nil)
                    let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                    detailVC.productDetail = product
                    self.navigationController!.pushViewController(detailVC, animated: true)
                }
            }
        } else {
            if self.newsFollowingArray.count > 0{
                if let product = self.newsYouArray[indexPath.row].product {
                    let mainSt = UIStoryboard(name: "Main", bundle: nil)
                    let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                    detailVC.productDetail = product
                    self.navigationController!.pushViewController(detailVC, animated: true)
                }                
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
//        if (!itemIsExist) {
//            return 70
//        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.segmentView != nil){
            if(self.segmentView!.segmentedControl.selectedSegmentIndex == 0)
            {
                if(self.newsFollowingArray!.count > 0)
                {
                    self.dataIsAvailable = true
                }
                else
                {
                    self.dataIsAvailable = false
                }
                
                if(self.dataIsAvailable)
                {
                    return self.newsFollowingArray!.count
                }
                else
                {
                    return 1
                }
            }
            else
            {
                if(self.newsYouArray!.count > 0)
                {
                    self.dataIsAvailable = true
                }
                else
                {
                    self.dataIsAvailable = false
                }
                
                if(self.dataIsAvailable)
                {
                    return self.newsYouArray!.count
                }
                else
                {
                    return 1
                }
            }
        }
        else
        {
            if(self.newsYouArray!.count > 0)
            {
                self.dataIsAvailable = true
            }
            else
            {
                self.dataIsAvailable = false
            }
            
            if(self.dataIsAvailable)
            {
                return self.newsYouArray!.count
            }
            else
            {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50))
        
        footerView.alpha = 0
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    //MARK: TTTAttributedLabel Delegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!){
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = ("\(url)" as NSString).integerValue
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    
    //MARK: Action methods
    func segmentValueChanged(sender: UISegmentedControl) {
        let indexSet = NSIndexSet(index: 0)
        self.newsTableView.reloadSections(indexSet, withRowAnimation: .Fade)

    }
    
    // MARK: Cell delegates
    func onTouchItemImageButtonInCell(cell: UITableViewCell) {
        let indexPath:NSIndexPath! = self.newsTableView.indexPathForCell(cell)!
        if(self.segmentView!.segmentedControl.selectedSegmentIndex == 0) {
            if(self.newsFollowingArray[indexPath.row].product != nil) {
                let mainSt = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                detailVC.productDetail = self.newsFollowingArray[indexPath.row].product
                self.navigationController!.pushViewController(detailVC, animated: true)
            }
        } else {
            if(self.newsYouArray[indexPath.row].product != nil) {
                let mainSt = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                detailVC.productDetail = self.newsYouArray[indexPath.row].product
                self.navigationController!.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    func onTouchCommentButtonInCell(cell: UITableViewCell) {
        // TODO: Logic for comment
    }
    
    func inboxButtonPressed(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let myCartViewController = mainSt.instantiateViewControllerWithIdentifier("MyCartViewController")  as! MyCartViewController
        self.navigationController?.pushViewController(myCartViewController, animated: true)
    }
    
    func refreshData() {
        startedDataRefresh = true
        fetchData()
    }
        
    //MARK: Fetch logic
    func fetchData() {
        SVProgressHUD.show()
        SVProgressHUD.show()
        MVDataManager.getNewsYou(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            SVProgressHUD.popActivity()
            self.newsYouArray = response as! [MVNews]
            if self.segmentView!.segmentedControl.selectedSegmentIndex == 1{
                self.newsTableView.reloadData()
            }
            
            }) { failure in
                SVProgressHUD.popActivity()
                print(failure)
        }
        
        MVDataManager.getNewsFollowing(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            self.newsFollowingArray = response as! [MVNews]
            SVProgressHUD.popActivity()
            if self.segmentView!.segmentedControl.selectedSegmentIndex == 0{
                self.newsTableView.reloadData()
            }
            
            }) { failure in
                SVProgressHUD.popActivity()
                print(failure)
        }
        
    }
    
    //MARK: Screen setup
    
    func addRightNavItemOnView() {
        let inboxButton: UIButton = UIButton(type: UIButtonType.Custom)
        inboxButton.frame = CGRectMake(0, 0, 25, 20)
        inboxButton.setImage(UIImage(named:"inboxButton.png"), forState: UIControlState.Normal)
        inboxButton.addTarget(self, action: #selector(NewsViewController.inboxButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
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
//        self.badgeButtonItem
        self.navigationItem.setRightBarButtonItem(self.badgeButtonItem, animated: true)
    }
    
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return  UIInterfaceOrientation.Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func addLinkToLabel(linkString:NSString,label:TTTAttributedLabel, user:MVUser){
        let range : NSRange = linkString.rangeOfString("@" + user.username)
//        println(linkString)
//        println(range)
        let url : NSURL! = NSURL(string: "\(user.id)")
        label.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
        label.addLinkToURL(url, withRange: range)
    }
    
    func setActionImageAndString(actionType:MVNewsAction) -> String{
        var actionImage = ""
        var actionString = ""
        switch(actionType.rawValue){
        case MVNewsAction.Comment.rawValue:
            actionImage = "commentButton.png"
            actionString = " commented on "
            break
        case MVNewsAction.Like.rawValue:
            actionImage = "likeButton.png"
            actionString = " liked "
            break
        case MVNewsAction.Friends.rawValue:
            actionImage = "friendsIcon.png"
            break
        case MVNewsAction.Bought.rawValue, MVNewsAction.Purchase.rawValue:
            actionImage = "boughtIcon.png"
            actionString = " bought "
            break
        case MVNewsAction.Sold.rawValue:
            actionImage = "soldIcon.png"
            actionString = " sold "
            break
        default:
            actionImage = ""
            actionString = ""
            break
            
        }
        
        //button.setImage(UIImage(named: actionImage), forState: .Normal)
        return actionString
    }
    
}
