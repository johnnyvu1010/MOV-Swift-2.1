//
//  ContactUsViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 22/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    let titleItems = ["Full Name", "E-mail", "Subject", "Message", "SUBMIT"]
    let itemsRequired = [0,0,1,1,1];

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact us"
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        self.addRightNavItemOnView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Screen setup
    func addRightNavItemOnView() {
        let inboxButton: UIButton = UIButton(type: UIButtonType.Custom)
        inboxButton.frame = CGRectMake(0, 0, 25, 20)
        inboxButton.setImage(UIImage(named:"inboxButton.png"), forState: UIControlState.Normal)
        inboxButton.addTarget(self, action: #selector(ContactUsViewController.inboxButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: inboxButton), animated: true)
    }
    
    func inboxButtonTapped() {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let myCartViewController = mainSt.instantiateViewControllerWithIdentifier("MyCartViewController")  as! MyCartViewController
        self.navigationController?.pushViewController(myCartViewController, animated: true)
    }
    
    //MARK:- UITableViewDelegate, Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0...2:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactTextFieldTableViewCell), forIndexPath: indexPath) as! ContactTextFieldTableViewCell
            cell.labelTitleHint.text = titleItems[indexPath.row]
            cell.labelRequiredHint.hidden = (itemsRequired[indexPath.row] == 0)
            cell.textFieldDetails.tag = indexPath.row
            cell.textFieldDetails.addTarget(self, action: #selector(ContactUsViewController.textFieldValueChanged(_:)), forControlEvents: .EditingChanged)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactTextViewTableViewCell), forIndexPath: indexPath) as! ContactTextViewTableViewCell
            cell.labelTitleHint.text = titleItems[indexPath.row]
            cell.labelRequiredHint.hidden = (itemsRequired[indexPath.row] == 0)
            cell.textViewDetails.delegate = self
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ContactButtonTableViewCell), forIndexPath: indexPath) as! ContactButtonTableViewCell
            cell.buttonSubmit.addTarget(self, action: #selector(ContactUsViewController.submitButtonTapped(_:)), forControlEvents: .TouchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0...2:
            return 70
        case 3,4:
            return 140
        default:
            return 44
        }
    }
    
    func textFieldValueChanged(sender:UITextField) {
        switch sender.tag {
        case 0:
        ""
        case 1:
          ""
        case 2:
            ""
        default:
            ""
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
    }
    
    func submitButtonTapped(sender:UIButton) {
        
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
