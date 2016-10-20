//
//  ItemsViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 14/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking
import TwitterKit
import FBSDKShareKit
import MessageUI
import PhotosUI
import AssetsLibrary

class ItemsViewController: UIViewController, UITableViewDataSource,MFMessageComposeViewControllerDelegate, UITableViewDelegate, ItemDetailViewControllerDelegate, SharingViewControllerDelegate, TTTAttributedLabelDelegate, MOVVItemCellDelegate {
    
    var productTitle : String!
    var shareUrl : String!
    var shareImg : UIImage!
    var imgLocalPath: NSURL!
    var imageMain : UIImageView!
    var documentController : UIDocumentInteractionController!
    var docController = UIDocumentInteractionController()
    var shareVideo: NSURL? = nil
    var shareImageURLString : NSString!
    
    var blurEffect = UIBlurEffect()
    var effectView = UIVisualEffectView()
    var presentedVC = UIViewController()
    
    
    @IBOutlet var itemsTable: UITableView!
    
    var userProfile : MVUserProfile!
    var sellingArray:[MVProduct]! = [MVProduct]()
    var boughtArray:[MVActionProduct]! = [MVActionProduct]()
    var soldArray:[MVActionProduct]! = [MVActionProduct]()
    var selectedProductIndex : Int!
    var dataIsAvailable : Bool = false
    var isDoubleTapRecognized: Bool = false
    var isLikeRequestOngoing:Bool = false
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchData()
        // Do any additional setup after loading the view.
        itemsTable.addPullToRefreshAboveSegmentControlWithAction({
            NSOperationQueue().addOperationWithBlock {
                sleep(1)
                self.fetchData()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.itemsTable.stopPullToRefresh()
                }
            }
            }, withAnimator: BeatAnimator())
        self.preferredStatusBarStyle()
        
        presentedVC = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        
        
        blurEffect = UIBlurEffect(style: .Dark)
        effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = presentedVC.view.frame
        //        self.navigationController?.navigationBar.subviews[0].addSubview(effectView)
        presentedVC.view.addSubview(effectView)
        
        effectView.alpha = 0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().postNotificationName("hideTabbar", object: nil)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        
        if(MVParameters.sharedInstance.currentMVUser.id == self.userProfile.id)
        {
            self.navigationItem.title = "My Items"
        }
        else
        {
            self.navigationItem.title = "\(self.userProfile.username)'s items"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Table View Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView.tag == 0){
            if(self.dataIsAvailable)
            {
                let cell = tableView .dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! MOVVItemCell
                cell.tag = indexPath.row
                cell.delegate = self
                let product : MVProduct = self.sellingArray[indexPath.row]
                tableView.separatorColor = UIColor.clearColor()
                
                cell.itemName.text = product.name
                cell.itemImage.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                let buyButtonTitle = (product.user.id == MVParameters.sharedInstance.currentMVUser.id) ? "EDIT" : "OFFER"
                cell.homeBuyButton.setTitle(buyButtonTitle, forState: .Normal)
                cell.homeBuyButton.addTarget(self, action: #selector(ItemsViewController.buyItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.homeBuyButton.tag = indexPath.row
                cell.titleLabel.text              = product.name
                let greenBoldedFont               = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]
                let concatenatedString:String     = "@" + product.user.username + "                        "
                let string                        = concatenatedString as NSString
                let attributedString              = NSMutableAttributedString(string: string as String)
                
                attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString("@" + product.user.username))
                
                var range : NSRange!
                range                             = string.rangeOfString("@" + product.user.username)
                let url : NSURL!                  = NSURL(string: "\(product.user.id)")
                cell.usernameLabel.attributedText = attributedString
                cell.usernameLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
                cell.usernameLabel.addLinkToURL(url, withRange: range)
                cell.usernameLabel.delegate       = self
                cell.locationLabel.text           = product.user.location
                cell.userImage.setImageWithURL(NSURL(string: product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                cell.userProfileButton.tag        = indexPath.row
                cell.commentButton.tag        = indexPath.row
                cell.userProfileButton.addTarget(self, action: #selector(ItemsViewController.userProfileTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
                MVHelper.addMOVVCornerRadiusToView(cell.userImage)

                
                cell.itemDetailsButton.addTarget(self, action: #selector(ItemsViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.itemDetailsButton.tag = indexPath.row
                cell.amountLabel.text = "$\(product.price)"
                cell.commentCountLabel.text = "\(product.numComments)"
                cell.likeCountLabel.text = "\(product.numLikes)"
                cell.tagsLabel.text = product.tags
                
                cell.likeButton.addTarget(self, action: #selector(ItemsViewController.likeButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                if(product.isLiked as Bool)
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonSelectedAsset"), forState: UIControlState.Normal)
                }
                else
                {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeButtonAsset"), forState: UIControlState.Normal)
                }
                return cell
            }
            else
            {
                let cell = tableView .dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! MOVVItemCell
                return cell
            }
        }
        else if(tableView.tag == 1)
        {
            if(self.dataIsAvailable)
            {
                let cell = tableView .dequeueReusableCellWithIdentifier("boughtCell", forIndexPath: indexPath) as! MOVVItemCell
                let actionProduct : MVActionProduct = self.boughtArray[indexPath.row]
                
                cell.userImage.setImageWithURL(NSURL(string: actionProduct.product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userImage)
                cell.amountLabel.text = "$\(actionProduct.product.price)"
                
                cell.timeLabel.text = actionProduct.timestamp
                
                let formattedUsername = "@" + actionProduct.product.user.username
                let concatenatedString:String = actionProduct.product.name + " from " + formattedUsername
                
                let string = concatenatedString as NSString
                let attributedString = NSMutableAttributedString(string: string as String)
                let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(15)]
                let boldedFont = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor()]
                
                attributedString.addAttributes(boldedFont, range: string.rangeOfString(actionProduct.product.name))
                attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString(formattedUsername))
                attributedString.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor()], range: string.rangeOfString(" from "))
                
                cell.itemName.attributedText = attributedString
                
                self.addLinkToLabel(string, label: cell.itemName, user: actionProduct.product.user)
                cell.itemName.delegate = self
                cell.itemName.attributedText = attributedString
                return cell
            }
            else
            {
                let cell = tableView .dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! MOVVItemCell
                return cell
            }
        }
        else
        {
            if(self.dataIsAvailable)
            {
                let cell = tableView .dequeueReusableCellWithIdentifier("boughtCell", forIndexPath: indexPath) as! MOVVItemCell
                let actionProduct : MVActionProduct = self.soldArray[indexPath.row]
                
                cell.userImage.setImageWithURL(NSURL(string: actionProduct.actionUser.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                MVHelper.addMOVVCornerRadiusToView(cell.userImage)
                cell.amountLabel.text = "$\(actionProduct.product.price)"
                cell.timeLabel.text = actionProduct.timestamp
                let formattedUsername = "@" + actionProduct.actionUser.username
                let concatenatedString:String = actionProduct.product.name + " to " + formattedUsername
                
                let string = concatenatedString as NSString
                let attributedString = NSMutableAttributedString(string: string as String)
                let greenBoldedFont = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(15)]
                let boldedFont = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor()]
                
                attributedString.addAttributes(boldedFont, range: string.rangeOfString(actionProduct.product.name))
                attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString(formattedUsername))
                attributedString.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor()], range: string.rangeOfString(" to "))
                
                cell.itemName.attributedText = attributedString
                self.addLinkToLabel(string, label: cell.itemName, user: actionProduct.actionUser)
                cell.itemName.delegate = self
                cell.itemName.attributedText = attributedString
                return cell
            }
            else
            {
                let cell = tableView .dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath) as! MOVVItemCell
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView.tag == 0){
            return UITableViewAutomaticDimension
        } else {
            return 70
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let segmentView:FriendsSectionHeaderView = NSBundle.mainBundle().loadNibNamed("FriendsSectionHeaderView", owner: self, options: nil)[0] as! FriendsSectionHeaderView
        segmentView.segmentedControl.removeAllSegments()
        segmentView.segmentedControl.addTarget(self, action: #selector(ItemsViewController.segmentValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        segmentView.segmentedControl.insertSegmentWithTitle("Selling", atIndex: 0, animated: true)
        segmentView.segmentedControl.insertSegmentWithTitle("Bought", atIndex: 1, animated: true)
        segmentView.segmentedControl.insertSegmentWithTitle("Sold", atIndex: 2, animated: true)
        segmentView.segmentedControl.selectedSegmentIndex = tableView.tag
        segmentView.frame = CGRectMake(0, 0, tableView.frame.size.width, 48)
        return segmentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if(self.itemsTable.tag == 0)
        {
            if(self.sellingArray.count > 0)
            {
                self.dataIsAvailable = true
            }
            else
            {
                self.dataIsAvailable = false
            }
            
            if(self.dataIsAvailable)
            {
                return  self.sellingArray.count
            }
            else
            {
                return 1
            }
        }
            
        else if (self.itemsTable.tag == 1)
        {
            if(self.boughtArray.count > 0)
            {
                self.dataIsAvailable = true
            }
            else
            {
                self.dataIsAvailable = false
            }
            if(self.dataIsAvailable)
            {
                return  self.boughtArray.count
            }
            else
            {
                return 1
            }
        }
        else if (self.itemsTable.tag == 2)
        {
            if(self.soldArray.count > 0)
            {
                self.dataIsAvailable = true
            }
            else
            {
                self.dataIsAvailable = false
            }
            if(self.dataIsAvailable)
            {
                return  self.soldArray.count
            }
            else
            {
                return 1
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(tableView.tag > 0){
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(tableView.tag == 0)
        {
            if(self.dataIsAvailable){
                
            }
            else{
                
            }
        }
        else if(tableView.tag == 1)

        {
            if(self.dataIsAvailable){
                let mainSt = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                detailVC.productDetail = self.boughtArray[indexPath.row].product
                self.navigationController!.pushViewController(detailVC, animated: true)
            }
            else{
                
            }
            
        } else {
            if(self.dataIsAvailable){
                let mainSt = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                detailVC.productDetail = self.soldArray[indexPath.row].product
                self.navigationController!.pushViewController(detailVC, animated: true)
            }
            else{
                
            }
        }
        
    }
    
    //MARK: ItemDetailViewController Delegate
    func productLikeStateChanged(product : MVProduct)
    {
        if(self.itemsTable.tag == 0)
        {
            self.sellingArray[self.selectedProductIndex].isLiked = product.isLiked
        }
        self.itemsTable.reloadData()
    }
    
    //MARK: Fetch logic
    func fetchData()
    {
        SVProgressHUD.show()
        MVDataManager.getUserSellingProducts(self.userProfile, successBlock: { response in
            
            self.sellingArray = response as! [MVProduct]
            self.itemsTable.reloadData()
            SVProgressHUD.popActivity()
            
        }) { failure in
            
            SVProgressHUD.popActivity()
            print(failure)
            
        }
        
        MVDataManager.getUserBoughtProducts(self.userProfile, successBlock: { response in
            
            self.boughtArray = response as! [MVActionProduct]
            
            }) { failure in
                
                print(failure)
                
        }
        
        MVDataManager.getUserSoldProducts(self.userProfile, successBlock: { response in
            
            self.soldArray = response as! [MVActionProduct]

            }) { failure in
                
                print(failure)
                
        }
    }
    

    //MARK: Action methods
    
    func showDetails(sender:UIButton){
        let product : MVProduct! = self.sellingArray[sender.tag];
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mixpanel?.track("Comment", properties: ["item" : product.name])
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        detailVC.productDetail = product
//        detailVC.delegate = self
        self.selectedProductIndex = sender.tag
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func likeButtonTouched(sender:UIButton) {
        let btn : UIButton = sender
        let product : MVProduct = self.sellingArray![sender.tag]
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.isLikeRequestOngoing = true
        MVDataManager.likeProduct(product.id, successBlock: { response in
            self.isLikeRequestOngoing = false
            if(product.isLiked as Bool)
            {
                appDelegate.mixpanel?.track("Unlike",properties: ["item": product.name])
                btn.setBackgroundImage(UIImage(named: "likeButton.png"), forState: UIControlState.Normal)
                self.sellingArray![sender.tag].isLiked = false
                self.sellingArray![sender.tag].numLikes = self.sellingArray![sender.tag].numLikes - 1
            }
            else
            {
                appDelegate.mixpanel?.track("Like",properties: ["item": product.name])
                btn.setBackgroundImage(UIImage(named: "likeButton_selected.png"), forState: UIControlState.Normal)
                self.sellingArray![sender.tag].isLiked = true
                self.sellingArray![sender.tag].numLikes = self.sellingArray![sender.tag].numLikes + 1
            }
            
            self.itemsTable.reloadData()
            
            }) { failure in
                self.isLikeRequestOngoing = false
                print(failure)
                
        }
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl)
    {
        self.itemsTable.tag = sender.selectedSegmentIndex
        let indexSet = NSIndexSet(index: 0)
        self.itemsTable.reloadSections(indexSet, withRowAnimation: .Fade)
    }
    
    //MARK: Screen setup
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    //MARK: TTTAttributedLabel Delegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = ("\(url)" as NSString).integerValue
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    func addLinkToLabel(linkString:NSString,label:TTTAttributedLabel, user:MVUser){
        let range : NSRange = linkString.rangeOfString("@" + user.username)
        let url : NSURL! = NSURL(string: "\(user.id)")
        label.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
        label.addLinkToURL(url, withRange: range)
    }
    
    
    // MARK: Delegate
    func onTouchShareButton(cell: UITableViewCell) {
        
        addBlur()
        
        let product: MVProduct = sellingArray![self.itemsTable.indexPathForCell(cell)!.row]
        let mainSt                = UIStoryboard(name: "Main", bundle: nil)
        let sharingVC              = mainSt.instantiateViewControllerWithIdentifier("SharingVC")  as! SharingViewController
        sharingVC.delegate = self
        self.productTitle = product.name
        self.shareUrl = product.shareLink
        self.shareVideo = NSURL(string: product.videoFile)
        self.shareImageURLString = product.previewImage
        self.presentViewController(sharingVC, animated: true, completion: nil)
    }
    
    func onTouchOfferButton(cell: UITableViewCell) {
        if let viewController = MVEditProductViewController(nibName: "MVEditProductViewController", bundle: nil) as? MVEditProductViewController
        {
            let navigationController = UINavigationController(rootViewController: viewController)
            viewController.item = sellingArray[itemsTable.indexPathForCell(cell)!.row]
            navigationController.modalPresentationStyle = .OverCurrentContext
            viewController.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    func userProfileTouched(sender:UIButton)
    {
        //        self.tableView.frame                = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height - 20)
        let main                            = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC                   = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId         = sellingArray![sender.tag].user.id
        self.navigationItem.hidesBackButton = false
        
        
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    func buyItem(sender : UIButton)
    {
//        let btn : UIButton! = sender
//        let productDetail : MVProduct! = self.sellingArray![btn.tag]
//        let mainSt = UIStoryboard(name: "Main", bundle: nil)
//        
//        let cardInfoVC:MVVenmoPaymentViewController = mainSt.instantiateViewControllerWithIdentifier("venmoPaymentViewController")  as! MVVenmoPaymentViewController
//        cardInfoVC.itemPrice = productDetail.price
//        cardInfoVC.product = productDetail
//        NSNotificationCenter.defaultCenter().postNotification(hideTabbarNotification)
//        self.navigationController!.pushViewController(cardInfoVC, animated: true)
        let btn : UIButton! = sender
        let productDetail : MVProduct! = self.sellingArray![btn.tag]
        if (productDetail.user.id == MVParameters.sharedInstance.currentMVUser.id){
            if let viewController = MVEditProductViewController(nibName: "MVEditProductViewController", bundle: nil) as? MVEditProductViewController
            {
                let navigationController = UINavigationController(rootViewController: viewController)
                viewController.item = productDetail
                navigationController.modalPresentationStyle = .OverCurrentContext
                viewController.modalPresentationStyle = .OverCurrentContext
                self.presentViewController(navigationController, animated: true, completion: nil)
            }
        }else{
            let main = UIStoryboard(name: "Main", bundle: nil)
            offerPriceVC = main.instantiateViewControllerWithIdentifier("OfferPriceViewController")  as! OfferPriceViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            offerPriceVC.view.translatesAutoresizingMaskIntoConstraints = true
            offerPriceVC.view.frame = UIScreen.mainScreen().bounds
            offerPriceVC.view.alpha = 0;
            offerPriceVC.product = self.sellingArray![btn.tag]
            appDelegate.window?.addSubview(offerPriceVC.view)
            UIView.animateWithDuration(0.3) {
                offerPriceVC.view.alpha = 1;
            }
        }
        
    }

    func tapGestureLikeRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Recognized && itemsTable.tag == 0 && !isLikeRequestOngoing{
            self.isDoubleTapRecognized = true
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let product : MVProduct   = sellingArray![sender.view!.tag]
            let cell = itemsTable.cellForRowAtIndexPath(NSIndexPath(forRow: sender.view!.tag, inSection: 0)) as! MOVVItemCell
            if !(product.isLiked as Bool){
                isLikeRequestOngoing = true
                MVDataManager.likeProduct(product.id, successBlock: { response in
                    self.isLikeRequestOngoing = false
                    appDelegate.mixpanel?.track("Like",properties: ["item": product.name])
                    cell.likeButton.setImage(UIImage(named: "likeButtonSelectedAssets"), forState: UIControlState.Normal)
                    self.sellingArray![sender.view!.tag].isLiked  = true
                    self.sellingArray![sender.view!.tag].numLikes = self.sellingArray![sender.view!.tag].numLikes + 1
                    self.itemsTable.reloadData()
                }) { failure in
                    self.isLikeRequestOngoing = false
                    print(failure)
                }
            }
            let point = sender.locationInView(sender.view)
            let likeImage = UIImageView(frame: CGRectMake(point.x-50, point.y-50, 100, 100))
            likeImage.contentMode = .ScaleAspectFill
            likeImage.sd_setImageWithURL(NSBundle.mainBundle().URLForResource("Liked", withExtension: "gif"))
            let width = UIScreen.mainScreen().bounds.width
            likeImage.transform = CGAffineTransformMakeRotation((point.x < (width/2-30)) ? -0.8 : (point.x > (width/2+30)) ? 0.8 : 0)
            sender.view!.addSubview(likeImage)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.isDoubleTapRecognized = false
                likeImage.removeFromSuperview()
            })
        }
    }
    
    func tapGestureShowDetailsRecognizer(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Recognized && itemsTable.tag == 0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                if !self.isDoubleTapRecognized{
                    let product : MVProduct! = self.sellingArray![sender.view!.tag];
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.mixpanel?.track("Comment", properties: ["item" : product.name])
                    let mainSt                = UIStoryboard(name: "Main", bundle: nil)
                    let detailVC              = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                    self.selectedProductIndex = sender.view!.tag
                    detailVC.productDetail    = product
                    self.navigationController!.pushViewController(detailVC, animated: true)
                }
            }
        }
    }


    func likeCountTapped(tag: Int) {
        let product = self.sellingArray[tag]
        self.navigationController?.pushViewController(MVLikesViewController.getLikeViewController(product), animated: true)
    }
    
    // Mark SharingViewControllerDelegate
    func addBlur() {
        UIView.animateWithDuration(0.8) {
            self.effectView.alpha = 1.0
        }
    }
    
    // Cancel
    func dismissViewCon(viewCon: SharingViewController) {
        viewCon.dismissViewControllerAnimated(true, completion: nil)
        
        removeBlur()
    }
    func removeBlur() {
        UIView.animateWithDuration(0.8) {
            self.effectView.alpha = 0.0
            
        }
    }
    
    
    
    // Copy Share Link Part
    func copysharelink(viewCon: SharingViewController) {
        removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.donecopysharelink()
        })
    }
    func donecopysharelink() {
        let pasteboard : UIPasteboard! = UIPasteboard.generalPasteboard()
        if(self.shareUrl != nil)
        {
            pasteboard.URL = NSURL(string: "\(shareUrl)")!
            let alertView : UIAlertController = UIAlertController(title: "", message: "Share URL is copied to clipoard!", preferredStyle: UIAlertControllerStyle.Alert)
            let action : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertView.addAction(action)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    // Instagram Share
    func sharetoinstagram(viewCon: SharingViewController) {
        removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
//            self.doneinstagram()
            self.downloadVideo()
        })
    }
    func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        return documentsFolderPath
    }
    
    func downloadVideo() {
        SVProgressHUD.show()
        let request = NSURLRequest.init(URL:self.shareVideo!)
        let operation = AFHTTPRequestOperation.init(request: request)
        let title = productTitle.componentsSeparatedByString(" ").joinWithSeparator("")
        let path = self.documentsDirectory().stringByAppendingString("/\(title).mp4")
        operation.outputStream = NSOutputStream.init(toFileAtPath: path, append: false)
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) in
            print("success")
            let fileURL = NSURL(fileURLWithPath: path)
            
            let composition = AVMutableComposition()
            let vidAsset = AVURLAsset(URL: fileURL, options: nil)
            
            // get video track
            let vtrack =  vidAsset.tracksWithMediaType(AVMediaTypeVideo)
            let videoTrack:AVAssetTrack = vtrack[0]
            let vid_duration = videoTrack.timeRange.duration
            let vid_timerange = CMTimeRangeMake(kCMTimeZero, vidAsset.duration)
            
            do {
                let compositionvideoTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
                try compositionvideoTrack.insertTimeRange(vid_timerange, ofTrack: videoTrack, atTime: kCMTimeZero)
                compositionvideoTrack.preferredTransform = videoTrack.preferredTransform
                
                // get audio track
                let clipAudioTrack = vidAsset.tracksWithMediaType(AVMediaTypeAudio)[0]
                let compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
                try  compositionAudioTrack.insertTimeRange(vid_timerange, ofTrack: clipAudioTrack, atTime: kCMTimeZero)
                
            } catch {
                print(error)
            }
            
            
            // Watermark Effect
            let size = videoTrack.naturalSize
            //            var size = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform)
            //            size = CGSizeMake(fabs(size.width), fabs(size.height))
            
            let imglogo = UIImage(named: "watermark.png")
            let imglayer = CALayer()
            imglayer.contents = imglogo?.CGImage
            imglayer.frame = CGRectMake(20, size.height - imglogo!.size.height - 20, imglogo!.size.width, imglogo!.size.height)
            //            imglayer.opacity = 0.6
            
            let videolayer = CALayer()
            videolayer.frame = CGRectMake(0, 0, size.width, size.height)
            
            let parentlayer = CALayer()
            parentlayer.frame = CGRectMake(0, 0, size.width, size.height)
            parentlayer.addSublayer(videolayer)
            parentlayer.addSublayer(imglayer)
            
            let layercomposition = AVMutableVideoComposition()
            layercomposition.frameDuration = CMTimeMake(1, 30)
            layercomposition.renderSize = size
            layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, inLayer: parentlayer)
            
            // instruction for watermark
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
            let videotrack = composition.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
            let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
            
            //            layerinstruction.setTransform(CGAffineTransformMakeRotation(90), atTime: vid_duration)
            
            //            let t1 = CGAffineTransformMakeTranslation(0, 0);
            //            let t2 = CGAffineTransformRotate(t1, CGFloat(M_PI_2));
            //
            //            layerinstruction.setTransform(t2, atTime: kCMTimeZero)
            //            layerinstruction.setOpacity(0.0, atTime: vid_duration)
            //            instruction.layerInstructions = [layerinstruction]
            //            layercomposition.instructions = [instruction]
            
            
            //            var videoAssetOrientation = UIImageOrientation.Up
            //            var isVideoAssetPortrait = false
            //            let videoTransform = videotrack.preferredTransform
            //
            //            if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)
            //            {
            //                videoAssetOrientation = UIImageOrientation.Right
            //                isVideoAssetPortrait = true
            //            }
            //            if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)
            //            {
            //                videoAssetOrientation =  UIImageOrientation.Left
            //                isVideoAssetPortrait = true
            //            }
            //            if(videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)
            //            {
            //                videoAssetOrientation =  UIImageOrientation.Up
            //            }
            //            if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0)
            //            {
            //                videoAssetOrientation = UIImageOrientation.Down
            //            }
            //
            //            var FirstAssetScaleToFitRatio = 320.0 / videotrack.naturalSize.width
            //
            //
            //
            //            if(isVideoAssetPortrait) {
            //                FirstAssetScaleToFitRatio = 320.0/videotrack.naturalSize.height
            //
            //                let FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio)
            //                layerinstruction.setTransform(CGAffineTransformConcat(videotrack.preferredTransform, FirstAssetScaleFactor), atTime: kCMTimeZero)
            //
            //            }else{
            //                let FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio)
            //                layerinstruction.setTransform(CGAffineTransformConcat(CGAffineTransformConcat(videotrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 320)), atTime: kCMTimeZero)
            //            }
            //            layerinstruction.setOpacity(0.0, atTime: vid_duration)
            //
            
            instruction.layerInstructions = NSArray(object: layerinstruction) as! [AVVideoCompositionLayerInstruction]
            layercomposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
            
            
            
            //  create new file to receive data
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir: AnyObject = dirPaths[0]
            let movieFilePath = docsDir.stringByAppendingPathComponent("result.mp4")
            let movieDestinationUrl = NSURL(fileURLWithPath: movieFilePath)
            
            _ = try? NSFileManager().removeItemAtURL(movieDestinationUrl)
            
            // use AVAssetExportSession to export video
            let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality)
            assetExport!.outputFileType = AVFileTypeMPEG4
            assetExport!.outputURL = movieDestinationUrl
            assetExport?.videoComposition = layercomposition
            assetExport!.exportAsynchronouslyWithCompletionHandler({
                switch assetExport!.status{
                case  AVAssetExportSessionStatus.Failed:
                    print("failed \(assetExport!.error)")
                case AVAssetExportSessionStatus.Cancelled:
                    print("cancelled \(assetExport!.error)")
                default:
                    print("Movie complete")
                    ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(movieDestinationUrl, completionBlock: nil)
                }
            })
            //            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(NSURL.init(string: path), completionBlock: nil)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
                SVProgressHUD.popActivity()
                self.doneinstagram()
            }
        }) { (operation, error) in
            SVProgressHUD.popActivity()
            print("failed")
        }
        operation.start()
    }
    
    func doneinstagram() {
        if self.shareVideo!.isValid() {
            UIPasteboard.generalPasteboard().string = "Hey guys! \nCheck out this \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)"
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:false)]
            let fetchResult = PHAsset.fetchAssetsWithMediaType(.Video, options: fetchOptions)
            if let lastAsset = fetchResult.firstObject as? PHAsset {
                let url = NSURL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")
                if UIApplication.sharedApplication().canOpenURL(url!) {
                    UIApplication.sharedApplication().openURL(url!)
                }
            }
        } else {
            let alert: MOVVAlertViewController = MOVVAlertViewController(title: "Instagram not installed", message: "Please install instagram application for this feature", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("no instagram found")
        }
    }
    
    func downloadImage(urlString:String, shareImage:(UIImage)->Void){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            dispatch_async(dispatch_get_main_queue(), {
                SVProgressHUD.show()
            })
            let url = NSURL(string: urlString)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            let img = UIImage(data: data!)
            
            let rect = CGRect(x: 0, y: 0, width: img!.size.width, height: img!.size.height)
            
            UIGraphicsBeginImageContextWithOptions(img!.size, true, 0)
            let context = UIGraphicsGetCurrentContext()
            
            CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextFillRect(context, rect)
            
            img!.drawInRect(rect, blendMode: .Normal, alpha: 1)
            let watermark = UIImage(named: "watermark.png")
            
            watermark!.drawInRect(CGRectMake(20,20,watermark!.size.width,watermark!.size.height), blendMode: .Normal, alpha: 1)
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            dispatch_async(dispatch_get_main_queue(), {
                SVProgressHUD.dismiss()
                shareImage(result)
            })
            
        }
    }
    
    //Twitter Share
    func sharetotwitter(viewCon: SharingViewController) {
        self.removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadImage(self.shareImageURLString as String) { result in
                self.shareImg = result
                self.donetwitter()
            }
        })
    }
    func donetwitter() {
        let composer = TWTRComposer()
        composer.setText("Hey guys! \nCheck out \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)")
        if let image = self.shareImg{
            composer.setImage(image)
        }
        composer.showFromViewController(self) { (result) in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
        }
        
    }
    
    //Facebook Share
    func sharetofacebook(viewCon: SharingViewController) {
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadImage(self.shareImageURLString as String) { result in
                self.shareImg = result
                self.donefacebook()
            }
        })
    }
    func donefacebook() {
        print("Facebook sharing")
        let content = FBSDKShareLinkContent()
        content.contentTitle = "\(self.productTitle)"
        content.contentDescription = "Hey guys! \nCheck out \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)"
        content.contentURL = NSURL(string: shareUrl)
        
        let dialog = FBSDKShareDialog.init()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = .Automatic
        dialog.show()
    }
    
    //Message Share
    func sharetomessage(viewCon: SharingViewController) {
        self.removeBlur()
        viewCon.dismissViewControllerAnimated(true, completion: {
            self.downloadImage(self.shareImageURLString as String) { result in
                self.shareImg = result
                self.donemessage()
            }
        })
    }
    func donemessage() {
        UINavigationBar.appearance().barTintColor = UIColor.greenAppColor()
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hey guys! \nCheck out \(self.productTitle) on Mov. Watch the full video here! \n\(shareUrl)"
            if let image = self.shareImg{
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                controller.addAttachmentData(imageData!, typeIdentifier: "image/jpeg", filename: "\(self.productTitle).jpeg")
            }
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Report
    func report(viewCon: SharingViewController) {
        viewCon.dismissViewControllerAnimated(true, completion: nil)
        removeBlur()
        donereport(viewCon.product)
    }
    func donereport(product:MVProduct) {
        let request : String! = "product-report"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)",
                                           "product_id":"\(product.id)"]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            UIAlertView(title: "Thank you for reporting!", message: "We investigate every report.", delegate: self, cancelButtonTitle: "Ok").show()
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:failure, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: {
            })
        }
    }
    
}
