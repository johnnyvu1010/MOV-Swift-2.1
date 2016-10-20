//
//  ChangeCityStateViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 01/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChangeCityStateViewController: UIViewController {

    @IBOutlet weak var textFieldCity: UITextField!
    @IBOutlet weak var textFieldState: UITextField!
    var userCountry:String!
    var userStreet:String!
    var userPostalCode:Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.title = "Change Profile City/State"
        self.getAddress()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonSaveTapped(sender: UIButton) {
        self.view.endEditing(true)
        if textFieldCity.text!.isEmpty || textFieldState.text!.isEmpty {
            let alert:UIAlertController = UIAlertController(title: "", message: "All fields are required.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        self.updateAddress()
    }
    
    func getAddress() {
        SVProgressHUD.show()
        MVDataManager.getUserAddress(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            let address:MVUserAddress = response as! MVUserAddress
            SVProgressHUD.popActivity()
            self.textFieldState.text = address.state.isEmpty ? "" : address.state
            self.textFieldCity.text = address.city.isEmpty ? "" : address.city
            self.userCountry = address.country.isEmpty ? "x" : address.country
            self.userStreet = address.street.isEmpty ? "x" : address.street
            self.userPostalCode = address.postalCode
        }) { failure in
            print(failure)
            SVProgressHUD.popActivity()
        }
    }
    
    func updateAddress(){
        let request : String! = "update-user-address"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "state":"\(self.textFieldState.text!)",
                                           "city":"\(self.textFieldCity.text!)",
                                           "street":"\(self.userStreet)",
                                           "postal_code":"\(self.userCountry)",
                                           "country":"\(self.userCountry)"]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            UIAlertView(title: "Address updated.", message: nil, delegate: self, cancelButtonTitle: "Ok").show()
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:failure, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: {
            })
        }
        
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
