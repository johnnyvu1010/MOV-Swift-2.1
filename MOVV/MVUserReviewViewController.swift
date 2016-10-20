//
//  MVUserReviewViewController.swift
//  MOVV
//
//  Created by Yuki on 24/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class MVUserReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var reviewTableView: UITableView!
    
    var userProfile : MVUserProfile!
    var userProfileId : Int?
    var reviewsArray:[MVReview]! = [MVReview]()
    var dataIsAvailable : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchData()
        // Do any additional setup after loading the view.
        reviewTableView.addPullToRefreshAboveSegmentControlWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(1)
                self.fetchData()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.reviewTableView.stopPullToRefresh()
                }
            }
            }, withAnimator: BeatAnimator())
        self.preferredStatusBarStyle()
        
        
        self.reviewTableView.registerClass(MVUserReviewTableViewCell.self, forCellReuseIdentifier: "MVUserReviewCell")
        self.reviewTableView.registerClass(MOVVItemCell.self, forCellReuseIdentifier: "noDataCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().postNotificationName("hideTabbar", object: nil)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.blueColor()
        
        if(MVParameters.sharedInstance.currentMVUser.id == self.userProfile.id)
        {
            self.navigationItem.title = "My Reviews"
        }
        else
        {
            self.navigationItem.title = "\(self.userProfile.username)'s Reviews"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: TableView Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(self.dataIsAvailable)
        {
            let cell = tableView .dequeueReusableCellWithIdentifier("MVUserReviewCell", forIndexPath: indexPath) as! MVUserReviewTableViewCell
            //        let review : MVReview = self.reviewsArray[indexPath.row]
            //        cell.reviewLabel.text = review.comment
            //
            //        for i : Int in 0 ..< review.rating
            //        {
            //            let button : UIButton = cell.viewWithTag(100+i) as! UIButton
            //            button.setBackgroundImage((UIImage(named: "starFilled.png")), forState: UIControlState.Normal)
            //        }
            //
            //
            //        cell.reviewLabel.accessibilityLabel = "Quote Content"
            //        cell.reviewLabel.accessibilityValue = review.comment
            //        cell.reviewLabel.preferredMaxLayoutWidth = self.view.frame.size.width
            //        cell.reviewLabel.sizeToFit()
            //        cell.setNeedsLayout()
            //        cell.layoutIfNeeded()
            return cell
        }
        else
        {
            let cell = tableView .dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! MOVVItemCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.reviewsArray.count > 0){
            self.dataIsAvailable = true
        }
        else
        {
            self.dataIsAvailable = false
        }
        
        if(self.dataIsAvailable) {
            return self.reviewsArray.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    //MARK: fetch logic
    func fetchData() {
        SVProgressHUD.show()
        MVDataManager.getUserReviews(self.userProfileId, successBlock: { response in
            self.reviewsArray = response as! [MVReview]
            self.reviewTableView.reloadData()
            SVProgressHUD.popActivity()
            }, failureBlock: { failure in
                SVProgressHUD.popActivity()
                print(failure)
        })
    }

}
