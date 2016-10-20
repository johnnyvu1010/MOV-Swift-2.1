//
//  FriendsViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 14/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import BBBadgeBarButtonItem
import SVProgressHUD

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var friendsSegmentedControl: UISegmentedControl!
    @IBOutlet var followersTable: UITableView!

    var badgeButtonItem: BBBadgeBarButtonItem!
    var followingArray:[MVUser]! = [MVUser]()
    var followersArray:[MVUser]! = [MVUser]()
    var selectedUserID : Int! = 0
    var shouldDisplayFollowUnfollowButtons : Bool = true
    var visualEffectView:UIVisualEffectView?
    var dataIsAvailable : Bool = true
    var isRequestFinished :Bool = false
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        followersTable.addPullToRefreshAboveSegmentControlWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(2)
                self.fetchData()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.followersTable.stopPullToRefresh()
                }
            }
            }, withAnimator: BeatAnimator())
        
         NSNotificationCenter.defaultCenter().postNotificationName("hideTabbar", object: nil)
        self.preferredStatusBarStyle()
        self.followersTable.tag = 1
        
        self.followersTable.registerNib(UINib(nibName: "noDataCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        self.navigationController!.setNavigationBarHidden(true, animated: false)
//        self.navigationItem.hidesBackButton = false
//        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
//        self.navigationItem.title = "Friends"
        
        if(self.visualEffectView == nil){
            addBlurEffect()
        }
        if(self.selectedUserID == MVParameters.sharedInstance.currentMVUser.id){
            addRightNavItemOnView()
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
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.followersTable.stopPullToRefresh()
        }
        self.fetchData(true)
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
        
        var cell : UserCell!
        
        if(tableView.tag == 1)
        {
            if (self.dataIsAvailable)
            {
                cell = tableView .dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserCell
                let user : MVUser = self.followersArray[indexPath.row] as MVUser
                cell.userName.text = user.fullName
                cell.hashtag.text = "@\(user.username)"
                cell.userImage.setImageWithURL(NSURL(string: user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userImage)
                if(user.isFollowingBack!)
                {
                    cell.followButton.setImage(UIImage(named: "follow_check"), forState: .Normal)
                }
                else
                {
                    cell.followButton.setImage(UIImage(named: "follow_checked"), forState: .Normal)
                }
                cell.userProfileButton.addTarget(self, action: #selector(FriendsViewController.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.userProfileButton.tag = indexPath.row
                cell.followButton.hidden = self.shouldDisplayFollowUnfollowButtons
                cell.separatorInset = UIEdgeInsetsZero
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                cell.followButton.addTarget(self, action: #selector(FriendsViewController.followButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
                cell.followButton.tag = indexPath.row
                if(user.id == MVParameters.sharedInstance.currentMVUser.id)
                {
                    cell.followButton.hidden = true
                }
            }
            else
            {
                cell = tableView .dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! UserCell
            }
        }
        else
        {
            if(self.dataIsAvailable)
            {
                cell = tableView .dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserCell
                let user : MVUser = self.followingArray[indexPath.row] as MVUser
                cell.userName.text = user.fullName
                cell.hashtag.text = "@\(user.username)"
                cell.userImage.setImageWithURL(NSURL(string: user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userImage)
                cell.followButton.setImage(UIImage(named: "follow_checked"), forState: .Normal)
                cell.userProfileButton.addTarget(self, action: #selector(FriendsViewController.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.userProfileButton.tag = indexPath.row
                cell.followButton.hidden = self.shouldDisplayFollowUnfollowButtons
                cell.separatorInset = UIEdgeInsetsZero
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                cell.followButton.addTarget(self, action: #selector(FriendsViewController.followButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
                cell.followButton.tag = indexPath.row
            }
            else
            {
                cell = tableView .dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! UserCell
            }
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let segmentView:FriendsSectionHeaderView = NSBundle.mainBundle().loadNibNamed("FriendsSectionHeaderView", owner: self, options: nil)[0] as! FriendsSectionHeaderView
        segmentView.segmentedControl.removeAllSegments()
        segmentView.segmentedControl.addTarget(self, action: #selector(FriendsViewController.segmentValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        segmentView.segmentedControl.insertSegmentWithTitle("Following", atIndex: 0, animated: true)
        segmentView.segmentedControl.insertSegmentWithTitle("Followers", atIndex: 1, animated: true)
        segmentView.segmentedControl.selectedSegmentIndex = tableView.tag
        segmentView.frame = CGRectMake(0, 0, tableView.frame.size.width, 48)
        return segmentView
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRequestFinished == false
        {
            return 0
        }
        if(tableView.tag == 1){
            if(self.followersArray!.count > 0)
            {
                self.dataIsAvailable = true
            }
            else
            {
                self.dataIsAvailable = false
            }
            
            if(self.dataIsAvailable)
            {
                return self.followersArray!.count
            }
            else
            {
                return 1
            }
            
        } else {
            if(self.followingArray!.count > 0)
            {
                self.dataIsAvailable = true
            }
            else
            {
                self.dataIsAvailable = false
            }
            if(self.dataIsAvailable)
            {
                return self.followingArray!.count
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
    

    
    //MARK: Fetch logic
    
    func fetchData(isInitialRequest : Bool = false) {
        if isInitialRequest
        {
            SVProgressHUD.show()
        }
        MVDataManager.getUserFollowing(self.selectedUserID, successBlock: { response in
            
            self.followingArray = response as! [MVUser]
            
            MVDataManager.getUserFollowers(self.selectedUserID, successBlock: { response in
                self.isRequestFinished = true
                self.followersArray = response as! [MVUser]
                self.followersTable.reloadData()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.popActivity()
                })
                },
                    failureBlock: { response in
                    self.isRequestFinished = true
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        SVProgressHUD.popActivity()
                    })
                    self.followersTable.reloadData()
            })
            
            },
                failureBlock: { response in
                self.isRequestFinished = true
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.popActivity()
                })
                self.followersTable.reloadData()
        })
    }
    
    //MARK: Action methods
    @IBAction func onBackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    func inboxButtonPressed(sender:UIButton!) {
        
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let myCartViewController = mainSt.instantiateViewControllerWithIdentifier("MyCartViewController")  as! MyCartViewController
        self.navigationController?.pushViewController(myCartViewController, animated: true)
        
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            self.followersTable.tag = 0
        } else {
            self.followersTable.tag = 1
        }
        let indexSet = NSIndexSet(index: 0)
        self.followersTable.reloadSections(indexSet, withRowAnimation: .Fade)
    }
    
    func followButtonTouched(sender : UIButton)
    {
        if(self.followersTable.tag == 0)
        {
            MVDataManager.unfollowUser(self.followingArray[sender.tag].id, successBlock: { response in
                
                print(response)
                self.fetchData()
                
                }, failureBlock: { failure in
                    
                    print(failure)
            })
        }
        else
        {
            if(self.followersArray[sender.tag].isFollowingBack!)
            {
                MVDataManager.unfollowUser(self.followersArray[sender.tag].id, successBlock: { response in
                    
                    print(response)
                    self.fetchData()
                    
                    }, failureBlock: { failure in
                        
                        print(failure)
                })
            }
            else
            {
                
                MVDataManager.followUser(self.followersArray[sender.tag].id, successBlock: { response in
                    
                    print(response)
                    self.fetchData()
                    
                    }, failureBlock: { failure in
                        
                        print(failure)
                        
                })
            }
        }
    }
    
    func userProfileButtonTouched(sender : UIButton) {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        if(self.followersTable.tag == 0)
        {
            userProfileVC.userProfileId = self.followingArray[sender.tag].id
        }
        else
        {
            userProfileVC.userProfileId = self.followersArray[sender.tag].id
        }
        if(userProfileVC.userProfileId != MVParameters.sharedInstance.currentMVUser.id){
        self.navigationController!.pushViewController(userProfileVC, animated: true)
        }
        
    }

    
    //MARK: Screen setup
    
    func addRightNavItemOnView() {
        let inboxButton: UIButton = UIButton(type: UIButtonType.Custom)
        inboxButton.frame = CGRectMake(0, 0, 25, 20)
        inboxButton.setImage(UIImage(named:"inboxButton.png"), forState: UIControlState.Normal)
        inboxButton.addTarget(self, action: #selector(FriendsViewController.inboxButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
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
    
    func addBlurEffect() {
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        self.visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        self.visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.visualEffectView?.removeFromSuperview()
        self.visualEffectView = nil
    }
    
    
}
