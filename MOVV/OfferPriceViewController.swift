//
//  OfferPriceViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 17/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD
import Braintree

protocol OfferPriceViewControllerDelegate {
    func offerPriceSent(product:MVProduct, price:Int, deliveryOption:String)
}

class OfferPriceViewController: UIViewController, BTDropInViewControllerDelegate, AddressControllerDelegate, PaymentControllerDelegate {
    var product:MVProduct!
    var delegate:OfferPriceViewControllerDelegate!
    var deliveryOptionsVC:DeliveryOptionsViewController!
    var addressVC:AddressViewController!
    var nonce:String!
    var paymentNVC:UINavigationController!
    
    @IBOutlet var buttonSendOffer: UIButton!
    @IBOutlet var buttonCancel: UIButton!
    @IBOutlet var segmentOfferOption: UISegmentedControl!
    @IBOutlet var textFieldPrice: UITextField!
    @IBOutlet var viewError: UIView!
    @IBOutlet var viewContent: UIView!
    @IBOutlet var labelError: UILabel!
    var dropInViewController:BTDropInViewController!
    
    var borderColor:UIColor = UIColor.init(red: 228.0/255, green: 228.0/255, blue: 228.0/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonCancel.layer.borderColor = borderColor.CGColor;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Controls Action
    
    @IBAction func buttonSendTapped(sender: UIButton) {
        if (product.price/2) > self.getPriceFromTextField() || self.getPriceFromTextField() == 0{
            self.showErrorAlert(true, text: "Must offer at least 50% of asking price")
            return;
        }
        
//        if self.segmentOfferOption.selectedSegmentIndex == 1 {
//            self.showErrorAlert(true, text: "Sorry, this item is too big to ship")
//            return
//        }
//        self.sendOffer()
        self.paymentDetailsWithCustomUI()
//        self.paymentDetailsWithDefaultUI()
    }
    
    @IBAction func buttonCancelTapped(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.view.alpha = 0
            }, completion: { (complete) in
                if complete{
                    self.view.removeFromSuperview()
                }
        })
    }
    
    @IBAction func segmentOfferValueChanged(sender: UISegmentedControl) {
        self.showErrorAlert(false, text: nil)
        if sender.selectedSegmentIndex == 1 && product.parcelSizeId == "0"{
            self.showErrorAlert(true, text: "We can't able to ship this item.")
            sender.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func buttonNumKeyTapped(sender: UIButton) {
        self.showErrorAlert(false, text: nil)
        if textFieldPrice.text!.length > 6 {
            return;
        }
        if sender.titleLabel?.text == "0" && textFieldPrice.text?.length == 1 {
            return;
        }
        textFieldPrice.text = textFieldPrice.text?.stringByAppendingString((sender.titleLabel?.text)!)
    }
    
    @IBAction func buttonBackKeyTapped(sender: UIButton) {
        self.showErrorAlert(false, text: nil)
        if textFieldPrice.text!.length > 1 {
            textFieldPrice.text = textFieldPrice.text!.substringToIndex(textFieldPrice.text!.startIndex.advancedBy(textFieldPrice.text!.characters.count - 1))
        }
    }
    
    //MARK: - Helper Function
    
    func showErrorAlert(show:Bool, text:String?) {
        if text?.length > 0 {
            labelError.text = text;
        }
        if show && viewError.hidden {
            viewError.alpha = 0;
            viewError.hidden = false
            UIView.animateWithDuration(0.5) {
                self.viewError.alpha = 1
            }
        }else if !show && !viewError.hidden{
            UIView.animateWithDuration(0.5, animations: {
                self.viewError.alpha = 0
                }, completion: { (complete) in
                    if complete{
                        self.viewError.hidden = true
                    }
            })
        }
    }
    
    func getPriceFromTextField() -> Int {
        let price:NSString = (textFieldPrice.text?.substringFromIndex(textFieldPrice.text!.startIndex.advancedBy(1)))!;
        return price.integerValue
    }
    
    func sendOffer(){
        //product-offer
        let request : String! = "offers-add"
        let deliveryOption = segmentOfferOption.selectedSegmentIndex == 0 ? "meet_in_person" : "ship"
        let parameters :  NSDictionary! = ["product_id":"\(product.id)",
                                           "user_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "offer_price":"\(self.getPriceFromTextField())",
                                           "delivery_option":"\(deliveryOption)",
                                           "nonce":"\(nonce)"]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.dismiss()
            let alert:UIAlertController = UIAlertController.init(title: "", message:"Great! Offer is now in your cart", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: {
                self.buttonCancelTapped(self.buttonCancel)
            })
//            NSNotificationCenter.defaultCenter().postNotificationName("dismissCameraView", object: nil)
        }) { failure in
            SVProgressHUD.dismiss()
            let message:String!
            let alreadyOfferedMessage = "You have already offered on this product!"
            if failure == alreadyOfferedMessage{
                message = failure
            }else{
                message = "Something goes wrong. Please try again."
            }
            let alert:UIAlertController = UIAlertController.init(title: "", message:message  as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: {
                if failure == alreadyOfferedMessage{
                    self.buttonCancelTapped(self.buttonCancel)
                }
            })
        }
    }
    
    //MARK: - Setup BrainTree
    func paymentDetailsWithDefaultUI() {
        SVProgressHUD.show()
        MVDataManager.generateVenmoToken(MVParameters.sharedInstance.currentMVUser.id, successBlock: { (json) in
            SVProgressHUD.popActivity()
            if let braintreeClient: BTAPIClient = BTAPIClient(authorization: json["token"].stringValue) {
                self.dropInViewController = BTDropInViewController(APIClient: braintreeClient)
                self.dropInViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: self.dropInViewController)
                navigationController.navigationBar.barTintColor = UIColor.greenAppColor()
                self.presentViewController(navigationController, animated: true, completion: nil)
            } else {
                let alert = MVAlertController(title: nil, message: "Token is invalid", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                    
                }
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }) { (errorString) in
            SVProgressHUD.popActivity()
            let alert = MVAlertController(title: nil, message: errorString, preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                
            }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func paymentDetailsWithCustomUI(){
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let paymentVC = mainSt.instantiateViewControllerWithIdentifier("PaymentViewController")  as! PaymentViewController
        paymentVC.delegate = self
        paymentNVC = UINavigationController(rootViewController: paymentVC)
        paymentNVC.title = "Payment"
        paymentNVC.navigationBar.tintColor = UIColor.whiteColor()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelButtonTapped))
        paymentVC.navigationItem.setRightBarButtonItem(cancelButton, animated: true)
        paymentNVC.navigationBar.barTintColor = UIColor(red: 70.0/255, green: 213.0/255, blue: 39.0/255, alpha: 1)
        self.presentViewController(paymentNVC, animated: true, completion: nil)
    }
    
    func cancelButtonTapped(){
        paymentNVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        dismissViewControllerAnimated(true, completion: nil)
        nonce = paymentMethodNonce.nonce
        let venmoAccountNonce : BTVenmoAccountNonce? = paymentMethodNonce as? BTVenmoAccountNonce
        if (venmoAccountNonce != nil) {
            let username = venmoAccountNonce!.username
            print(username)
        }
        if segmentOfferOption.selectedSegmentIndex == 0 {
            self.sendOffer();
        }else{
            let main = UIStoryboard(name: "Main", bundle: nil)
            self.addressVC = main.instantiateViewControllerWithIdentifier("AddressViewController")  as! AddressViewController
            self.addressVC.view.frame = CGRectMake(self.viewContent.frame.size.width, 0, self.viewContent.frame.size.width, self.viewContent.frame.size.height)
            self.addressVC.product = product
            self.addressVC.delegate = self
            self.viewContent.addSubview(addressVC.view)
            UIView.animateWithDuration(0.3) {
                self.addressVC.view.frame = CGRectMake(0, 0, self.viewContent.frame.size.width, self.viewContent.frame.size.height)
            }
        }
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        
    }
    
    //MARK: - AddressController Delegate
    func addressUpdateFailed() {
        
    }
    
    func addressUpdateSuccess() {
        self.backButtonTapped()
        self.sendOffer()
    }
    
    func backButtonTapped() {
        UIView.animateWithDuration(0.3, animations: {
            self.addressVC.view.frame = CGRectMake(self.viewContent.frame.size.width, 0, self.viewContent.frame.size.width, self.viewContent.frame.size.height)
        }) { (completed) in
            if completed{
                self.addressVC.view.removeFromSuperview()
            }
        }
    }
    
    func paymentFailed() {
        let alert:UIAlertController = UIAlertController.init(title: "", message:"Something goes wrong. Please try again."  as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
            });
        self.presentViewController(alert, animated: true, completion: {
        })
        paymentNVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func paymentSuccess(nonce: String) {
        self.nonce = nonce
        paymentNVC.dismissViewControllerAnimated(true, completion: nil)
        if segmentOfferOption.selectedSegmentIndex == 0 {
            self.sendOffer();
        }else{
//            self.sendOffer();
            let main = UIStoryboard(name: "Main", bundle: nil)
            self.addressVC = main.instantiateViewControllerWithIdentifier("AddressViewController")  as! AddressViewController
            self.addressVC.view.frame = CGRectMake(self.viewContent.frame.size.width, 0, self.viewContent.frame.size.width, self.viewContent.frame.size.height)
            self.addressVC.product = product
            self.addressVC.delegate = self
            self.viewContent.addSubview(addressVC.view)
            UIView.animateWithDuration(0.3) {
                self.addressVC.view.frame = CGRectMake(0, 0, self.viewContent.frame.size.width, self.viewContent.frame.size.height)
            }
        }
    }
    
}
