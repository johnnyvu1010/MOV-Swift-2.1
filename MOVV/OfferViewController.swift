//
//  OfferViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 16/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol OfferViewDelegate {
    func offerAccepted()
}

enum OfferFilterType : String {
    case None
    case Alphabetical
    case MeetShip
    case Time
    case Price
}

class OfferViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, OfferDetailsActionDelegate, OffeerFilterHeaderDelegate {
    @IBOutlet var tableViewOffers: UITableView!

    var product : MVProduct!
    var cartOffer : MyCartOffers!
    var delegate : OfferViewDelegate!
    var productOffers : ProductOffers!
    var productMeetOffers : NSMutableArray!
    var productShipOffers : NSMutableArray!
    var productOffersByTime : NSMutableArray!
    var offerDetailsActionVC : OfferDetailsActionViewController!
    var isDetailsAdded = false
    var selectedFilter : OfferFilterType! = .Alphabetical
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = cartOffer.offerName
        loadOfferData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navbarVideo"), forBarMetrics: UIBarMetrics.Default)
        if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            addBlurEffect()
        }

        if isDetailsAdded {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.addSubview(offerDetailsActionVC.view)
            isDetailsAdded = false
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        offerDetailsActionVC?.view?.removeFromSuperview()
    }

    var visualEffectView:UIVisualEffectView?
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        //        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }


    //MARK: - Load Data
    func loadOfferData(){
        //product-offer

        let request : String! = "offers-product"
        let parameters :  NSDictionary! = ["product_id":"\(cartOffer.productId)"]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            print(response as! NSDictionary)
            self.productOffers = ProductOffers.init(serverResponse: response as! NSDictionary)
            self.productOffersByTime = NSMutableArray.init(array: self.productOffers.productOffers)
            let sortPriceDescriptor = NSSortDescriptor(key: "offerPrice", ascending: false, selector: #selector(NSString.localizedStandardCompare))
            let sortDescriptor = NSSortDescriptor(key: "offerUserFullName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
            self.productOffers.productOffers.sortUsingDescriptors([sortPriceDescriptor, sortDescriptor])
            self.tableViewOffers.reloadData()
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:"Something goes wrong. Please try again."  as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    //MARK: - UITableView Delegate & DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 +
            ((self.productOffers == nil) ? 0 :((self.productOffers.productOffers.count == 0) ? 0 : 1)) +
            ((selectedFilter == OfferFilterType.None) ? 0 : ((selectedFilter  == OfferFilterType.MeetShip) ? 2 : 0))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 1 + ((self.productOffers == nil) ? 0 :((self.productOffers.productOffers.count == 0) ? 1 : 0))}
        else if selectedFilter == OfferFilterType.MeetShip{
            if section == 1{
                let totalRow = ((productMeetOffers == nil) ? 0 : ((productMeetOffers.count == 0) ? 0 : productMeetOffers.count)) + ((productShipOffers == nil) ? 0 : ((productShipOffers.count == 0) ? 0 : productShipOffers.count))
                return totalRow
            }else{ return 0 }
        }else{
            if section == 1 {return (self.productOffers == nil) ? 0 : ((self.productOffers.productOffers.count == 0) ? 0 : self.productOffers.productOffers.count)}
            else {return 0}
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell:OfferImageTableViewCell = tableView.dequeueReusableCellWithIdentifier("OfferImageCellId", forIndexPath: indexPath) as! OfferImageTableViewCell
            cell.setupCell(product)
            return cell
        }else if  indexPath.section == 0 && indexPath.row == 1 {
            let cell:NoOfferTableViewCell = tableView.dequeueReusableCellWithIdentifier("NoOfferTableViewCell", forIndexPath: indexPath) as! NoOfferTableViewCell
            return cell
        }else if indexPath.section == 1 {
            let cell:OfferBuyerDetailsTableViewCell = tableView.dequeueReusableCellWithIdentifier("OfferBuyerDetailsCellId", forIndexPath: indexPath) as!OfferBuyerDetailsTableViewCell
            cell.setupCell(productOffers.productOffers.objectAtIndex(indexPath.row) as! ProductOffer)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let mainSt = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
            detailVC.productDetail = product
            self.navigationController!.pushViewController(detailVC, animated: true)
        }else if (self.productOffers.productOffers.count > 0){
            let main = UIStoryboard(name: "Main", bundle: nil)
            offerDetailsActionVC = main.instantiateViewControllerWithIdentifier("OfferDetailsActionViewController")  as! OfferDetailsActionViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            offerDetailsActionVC.view.translatesAutoresizingMaskIntoConstraints = true
            offerDetailsActionVC.view.frame = UIScreen.mainScreen().bounds
            offerDetailsActionVC.view.alpha = 0
            offerDetailsActionVC.delegate = self
            offerDetailsActionVC.product = product
            offerDetailsActionVC.productOffer = productOffers.productOffers.objectAtIndex(indexPath.row) as! ProductOffer
            appDelegate.window?.addSubview(offerDetailsActionVC.view)
            UIView.animateWithDuration(0.5, animations: {
                self.offerDetailsActionVC.view.alpha = 1
            })
        }
    }
    
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 200
        }else{
            return 71
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let view = NSBundle.mainBundle().loadNibNamed("OfferFilterHeaderView", owner: self, options: nil)[0] as! OfferFilterHeaderView
            view.frame = CGRectMake(0,0,60,UIScreen.mainScreen().bounds.width)
            if let filter = selectedFilter , filter == OfferFilterType.MeetShip{
                view.buttonFilter.setTitle("Categorised by Meet & Ship", forState: .Normal)
            }else if let filter = selectedFilter{
                view.buttonFilter.setTitle("Sort by \(filter.rawValue)", forState: .Normal)
            }
            view.delegate = self
            return view;
        }else{
            return UIView.init(frame: CGRectZero)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 60
        }else{
            return 0
        }
    }
    
    //Offer filter header view delegate
    func filterButtonTapped(sender: UIButton) {
        let actionSheet = UIAlertController.init(title: "Filter", message: "", preferredStyle: .ActionSheet)
        //alphabetical sort
        actionSheet.addAction(UIAlertAction(title: "Alphabetical", style: .Default, handler: { (alert) in
            self.selectedFilter = OfferFilterType.Alphabetical
            let sortPriceDescriptor = NSSortDescriptor(key: "offerPrice", ascending: false, selector: #selector(NSString.localizedStandardCompare))
            let sortDescriptor = NSSortDescriptor(key: "offerUserFullName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
            self.productOffers.productOffers.sortUsingDescriptors([sortPriceDescriptor, sortDescriptor])
            self.updateFilter()
        }))
        
        //meet and ship filter
        actionSheet.addAction(UIAlertAction(title: "Meet/Ship", style: .Default, handler: { (alert) in
            self.selectedFilter = OfferFilterType.MeetShip
            let sortPriceDescriptor = NSSortDescriptor(key: "offerPrice", ascending: false, selector: #selector(NSString.localizedStandardCompare))
            self.productOffers.productOffers.sortUsingDescriptors([sortPriceDescriptor])
            if self.productMeetOffers == nil{
                self.productMeetOffers = NSMutableArray()
            }
            if self.productShipOffers == nil{
                self.productShipOffers = NSMutableArray()
            }
            self.productShipOffers.removeAllObjects()
            self.productMeetOffers.removeAllObjects()
            if (self.productOffers != nil && self.productOffers.productOffers.count != 0){
                self.productOffers.productOffers.enumerateObjectsUsingBlock({ (obj, idx, stop) in
                    if let productoffer = obj as? ProductOffer{
                        if productoffer.offerDeliveryOption == .MeetInPerson{
                            self.productMeetOffers.addObject(productoffer)
                        }else{
                            self.productShipOffers.addObject(productoffer)
                        }
                    }
                })
            }
            self.productOffers.productOffers.removeAllObjects()
            self.productOffers.productOffers.addObjectsFromArray(self.productMeetOffers as [AnyObject])
            self.productOffers.productOffers.addObjectsFromArray(self.productShipOffers as [AnyObject])
            self.updateFilter()
        }))
        actionSheet.addAction(UIAlertAction(title: "Time", style: .Default, handler: { (alert) in
            self.selectedFilter = OfferFilterType.Time
            self.productOffers.productOffers.removeAllObjects()
            self.productOffers.productOffers.addObjectsFromArray(self.productOffersByTime as [AnyObject])
            self.updateFilter()
        }))
        actionSheet.addAction(UIAlertAction(title: "Price", style: .Default, handler: { (alert) in
            self.selectedFilter = OfferFilterType.Price
            let sortPriceDescriptor = NSSortDescriptor(key: "offerPrice", ascending: false, selector: #selector(NSString.localizedStandardCompare))
            let sortDescriptor = NSSortDescriptor(key: "offerPrice", ascending: false, selector: #selector(NSString.localizedStandardCompare))
            self.productOffers.productOffers.sortUsingDescriptors([sortPriceDescriptor, sortDescriptor])
            self.updateFilter()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alert) in
            
        }))
        self.presentViewController(actionSheet, animated: true, completion: nil);
    }
    
    func updateFilter(){
        tableViewOffers.reloadData()
    }

    //MARK: - Offer Action Delegate
    func offerActionRejected() {
        selectedFilter = OfferFilterType.Alphabetical
        loadOfferData()
    }

    func offerActionAccepted(topicid: Int, deliveryOption: DeliveryOption) {
        delegate.offerAccepted()
        //  self.navigationController?.popViewControllerAnimated(false)
        SVProgressHUD.show()
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let chatVC:ChatingViewController = mainSt.instantiateViewControllerWithIdentifier("chatVC")  as! ChatingViewController
        chatVC.product = self.product
        chatVC.topicID = topicid
        chatVC.isMeet = (cartOffer.offerDeliveryOption == DeliveryOption.MeetInPerson)
        self.navigationController!.pushViewController(chatVC, animated: true)
        self.performSelector(#selector(OfferViewController.removeThisViewController), withObject: nil, afterDelay: 0.6)
    }
    
    func removeThisViewController(){
        self.navigationController!.viewControllers.removeAtIndex(self.navigationController!.viewControllers.count-2)
    }
    
    
    func showUserProfile(product: MVProduct, productOffer: ProductOffer) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = Int(productOffer.buyerId)
        if(userProfileVC.userProfileId != MVParameters.sharedInstance.currentMVUser.id){
            isDetailsAdded = true
            self.navigationController!.pushViewController(userProfileVC, animated: true)
        }
    }
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
