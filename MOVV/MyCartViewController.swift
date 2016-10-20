 //
//  MyCartViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 17/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class MyCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferViewDelegate {

    //MARK: - IBOutlet
    @IBOutlet var tableViewCart: UITableView!
    @IBOutlet var segmentCartOption: UISegmentedControl!
    
    //MARK: - Variables
    var minNoVisibleRow = 3
    
    
    var allBuyPendingVisiable:Bool = false
    var allBuyAcceptedVisiable:Bool = false
    var allSellPendingVisiable:Bool = false
    var allSellAcceptedVisiable:Bool = false
    
    var buyPendingProductList:NSMutableArray = NSMutableArray()
    var buyAcceptedProductList:NSMutableArray = NSMutableArray()
    var sellPendingProductList:NSMutableArray = NSMutableArray()
    var sellAcceptedProductList:NSMutableArray = NSMutableArray()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My cart"
        tableViewCart.sectionHeaderHeight = 30
        allBuyPendingVisiable = true
        allSellPendingVisiable = true
        loadBuyProductList()
        loadSellProductList()
        loadSoldProductList()
        segmentCartOption.selectedSegmentIndex = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            addBlurEffect()
        }
    }
    
    var visualEffectView:UIVisualEffectView?
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }
    
    //MARK: - Load Cart Data
    func loadBuyProductList(){
        let request : String! = "offers-users"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "status":"pending,accepted,rejected"]
        SVProgressHUD.show()
        buyPendingProductList.removeAllObjects()
        buyAcceptedProductList.removeAllObjects()
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            let offers:NSArray = response.valueForKey("offers") as! NSArray
            offers.enumerateObjectsUsingBlock({ (offerObj, idx, stop) in
                let myCartOffer:MyCartOffers = MyCartOffers.init(serverResponse: offerObj as! NSDictionary)
                if  myCartOffer.offerStatus.lowercaseString == "pending"{
                    self.buyPendingProductList.addObject(myCartOffer)
                }else{
                    self.buyAcceptedProductList.addObject(myCartOffer)
                }
            })
            self.buyAcceptedProductList.sortUsingDescriptors([NSSortDescriptor(key: "unreadMsgCount", ascending: false)])
            self.tableViewCart.reloadData()
        }) { failure in
            SVProgressHUD.popActivity()
        }
    }
    
    func loadSellProductList(){
        let request : String! = "offers-offered"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)"]
        SVProgressHUD.show()
        sellPendingProductList.removeAllObjects()
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            let offers:NSArray = response.valueForKey("offered_products") as! NSArray
            offers.enumerateObjectsUsingBlock({ (offerObj, idx, stop) in
                let myCartOffer:MyCartOffers = MyCartOffers.init(serverResponse: offerObj as! NSDictionary)
                self.sellPendingProductList.addObject(myCartOffer)
            })
            self.tableViewCart.reloadData()
        }) { failure in
            SVProgressHUD.popActivity()
        }
    }
    
    func loadSoldProductList() {
        let request : String! = "user-sold"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)", "thumb":"128x128"]
        SVProgressHUD.show()
        sellAcceptedProductList.removeAllObjects()
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
            if(productsArray.count > 0){
                for i :Int in 0 ..< productsArray.count{
                    let actionProduct : MVActionProduct = MVActionProduct(dictionary: productsArray[i]  as! NSDictionary)
                    self.sellAcceptedProductList.addObject(actionProduct)
                }
            }
            self.tableViewCart.reloadData()
        }) { failure in
            SVProgressHUD.popActivity()
        }
    }
    
    func showCommonErrorMessage(){
        let alert:UIAlertController = UIAlertController.init(title: "", message:"Something goes wrong. Please try again."  as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in});
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView DataSource and Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRow:Int;
        if segmentCartOption.selectedSegmentIndex == 0
        {
            if section == 0
            {
                numberOfRow = buyPendingProductList.count
            }
            else
            {
                numberOfRow = ((buyAcceptedProductList.count <= minNoVisibleRow || allBuyAcceptedVisiable) ? buyAcceptedProductList.count + Int(allBuyAcceptedVisiable) : self.getVisibleRows()  + 1 )
            }
        }else{
            numberOfRow = section == 0 ? sellPendingProductList.count  : ((sellAcceptedProductList.count <= minNoVisibleRow || allSellAcceptedVisiable) ? sellAcceptedProductList.count + Int(allSellAcceptedVisiable) : minNoVisibleRow + 1 )
        }
        return (numberOfRow == 0) ? 1 : numberOfRow;
    }
    
    func getVisibleRows() -> NSInteger
    {
        var count = 0
        for offerObj in buyAcceptedProductList {
            if let offer = offerObj as? MyCartOffers{
                if offer.unreadMsgCount.integerValue > 0 && offer.offerStatus.lowercaseString == "accepted"{
                    count = count + 1
                }
            }
        }
        if count < 3{
            return minNoVisibleRow
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if self.isLastRow(indexPath) {
                let cell = tableView.dequeueReusableCellWithIdentifier("MyCartMoreItemsCellId", forIndexPath: indexPath) as! MyCartMoreItemsTableViewCell
                cell.labelTitle.text = self.getTitleForLastRow(indexPath)
                return cell;
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("LiveProductCellId", forIndexPath: indexPath) as! LiveProductTableViewCell
                if segmentCartOption.selectedSegmentIndex == 0{
                    cell.setupCell(buyPendingProductList.objectAtIndex(indexPath.row) as! MyCartOffers, cellType: .CellTypeBuy)
                }else if segmentCartOption.selectedSegmentIndex == 1{
                    cell.setupCell(sellPendingProductList.objectAtIndex(indexPath.row) as! MyCartOffers, cellType: .CellTypeSell)
                }
                return cell
            }
        }else{
            if self.isLastRow(indexPath) {
                let cell = tableView.dequeueReusableCellWithIdentifier("MyCartMoreItemsCellId", forIndexPath: indexPath) as! MyCartMoreItemsTableViewCell
                cell.labelTitle.text = self.getTitleForLastRow(indexPath)
                return cell;
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("HistoryProductCellId", forIndexPath: indexPath) as!HistoryProductTableViewCell
                if segmentCartOption.selectedSegmentIndex == 0{
                    cell.setupCellForBuy(buyAcceptedProductList.objectAtIndex(indexPath.row) as! MyCartOffers)
                }else if segmentCartOption.selectedSegmentIndex == 1{
                    cell.setupCellForSell(sellAcceptedProductList.objectAtIndex(indexPath.row) as! MVActionProduct)
                }
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.isLastRow(indexPath) ? 40 : 110
        }else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header:MyCartTableSectionHeader = NSBundle.mainBundle().loadNibNamed("MyCartTableSectionHeader", owner: self, options: nil)[0] as! MyCartTableSectionHeader
        header.labelTitle.text = ( section == 0 ? "Live" : "History" )
        return header
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.isLastRow(indexPath) {
            if segmentCartOption.selectedSegmentIndex == 1 && indexPath.section == 0 {
                self.performSegueWithIdentifier("OfferViewController", sender: nil);
            }else{
                let product:MVProduct;
                if segmentCartOption.selectedSegmentIndex == 0 {
                    let productList:NSArray = (indexPath.section == 0 ? buyPendingProductList : buyAcceptedProductList)
                    let myCartOffer = productList.objectAtIndex(indexPath.row) as! MyCartOffers
                    product = myCartOffer.product
                    if (myCartOffer.offerStatus.lowercaseString == "accepted"){
                        self.showChatScreen(product, isMeet: (myCartOffer.offerDeliveryOption == DeliveryOption.MeetInPerson))
                    }else{
                        self.showProductDetails(product)
                    }
                    myCartOffer.unreadMsgCount = 0
                    self.tableViewCart.performSelector(#selector(self.tableViewCart.reloadData), withObject: nil, afterDelay: 0.6)
                }else{
                    let actionProduct = (sellAcceptedProductList.objectAtIndex(indexPath.row) as! MVActionProduct)
                    product = actionProduct.product
                    self.showChatScreen(product, isMeet: (actionProduct.offerDeliveryOption == DeliveryOption.MeetInPerson))
                    actionProduct.unreadMessageCount = 0
                    self.tableViewCart.performSelector(#selector(self.tableViewCart.reloadData), withObject: nil, afterDelay: 0.6)
                }
            }
        }else{
            if segmentCartOption.selectedSegmentIndex == 0 {
                if indexPath.section == 0 {
                    allBuyPendingVisiable = !allBuyPendingVisiable
                    allBuyAcceptedVisiable = false;
                }else{
                    allBuyAcceptedVisiable = !allBuyAcceptedVisiable
                    allBuyPendingVisiable = false;
                }
            }else{
                if indexPath.section == 0 {
                    allSellPendingVisiable = !allSellPendingVisiable
                    allSellAcceptedVisiable = false;
                }else{
                    allSellAcceptedVisiable = !allSellAcceptedVisiable
                    allSellPendingVisiable = false;
                }
            }
            tableViewCart.reloadSections(NSIndexSet.init(indexesInRange: NSRange(location: 0, length: 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    //MARK: - Helper Method
    func showProductDetails(product:MVProduct) {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        detailVC.productDetail = product
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func getAddressDetailsForProduct(product:MVProduct){
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let addressVC:AddressViewController = mainSt.instantiateViewControllerWithIdentifier("AddressViewController")  as! AddressViewController
        addressVC.product = product
        self.navigationController!.pushViewController(addressVC, animated: true)
    }
    
    func showChatScreen(product:MVProduct, isMeet:Bool) {
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let chatVC:ChatingViewController = mainSt.instantiateViewControllerWithIdentifier("chatVC")  as! ChatingViewController
        chatVC.product = product
        chatVC.isMeet = isMeet;
        chatVC.topicID = Int(product.topicId)
        self.navigationController!.pushViewController(chatVC, animated: true)
    }
    
    
    func isLastRow(indexPath:NSIndexPath) -> Bool {
        if segmentCartOption.selectedSegmentIndex == 0 {
            if indexPath.section == 0 {
                if buyPendingProductList.count == 0 {
                    return true
                }else if buyPendingProductList.count < minNoVisibleRow {
                    return false
                }
                return false
            }else{
                if buyAcceptedProductList.count == 0 {
                    return true
                }else if buyAcceptedProductList.count < minNoVisibleRow {
                    return false
                }
                let numberOfVisiableRow = ((buyAcceptedProductList.count < minNoVisibleRow || allBuyAcceptedVisiable) ? buyAcceptedProductList.count : getVisibleRows())
                return ((numberOfVisiableRow >= minNoVisibleRow) ? (numberOfVisiableRow + 1) : numberOfVisiableRow ) == indexPath.row + 1
            }
        }else{
            if indexPath.section == 0 {
                if sellPendingProductList.count == 0 {
                    return true
                }else if sellPendingProductList.count < minNoVisibleRow {
                    return false
                }
                return false
            }else{
                if sellAcceptedProductList.count == 0 {
                    return true
                }else if sellAcceptedProductList.count < minNoVisibleRow {
                    return false
                }
                let numberOfVisiableRow = ((sellAcceptedProductList.count < minNoVisibleRow || allSellAcceptedVisiable) ? sellAcceptedProductList.count : minNoVisibleRow )
                return ((numberOfVisiableRow >= minNoVisibleRow) ? (numberOfVisiableRow + 1) : numberOfVisiableRow ) == indexPath.row + 1
            }
        }
    }
    
    func getTitleForLastRow(indexPath:NSIndexPath) -> String {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return "No live offer available..."
            }else{
                return ((segmentCartOption.selectedSegmentIndex == 0 && allBuyPendingVisiable) || (segmentCartOption.selectedSegmentIndex == 1 && allSellPendingVisiable)) ? "See less live offers..." : "See more live offers..."
            }
        }else{
            if indexPath.row == 0 {
                return "No history offer available..."
            }else{
                return ((segmentCartOption.selectedSegmentIndex == 0 && allBuyAcceptedVisiable) || (segmentCartOption.selectedSegmentIndex == 1 && allSellAcceptedVisiable)) ? "See less history offers..." : "See more history offers..."
            }
        }
    }
    
    
    //MARK: - UIControls Action
    @IBAction func myCartSegmentOptionChanfed(sender: UISegmentedControl) {
        tableViewCart.reloadSections(NSIndexSet.init(indexesInRange: NSRange(location: 0, length: 2)), withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OfferViewController" {
            let offerViewController = (segue.destinationViewController as! OfferViewController)
            offerViewController.delegate = self
            offerViewController.cartOffer = sellPendingProductList.objectAtIndex(tableViewCart.indexPathForSelectedRow!.row) as! MyCartOffers
            offerViewController.product = (sellPendingProductList.objectAtIndex(tableViewCart.indexPathForSelectedRow!.row) as! MyCartOffers).product
        }
    }
    
    func offerAccepted() {
        self.loadSellProductList()
        self.loadSoldProductList()
        self.loadBuyProductList()
    }

}
