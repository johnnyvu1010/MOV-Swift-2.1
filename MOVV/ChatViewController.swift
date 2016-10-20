//
//  ChatViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 26/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import IQKeyboardManager
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var postView: UIView!
    @IBOutlet var chatTableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    var visualEffectView:UIVisualEffectView?
    @IBOutlet weak var movvCodeTextField: UITextField!
    @IBOutlet var movvCodeView: UIView!
    var keyboardRect : CGRect!

    @IBOutlet var tableViewTopConstrain: NSLayoutConstraint!
    var product : MVProduct!
    var messagesArray : [MVMessageDetails]! = [MVMessageDetails]()
    var topicID : Int!
    var blurInt: Int! = 0
    var shouldPopToRootViewController : Bool = false
    var isUserProfile:Bool!
    var messageType : MVMessageType = MVMessageType.Text
    var messageText : String! = ""
    var userAddress : MVUserAddress!
    var pinOKMessageRecieved : Bool = false
    
    @IBOutlet var messageTextFieldConstrain: NSLayoutConstraint!
    
    private let kAcceptDeclineCellID = "acceptDeclineCell"
    private let kChatCellID = "chatCell"
    private let kMOVVChatCellID = "movvChatCell"
    private let kConfirmAddressCellID = "confirmAddressCell"
    private let kReviewCellCellID = "reviewCell"
    private let kReviewScoreCellCellID = "reviewScoreCell"
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.fetchData()
        self.chatTableView.addPullToRefreshAboveSegmentControlWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(2)
                self.fetchData(true)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.chatTableView.stopPullToRefresh()
                    
                }
            }
            }, withAnimator: BeatAnimator())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        postView.layer.borderColor = UIColor.lightGrayColor().CGColor
        postView.layer.borderWidth = 1
        // Do any additional setup after loading the view.
        
    }
    
    func keyboardWillChange(notification : NSNotification)
    {
        self.keyboardRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.keyboardRect = self.view.convertRect(self.keyboardRect, fromView: nil)
    }

    
    func keyboardWillShow()
    {
        self.messageTextFieldConstrain.constant = self.keyboardRect.size.height
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.postView.layoutIfNeeded()
        })

    }

    func keyboardWillHide()
    {
        self.messageTextFieldConstrain.constant = 0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.postView.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.fetchUserAddress()
        
        
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationItem.title = "Messages"
        
        if self.isUserProfile == true {
            
        } else if self.blurInt == 1 || self.parentViewController?.parentViewController?.isKindOfClass(HomeViewController) != nil {
            if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
                addBlurEffect()
            }
        }
    
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().enable = false
        if(self.shouldPopToRootViewController)
        {
            let rightButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ChatViewController.popToRoot))
            self.navigationItem.rightBarButtonItem = rightButton
            self.navigationItem.setHidesBackButton(true, animated: false)
        }else{
            let rightButton : UIBarButtonItem = UIBarButtonItem(title: "AddReview", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ChatViewController.gotoReview))
            self.navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
        
        self.view.endEditing(true)
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let messageDetails : MVMessageDetails! = self.messagesArray[indexPath.row]
        
//        var messageDetails : MVMessageDetails! = self.messagesArray[indexPath.row]
        self.setMovvCodeLabel(messageDetails, indexPath : indexPath)
        if messageDetails.sentFromUser.id == 1 {
            if (messageDetails.messageType == MVMessageType.DeclineMeet)
            {
                return MVHelper.heightForText(messageDetails.message, forFont: UIFont.boldSystemFontOfSize(15), andWidth: self.view.bounds.size.width - 135) + 293
            }
            else if (messageDetails.messageType == MVMessageType.Review)
            {
                return MVHelper.heightForText(messageDetails.message, forFont: UIFont.boldSystemFontOfSize(15), andWidth: self.view.bounds.size.width - 135) + 145
            }
            else if (messageDetails.messageType == MVMessageType.ReviewResult)
            {
                return 48
            }
            else
            {
                return MVHelper.heightForText(messageDetails.message, forFont: UIFont.boldSystemFontOfSize(15), andWidth: self.view.bounds.size.width - 135) + 119
            }
        }
        else
        {
            if (messageDetails.messageType == MVMessageType.MeetInPerson)
            {
                return MVHelper.heightForText(messageDetails.message, forFont: UIFont.boldSystemFontOfSize(15), andWidth: self.view.bounds.size.width - 135) + 116
            }
                
            else
            {
                return MVHelper.heightForText(messageDetails.message, forFont: UIFont.boldSystemFontOfSize(15), andWidth: self.view.bounds.size.width - 135) + 74
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let messageDetails : MVMessageDetails! = self.messagesArray[indexPath.row]
        
//        if(messageDetails.messageType == MVMessageType.PinOK.rawValue)
//        {
//            self.movvCodeTextField.text = "Pin OK!"
//            self.movvCodeTextField.enabled = false
//        }
        
       
        

        
        if (messageDetails.messageType == MVMessageType.MeetInPerson)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.kAcceptDeclineCellID, forIndexPath: indexPath) as! ChatCell
            
//            cell.chatText.text                 = messageDetails.message
//            cell.userImage.hidden              = false
//            cell.userOneImage.hidden           = true
//            cell.chatIndicatorLeft.hidden      = true
//            cell.chatIndicatorRight.hidden     = false
//            cell.timeLabel.text                = messageDetails.sentDate
//            cell.containerView.backgroundColor = UIColor(red: 60/255, green: 219/255, blue: 79/255, alpha: 1)
//            cell.chatText.textColor            = UIColor.whiteColor()
//            cell.userImage.setImageWithURL(NSURL(string: messageDetails.sentFromUser.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
//            MVHelper.addMOVVCornerRadiusToView(cell.userImage)
//            
//            cell.containerView.layer.cornerRadius = 4
//            cell.containerView.clipsToBounds = true
            
            return cell
        }
            else if (messageDetails.messageType == MVMessageType.DeclineMeet)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.kConfirmAddressCellID, forIndexPath: indexPath) as! ChatCell
            cell.chatText.text = messageDetails.message
            cell.addressLabel.text = self.userAddress.street
            cell.postalCodeLabel.text = "\(self.userAddress.postalCode)"
            cell.cityLabel.text = self.userAddress.city
            cell.stateLabel.text = self.userAddress.state
            cell.countryLabel.text = self.userAddress.country
            
            cell.containerView.layer.cornerRadius = 4
            cell.containerView.clipsToBounds = true
            
            return cell
        }
            
        else if (messageDetails.messageType == MVMessageType.Review)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.kReviewCellCellID, forIndexPath: indexPath) as! ChatCell
            cell.chatText.text = messageDetails.message
//            cell.addressLabel.text = self.userAddress.street
//            cell.postalCodeLabel.text = "\(self.userAddress.postalCode)"
//            cell.cityLabel.text = self.userAddress.city
//            cell.stateLabel.text = self.userAddress.state
//            cell.countryLabel.text = self.userAddress.country
            
            cell.containerView.layer.cornerRadius = 4
            cell.containerView.clipsToBounds = true
            
            return cell
        }
        else if (messageDetails.messageType == MVMessageType.ReviewResult)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.kReviewScoreCellCellID, forIndexPath: indexPath) as! ChatCell
            
            let score : Int = (messageDetails.message as NSString).integerValue
            let image : UIImage = UIImage(named: "starFilled.png")!
            
            for i : Int in 1 ..< score + 1
            {
                let imageView : UIImageView = self.view.viewWithTag(i) as! UIImageView

                    imageView.image = image

                
            }

            
            return cell
        }
        else
        {
            if messageDetails.sentFromUser.id == 1 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(self.kMOVVChatCellID, forIndexPath: indexPath) as! ChatCell
                cell.chatText.text = messageDetails.message
                cell.systemTimeLabel.text = messageDetails.sentDate
                cell.containerView.layer.cornerRadius = 4
                cell.containerView.clipsToBounds = true

                return cell
                
            } else if (messageDetails.sentFromUser.id == MVParameters.sharedInstance.currentMVUser.id) {
                let cell = tableView.dequeueReusableCellWithIdentifier(self.kChatCellID, forIndexPath: indexPath) as! ChatCell
                
                cell.chatText.text                 = messageDetails.message
                cell.userImage.hidden              = false
                cell.userOneImage.hidden           = true
                cell.chatIndicatorLeft.hidden      = true
                cell.chatIndicatorRight.hidden     = false
                cell.timeLabel.text                = messageDetails.sentDate
                cell.containerView.backgroundColor = UIColor(red: 60/255, green: 219/255, blue: 79/255, alpha: 1)
                cell.chatText.textColor            = UIColor.whiteColor()
                cell.userImage.setImageWithURL(NSURL(string: messageDetails.sentFromUser.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userImage)
                
                cell.containerView.layer.cornerRadius = 4
                cell.containerView.clipsToBounds = true
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(self.kChatCellID, forIndexPath: indexPath) as! ChatCell
                
                cell.chatText.text                 = messageDetails.message
                cell.userImage.hidden              = true
                cell.userOneImage.hidden           = false
                cell.chatIndicatorLeft.hidden      = false
                cell.chatIndicatorRight.hidden     = true
                cell.timeLabel.text                = messageDetails.sentDate
                cell.containerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
                cell.chatText.textColor            = UIColor.darkGrayColor()
                cell.userOneImage.setImageWithURL(NSURL(string: messageDetails.sentFromUser.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userOneImage)
                
                cell.containerView.layer.cornerRadius = 4
                cell.containerView.clipsToBounds = true
                
                return cell
            }

        }

    
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.messagesArray.count
    }
    
    // MARK: Textfield delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        

        
        
        
        
        if textField == self.movvCodeTextField && textField.text == "Input MovCode here" {
            let alert:MOVVAlertViewController = MOVVAlertViewController(title: "Input MOV code", message: "Enter four digit code!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in
                textField.placeholder = "1234"
                textField.clearButtonMode = UITextFieldViewMode.WhileEditing
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.addTarget(self, action: #selector(ChatViewController.alertTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
                
            })
            
            let confirmAction:UIAlertAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                let enteredCodeTextField:UITextField = alert.textFields!.first!
                self.movvCodeTextField.text = enteredCodeTextField.text
                self.messageText = enteredCodeTextField.text
               self.pinEntered(self.movvCodeTextField)
            })
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            confirmAction.enabled = false
            
            
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        else if textField == self.movvCodeTextField && textField.text == "Input tracking code here" {
            let alert:MOVVAlertViewController = MOVVAlertViewController(title: "Input tracking code here", message: "Enter tracking code!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in
//                textField.placeholder = "1234"
                textField.clearButtonMode = UITextFieldViewMode.WhileEditing
                textField.keyboardType = UIKeyboardType.Default
                textField.addTarget(self, action: #selector(ChatViewController.alertTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
                
            })
            
            let confirmAction:UIAlertAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                let enteredCodeTextField:UITextField = (alert.textFields?.first)!
                self.movvCodeTextField.text = enteredCodeTextField.text
                self.messageText = enteredCodeTextField.text
                self.trackingNumberEntered(self.movvCodeTextField)
            })
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            confirmAction.enabled = false
            
            
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        
        else if (textField == self.movvCodeTextField) {
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.postButtonTouched(self)
        return true
    }
    
    // Notification
    func alertTextFieldDidChange(sender:UITextField) {
        let alertController:MOVVAlertViewController? = self.presentedViewController as? MOVVAlertViewController
        if (alertController != nil) {
            let movvCodeTextField:UITextField = alertController!.textFields!.first!
            let confirmAction:UIAlertAction = alertController!.actions.last!
            
            if(sender.text == "Input MOV code")
            {
                confirmAction.enabled = movvCodeTextField.text!.length > 3
                if (movvCodeTextField.text!.length > 4) {
                    movvCodeTextField.text = (movvCodeTextField.text! as NSString).substringToIndex(4)
                }
            }
            else
            {
                confirmAction.enabled = true
            }
        }
    }
    
    // MARK: Layout
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    // MARK: Actions
    @IBAction func postButtonTouched(sender: AnyObject) {
        self.view.endEditing(true)
        SVProgressHUD.show()

        
        if(self.messageType == MVMessageType.Text)
        {
            self.messageText = self.messageTextField.text
        }
        else if(self.messageType == MVMessageType.TrackingCode)
        {
            //self.messageText == text iz shippingCode text fielda
        }
        else if(self.messageType == MVMessageType.ReviewScore)
        {
            let btn : UIButton = sender as! UIButton
            self.messageText = "\(btn.tag)"
        }
        else if(self.messageType == MVMessageType.ConfirmMeet || self.messageType == MVMessageType.DeclineMeet)
        {
            self.messageText = self.messageType.rawValue
        }
        else if(self.messageType == MVMessageType.ConfirmShipping)
        {
            self.messageText = self.messageType.rawValue
        }

        MVDataManager.sendMessage(MVParameters.sharedInstance.currentMVUser.id, topicID: topicID, message: "\(self.messageText)", messageType : "\(self.messageType.rawValue)",successBlock: { response in

            self.messageTextField.text = ""
            self.fetchData(true)
            SVProgressHUD.popActivity()
        }) { failure in
            print("Error: \(failure)")
            SVProgressHUD.popActivity()
        }
        
        //set back to default messageType
        self.messageType = MVMessageType.Text
        
    }
    
    func popToRoot()
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }



    @IBAction func confirmAddressButtonTouched(sender: AnyObject) {
        self.messageType = MVMessageType.ConfirmShipping
        self.postButtonTouched(sender)
    }
    
    
    @IBAction func changeAddressButtonTouched(sender: AnyObject) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("addressSettingsViewController")  as! AddressSettingsVCTableViewController
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    @IBAction func confirmMeetButtonTouched(sender: AnyObject) {
        self.messageType = MVMessageType.ConfirmMeet
        self.postButtonTouched(sender)
    }
    
    @IBAction func declineMeetButtonTouched(sender: AnyObject) {
        self.messageType = MVMessageType.DeclineMeet
        self.postButtonTouched(sender)
    }
    
    func shippingCodeEntered(sender : UITextField)
    {
        self.messageType = MVMessageType.ShippingCode
        self.postButtonTouched(sender)
    }
    
    func pinEntered(sender : UITextField)
    {
        self.messageType = MVMessageType.PinInput
        self.postButtonTouched(sender)
    }
    
    func trackingNumberEntered(sender : UITextField)
    {
        self.messageType = MVMessageType.TrackingCode
        self.postButtonTouched(sender)
    }
    
 
    
    // MARK: Fetch data
    func fetchData(showProgress:Bool) {
        if showProgress {
            SVProgressHUD.show()
        }
        MVDataManager.getMessageTopic(topicID, successBlock: { response in
            
            self.messagesArray = response as! [MVMessageDetails]
            
            self.chatTableView.reloadData()
            if self.messagesArray.count > 0{
                self.chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messagesArray.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
            if showProgress {
                SVProgressHUD.popActivity()
            }
            
            }) { failure in
                print("Error: \(failure)")
                SVProgressHUD.popActivity()
        }
    }
    
    func fetchUserAddress()
    {
        SVProgressHUD.show()
        MVDataManager.getUserAddress(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            self.userAddress = response as! MVUserAddress
            self.fetchData(true)
             SVProgressHUD.popActivity()
        }) { failure in
            print(failure)
             SVProgressHUD.popActivity()
        }
    }
    

    @IBAction func reviewStarButtonTouched(sender: AnyObject) {
        
        let btn : UIButton = sender as! UIButton
        print(btn.tag)

        let filledStarImage : UIImage = UIImage(named: "starFilled.png")!
        let emptyStarImage : UIImage  = UIImage(named: "starEmptyGrey.png")!

        for i : Int in 1 ..< 6 {
            let button : UIButton = self.view.viewWithTag(i) as! UIButton
            if(i < btn.tag + 1)
            {
                button.setImage(filledStarImage, forState: UIControlState.Normal)
            }
            else
            {
                button.setImage(emptyStarImage, forState: UIControlState.Normal)
            }
            
        }
        self.messageType = MVMessageType.ReviewScore
        self.postButtonTouched(sender)
    }
    
    func setMovvCodeLabel(messageDetails : MVMessageDetails, indexPath : NSIndexPath)
    {
        if(messageDetails.messageType == MVMessageType.PinOK)
        {
            self.pinOKMessageRecieved = true
        }
        
        if(self.pinOKMessageRecieved)
        {
            self.movvCodeTextField.text = "Pin OK!"
            self.movvCodeTextField.enabled = false
        }
        else if(messageDetails.messageType == MVMessageType.EnterTrackingCode)
        {
            self.movvCodeTextField.text = "Input tracking code here"
        }
        else if (messageDetails.messageType == MVMessageType.MovvPinCode)
        {
            self.movvCodeTextField.text = "Input MovCode here"
        }

        
        if(indexPath.row == self.messagesArray.count - 1 && self.movvCodeTextField.text != "")
        {
            self.movvCodeTextField.backgroundColor = UIColor.lightGrayColor()
            self.movvCodeView.backgroundColor = UIColor.lightGrayColor()
            
        }
        
        if(indexPath.row == self.messagesArray.count - 1 && self.movvCodeTextField.text == "")
        {
            self.tableViewTopConstrain.constant = -40
        }
        
        
    }
    func gotoReview() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let AddReviewVC = main.instantiateViewControllerWithIdentifier("addreviewVC")  as! AddReviewViewController
        let messageDetails : MVMessageDetails! = self.messagesArray[0]
        print(messageDetails.sentToUser.profileImage)
        self.navigationController!.pushViewController(AddReviewVC, animated: true)
    }

    

}



