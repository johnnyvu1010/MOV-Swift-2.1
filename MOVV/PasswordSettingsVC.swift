//
//  PasswordSettingsVC.swift
//  MOVV
//
//  Created by Petar Bandov on 09/06/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class PasswordSettingsVC: UITableViewController {
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var saveSettingsButton: UIButton!

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.userInteractionEnabled = true
        self.navigationItem.title = "Change Passwords"
        
        if(self.navigationController?.navigationBarHidden == true)
        {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    // MARK: Lifecycle
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
    
    // MARK: Tableview
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }

    // MARK: Button actions
    @IBAction func saveSettingsButtonAction(sender: UIButton) {
        
        let oldPassword : String! = self.oldPasswordTextField.text
        let newPassword : String! = self.newPasswordTextField.text
        let confirmNewPassword : String! = self.retypePasswordTextField.text
        
        if (oldPassword == "" || newPassword == "" || confirmNewPassword == "") {
            let alert:UIAlertView = UIAlertView(title: "All fields are required", message: nil, delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        } else if (newPassword != confirmNewPassword) {
            let alert:UIAlertView = UIAlertView(title: "New password and confirm new password missmatch", message: nil, delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        } else {
            
            MVDataManager.updateUserPassword(MVParameters.sharedInstance.currentMVUser.id, oldPassword: oldPassword, newPassword: newPassword, confirmNewPassword: confirmNewPassword, successBlock: { response in
                print(response)
                let alert:UIAlertView = UIAlertView(title: response as? String, message: nil, delegate: self, cancelButtonTitle: "Ok")
                alert.show()
                
                }) { failure in
                    
                    let alert:UIAlertView = UIAlertView(title: "Password change failed", message: nil, delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                    
            }
        }
        
    }
}
