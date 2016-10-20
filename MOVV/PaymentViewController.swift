//
//  PaymentViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 20/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import Braintree
import SVProgressHUD

protocol PaymentControllerDelegate {
    func paymentSuccess(nonce:String)
    func paymentFailed()
}

class PaymentViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldCVV: UITextField!
    @IBOutlet weak var textFieldCardNumber: UITextField!
    @IBOutlet weak var textFieldExpireDate: UITextField!
    @IBOutlet weak var buttonPay: UIButton!
    var delegate:PaymentControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func buttonPayTapped(sender: UIButton) {
        self.view.endEditing(true)
        if self.validate().length > 0 {
            let alert = MVAlertController(title: nil, message: self.validate(), preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            SVProgressHUD.show()
            MVDataManager.generateVenmoToken(MVParameters.sharedInstance.currentMVUser.id, successBlock: { (json) in
                //this code only for testing perpose
                if json["token"].stringValue == "fake-valid-nonce"{
                    self.delegate?.paymentSuccess("fake-valid-nonce")
                    SVProgressHUD.popActivity()
                    return
                }
                if let braintreeClient: BTAPIClient = BTAPIClient(authorization: json["token"].stringValue) {
                    if let cardClient:BTCardClient = BTCardClient(APIClient: braintreeClient) {
                        let expireDateComponent = self.textFieldExpireDate.text?.componentsSeparatedByString("/")
                        let card = BTCard(number: self.getCardNumber(), expirationMonth: expireDateComponent![0], expirationYear: expireDateComponent![1], cvv: self.textFieldCVV.text!)
                        cardClient.tokenizeCard(card) { (tokenizedCard, error) in
                            SVProgressHUD.popActivity()
                            if tokenizedCard != nil{
                                self.delegate?.paymentSuccess(tokenizedCard!.nonce)
                            }else{
                                self.delegate?.paymentFailed()
                            }
                        }
                    } else {
                        SVProgressHUD.popActivity()
                        print("Unable to create cardClient. Check that tokenization key or client token is valid.")
                        self.delegate?.paymentFailed()
                    }
                } else {
                    SVProgressHUD.popActivity()
                    self.delegate?.paymentFailed()
                }
            }) { (errorString) in
                SVProgressHUD.popActivity()
                self.delegate?.paymentFailed()
            }
        }
    }
    
    func validate() -> String{
        if !(textFieldCardNumber.text?.length > 0) {
            return "Please enter card number."
        }
        if !(self.getCardNumber().length == 16) {
            return "Please enter a valid card number."
        }
        if !(textFieldCardNumber.text?.length > 0) {
            return "Please enter card expire date."
        }
        if !(textFieldCVV.text?.length > 0) {
            return "Please enter CVV number."
        }
        if !(textFieldCVV.text?.length == 3) {
            return "Please enter a valid CVV number."
        }
        let expireDateComponent = self.textFieldExpireDate.text?.componentsSeparatedByString("/")
        if !(expireDateComponent?.count == 2) {
            return "Please enter card expire date in correct format."
        }
        return ""
    }
    
    func getCardNumber() -> String{
        return textFieldCardNumber.text!.componentsSeparatedByString(" ").joinWithSeparator("")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.length <= 1 && range.length <= 1 {
            if string.length == 0{
                if textField == textFieldCardNumber {
                    if textField.text!.characters[textField.text!.endIndex.advancedBy(-1)] == " "{
                        textField.text = textField.text!.substringToIndex(textField.text!.endIndex.advancedBy(-2))
                        return false
                    }
                }else if textField == textFieldExpireDate{
                    if textField.text!.characters[textField.text!.endIndex.advancedBy(-1)] == "/" {
                        textField.text = textField.text!.substringToIndex(textField.text!.endIndex.advancedBy(-2))
                        return false
                    }
                }
                return true
            }
            if textField == textFieldCardNumber {
                if self.getCardNumber().length + string.length > 16 {
                    return false
                }
                if self.getCardNumber().length < 15 && (((self.getCardNumber().length + string.length) % 4) == 0) {
                    textField.text?.appendContentsOf("\(string) ")
                    return false
                }
            }else if textField == textFieldExpireDate {
                let totalLength = textField.text!.length + string.length
                if  totalLength > 5 {
                    return false
                }
                if totalLength == 1 {
                    return (Int(string) == 0 || Int(string) == 1 )
                }
                if totalLength == 2 {
                    let mmFirstDigitValidation = (Int(textField.text!) == 1 && (Int(string) >= 0 && Int(string) <= 2))
                    let mmSecondDigitValidation = (Int(textField.text!) == 0 && (Int(string) >= 1 && Int(string) <= 9))
                    if (mmFirstDigitValidation || mmSecondDigitValidation) {
                        textField.text?.appendContentsOf("\(string)/")
                    }
                    return false
                }
            }else if textField == textFieldCVV{
                let totalLength = textField.text!.length + string.length
                if totalLength > 3{
                    return false
                }
            }
            return true
        }
        return false
    }

}
