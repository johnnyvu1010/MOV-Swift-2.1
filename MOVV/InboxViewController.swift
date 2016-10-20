//
//  InboxViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 26/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var inboxTableView: UITableView!
    
    
    //MARK: Lifecycle
    
    var visualEffectView:UIVisualEffectView?
    var messageArray:[MVMessage]? = [MVMessage]()
    var blurInt: Int! = 0
    var isUserProfile:Bool = false
    
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        
        self.inboxTableView.addPullToRefreshAboveSegmentControlWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(2)
                self.fetchData()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.inboxTableView.stopPullToRefresh()
                    
                }
            }
            }, withAnimator: BeatAnimator())
        
        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if self.parentViewController?.title == "news" || self.parentViewController?.isKindOfClass(HomeViewController) != nil {
                
                if(visualEffectView == nil){
                    addBlurEffect()
                }
        }
        if self.blurInt == 1 {
            if(visualEffectView == nil){
                addBlurEffect()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationItem.title = "Inbox"
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
        
        let cell = tableView .dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as! MOVVItemCell
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        let message : MVMessage! = self.messageArray![indexPath.row]
        
//        var userModel = usersArray[indexPath.row] as UserModel
//        var model = itemsArray![indexPath.row] as ItemModel
//        cell.itemModel = model
//        cell.itemImage.image = userModel.userImage
//        
//        
//        model.commentModel = CommentModel()
//        model.commentModel.userName = userModel.userName
//        model.commentModel.commentedItemName = model.itemName
//        model.commentModel.comment = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
//        var maxLength = 110
//        
//        var nonCommentLength = userModel.userName.length + " regarding ".length + model.itemName.length
//        var allowedCommentLength = maxLength - nonCommentLength
//        
//        
//        
//        var shortenedComment:String?
//        if(model.commentModel.comment.length > allowedCommentLength){
//            shortenedComment = model.commentModel.comment.substringToIndex(advance(model.commentModel.comment.startIndex,allowedCommentLength))
//            shortenedComment = shortenedComment! + "... "
//        } else {
//            shortenedComment = model.commentModel.comment
//        }
        
        
        var concatenatedString : String! = ""
        
        if(message.userRole == MVUserRole.Seller)
        {
            concatenatedString = "@" + message.buyer.username + " regarding " + message.product.name
        }
        else if (message.userRole == MVUserRole.Buyer)
        {
            concatenatedString = "@" + message.seller.username + " regarding " + message.product.name
        }

        let string = concatenatedString as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        
        let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(15)]
        
        let boldedFont = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor()]
        
        let lineSpacing = NSMutableParagraphStyle()
        lineSpacing.lineSpacing = 3
        if(message.userRole == MVUserRole.Seller)
        {
            attributedString.addAttributes(greenBoldedFont, range:string.rangeOfString("@\(message.buyer.username)"))
            cell.userImage.setImageWithURL(NSURL(string: message.buyer.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        }
        else if (message.userRole == MVUserRole.Buyer)
        {
            attributedString.addAttributes(greenBoldedFont, range:string.rangeOfString("@\(message.seller.username)"))
            cell.userImage.setImageWithURL(NSURL(string: message.seller.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        }
        MVHelper.addMOVVCornerRadiusToView(cell.userImage)
        attributedString.addAttributes(boldedFont, range: string.rangeOfString(message.product.name))
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: lineSpacing, range: string.rangeOfString(string as String))
        
        cell.userName.attributedText = attributedString
        cell.userName.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
       
        let comment = NSMutableAttributedString(string: message.message)
        
        comment.addAttribute(NSParagraphStyleAttributeName, value: lineSpacing, range: (message.message as NSString).rangeOfString(message.message as String))
        cell.newsLabel.attributedText = comment
        cell.newsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.timeLabel.text = message.sentDate

        
        cell.userProfileButton.tag = indexPath.row
        cell.userProfileButton.addTarget(self, action: #selector(InboxViewController.userProfileTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
        
        
        if(message.unreadMessages == 0)
        {
            cell.notificationButton.hidden = true
        }
        else
        {
            cell.notificationButton.hidden = false
            cell.notificationButton.setTitle("\(message.unreadMessages)", forState: UIControlState.Normal)
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray!.count
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
        self.performSegueWithIdentifier("messageSegue", sender: indexPath)
        
        
        
    }
    
    //MARK: Screen setup
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "messageSegue" {
            
            let indexPath : NSIndexPath = sender as! NSIndexPath
            let destinationVC = segue.destinationViewController as! ChatViewController
            destinationVC.topicID = (messageArray![indexPath.row] as MVMessage).id
            destinationVC.isUserProfile = self.isUserProfile
            
            if self.blurInt == 1
            {
                destinationVC.blurInt = 1
            }
            
        }
    }
    
    func userProfileTouched(sender:UIButton)
    {
//        self.tableView.frame = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height - 20)
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = messageArray![sender.tag].seller.id
//        self.navigationItem.hidesBackButton = false
        
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    
    func fetchData()
    {
        MVDataManager.userMessages({ response in
            
            self.messageArray = response as! NSArray as? [MVMessage]
            
            self.inboxTableView.reloadData()
            
            
        }, failureBlock: { failure in
            
            print(failure)
            
        })
    }
    
}
