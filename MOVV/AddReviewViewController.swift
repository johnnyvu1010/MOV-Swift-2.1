//
//  AddReviewViewController.swift
//  MOVV
//
//  Created by Yuki on 23/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ReviewControllerDelegate : NSObjectProtocol {
    func reviewSuccess()
}

class AddReviewViewController: UIViewController {
    var topicId:String!
    var reviewToUser:MVUser!
    var isOpenKeyboard : Bool = false
    weak var delegate : ReviewControllerDelegate!
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var useravatar: UIImageView!
    @IBOutlet weak var textmessage: UITextView!
    @IBOutlet weak var btnAddReview: UIButton!
    @IBOutlet weak var ratingV: RatingView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddReviewViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddReviewViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        self.useravatar.setImageWithURL(NSURL(string: reviewToUser.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        MVHelper.addMOVVCornerRadiusToView(self.useravatar)
        self.username.text = reviewToUser.username
        self.navigationItem.title = "Add Review"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if !isOpenKeyboard {
            if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y -= 280
                print(keyboardSize.height)
                isOpenKeyboard = true
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if isOpenKeyboard {
            if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y += 280
                print(keyboardSize.height)
                isOpenKeyboard = false
            }
        }
    }
    
    //Button Event
    
    @IBAction func addreview_clicked(sender: AnyObject) {
        self.view.endEditing(true)
        let request : String! = "user-review"
        let parameters :  NSDictionary! = ["user_id":"\(reviewToUser.id)",
                                           "reviewer_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "score":String(Int(self.ratingV.rating)),
                                           "review":textmessage.text,
                                           "offer_id":topicId]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            self.navigationController?.popViewControllerAnimated(true)
            SVProgressHUD.popActivity()
            self.delegate?.reviewSuccess()
        }) { failure in
            MVHelper.showCommonErrorAlert()
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func buttonUserNameTapped(sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = reviewToUser.id
        self.navigationItem.hidesBackButton = false
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }

}
