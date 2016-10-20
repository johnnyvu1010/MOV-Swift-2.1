//
//  MerchantAccountVC.swift
//  MOVV
//
//  Created by Yuki on 08/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

protocol MerchantAccountDelegate {
    func merchantAccountDetailsSaved(sender:MerchantAccountVC)
    func merchantAccountDetailsFailed(sender:MerchantAccountVC)
}


class MerchantAccountVC: UITableViewController {

    @IBOutlet weak var saveSettingsButton: UIButton!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var regionTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var accountNumberTextField: UITextField!
    @IBOutlet weak var routingNumberTextField: UITextField!
    
    var delegate:MerchantAccountDelegate?
    
    // MARK: Variables
    private lazy var datePicker: UIDatePicker = {
        let datePicker: UIDatePicker = UIDatePicker()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let firstDate = "1924-01-01"
        let minDate = dateFormatter.dateFromString(firstDate)
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = NSDate()
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: #selector(MerchantAccountVC.datePickerChanged), forControlEvents: .ValueChanged)
        
        return datePicker
    }()
    
    func datePickerChanged() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.dateOfBirthTextField.text = dateFormatter.stringFromDate(self.datePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Merchant Account"
        self.dateOfBirthTextField.inputView = self.datePicker
        
        
        self.fetchData()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Force your tableview margins (this may be a bad idea)
        if self.tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        self.tableView.layoutIfNeeded()
        
        if self.tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
    }
    
    func cancelButtonTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Tableview
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    
    // MARK: Button actions
    @IBAction func saveSettingsButtonAction(sender: AnyObject) {
        
        if (self.firstnameTextField.text == ""
            || self.lastnameTextField.text == ""
            || self.emailTextField.text == ""
            || self.phoneTextField.text == ""
            || self.dateOfBirthTextField.text == ""
            || self.streetTextField.text == ""
            || self.cityTextField.text == ""
            || self.regionTextField.text == ""
            || self.postalCodeTextField.text == ""
            || self.routingNumberTextField.text == ""
            || self.accountNumberTextField.text == "") {
            let alert:UIAlertView = UIAlertView(title: "All fields are required", message: nil, delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        }else if self.regionTextField.text?.length > 2 {
            UIAlertView(title: "Please use state abbreviation like WA for Washington", message: nil, delegate: self, cancelButtonTitle: "Ok").show()
        } else {
            let data: [String: String] = [
                "user_id": "\(MVParameters.sharedInstance.currentMVUser.id)",
                "first_name": self.firstnameTextField.text!,
                "last_name": self.lastnameTextField.text!,
                "email": self.emailTextField.text!,
                "phone": self.phoneTextField.text!,
                "date_of_birth": self.dateOfBirthTextField.text!,
                "address_street": self.streetTextField.text!,
                "address_city": self.cityTextField.text!,
                "address_region": self.regionTextField.text!,
                "address_postal": self.postalCodeTextField.text!,
                "account_number": self.accountNumberTextField.text!,
                "routing_number": self.routingNumberTextField.text!
            ]
            
            SVProgressHUD.show()
            MVDataManager.updateMerchantAccount(data, successBlock: { response in
                SVProgressHUD.popActivity()
                MVParameters.sharedInstance.currentMVUser.can_sell = true
                let alert:UIAlertView = UIAlertView(title: response as? String, message: nil, delegate: self, cancelButtonTitle: "Ok")
                alert.show()
                self.delegate?.merchantAccountDetailsSaved(self)
            }) { failure in
                SVProgressHUD.popActivity()
                let alert:UIAlertView = UIAlertView(title: "Merchant account update failed", message: nil, delegate: self, cancelButtonTitle: "Ok")
                alert.show()
                self.delegate?.merchantAccountDetailsFailed(self)
            }
        }
        
    }
    
    
    private func fetchData() {
        // user-merchant-account
        SVProgressHUD.show()
        MVDataManager.getMerchantInfo({ (response) in
            SVProgressHUD.popActivity()
            
            let json = JSON(response)
            
            self.firstnameTextField.text = json["merchant_data"]["first_name"].stringValue
            self.lastnameTextField.text = json["merchant_data"]["last_name"].stringValue
            self.emailTextField.text = json["merchant_data"]["email"].stringValue
            self.phoneTextField.text = json["merchant_data"]["phone"].stringValue
            self.dateOfBirthTextField.text = json["merchant_data"]["date_of_birth"].stringValue
            self.streetTextField.text = json["merchant_data"]["address_street"].stringValue
            self.cityTextField.text = json["merchant_data"]["address_locality"].stringValue
            self.regionTextField.text = json["merchant_data"]["address_region"].stringValue
            self.postalCodeTextField.text = json["merchant_data"]["address_postal"].stringValue
            self.accountNumberTextField.text = json["merchant_data"]["account_number"].stringValue
            self.routingNumberTextField.text = json["merchant_data"]["routing_number"].stringValue
            
        }) { (failure) in
            SVProgressHUD.popActivity()
            let alert:UIAlertView = UIAlertView(title: "Merchant account update failed", message: nil, delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    

    
}
