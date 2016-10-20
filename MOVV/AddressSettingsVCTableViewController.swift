//
//  AddressSettingsVCTableViewController.swift
//  MOVV
//
//  Created by Petar Bandov on 08/06/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class AddressSettingsVCTableViewController: UITableViewController {
    
    @IBOutlet var streetTextField: UITextField!
    @IBOutlet var postalCodeTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var countryTextField: UITextField!
    @IBOutlet var changeAddressButton: UIButton!
    
    var userAddress : MVUserAddress!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.userInteractionEnabled = true
        
        self.changeAddressButton.layer.borderWidth = 1.0
        self.changeAddressButton.layer.cornerRadius = 3.0
        self.changeAddressButton.layer.borderColor = UIColor(red: 150/255.0, green: 235/255.0, blue: 98/255.0, alpha: 1).CGColor
//        [[myButton layer] setBorderColor:[UIColor greenColor].CGColor];
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

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    

    
    func fetchData()
    {
        MVDataManager.getUserAddress(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in

            self.userAddress = response as! MVUserAddress
            self.setAddressTextFields()

        }) { failure in
            
            print(failure)
        }
    }
    
    func setAddressTextFields()
    {
        self.streetTextField.text = self.userAddress.street
        self.postalCodeTextField.text = "\(self.userAddress.postalCode)"
        self.cityTextField.text = self.userAddress.city
        self.countryTextField.text = self.userAddress.country
        self.stateTextField.text = self.userAddress.state
    }
    

    func setUserAddress()
    {
        MVDataManager.updateUserAddress(MVParameters.sharedInstance.currentMVUser.id, street: self.streetTextField.text, postalCode: Int(self.postalCodeTextField.text!), city: self.cityTextField.text, country: self.countryTextField.text, state: self.stateTextField.text, successBlock: { response in
            
            print("Update address success message: \(response)")
            self.showAlertWithMessage(response as! String)
            
        }) { failure in
            
            print("Update address success message: \(failure)")
            self.showAlertWithMessage(failure as! String)
        }
    }
    
    
    @IBAction func changeAddressButtonTouched(sender: AnyObject) {
        
        self.setUserAddress()
    }
    
    func showAlertWithMessage(message:String){
        let alert = MOVVAlertViewController(title: "", message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
