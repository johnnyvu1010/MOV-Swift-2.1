//
//  ContactsViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 23/06/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import MessageUI
import UIKit
import AddressBook
import AddressBookUI

import Contacts

@available(iOS 9.0, *)

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , MFMessageComposeViewControllerDelegate , MFMailComposeViewControllerDelegate, ContactCellDelegate {
    
    var people : [SwiftAddressBookPerson]? = []
    var messageVC:MFMessageComposeViewController?
    var mailComposerVC:MFMailComposeViewController?
    var contacts: [SwiftAddressBookPerson]? = []
     var cnContacts: [CNContact]? = []
    
    var store = CNContactStore()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.userInteractionEnabled = true
        self.navigationItem.title = "Invite Contacts"
        
        if(self.navigationController?.navigationBarHidden == true)
        {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        let toFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        let request = CNContactFetchRequest(keysToFetch: toFetch)
        
        do{
            try store.enumerateContactsWithFetchRequest(request) {
                contact, stop in
//                print(contact.givenName)
//                print(contact.familyName)
//                print(contact.identifier)
                self.cnContacts?.append(contact)
                
            }
        } catch let err{
            print(err)
        }
        
        
        
        
        
//        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
//        swiftAddressBook?.requestAccessWithCompletion({ (success, error) -> Void in
//            
////            print(SwiftAddressBook.allPeopleInSource(swiftAddressBook!))
//            print(swiftAddressBook!.personCount)
//            print(swiftAddressBook!.allPeople)
//            
//            if success {
//                if let people = swiftAddressBook?.allPeople {
//                    for person in people {
//                        if (person.compositeName != nil) {
//                            self.contacts?.append(person)
//                        }
//                    }
//                }
//            } else {
//                //no success. Optionally evaluate error
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.tableView.reloadData()
//                SVProgressHUD.popActivity()
//            })
//        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func checkAccessStatus(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
        case .Denied, .NotDetermined:
            self.store.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                } else {
                    print("access denied")
                }
            })
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cnContacts!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:ContactCell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactCell
        
        
        
        let contact = self.cnContacts![indexPath.row]
        cell.contactNameLabel.text = "\(contact.givenName) \(contact.familyName)"

        
//        print((contact.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits")!)
//        print((contact.phoneNumbers[0].value as! CNPhoneNumber).stringValue)
        
        if(contact.emailAddresses.count > 0)
        {
            print(contact.emailAddresses[0].value)
        }


        if (contact.phoneNumbers.count > 0) {
            cell.contactDetailsLabel.text = (contact.phoneNumbers[0].value as! CNPhoneNumber).stringValue
            cell.sendSMSButton.setImage(UIImage(named: "inviteSMS.png"), forState: UIControlState.Normal)
            cell.isSendSMS = true
        } else if (contact.emailAddresses.count > 0) {
            cell.contactDetailsLabel.text = contact.emailAddresses[0].value as? String
            cell.sendSMSButton.setImage(UIImage(named: "inviteMail.png"), forState: UIControlState.Normal)
            cell.isSendSMS = false
        } else {
            cell.contactDetailsLabel.text = ""
            cell.sendSMSButton.setImage(UIImage(named: "inviteMail.png"), forState: UIControlState.Normal)
            cell.isSendSMS = false
        }

        cell.delegate = self
        return cell
    }
    


    
    func onTouchSendButton(isSendSMS: Bool, forCell:UITableViewCell) {
        if (isSendSMS) {
            self.sendSMS(forCell as! ContactCell)
        } else {
            self.sendMail(forCell as! ContactCell)
        }
    }
    
    func sendMail(cell:ContactCell){
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:MOVVGreen]
        UIBarButtonItem.appearance().tintColor = MOVVGreen
        mailComposerVC = MFMailComposeViewController()
        mailComposerVC!.mailComposeDelegate = self
        
        mailComposerVC!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        mailComposerVC!.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))

        mailComposerVC!.setToRecipients([cell.contactDetailsLabel.text!])
        mailComposerVC!.setSubject("MOV app")
        mailComposerVC!.setMessageBody("Download MOV on the AppStore today: http://bit.ly/getMOVios ", isHTML: false)
        if MFMailComposeViewController.canSendMail() {
            mailComposerVC!.view.alpha = 0
            self.view.window?.addSubview(mailComposerVC!.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.mailComposerVC!.view.alpha = 1
            })

        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.mailComposerVC!.view.alpha = 0
            }) { (Bool) -> Void in
                self.mailComposerVC!.view.removeFromSuperview()
                self.mailComposerVC = nil
        }
        
    }
    
    
    func sendSMS(cell:ContactCell){
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:MOVVGreen]
        UIBarButtonItem.appearance().tintColor = MOVVGreen
        var phoneNumber = cell.contactDetailsLabel.text?.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        phoneNumber = phoneNumber?.stringByReplacingOccurrencesOfString("+385", withString: "0", options: [], range: nil)
        messageVC = MFMessageComposeViewController()
        messageVC?.navigationBar.backgroundColor = MOVVGreen
        messageVC!.body = "Download MOV on the AppStore today: http://bit.ly/getMOVios";
        messageVC!.recipients = [phoneNumber!]
        messageVC!.messageComposeDelegate = self;
        messageVC?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        messageVC?.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))
        
        messageVC?.view.alpha = 0
        self.view.window?.addSubview(messageVC!.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.messageVC?.view.alpha = 1
        })
        
        
    }
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            
        default:
            break;
        }
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.messageVC?.view.alpha = 0
            }) { (Bool) -> Void in
                self.messageVC?.view.removeFromSuperview()
                self.messageVC = nil
        }
        
        
    }
}
