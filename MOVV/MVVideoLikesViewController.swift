//
//  MVVideoLikesViewController.swift
//  MOVV
//
//  Created by Yuki on 29/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class MVVideoLikesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    var userProfile : MVUserProfile!
    var userProfileId : Int?
    var reviewsArray:[MVReview]! = [MVReview]()
    var dataIsAvailable : Bool = false
    
    
    @IBOutlet weak var likesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.fetchData()
        // Do any additional setup after loading the view.
        likesTableView.addPullToRefreshAboveSegmentControlWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(1)
//                self.fetchData()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.likesTableView.stopPullToRefresh()
                }
            }
            }, withAnimator: BeatAnimator())
        self.preferredStatusBarStyle()
        
        
        self.likesTableView.registerClass(MVVideoLikesTableViewCell.self, forCellReuseIdentifier: "MVVideoLikesCell")
        self.likesTableView.registerClass(MOVVItemCell.self, forCellReuseIdentifier: "noDataCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().postNotificationName("hideTabbar", object: nil)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.blueColor()
        self.navigationItem.title = "Liked Users"
        
        
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
            let cell = tableView .dequeueReusableCellWithIdentifier("MVVideoLikesCell", forIndexPath: indexPath) as! MVVideoLikesTableViewCell
            
            return cell
        }
        else
        {
            let cell = tableView .dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! MOVVItemCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 43
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
            self.likesTableView.reloadData()
            SVProgressHUD.popActivity()
            }, failureBlock: { failure in
                SVProgressHUD.popActivity()
                print(failure)
        })
    }

}
