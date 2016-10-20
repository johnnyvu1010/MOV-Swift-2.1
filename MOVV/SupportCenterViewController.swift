//
//  SupportCenterViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 22/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import MessageUI

class SupportCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textFieldAskQuestion: UITextField!
    @IBOutlet weak var tableViewSupportOption: UITableView!
    
    let supportItems = ["Community Guidelines", "Copyright Policy", "FAQ", "MOV Support"]
    let supportLinks = [ "http://mymov.co/app/marketplace.php", "http://mymov.co/app/privacy.php", "http://mymov.co/app/faq.php", "http://mymov.co/app/contact.php"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navbarVideo"), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.hidesBackButton = false
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        self.addRightNavItemOnView()
        
        if self.view.respondsToSelector(Selector("setLayoutMargins:")) {
            self.view.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        inboxButton.addTarget(self, action: #selector(SupportCenterViewController.inboxButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: inboxButton), animated: true)
    }
    
    func inboxButtonTapped() {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let myCartViewController = mainSt.instantiateViewControllerWithIdentifier("MyCartViewController")  as! MyCartViewController
        self.navigationController?.pushViewController(myCartViewController, animated: true)
    }
    
    @IBAction func buttonAskQuestionTapped(sender: UIButton) {
        self.send("", messageBody: "", toRecipients: ["contact@mymov.com"])
    }
    
    //MARK: - UITableView Delegate + Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(SupportCenterTableViewCell), forIndexPath: indexPath) as! SupportCenterTableViewCell
        cell.labelSupportTitle.text = supportItems[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
//        if indexPath.row == 3 {
//            let contactUSVC = mainSt.instantiateViewControllerWithIdentifier(String(ContactUsViewController)) as! ContactUsViewController
//            self.navigationController!.pushViewController(contactUSVC, animated: true)
//            return
//        }
        let webContentVC: MVShowWebContentViewController = mainSt.instantiateViewControllerWithIdentifier(String(MVShowWebContentViewController)) as! MVShowWebContentViewController
        webContentVC.urlString = supportLinks[indexPath.row]
        webContentVC.title = supportItems[indexPath.row]
        self.navigationController?.pushViewController(webContentVC, animated: true)
    }
    
    //MARK- Email Helper
    func send(title: String, messageBody: String, toRecipients: [String]) {
        UINavigationBar.appearance().barTintColor = UIColor.greenAppColor()
        if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.delegate = self
            mc.mailComposeDelegate = self
            mc.setSubject(title)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipients)
            mc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            mc.navigationBar.tintColor = UIColor.whiteColor();
            self.presentViewController(mc, animated: true, completion: nil)
        } else {
            MVHelper.showAlertWithMessageAndTitle("No email account found.", title: "Error")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue: print("Mail Cancelled")
        case MFMailComposeResultSaved.rawValue: print("Mail Saved")
        case MFMailComposeResultSent.rawValue: print("Mail Sent")
        case MFMailComposeResultFailed.rawValue: print("Mail Failed")
        default: break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
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
