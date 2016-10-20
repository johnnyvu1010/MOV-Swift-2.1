//
//  SearchViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 12/05/15.

//  Copyright (c) 2015 Martino Mamic. All rights reserved.


import UIKit
import SVProgressHUD


class SearchResultViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate, UserProfileViewControllerDelegate , TTTAttributedLabelDelegate, ItemDetailViewControllerDelegate {
    
    
    @IBOutlet var navbarSearchButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var categoryTableView: UITableView!
    
    var isFirstTime:Bool!
    var headerNib:UINib!
    var footerNib:UINib!
    var searchBar: UISearchBar!
    var selectedItemIndex : Int = 0
    var searchActive : Bool = false
    var showOnlyProduct : Bool = false
    var filtered:[String] = []
    var searchProductsArray:[MVProduct]! = [MVProduct]()
    var categoryProductsArray:[MVProduct]! = [MVProduct]()
    var searchUsersArray:[SearchResultUser]! = [SearchResultUser]()
    var searchTagsArray:[SearchResultTag] = [SearchResultTag]()
    
    var selectedSegment : Int! = 0
    var selectedCellIndex : Int! = 0
    var tagMoreBtnPressed : Bool!
    var userMoreBtnPressed : Bool!
    var ProductMoreBtnPressed : Bool!
    var selectedCategory:ProductCategory!
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredStatusBarStyle()
        self.collectionView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        isFirstTime = true
        tagMoreBtnPressed=false;
        userMoreBtnPressed=false;
        ProductMoreBtnPressed=false;
        self.collectionView.hidden = true
        self.categoryTableView.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(SearchResultViewController.respondToSwipeGesture(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.collectionView.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(SearchResultViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.collectionView.addGestureRecognizer(swipeDown)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTime == true {
            searchBar = setupSearch()
            self.view .addSubview(searchBar)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.searchBar.alpha = 1
                self.navbarSearchButton.alpha = 0
            }) { (Bool) -> Void in
            }
            isFirstTime = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Collection View Delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if showOnlyProduct{
            return 1
        }
        return Int(searchUsersArray.count > 0) + Int(searchTagsArray.count > 0) + Int(searchProductsArray.count > 0)
    }
    
    
    func getImaginaryIndex(realIndex:Int) -> Int {
        if realIndex == 0{
            if searchUsersArray.count > 0 {return 0}
            else if searchTagsArray.count > 0 {return 1}
            else if searchProductsArray.count > 0 {return 2}
        }else if realIndex == 1 {
            if searchTagsArray.count > 0 {return 1}
            else if searchProductsArray.count > 0 {return 2}
        }else if realIndex == 2{
            return 2
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = CGRectGetWidth(collectionView.bounds)
        if showOnlyProduct{
            let cellWidth = screenWidth/2
            if(indexPath.row == categoryProductsArray!.count){
                return CGSize(width: screenWidth, height: 0)
            }
            if(collectionView.tag == 0){
                return CGSize(width: cellWidth-15, height: 140)
            }else{
                return CGSize(width: screenWidth, height: 70)
            }
        }
        switch self.getImaginaryIndex(indexPath.section)  {
        case 0:
            if (indexPath.row==self.searchUsersArray.count && userMoreBtnPressed)||(indexPath.row==3 && !userMoreBtnPressed){
                return CGSize(width: screenWidth, height: 33)
            }else{
                return CGSize(width: screenWidth, height: 86)
            }
        case 1:
            if (indexPath.row==self.searchTagsArray.count && tagMoreBtnPressed)||(indexPath.row==3 && !tagMoreBtnPressed){
                return CGSize(width: screenWidth, height: 33)
            }else{
                return CGSize(width: screenWidth, height: 86)
            }
        case 2:
            if (indexPath.row==self.searchProductsArray.count && ProductMoreBtnPressed)||(indexPath.row==3 && !ProductMoreBtnPressed){
                return CGSize(width: screenWidth, height: 33)
            }else{
                return CGSize(width: screenWidth, height: 86)
            }
        default:
            return CGSize(width: screenWidth, height: 86)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if showOnlyProduct{
            if(collectionView.tag == 0){
                return 5
            } else {
                return 1
            }
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if(collectionView.tag == 0 && showOnlyProduct){
            return 3
        } else {
            return 0
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identifier:String
        if showOnlyProduct{
            if(self.selectedSegment == 0){
                identifier = "gridCell"
            }
            else{
                identifier = "userGridCell"
            }
            
            if(indexPath.row == categoryProductsArray!.count ){
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("footerCell", forIndexPath: indexPath)
                return cell
            }
            
            let cell:GridCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! GridCell
            
            var product : MVProduct!
            if(indexPath.row < self.categoryProductsArray?.count){
                product  = self.categoryProductsArray![indexPath.row]
            }
            cell.itemPreview.clipsToBounds = true
            cell.playButton.tag            = indexPath.row
            cell.priceLabel.text           = "$\(product.price)"
            cell.itemName.text = product.name
            cell.itemPreview.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            MVHelper.addMOVVCornerRadiusToView(cell.userIcon)
            cell.userIcon.setImageWithURL(NSURL(string: product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            cell.playButton.addTarget(self, action: #selector(SearchResultViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.userProfileButton.addTarget(self, action: #selector(SearchResultViewController.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.itemPreview.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            cell.userIcon.setImageWithURL(NSURL(string: product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            MVHelper.addMOVVCornerRadiusToView(cell.userIcon)
            let greenBoldedFont           = [NSForegroundColorAttributeName: MOVVGreen, NSFontAttributeName: UIFont.boldSystemFontOfSize(16)]
            let concatenatedString:String = "@" + product.user.username + "                    "
            let string                    = concatenatedString as NSString
            let attributedString          = NSMutableAttributedString(string: string as String)
            attributedString.addAttributes(greenBoldedFont, range: string.rangeOfString("@" + product.user.username))
            
            var range : NSRange!
            range                             = string.rangeOfString("@" + product.user.username)
            let url : NSURL!                  = NSURL(string: "\(product.user.id)")
            return cell
        }
        
        if (self.getImaginaryIndex(indexPath.section) == 2) {
            identifier="productCell"
        }
        else{
            identifier="userGridCell"
        }
        
        if self.getImaginaryIndex(indexPath.section) == 0{
            if (indexPath.row==self.searchUsersArray.count && userMoreBtnPressed)||(indexPath.row==3 && !userMoreBtnPressed) {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("footerCell", forIndexPath: indexPath)as! ExtraLoadingCollectionViewCell
                cell.loadMoreBtn.tag = self.getImaginaryIndex(indexPath.section) + 1
                cell.loadMoreBtn.addTarget(self, action: #selector(SearchResultViewController.loadMoreBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.loadMoreBtn .setTitle("See more users", forState: UIControlState.Normal)
                cell.loadMoreBtn .setTitle("See less users", forState: UIControlState.Highlighted)
                cell.loadMoreBtn .setTitle("See less users", forState: UIControlState.Selected)
                if (userMoreBtnPressed == true) {
                    cell.loadMoreBtn.selected=true
                }else{
                    cell.loadMoreBtn.selected=false
                }
                return cell
                
            }else{
                let cell:GridCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! GridCell
                var user : SearchResultUser!
                if(indexPath.row < self.searchUsersArray.count){
                    user = self.searchUsersArray[indexPath.row]
                }
                cell.usernameLabel.text = user.firstName + " " + user.lastName
                cell.userTagLabel.text  = user.username
                cell.userIcon.setImageWithURL(NSURL(string: user.userProfileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                cell.userIcon.hidden = false
                cell.userIconWidth.constant = 40
                MVHelper.addMOVVCornerRadiusToView(cell.userIcon)
                return cell;
            }
        }else if self.getImaginaryIndex(indexPath.section) == 1 {
            if (indexPath.row==self.searchTagsArray.count && tagMoreBtnPressed)||(indexPath.row==3 && !tagMoreBtnPressed) {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("footerCell", forIndexPath: indexPath)as! ExtraLoadingCollectionViewCell
                cell.loadMoreBtn.tag = self.getImaginaryIndex(indexPath.section)+1
                
                cell.loadMoreBtn .setTitle("See more tags", forState: UIControlState.Normal)
                cell.loadMoreBtn .setTitle("See less tags", forState: UIControlState.Highlighted)
                cell.loadMoreBtn .setTitle("See less tags", forState: UIControlState.Selected)
                
                cell.loadMoreBtn.addTarget(self, action: #selector(SearchResultViewController.loadMoreBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                if (tagMoreBtnPressed == true) {
                    cell.loadMoreBtn.selected=true
                }else{
                    cell.loadMoreBtn.selected=false
                }
                return cell
                
            }else{
                let cell:GridCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! GridCell
                var tag : SearchResultTag!
                if(indexPath.row < self.searchTagsArray.count){
                    tag = self.searchTagsArray[indexPath.row]
                }
                cell.usernameLabel.text = tag.tagName
                let suffix = Int(tag.count) > 1 ? "s":""
                cell.userTagLabel.text  = tag.count + " product" + suffix
                cell.userIcon.hidden = true
                cell.userIconWidth.constant = 0
                MVHelper.addMOVVCornerRadiusToView(cell.userIcon)
                return cell;
            }
            
        }else {
            if (indexPath.row==self.searchProductsArray.count && ProductMoreBtnPressed)||(indexPath.row==3 && !ProductMoreBtnPressed){
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("footerCell", forIndexPath: indexPath)as! ExtraLoadingCollectionViewCell
                cell.loadMoreBtn.tag = self.getImaginaryIndex(indexPath.section)+1
                cell.loadMoreBtn .setTitle("See more products", forState: UIControlState.Normal)
                cell.loadMoreBtn .setTitle("See less products", forState: UIControlState.Highlighted)
                cell.loadMoreBtn .setTitle("See less products", forState: UIControlState.Selected)
                cell.loadMoreBtn.addTarget(self, action: #selector(SearchResultViewController.loadMoreBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                if (ProductMoreBtnPressed == true) {
                    cell.loadMoreBtn.selected=true
                }else{
                    cell.loadMoreBtn.selected=false
                }
                return cell
            }else{
                var product : MVProduct!
                if(indexPath.row < self.searchProductsArray?.count){
                    product = self.searchProductsArray![indexPath.row]
                }
                let cell:ProductSearchCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as!ProductSearchCollectionViewCell
                cell.productImage.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                cell.productName.text=product.name
                cell.productPrice.text = "$ \(product.price)"
                return cell
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if(collectionView.tag == 0 && showOnlyProduct){
            return UIEdgeInsetsMake(10,10,10,10)
        } else {
            return UIEdgeInsetsZero
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if showOnlyProduct{
            if(self.categoryProductsArray.count > 0){
                return self.categoryProductsArray.count
            }else{
                return 0
            }
        }
        
        if self.getImaginaryIndex(section)==0 {
            if (self.searchUsersArray.count>4 && !userMoreBtnPressed) {
                return 4
            }else if (self.searchProductsArray.count == 4){
                return 4 + Int(userMoreBtnPressed)
            }else if self.searchUsersArray.count < 4 {
                return self.searchUsersArray.count
            }else{
                return (self.searchUsersArray.count == 0) ? 0 : self.searchUsersArray.count+1
            }
        }else if (self.getImaginaryIndex(section)==1){
            if (self.searchTagsArray.count>4 && !tagMoreBtnPressed){
                return 4
            }else if (self.searchProductsArray.count == 4){
                return 4 + Int(tagMoreBtnPressed)
            }else if self.searchTagsArray.count < 4 {
                return self.searchTagsArray.count
            }else{
                return (self.searchTagsArray.count == 0) ? 0 : self.searchTagsArray.count+1
            }
        }else{
            if self.searchProductsArray.count>4  && !ProductMoreBtnPressed{
                return 4
            }else if (self.searchProductsArray.count == 4){
                return 4 + Int(ProductMoreBtnPressed)
            }else if self.searchProductsArray.count < 4 {
                return self.searchProductsArray.count
            }else{
                return (self.searchProductsArray.count == 0) ? 0 : self.searchProductsArray.count+1
            }
        }
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            var yourOtherArray = ["Users", "Tags", "Products"]
            if showOnlyProduct{
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SearchHeaderCollectionReusableView", forIndexPath: indexPath) as! SearchHeaderCollectionReusableView
                headerView.headerLabel.text = "\(selectedCategory.stringValue)"
                return headerView
            }
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SearchHeaderCollectionReusableView", forIndexPath: indexPath) as! SearchHeaderCollectionReusableView
            headerView.headerLabel.text = yourOtherArray[self.getImaginaryIndex(indexPath.section)]
            return headerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if showOnlyProduct{
            let main = UIStoryboard(name: "Main", bundle: nil)
            let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
            userProfileVC.delegate = self
            self.selectedCellIndex = indexPath.row
            var user:MVUser!
            user = categoryProductsArray![indexPath.row].user
            userProfileVC.userProfileId = user.id
            self.navigationController!.pushViewController(userProfileVC, animated: true)
        }
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        switch self.getImaginaryIndex(indexPath.section) {
        case 0:
            if !(indexPath.row==self.searchUsersArray.count && userMoreBtnPressed)||(indexPath.row==3 && !userMoreBtnPressed){
                let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
                userProfileVC.delegate = self
                userProfileVC.userProfileId = Int(searchUsersArray[indexPath.row].id)
                self.selectedCellIndex = indexPath.row
                self.navigationController!.pushViewController(userProfileVC, animated: true)
            }
            break
        case 1:
            if !(indexPath.row==self.searchTagsArray.count && tagMoreBtnPressed)||(indexPath.row==3 && !tagMoreBtnPressed){
                let tagViewController = main.instantiateViewControllerWithIdentifier("TagDetailViewController")  as! TagDetailViewController
                tagViewController.tagName = searchTagsArray[indexPath.row].tagName
                self.selectedCellIndex = indexPath.row
                self.navigationController!.pushViewController(tagViewController, animated: true)
            }
            break
        case 2:
            if !(indexPath.row==self.searchProductsArray.count && ProductMoreBtnPressed)||(indexPath.row==3 && !ProductMoreBtnPressed){
                let productViewController = main.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
                productViewController.productDetail = searchProductsArray[indexPath.row]
                //                productViewController.delegate = self
                self.selectedCellIndex = indexPath.row
                self.navigationController!.pushViewController(productViewController, animated: true)
            }
            break
        default:
            break
        }
    }
    
    func loadMoreBtnClicked(sender:UIButton)
    {
        switch sender.tag {
        case 1:
            
            if sender.selected {
                self.userMoreBtnPressed=false;
                sender .selected=false;
                
            }else{
                self.userMoreBtnPressed=true;
                sender .selected=true;
            }
            self.collectionView.reloadData()
        case 2:
            if sender.selected {
                self.tagMoreBtnPressed=false;
                sender .selected=false;
                
            }else{
                self.tagMoreBtnPressed=true;
                sender .selected=true;
            }
            self.collectionView.reloadData()
            
        case 3:
            if sender.selected {
                self.ProductMoreBtnPressed=false;
                sender .selected=false;
                
            }else{
                self.ProductMoreBtnPressed=true;
                sender .selected=true;
            }
            self.collectionView.reloadData()
            
        default:
            print("Unused work")
        }
        
        
    }
    
    //MARK: - UITableView Delegate + Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProductCategory.allCategories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(CategoryTableViewCell), forIndexPath: indexPath) as! CategoryTableViewCell
        cell.labelCategoryName.text = ProductCategory.allCategories[indexPath.row].stringValue
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCategory = ProductCategory.allCategories[indexPath.row]
        fetchData(selectedCategory.rawValue)
        tableView.hidden = true
        collectionView.hidden = false
        if searchBar.isFirstResponder(){
            searchBar.resignFirstResponder()
        }
    }
    
    
    //MARK: - TTTAttributed Label Delegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        let main                    = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC           = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.userProfileId = ("\(url)" as NSString).integerValue
        
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    
    //MARK: ItemDetailViewController Delegate
    func productLikeStateChanged(product : MVProduct)
    {
        self.searchProductsArray[self.selectedItemIndex].isLiked = product.isLiked
        self.collectionView.reloadData()
    }
    
    
    //MARK: UserProfileViewController Delegate
    func userFollowStateChanged(followState: Bool) {
        if(self.selectedSegment == 0){
            self.searchProductsArray[self.selectedItemIndex].user.isFollowed = followState
        }else{
            //            self.searchUsersArray[self.selectedItemIndex].isFollowed = followState
        }
        self.collectionView.reloadData()
    }
    
    
    
    //MARK: - Searchbar Delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        //        UIView.animateWithDuration(0.3, animations: { () -> Void in
        //            self.searchBar.alpha = 0
        //            self.navbarSearchButton.alpha = 1
        //        }) { (Bool) -> Void in
        //            self.searchBar.removeFromSuperview()
        //        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text?.length > 0 {
            self.fetchData()
        }
        self.view.endEditing(true)
        self.enableCancleButton(searchBar)
    }
    
    func enableCancleButton (searchBar : UISearchBar) {
        for view in searchBar.subviews {
            for view in view.subviews {
                if view.isKindOfClass(UIButton) {
                    let button = view as! UIButton
                    button.enabled = true
                    button.userInteractionEnabled = true
                }
            }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
    }
    
    
    //MARK: - fetch logic
    
    func fetchData(){
        showOnlyProduct = false
        let request : String! = "search"
        let parameters :  NSMutableDictionary! = ["q": searchBar.text!]
        if let category = selectedCategory{
            parameters.setValue("\(category.rawValue)", forKey: "category_id")
        }
        self.searchTagsArray.removeAll()
        self.searchUsersArray.removeAll()
        self.searchProductsArray.removeAll()
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            self.collectionView.hidden = false
            self.categoryTableView.hidden = true
            let products = response.valueForKey("products") as? NSArray
            products?.enumerateObjectsUsingBlock({ (obj, idx, stop) in
                self.searchProductsArray.append(MVProduct.init(dictionary: obj as! NSDictionary))
            })
            let tags = response.valueForKey("tags") as? NSArray
            tags?.enumerateObjectsUsingBlock({ (obj, idx, bool) in
                self.searchTagsArray.append(SearchResultTag.init(serverResponse: obj as! NSDictionary))
            })
            let users = response.valueForKey("users") as? NSArray
            users?.enumerateObjectsUsingBlock({ (obj, idx, bool) in
                self.searchUsersArray.append(SearchResultUser.init(serverResponse: obj as! NSDictionary))
            })
            self.collectionView.reloadData()
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:"No result found. Please try different keywords."  as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                })
            self.presentViewController(alert, animated: true, completion: nil)
            self.collectionView.reloadData()
        }
    }
    
    func fetchData(category_id:Int) {
        SVProgressHUD.show()
        showOnlyProduct = true
        let request : String! = "explore-products"
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)","category_id":"\(category_id)"]
        MVSyncManager.getDataFromServerUsingGET(parameters, request: request, successBlock: { response in
            SVProgressHUD.dismiss()
            let resultDictionary : NSDictionary! = response as! NSDictionary
            let productsArray : NSArray = resultDictionary["products"] as! NSArray
            self.categoryProductsArray.removeAll()
            for dict in productsArray{
                let product : MVProduct = MVProduct(dictionary: dict as! NSDictionary)
                self.categoryProductsArray.append(product)
            }
            self.collectionView.reloadData()
        }) { failure in
            SVProgressHUD.dismiss()
        }
        
    }
    
    
    //MARK: - Action methods
    
    @IBAction func seachButtonPressed(sender: AnyObject) {
        searchBar = setupSearch()
        self.view .addSubview(searchBar)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.navbarSearchButton.alpha   = 0
            self.searchBar.alpha            = 1
        }) { (Bool) -> Void in
        }
    }
    
    func showDetails(sender:UIButton) {
        let product : MVProduct! = self.categoryProductsArray![sender.tag];
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mixpanel?.track("Comment", properties: ["item" : product.name])
        let mainSt = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        detailVC.productDetail = product
        self.selectedItemIndex = sender.tag
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func userProfileButtonTouched(sender : UIButton) {
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath:NSIndexPath = self.collectionView.indexPathForCell(cell)!
        let main = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.delegate = self
        self.selectedCellIndex = indexPath.row
        let user = categoryProductsArray![indexPath.row].user
        userProfileVC.userProfileId = user.id
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }

    
    //MARK: - Screen setup
    func setupSearch()->UISearchBar {
        let search                                      = UISearchBar(frame: CGRectMake(navbarSearchButton.frame.origin.x, navbarSearchButton.frame.origin.y,navbarSearchButton.frame.size.width , navbarSearchButton.frame.size.height))
        search.delegate                                 = self
        search.placeholder                              = "Search"
        search.searchBarStyle                           = UISearchBarStyle.Minimal
        search.tintColor                                = UIColor.whiteColor()
        search.barTintColor                             = UIColor.whiteColor()
        search.becomeFirstResponder()
        //        search.setImage(UIImage(named: "searchBarButton"), forSearchBarIcon: .Search, state: .Normal)
        let textFieldInsideSearchBar                    = search.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar!.attributedPlaceholder = NSAttributedString(string:"Search", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        textFieldInsideSearchBar?.leftView?.tintColor   = UIColor.whiteColor()
        textFieldInsideSearchBar!.textColor             = UIColor.whiteColor()
        textFieldInsideSearchBar!.tintColor             = UIColor.whiteColor()
        search.showsCancelButton                        = true
        search.alpha                                    = 0
        return search
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Up:
                break;
            case UISwipeGestureRecognizerDirection.Down:
                break;
            default:
                break
            }
        }
    }
}