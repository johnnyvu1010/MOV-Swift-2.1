//
//  AddressViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 13/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD
import Braintree

protocol AddressControllerDelegate {
    func addressUpdateSuccess()
    func addressUpdateFailed()
    func backButtonTapped()
}

class AddressViewController: UIViewController, UITextFieldDelegate, BTDropInViewControllerDelegate {

    var product:MVProduct!
    var delegate:AddressControllerDelegate?
    
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var textFieldCity: UITextField!
    @IBOutlet weak var textFieldState: UITextField!
    @IBOutlet weak var textFieldCountry: UITextField!
    @IBOutlet weak var textFieldPostalCode: UITextField!
    @IBOutlet weak var textFieldMobileNumber: UITextField!
    @IBOutlet weak var textFieldStreetAddress: UITextField!
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldPostalCode.delegate = self
        self.getAddress()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UIControls Action
    @IBAction func buttonBackTapped(sender: AnyObject) {
        self.delegate?.backButtonTapped()
    }
    
    @IBAction func buttonSaveTapped(sender: UIButton) {
        if textFieldCity.text!.isEmpty || textFieldCountry.text!.isEmpty || textFieldPostalCode.text!.isEmpty || textFieldStreetAddress.text!.isEmpty {
            let alert:UIAlertController = UIAlertController(title: "", message: "All fields are required.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if textFieldState.text!.length > 2{
            UIAlertView(title: "Please use state abbreviation like WA for Washington", message: nil, delegate: self, cancelButtonTitle: "Ok").show()
            return
        }
        if textFieldPostalCode.text?.length != 5{
            UIAlertView(title: "Please enter valid ZIP Code.", message: nil, delegate: self, cancelButtonTitle: "Ok").show()
            return
        }
        self.updateAddress()
    }
    
    func updateAddress(){
        let request : String! = "update-user-address"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "street":"\(self.textFieldStreetAddress.text!)",
                                           "postal_code":"\(self.textFieldPostalCode.text!)",
                                           "state":"\(self.textFieldState.text!)",
                                           "phone_number":"\(self.textFieldMobileNumber.text!)",
                                           "city":"\(self.textFieldCity.text!)",
                                           "country":"\(self.textFieldCountry.text!)"]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            self.delegate?.addressUpdateSuccess()
            if self.delegate == nil{
                UIAlertView(title: "Address updated.", message: nil, delegate: self, cancelButtonTitle: "Ok").show()
            }
        }) { failure in
            SVProgressHUD.popActivity()
            self.delegate?.addressUpdateFailed()
            let alert:UIAlertController = UIAlertController.init(title: "", message:failure, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: {
            })
        }

    }
    
    func getAddress() {
        SVProgressHUD.show()
        MVDataManager.getUserAddress(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            let address:MVUserAddress = response as! MVUserAddress
            SVProgressHUD.popActivity()
//            if let str = address.country {
//                self.textFieldCountry.text = str
//            }
            self.textFieldCity.text = address.city!
            self.textFieldState.text = address.state!
            self.textFieldMobileNumber.text = address.number!
            self.textFieldPostalCode.text = String(address.postalCode!)
            self.textFieldStreetAddress.text = String(address.street!)
        }) { failure in
            print(failure)
            SVProgressHUD.popActivity()
        }

    }
    
    
    // MARK: - Brain Tree Payment
    func checkIfCustomerIsWhiteListed() {
        SVProgressHUD.show()
        let phone = "555-555-5555"
        let email = "johndoe@venmo.com"
        
        let venmoWhitelistRequest = NSMutableURLRequest(URL: NSURL(string: "https://api.venmo.com/pwv-whitelist")!)
        venmoWhitelistRequest.HTTPMethod = "POST"
        let postData = try! NSJSONSerialization.dataWithJSONObject(["email": email, "phone": phone], options: .PrettyPrinted)
        venmoWhitelistRequest.HTTPBody = postData
        venmoWhitelistRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        NSURLSession.sharedSession().dataTaskWithRequest(venmoWhitelistRequest) { ( _, response, _) -> Void in
            SVProgressHUD.popActivity()
            guard let httpResponse : NSHTTPURLResponse = response as? NSHTTPURLResponse else { return }
            if (httpResponse.statusCode == 200) {
                
            }
            }.resume()
    }
    
    
    
    
    func tappedMyPayButton() {
//        let mainSt                           = UIStoryboard(name: "Main", bundle: nil)
//        let chatVC:ChatViewController        = mainSt.instantiateViewControllerWithIdentifier("chatVC")  as! ChatViewController
//        chatVC.product                       = self.product
//        chatVC.topicID                       = 51
//        chatVC.shouldPopToRootViewController = true
//        chatVC.isUserProfile                 = false
//        self.navigationController!.pushViewController(chatVC, animated: true)
//        SVProgressHUD.show()
//        MVDataManager.generateVenmoToken(MVParameters.sharedInstance.currentMVUser.id, successBlock: { (json) in
//            
//            SVProgressHUD.popActivity()
//            if let braintreeClient: BTAPIClient = BTAPIClient(authorization: json["token"].stringValue) {
//                let dropInViewController = BTDropInViewController(APIClient: braintreeClient)
//                dropInViewController.delegate = self
//                
//                let navigationController = UINavigationController(rootViewController: dropInViewController)
//                navigationController.navigationBar.barTintColor = UIColor.greenAppColor()
//                self.presentViewController(navigationController, animated: true, completion: nil)
//                
//            } else {
//                let alert = MVAlertController(title: nil, message: "Token is invalid", preferredStyle: .Alert)
//                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
//                    
//                }
//                alert.addAction(alertAction)
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
//        }) { (errorString) in
//            SVProgressHUD.popActivity()
//            let alert = MVAlertController(title: nil, message: errorString, preferredStyle: .Alert)
//            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
//                
//            }
//            alert.addAction(alertAction)
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
    }
    
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        dismissViewControllerAnimated(true, completion: nil)
        let nonce = paymentMethodNonce.nonce
        let venmoAccountNonce : BTVenmoAccountNonce? = paymentMethodNonce as? BTVenmoAccountNonce
        if (venmoAccountNonce != nil) {
            let username = venmoAccountNonce!.username
            print(username)
        }

            SVProgressHUD.show()
            MVDataManager.updateUserAddress(MVParameters.sharedInstance.currentMVUser.id, street: self.textFieldStreetAddress.text, postalCode: Int(self.textFieldPostalCode.text!), city: self.textFieldCountry.text, country: self.textFieldCity.text, state: "", successBlock: { response in
                
                
                SVProgressHUD.show()
                MVDataManager.productBuyVenmo(MVParameters.sharedInstance.currentMVUser.id, productID: self.product.id, paidPrice: 1, deliveryOption: "", nonce: nonce, successBlock: { (json) in
                    SVProgressHUD.popActivity()
                    
                    let mainSt                           = UIStoryboard(name: "Main", bundle: nil)
                    let chatVC:ChatViewController        = mainSt.instantiateViewControllerWithIdentifier("chatVC")  as! ChatViewController
                    chatVC.product                       = self.product
                    chatVC.topicID                       = json["topic_id"].intValue
                    chatVC.shouldPopToRootViewController = true
                    chatVC.isUserProfile                 = false
                    self.navigationController!.pushViewController(chatVC, animated: true)
                    }, failureBlock: { (error) in
                        SVProgressHUD.popActivity()
                        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .Alert)
                        let alertActionYes = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        }
                        alert.addAction(alertActionYes)
                        self.presentViewController(alert, animated: true, completion: nil)
                })
                
                
                SVProgressHUD.popActivity()
            }) { failure in
                
                print(failure)
            }
        
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        
    }

    //MARK: TextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textFieldPostalCode == textFieldPostalCode{
            if (range.length + range.location) > textField.text!.length{
                return false
            }
            let newlength = textField.text!.length + string.length - range.length
            return newlength <= 5
        }
        return true
    }
}
