//
//  SearchViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 12/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UserProfileViewControllerDelegate , TTTAttributedLabelDelegate, ItemDetailViewControllerDelegate {
    
    
    @IBOutlet var navbarSearchButton: UIButton!
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    var isFromTabBar:Bool?
    var headerNib:UINib!
    var footerNib:UINib!
    var searchBar: UISearchBar!
    var selectedItemIndex : Int          = 0
    var searchActive : Bool              = false
    var filtered:[String]                = []
    var searchProductsArray:[MVProduct]! = [MVProduct]()
    var searchUsersArray:[MVUser]!       = [MVUser]()
    var selectedSegment : Int!           = 0
    var selectedCellIndex : Int!         = 0
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredStatusBarStyle()
        //        headerNib = UINib(nibName: "CollectionHeaderView", bundle: nil)
        //        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        // Do any additional setup after loading the view.
        self.collectionView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0)
        self.fetchData()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if !self.view.userInteractionEnabled {
            self.view.userInteractionEnabled = true
            if collectionView.numberOfItemsInSection(0) > 0{
                self.fetchData()
                collectionView.scrollToItemAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: .Bottom, animated: false)
            }
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Collection View Delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let screenWidth = CGRectGetWidth(collectionView.bounds)
        let cellWidth = screenWidth/2
        
        if(self.selectedSegment == 0)
        {
            if(indexPath.row == searchProductsArray!.count)
            {
                return CGSize(width: screenWidth, height: 0)
            }
        }
        else
        {
            if(indexPath.row == searchUsersArray!.count)
            {
                return CGSize(width: screenWidth, height: 0)
            }
        }
        
        
        if(collectionView.tag == 0)
        {
            return CGSize(width: cellWidth-15, height: 140)
        }
        else
        {
            return CGSize(width: screenWidth, height: 70)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if(collectionView.tag == 0){
            return 5
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if(collectionView.tag == 0){
            return 3
        } else {
            return 0
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        var identifier:String
        if(self.selectedSegment == 0){
            identifier = "gridCell"
        }
        else{
            identifier = "userGridCell"
        }
        
        if(self.selectedSegment == 0)
        {
            if(indexPath.row == searchProductsArray!.count ){
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("footerCell", forIndexPath: indexPath)
                
                return cell
            }
        }
        else
        {
            if(indexPath.row == searchUsersArray!.count){
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("footerCell", forIndexPath: indexPath)
                
                return cell
            }
        }
        
        let cell:GridCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! GridCell
        
        if(self.selectedSegment == 0)
        {
            var product : MVProduct!
            if(indexPath.row < self.searchProductsArray?.count)
            {
                product  = self.searchProductsArray![indexPath.row]
            }
//            
//            cell.layer.borderWidth         = 0.5
//            cell.layer.borderColor         = UIColor.lightGrayColor().CGColor
            cell.itemPreview.clipsToBounds = true
            cell.playButton.tag            = indexPath.row
            //cell.userProfileButton.tag     = indexPath.row
            //cell.usernameLabel.text        = "@\(product.user.username)"
            //cell.userLocationLabel.text    = product.user.location
            //cell.likeCountLabel.text       = "\(product.numLikes)"
            //cell.commentCountLabel.text    = "\(product.numComments)"
            cell.priceLabel.text           = "$\(product.price)"
            cell.itemName.text = product.name
            cell.itemPreview.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            MVHelper.addMOVVCornerRadiusToView(cell.userIcon)
            cell.userIcon.setImageWithURL(NSURL(string: product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            
            cell.playButton.addTarget(self, action: #selector(SearchViewController.showDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.userProfileButton.addTarget(self, action: #selector(SearchViewController.userProfileButtonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
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
            //            cell.usernameLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
            //            cell.usernameLabel.addLinkToURL(url, withRange: range)
            //            cell.usernameLabel.attributedText = attributedString
            //            cell.usernameLabel.delegate       = self
            
            //            if(product.isLiked as Bool)
            //            {
            //                cell.likeButton.setImage(UIImage(named: "likeButton_selected.png"), forState: UIControlState.Normal)
            //            }
            //            else
            //            {
            //                cell.likeButton.setImage(UIImage(named: "likeButton.png"), forState: UIControlState.Normal)
            //            }
            
        }
        else
        {
            var user : MVUser!
            
            if(indexPath.row < self.searchUsersArray.count){
                
                user = self.searchUsersArray[indexPath.row]
                
            }
            
            cell.usernameLabel.text = user.displayName
            cell.userTagLabel.text  = "@\(user.username)"
            cell.userIcon.setImageWithURL(NSURL(string: user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            MVHelper.addMOVVCornerRadiusToView(cell.userIcon)
            
            if(user.isFollowed!)
            {
                cell.followButton.setImage(UIImage(named: "unfollowButton"), forState: .Normal)
            }
            else
            {
                cell.followButton.setImage(UIImage(named: "followButton"), forState: .Normal)
            }
            
            cell.followButton.addTarget(self, action: #selector(SearchViewController.followButtonTouched(_:)), forControlEvents:  UIControlEvents.TouchUpInside)
            // cell.userProfileButton.addTarget(self, action: Selector("userProfileButtonTouched:"), forControlEvents: UIControlEvents.TouchUpInside)
            print(indexPath.row)
            if(user.id == MVParameters.sharedInstance.currentMVUser.id)
            {
                cell.followButton.hidden = true
            }
            else
            {
                cell.followButton.hidden = false
            }
            
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if(collectionView.tag == 0){
            return UIEdgeInsetsMake(10,10,10,10)
        } else {
            return UIEdgeInsetsZero
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(self.selectedSegment == 0)
        {
            if(self.searchProductsArray.count > 0)
            {
                return self.searchProductsArray.count
            }
            else
            {
                return 0
            }
        }
        else
        {
            if(self.searchUsersArray.count > 0)
            {
                return self.searchUsersArray.count
            }
            else
            {
                return 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let main               = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC      = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.delegate = self
        self.selectedCellIndex = indexPath.row
        
        var user:MVUser!
        if(self.selectedSegment == 0)
        {
            user = searchProductsArray![indexPath.row].user
        }
        else
        {
            user = searchUsersArray![indexPath.row]
        }
        
        userProfileVC.userProfileId = user.id
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    //    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    //
    //        if(kind == UICollectionElementKindSectionHeader)
    //        {
    //            UIView.setAnimationsEnabled(false)
    //            let segmentView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "segmentView", forIndexPath: indexPath) as! CollectionHeaderReusableView
    //            segmentView.segmentedControl.removeAllSegments()
    //            segmentView.segmentedControl.addTarget(self, action: #selector(SearchViewController.segmentValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    //            segmentView.segmentedControl.insertSegmentWithTitle("Products", atIndex: 0, animated: true)
    //            segmentView.segmentedControl.insertSegmentWithTitle("People", atIndex: 1, animated: true)
    //            segmentView.segmentedControl.selectedSegmentIndex = collectionView.tag
    //            segmentView.frame = CGRectMake(0, 0, collectionView.frame.size.width, 48)
    //            UIView.setAnimationsEnabled(true)
    //            return segmentView
    //        }
    //        else
    //        {
    //            let reusableView = UICollectionReusableView(frame: CGRectMake(0, 0,CGRectGetWidth(collectionView.frame), 0))
    //            reusableView.backgroundColor = UIColor.greenColor()
    //            return reusableView
    //        }
    //    }
    
    //MARK: TTTAttributed Label Delegate
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
            self.searchUsersArray[self.selectedItemIndex].isFollowed = followState
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
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchBar.alpha = 0
            self.navbarSearchButton.alpha = 1
            //            self.searchCollectionview.alpha = 0
            //            self.gridCollectionView.alpha = 1
        }) { (Bool) -> Void in
            
            self.searchBar.removeFromSuperview()
        }
        fetchData()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if(searchBar.text!.length > 2)
        {
            if(self.selectedSegment == 0)
            {
                self.fetchSearchProducts(searchBar.text!)
                searchActive = false;
                
            }
            else
            {
                self.fetchSearchPeople(searchBar.text!)
                searchActive = false;
            }
            
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
    
    
    
    
    //MARK: fetch logic
    
    func fetchData()
    {
        SVProgressHUD.show()
        
        MVDataManager.exploreProducts(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            
            self.searchProductsArray = response as! NSArray as? [MVProduct]
            self.collectionView.reloadData()
            SVProgressHUD.dismiss()
        }) { failure in
            
            print(failure)
            SVProgressHUD.dismiss()
            
        }
        
        MVDataManager.explorePeople(MVParameters.sharedInstance.currentMVUser.id, successBlock: { response in
            
            self.searchUsersArray = response as! [MVUser]
            self.collectionView.reloadData()
            SVProgressHUD.dismiss()
        }) { failure in
            
            print(failure)
            SVProgressHUD.dismiss()
            
        }
        
    }
    
    
    func fetchSearchProducts(query : String) {
        MVDataManager.searchProducts(MVParameters.sharedInstance.currentMVUser.id, searchQuery: query, successBlock: { response in
            
            self.searchProductsArray = response as! [MVProduct]
            self.collectionView.reloadData()
            
        }) { failure in
            
            //                print(failure!)
            
            let alert = UIAlertController(title: "", message: "\(failure)", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func fetchSearchPeople(query : String) {
        MVDataManager.searchPeople(MVParameters.sharedInstance.currentMVUser.id, searchQuery: query, successBlock: { response in
            
            if((response as! [MVUser]).count == 0)
            {
                let alert = UIAlertController(title: "", message: "There are no people to show!", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            else
            {
                self.searchUsersArray = response as! [MVUser]
                self.collectionView.reloadData()
            }
        }) { failure in
            print(failure)
            
        }
    }
    
    //MARK: Action methods
    
    @IBAction func seachButtonPressed(sender: AnyObject) {
//        searchBar = setupSearch()
//        self.view .addSubview(searchBar)
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            self.navbarSearchButton.alpha   = 0
//            self.searchBar.alpha            = 1
//            
//        }) { (Bool) -> Void in
//            
//            
//        }
//        
    }
    
    func showDetails(sender:UIButton) {
        let product : MVProduct! = self.searchProductsArray![sender.tag];
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mixpanel?.track("Comment", properties: ["item" : product.name])
        let mainSt             = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = mainSt.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        detailVC.productDetail = product
//        detailVC.delegate      = self
        self.selectedItemIndex = sender.tag
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func userProfileButtonTouched(sender : UIButton) {
        var cell:UICollectionViewCell!
        if(selectedSegment == 0)
        {
            cell = sender.superview?.superview as! UICollectionViewCell
        }
        else
        {
            cell = sender.superview?.superview?.superview as! UICollectionViewCell
        }
        let indexPath:NSIndexPath = self.collectionView.indexPathForCell(cell)!
        
        let main               = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC      = main.instantiateViewControllerWithIdentifier("userProfileVC")  as! UserProfileViewController
        userProfileVC.delegate = self
        self.selectedCellIndex = indexPath.row
        
        var user:MVUser!
        if(self.selectedSegment == 0)
        {
            user = searchProductsArray![indexPath.row].user
        }
        else
        {
            user = searchUsersArray![indexPath.row]
        }
        
        userProfileVC.userProfileId = user.id
        
        self.navigationController!.pushViewController(userProfileVC, animated: true)
    }
    
    func followButtonTouched(sender : UIButton) {
        
        let cell:UICollectionViewCell = sender.superview?.superview as! UICollectionViewCell
        let indexPath:NSIndexPath = self.collectionView.indexPathForCell(cell)!
        
        let user:MVUser = self.searchUsersArray[indexPath.row]
        
        if(user.isFollowed!)
        {
            user.isFollowed = false
            MVDataManager.unfollowUser(user.id, successBlock: { response in
                
                print(response)
                
                }, failureBlock: { failure in
                    
                    print(failure)
                    user.isFollowed = true
                    self.collectionView.reloadData()
            })
        }
        else
        {
            user.isFollowed = true
            MVDataManager.followUser(user.id, successBlock: { response in
                
                print(response)
                
                
                }, failureBlock: { failure in
                    
                    print(failure)
                    user.isFollowed = false
                    self.collectionView.reloadData()
            })
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        
        self.collectionView.tag = sender.selectedSegmentIndex
        let indexPaths = NSMutableArray()
        
        
        for i : Int in 0 ..< searchProductsArray!.count + 1
        {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            indexPaths.addObject(indexPath)
        }
        
        self.selectedSegment = sender.selectedSegmentIndex
        
        self.collectionView.reloadData()
        
        //        self.collectionView.reloadSections(indexSet)
        
    }
    
    
    //MARK: Screen setup
    func setupSearch()->UISearchBar {
        let search                                      = UISearchBar(frame: CGRectMake(navbarSearchButton.frame.origin.x, navbarSearchButton.frame.origin.y,navbarSearchButton.frame.size.width , navbarSearchButton.frame.size.height))
        search.delegate                                 = self
        search.placeholder                              = "Search"
        search.searchBarStyle                           = UISearchBarStyle.Minimal
        search.tintColor                                = UIColor.whiteColor()
        search.barTintColor                             = UIColor.whiteColor()
        search.becomeFirstResponder()
        search.setImage(UIImage(named: "searchBarButton"), forSearchBarIcon: .Search, state: .Normal)
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
    
    
}
