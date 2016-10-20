
//  OfferDetailsActionViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 16/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

protocol OfferDetailsActionDelegate {
    func offerActionAccepted(topicid : Int, deliveryOption : DeliveryOption)
    func offerActionRejected()
    func showUserProfile(product:MVProduct,productOffer:ProductOffer)
}


class OfferDetailsActionViewController: UIViewController, MerchantAccountDelegate {

    @IBOutlet var buttonBack: UIButton!
    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var innerView: UIView!
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var labelAddress: UILabel!
    @IBOutlet var labelOfferOption: UILabel!
    @IBOutlet var labelOfferPrice: UILabel!

    @IBOutlet var constraintImageView: NSLayoutConstraint!
    var delegate:OfferDetailsActionDelegate!
    var product:MVProduct!
    var productOffer:ProductOffer!
    var merchantAccountVC:MerchantAccountVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(UIScreen.mainScreen().bounds.height == 480){
            constraintImageView.constant = 74;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.product.user.location != nil {
            labelAddress.text = self.product.user.location as String
            labelAddress.hidden = false
        }else{
            labelAddress.hidden = true
        }
        self.labelUserName.text = productOffer.offerUserFullName as String
        self.labelOfferPrice.text = "$ \(productOffer.offerPrice as String)"
        self.labelOfferOption.text = (productOffer.offerDeliveryOption == DeliveryOption.Ship) ? "SHIP" : "MEET"
        self.imageViewUser.setImageWithURL(NSURL.init(string: productOffer.offerUserProfileImage as String), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.buttonBack.layer.cornerRadius = buttonBack.frame.size.height/2.0
        self.imageViewUser.layer.cornerRadius = imageViewUser.frame.size.height/2.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonBackTapped(sender: UIButton) {
        UIView.animateWithDuration(0.5, animations: {
            self.view.alpha = 0
            }, completion: { (complete) in
                if complete{
                    self.view.removeFromSuperview()
                }
        })
    }
    
    
    @IBAction func acceptButtonTapped(sender: UIButton) {
        if MVParameters.sharedInstance.currentMVUser.can_sell {
            self.updateOffer("accepted")
        }else{
            let mainSt = UIStoryboard(name: "Main", bundle: nil)
            merchantAccountVC = mainSt.instantiateViewControllerWithIdentifier("merchantAccountVC")  as! MerchantAccountVC
            merchantAccountVC.delegate = self
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelButtonTapped))
            merchantAccountVC.navigationItem.setRightBarButtonItem(cancelButton, animated: true)
            self.presentViewController(UINavigationController(rootViewController:merchantAccountVC), animated: true, completion: nil)
        }
    }
    
    func cancelButtonTapped(){
        merchantAccountVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func rejectButtonTapped(sender: UIButton) {
        self.updateOffer("rejected")
    }
    
    func updateOffer(action:String) {
        let request : String! = "offers-update"
        let parameters :  NSDictionary! = ["offer_id":"\(productOffer.offerId)",
                                           "user_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "status":action]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:response.valueForKey("message") as? String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                })
            self.presentViewController(alert, animated: true, completion: {
                 self.buttonBackTapped(self.buttonBack)
                if  action == "accepted"{
                    let resultDict = JSON(response)
                    let topic_id = Int(resultDict["topic_id"].rawString()!)
                    self.delegate?.offerActionAccepted(topic_id!, deliveryOption: self.productOffer.offerDeliveryOption)
                }else if action == "rejected"{
                    self.delegate.offerActionRejected()
                }
               
            })
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:"Something goes wrong. Please try again."  as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func merchantAccountDetailsSaved(sender: MerchantAccountVC) {
        [sender .dismissViewControllerAnimated(true, completion: nil)];
        self.updateOffer("accepted")
    }
    
    func merchantAccountDetailsFailed(sender: MerchantAccountVC) {
        [sender .dismissViewControllerAnimated(true, completion: nil)];
    }
    
    @IBAction func openUserProfile(sender: AnyObject) {
        delegate.showUserProfile(product,productOffer: productOffer)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
