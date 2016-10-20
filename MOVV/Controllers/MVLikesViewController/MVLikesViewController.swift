//
//  MVLikesViewController.swift
//  MOVV
//
//  Created by Vidhan Nandi on 08/09/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class MVLikesViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var nullcaseLabel: UILabel!
    
    var currentProduct:MVProduct?
    var likedUsersArr = [MVLikedUser]()

    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.registerNib(UINib(nibName: String(MVLikedUserCell), bundle: nil), forCellReuseIdentifier: String(MVLikedUserCell))
        tblView.estimatedRowHeight = 60
        tblView.rowHeight = UITableViewAutomaticDimension
        tblView.tableFooterView = UIView(frame: CGRectZero)
        getLikes()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        self.navigationItem.title = "Likes"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Class methods
    class func getLikeViewController(product:MVProduct) -> MVLikesViewController {
        let viewCont = MVLikesViewController(nibName: String(MVLikesViewController), bundle: nil)
        viewCont.currentProduct = product
        return viewCont
    }

    //MARK:- Additional methods
    func processResponse(response:AnyObject) {
        if let dict = response as? NSDictionary{
            self.likedUsersArr = MVLikedUser.getLikedUser(dict)
            if likedUsersArr.count == 0{
                nullcaseLabel.hidden = false
            }else{
                nullcaseLabel.hidden = true
                self.tblView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        SVProgressHUD.popActivity()
    }

    
    //MARK:- network Calls
    func getLikes() {
        if let id = currentProduct?.id {
            SVProgressHUD.show()
            MVDataManager.getProductLikes(id, successBlock: { (response:AnyObject!) in
                    self.processResponse(response)
                }, failureBlock: { (error:AnyObject!) in
                    SVProgressHUD.popActivity()
                    print(error)
            })
        }
    }
}

//MARK:- UITableViewDataSource
extension MVLikesViewController:UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedUsersArr.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(String(MVLikedUserCell)) as? MVLikedUserCell{
            cell.configUsingObj(likedUsersArr[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension MVLikesViewController:UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = Int(likedUsersArr[indexPath.row].id)
        if(userProfileVC.userProfileId != MVParameters.sharedInstance.currentMVUser.id){
            self.navigationController!.pushViewController(userProfileVC, animated: true)
        }
    }
}
