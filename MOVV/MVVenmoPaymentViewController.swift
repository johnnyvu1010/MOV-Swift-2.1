

import UIKit
import SVProgressHUD
import Braintree

class MVVenmoPaymentViewController: UIViewController,  UITextFieldDelegate, BTDropInViewControllerDelegate {
    
    
    
    @IBOutlet var saveDataButton: UIButton!
    
    
    
    @IBOutlet var shippingAddressLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var addressView: UIView!
    @IBOutlet var addressTextField: TextFieldValidator!
    @IBOutlet var postalCodeTextField: TextFieldValidator!
    @IBOutlet var cityTextField: TextFieldValidator!
    @IBOutlet var stateTextField: TextFieldValidator!
    @IBOutlet var countryTextField: TextFieldValidator!
    
    @IBOutlet var meetInPersonButton: UIButton!
    @IBOutlet var shipItButton: UIButton!
    
    
    
    
    var itemPrice : Int!
    
    var product : MVProduct!
    var userAddress : MVUserAddress!
    
    
    //    var shouldBuyButtonBeEnabled : Bool = false
    
    var isMeetInPersonSelected : Bool = false
    var isShipItSelected : Bool = false
    var deliveryOption : String = ""
    
    
    
    //MARK: Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.checkIfCustomerIsWhiteListed()
        
        self.saveDataButton.layer.borderWidth  = 1.0
        self.saveDataButton.layer.cornerRadius = 3.0
        self.saveDataButton.layer.borderColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        
        self.meetInPersonButton.layer.borderWidth  = 1.0
        self.meetInPersonButton.layer.cornerRadius = 3.0
        self.meetInPersonButton.layer.borderColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        
        self.shipItButton.layer.borderWidth  = 1.0
        self.shipItButton.layer.cornerRadius = 3.0
        self.shipItButton.layer.borderColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1).CGColor
        
        let screenRect : CGRect                = UIScreen.mainScreen().bounds
        self.saveDataButton.frame              = CGRectMake(screenRect.width/2 - 50, self.saveDataButton.frame.origin.y, self.saveDataButton.frame.size.width, self.saveDataButton.frame.size.height)
        
        
        
        self.addressTextField.isMandatory = true
        self.postalCodeTextField.isMandatory = true
        self.cityTextField.isMandatory = true
        self.stateTextField.isMandatory = true
        self.countryTextField.isMandatory = true
        
        self.addressTextField.delegate = self
        self.postalCodeTextField.delegate = self
        self.cityTextField.delegate = self
        self.stateTextField.delegate = self
        self.countryTextField.delegate = self
        
        
    }
    
    
    
    
    //MARK: Action methods
    @IBAction func saveDataButtonTouched(sender: AnyObject)
    {
        self.tappedMyPayButton()
        
    }
    
    
    
    
    @IBAction func deliveryButtonSelected(sender: AnyObject) {
        
        let btn : UIButton = sender as! UIButton
        if(btn.tag == 1)
        {
            self.shippingAddressLabel.hidden = true
            self.separatorView.hidden        = true
            self.addressView.hidden          = true
            self.meetInPersonButton.backgroundColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1)
            self.meetInPersonButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.shipItButton.backgroundColor  = UIColor.clearColor()
            self.shipItButton.setTitleColor(UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1), forState: UIControlState.Normal)
            self.isMeetInPersonSelected = true
            self.deliveryOption = "meet_in_person"
            self.isShipItSelected = false
            self.setBuyButton()
        }
        else
        {
            self.meetInPersonButton.backgroundColor  = UIColor.clearColor()
            self.meetInPersonButton.setTitleColor(UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1), forState: UIControlState.Normal)
            self.shipItButton.backgroundColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1)
            self.shipItButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.isMeetInPersonSelected = false
            self.deliveryOption = "ship"
            self.isShipItSelected = true
            self.fetchData()
        }
        
    }
    
    
    func fetchData()
    {
        SVProgressHUD.show()
        
        MVDataManager.getUserAddress(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            
            self.userAddress = response as! MVUserAddress
            
            self.addressTextField.text = self.userAddress.street
            self.postalCodeTextField.text = "\(self.userAddress.postalCode)"
            self.cityTextField.text = self.userAddress.city
            self.countryTextField.text = self.userAddress.country
            self.stateTextField.text = self.userAddress.state
            
            self.shippingAddressLabel.hidden = false
            self.separatorView.hidden        = false
            self.addressView.hidden          = false
            
            self.isMeetInPersonSelected = false
            
            self.setBuyButton()
            SVProgressHUD.popActivity()
            
        }) { failure in
            
            print(failure)
            SVProgressHUD.popActivity()
        }
    }
    
    func setBuyButton()
    {
        if(self.isMeetInPersonSelected)
        {
            self.saveDataButton.enabled = true
            self.saveDataButton.backgroundColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1)
            self.saveDataButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
        else if (self.isShipItSelected)
        {
            if(self.addressTextField.validate() && self.postalCodeTextField.validate() && self.cityTextField.validate() && self.countryTextField.validate() && self.stateTextField.validate())
            {
                self.saveDataButton.enabled = true
                self.saveDataButton.backgroundColor  = UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1)
                self.saveDataButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
            else
            {
                self.saveDataButton.enabled = false
                self.saveDataButton.backgroundColor  = UIColor.clearColor()
                self.saveDataButton.setTitleColor(UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1), forState: UIControlState.Normal)
                
            }
            
        }
        else
        {
            self.saveDataButton.enabled = false
            self.saveDataButton.backgroundColor  = UIColor.clearColor()
            self.saveDataButton.setTitleColor(UIColor(red: 133/255.0, green: 231/255.0, blue: 97/255.0, alpha: 1), forState: UIControlState.Normal)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.setBuyButton()
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Payment
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
                BTConfiguration.enableVenmo(true)
            }
            }.resume()
    }
    
    
    
    
    func tappedMyPayButton() {
        SVProgressHUD.show()
        MVDataManager.generateVenmoToken(MVParameters.sharedInstance.currentMVUser.id, successBlock: { (json) in
            
            SVProgressHUD.popActivity()
            if let braintreeClient: BTAPIClient = BTAPIClient(authorization: json["token"].stringValue) {
                let dropInViewController = BTDropInViewController(APIClient: braintreeClient)
                dropInViewController.delegate = self
                
                let navigationController = UINavigationController(rootViewController: dropInViewController)
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
    
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        dismissViewControllerAnimated(true, completion: nil)
        let nonce = paymentMethodNonce.nonce
        let venmoAccountNonce : BTVenmoAccountNonce? = paymentMethodNonce as? BTVenmoAccountNonce
        if (venmoAccountNonce != nil) {
            let username = venmoAccountNonce!.username
            print(username)
        }
        
        
        if(self.isMeetInPersonSelected == true)
        {
            SVProgressHUD.show()
            MVDataManager.productBuyVenmo(MVParameters.sharedInstance.currentMVUser.id, productID: self.product.id, paidPrice: self.itemPrice, deliveryOption: self.deliveryOption, nonce: nonce, successBlock: { (json) in
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
        }
        else
        {
            SVProgressHUD.show()
            MVDataManager.updateUserAddress(MVParameters.sharedInstance.currentMVUser.id, street: self.addressTextField.text, postalCode: Int(self.postalCodeTextField.text!), city: self.cityTextField.text, country: self.countryTextField.text, state: self.stateTextField.text, successBlock: { response in
                
                
                SVProgressHUD.show()
                MVDataManager.productBuyVenmo(MVParameters.sharedInstance.currentMVUser.id, productID: self.product.id, paidPrice: self.itemPrice, deliveryOption: self.deliveryOption, nonce: nonce, successBlock: { (json) in
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
        
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        
    }
}
