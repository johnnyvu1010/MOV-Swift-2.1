//
//  ChatingViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 25/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChatingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShipActionDelegate, PaymentControllerDelegate, ReviewControllerDelegate {

    @IBOutlet weak var tableViewChating: UITableView!
    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var labelProductPrice: UILabel!
    
    @IBOutlet weak var viewMovCode: UIView!
    @IBOutlet weak var viewSendMessage: UIView!
    @IBOutlet weak var textFieldMessage: UITextField!
    @IBOutlet weak var textFieldMovCode: UITextField!
    @IBOutlet weak var buttonSendMessage: UIButton!
    @IBOutlet weak var constraintBottomMessageView: NSLayoutConstraint!
    @IBOutlet weak var constraintMovCodeViewHeight: NSLayoutConstraint!
    
    var topicID : Int!
    var nonce:String!
    var isMeet : Bool!
    var product : MVProduct!
    var messageList : [MVMessageDetails]! = [MVMessageDetails]()
    var shadowImage:UIImage!
    var paymentNVC:UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowImage = self.navigationController!.navigationBar.shadowImage
        imageViewProduct.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: .Gray)
        self.title = product.name
        labelProductName.text = product.name
        labelProductPrice.text = "$ \(product.price)"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatingViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatingViewController.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        self.tableViewChating.estimatedRowHeight = 150
        self.tableViewChating.rowHeight = UITableViewAutomaticDimension
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        self.fetchData(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("hideTabbar", object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            addBlurEffect()
        }
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    var visualEffectView:UIVisualEffectView?
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBar.shadowImage = shadowImage
    }
    
    //MARK: - Keyboard Notification
    func keyboardWillHide(notification : NSNotification){
        if textFieldMessage.isFirstResponder() {
            let duration:NSTimeInterval = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            self.view.layoutIfNeeded()
            constraintBottomMessageView.constant = 0
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(duration)
            self.view.layoutIfNeeded()
            UIView.commitAnimations()
            self.moveToLastRow()
        }
    }
    
    func keyboardWillChange(notification : NSNotification){
        if textFieldMessage.isFirstResponder() {
            let keyboardSize:CGSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
            let duration:NSTimeInterval = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            self.view.layoutIfNeeded()
            constraintBottomMessageView.constant = keyboardSize.height
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(duration)
            self.view.layoutIfNeeded()
            UIView.commitAnimations()
            self.moveToLastRow()
        }
    }
    
    
    
    //MARK: - UITableView Delegate+DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count + Int(!self.isNoActionTaken() && self.isKeepReturnReceived())
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < messageList.count{
            let message = messageList[indexPath.row]
            if message.messageType == MVMessageType.Text {
                if message.sentFromUser.id == MVParameters.sharedInstance.currentMVUser.id{
                    let cell = tableViewChating.dequeueReusableCellWithIdentifier(BuyerSellerChatTableViewCell.sellerIdentifier(), forIndexPath: indexPath) as! BuyerSellerChatTableViewCell
                    cell.configCellWithTextMessage(message)
                    cell.delegate = self
                    return cell
                }else{
                    let cell = tableViewChating.dequeueReusableCellWithIdentifier(BuyerSellerChatTableViewCell.buyerIdentifier(), forIndexPath: indexPath) as! BuyerSellerChatTableViewCell
                    cell.configCellWithTextMessage(message)
                    cell.delegate = self
                    return cell
                }
            }
            else{
                let cell = tableViewChating.dequeueReusableCellWithIdentifier(BuyerSellerChatTableViewCell.movIdentifer(), forIndexPath: indexPath) as! BuyerSellerChatTableViewCell
                cell.configCellWithTextMessage(message)
                cell.delegate = self
                return cell
            }
        }else if (!self.isNoActionTaken() && self.isKeepReturnReceived()){
            let cell = tableViewChating.dequeueReusableCellWithIdentifier(BuyerSellerChatTableViewCell.shipActionIdentifer(), forIndexPath: indexPath) as! BuyerSellerChatTableViewCell
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < messageList.count{
            let message = messageList[indexPath.row]
            if message.messageType == MVMessageType.Review{
                self.gotoReview()
            }else{
                if message.message.length > 25{
                    let urlString = message.message.substringFromIndex(message.message.startIndex.advancedBy(21));
                    if let url = NSURL(string: urlString) where (UIApplication.sharedApplication().canOpenURL(url)){
                        UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
                    }
                }
            }
        }
    }
    
    //MARK:- Messages Cell Delegate
    func shipActionKeep() {
        self.shipAction(true)
    }
    
    func shipActionReturn() {
        self.paymentDetailsWithCustomUI()
    }
    
    func userProfileTappedAction(cell: BuyerSellerChatTableViewCell) {
        if let row = tableViewChating.indexPathForCell(cell)?.row where row < messageList.count{
            let message = messageList[row]
            let main = UIStoryboard(name: "Main", bundle: nil)
            let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
            userProfileVC.userProfileId = message.sentFromUser.id
            self.navigationItem.hidesBackButton = false
            self.navigationController!.pushViewController(userProfileVC, animated: true)
        }
    }
    
    //MARK:- Review Delegate
    func reviewSuccess() {
        self.fetchData(true)
    }
    
    // MARK: - Fetch data
    func fetchData(showProgress:Bool) {
        if showProgress {
            SVProgressHUD.show()
        }
        MVDataManager.getMessageTopic(topicID, successBlock: { response in
            self.messageList = response as! [MVMessageDetails]
            if !self.isPinCodeEntered() && self.isMeet{
                self.textFieldMovCode?.placeholder = "Type MovCode..."
            }else{
                self.dismissMovCodeView()
            }
            if showProgress {
                SVProgressHUD.dismiss()
            }
            self.tableViewChating.reloadData()
            self.moveToLastRow()
        }) { failure in
            print("Error: \(failure)")
            if showProgress {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func moveToLastRow(){
        if self.messageList.count > 0{
            self.tableViewChating.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messageList.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    func shipAction(keep:Bool){
        let request : String! = "offers-return/"
        let parameters :  NSDictionary! = ["offer_id":"\(product.topicId)",
                                           "user_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "option":(keep) ? "keep" : "return",
                                           "nonce":(self.nonce == nil) ? "" : self.nonce]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:response.valueForKey("message") as? String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                })
            self.presentViewController(alert, animated: true, completion: {
                self.fetchData(true)
            })
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:failure  as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK:- Send Message
    @IBAction func buttonSendMessageTapped(sender: UIButton) {
        self.sendMessage(MVMessageType.Text, message: "\(self.textFieldMessage.text!)")
    }
    
    @IBAction func buttonSendMovCodeTapped(sender: UIButton) {
        self.sendMessage(MVMessageType.PinInput, message: "\(self.textFieldMovCode.text!)")
    }
    
    func sendMessage(messageType:MVMessageType, message:String)  {
        SVProgressHUD.show()
        MVDataManager.sendMessage(MVParameters.sharedInstance.currentMVUser.id, topicID: topicID, message: message, messageType : messageType.rawValue,successBlock: { response in
            self.textFieldMessage.text = ""
            self.textFieldMovCode.text = ""
            self.fetchData(true)
            if (self.isPinCodeEntered()){
                self.dismissMovCodeView()
            }
            self.moveToLastRow()
            SVProgressHUD.popActivity()
        }) { failure in
            print("Error: \(failure)")
            SVProgressHUD.popActivity()
        }
    }
    
    func dismissMovCodeView(){
        constraintMovCodeViewHeight.constant = 0
        self.viewMovCode.hidden = true
        self.navigationController!.navigationBar.shadowImage = shadowImage
    }
    
    //MARK: - Check
    func isPinCodeEntered()->Bool{
        for message in self.messageList{
            if (message.messageType == MVMessageType.PinOK){
                return true
            }
        }
        return false
    }
    
    func isReviewMessageReceived()->Bool{
        for message in self.messageList{
            if message.messageType == MVMessageType.Review {
                return true
            }
        }
        return false
    }
    
    func isKeepReturnReceived()->Bool{
        for message in self.messageList{
            if message.messageType == MVMessageType.KeepReturn{
                return true
            }
        }
        return false
    }
    
    func isNoActionTaken()->Bool{
        var isItemKeeped = false
        var isItemReturned = false
        for message in self.messageList{
            if message.messageType == MVMessageType.ItemKeep{
                isItemKeeped = true
            }
            if message.messageType == MVMessageType.ItemReturn{
                isItemReturned = true
            }
            if (isItemReturned || isItemKeeped){
                return false
            }
        }
        return false
    }
    
    // MARK: - Navigation
    func gotoReview() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let addReviewVC = main.instantiateViewControllerWithIdentifier("addreviewVC")  as! AddReviewViewController
        addReviewVC.delegate = self
        addReviewVC.topicId = "\(self.topicID)"
        let messageDetails : MVMessageDetails! = self.messageList[0]
        if (messageDetails.sentToUser.id == MVParameters.sharedInstance.currentMVUser.id){
            addReviewVC.reviewToUser = messageDetails.sentFromUser
        }else{
            addReviewVC.reviewToUser = messageDetails.sentToUser
        }
        self.navigationController!.pushViewController(addReviewVC, animated: true)
    }
    
    //MARK: - Payment
    func paymentDetailsWithCustomUI(){
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let paymentVC = mainSt.instantiateViewControllerWithIdentifier("PaymentViewController")  as! PaymentViewController
        paymentVC.delegate = self
        paymentNVC = UINavigationController(rootViewController: paymentVC)
        paymentNVC.title = "Payment"
        paymentNVC.navigationBar.tintColor = UIColor.whiteColor()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelButtonTapped))
        paymentVC.navigationItem.setRightBarButtonItem(cancelButton, animated: true)
        paymentNVC.navigationBar.barTintColor = UIColor(red: 70.0/255, green: 213.0/255, blue: 39.0/255, alpha: 1)
        self.presentViewController(paymentNVC, animated: true, completion: nil)
    }
    
    func cancelButtonTapped(){
        paymentNVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func paymentFailed() {
        let alert:UIAlertController = UIAlertController.init(title: "", message:"Something goes wrong. Please try again."  as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
            });
        self.presentViewController(alert, animated: true, completion: {
        })
        paymentNVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func paymentSuccess(nonce: String) {
        self.nonce = nonce
        paymentNVC.dismissViewControllerAnimated(true, completion: nil)
        self.shipAction(false)
    }
}
