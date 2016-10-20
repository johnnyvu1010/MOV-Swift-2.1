//
//  EditItemViewController.swift
//  MOVV
//
//  Created by Martino Mamic on 06/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit
import CoreLocation
import AssetsLibrary
import IQKeyboardManager
import SVProgressHUD
import ImageIO
import MobileCoreServices


protocol MVEditItemDelegate {
    func userDidDeselectedVideo()
    func userDidDeselectedImage()
}

var shareVC:MVShareViewController!
class EditItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, MVAwsUploadDelegate, TagsViewControllerDelegate, MVShareViewControllerDelegate, DeliveryOptionDelegate, UIActionSheetDelegate {
    
    var cell:EditItemCell! = EditItemCell()
    var tagsViewController : TagsViewController!
    var weightTitle:String! = ""
//    var itemModel:ItemModel!
    var termsMet = false
    var tagCollectionView:UICollectionView?
    var fields:NSMutableArray!
    @IBOutlet var editItemTable: UITableView!
    let selectedRows:NSMutableArray  = NSMutableArray()
    var viewAppeared:Bool!
    var moviePlayer:AVPlayer!
    var playButton:UIButton!
    var pauseButton:UIButton!
    
    var playerController:AVPlayerViewController?
    var player:AVPlayer?
    var playerGesture:UIGestureRecognizer?
    var preview:UIImageView?
    
    let locationManager = CLLocationManager()
    var userCoordinate = CLLocationCoordinate2D()
    
    var uploadVideoFileURL: NSURL! = NSURL()
    var uploadImageFileURL: NSURL! = NSURL()
    var uploadGifFileURL: NSURL! = NSURL()

    var shouldUploadImage : Bool = true
    var selectedCategory : ProductCategory!
    var selectedTags = Array<String>()
   
    var delegate:MVEditItemDelegate? = nil
    var shareImage : UIImage!
    var videoPlayFlage: Bool = false
    var isUploadingFailed:Bool = false
    var isUploadingInProgress:Bool = true
    var isPostButtonTapped:Bool = false
    var returnKeyHandler:IQKeyboardReturnKeyHandler!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        println(uploadVideoFileURL)
//         println(uploadImageFileURL)

        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        self.shouldAutorotate()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.preferredStatusBarStyle()
        addRightNavItemOnView()
        fields = NSMutableArray()
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        returnKeyHandler = IQKeyboardReturnKeyHandler.init(viewController: self)
//        let itemModel : ItemModel = ItemModel()
        
        
        viewAppeared = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navbarVideo"), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Edit item"

        if(visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar)){
            addBlurEffect()
        }
        self.saveVideoToDocumentsDirectory()
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared = true        
        if(videoPlayFlage == false){
            videoPlayFlage = true
            self.showPreviewVideo()
            self.createGif()
            self.uploadToS3(self.uploadVideoFileURL, bucketName : Buckets.Video)
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if((viewAppeared) != nil){
            editItemTable.reloadData()
        }
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIdentitfiers.count
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = cellIdentitfiers[indexPath.row]
        cell = tableView .dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! EditItemCell
        if(indexPath.row == 0){
            cell.videoPreview.setImageWithURL(uploadGifFileURL, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            let previewVideoGesture = UITapGestureRecognizer(target: self, action: #selector(EditItemViewController.showPreviewVideo))
            cell.videoPreview.userInteractionEnabled = true
            cell.videoPreview.addGestureRecognizer(previewVideoGesture)
            cell.dismissAndRecordVideo.addTarget(self, action: #selector(EditItemViewController.dismissAndResetVideo), forControlEvents: .TouchUpInside)
        } else if(indexPath.row == 1 ){
            if !fields.containsObject(cell.titleField) {
                fields.addObject(cell.titleField)
            }
            cell.titleField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: nil, nextAction: #selector(EditItemViewController.nameFieldDoneButtonHandler), doneAction: #selector(EditItemViewController.nameFieldDoneButtonHandler))
        } else if (indexPath.row == 2){
            if !fields.containsObject(cell.brandField) {
                fields.addObject(cell.brandField)
            }
            cell.brandField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(EditItemViewController.brandFieldPrevButtonHandler), nextAction: #selector(EditItemViewController.brandFieldDoneButtonHandler), doneAction: #selector(EditItemViewController.brandFieldDoneButtonHandler))
        } else if(indexPath.row == 3) {
            if !fields.containsObject(cell.categoryField){
                fields.addObjectsFromArray([cell.categoryField])
            }
            cell.categoryField.text = selectedCategory?.stringValue
        } else if(indexPath.row == 4) {
            if !fields.containsObject(cell.priceField){
                fields.addObjectsFromArray([cell.priceField, cell.quantityField])
            }
            cell.priceField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(EditItemViewController.priceFieldPrevButtonHandler), nextAction: #selector(EditItemViewController.priceFieldDoneButtonHandler), doneAction: #selector(EditItemViewController.priceFieldDoneButtonHandler))
        } else if(indexPath.row == 5){
            cell.labelTags.text = selectedTags.count > 0 ? selectedTags.joinWithSeparator(" ") : "Add Product Tags"
        } else if(indexPath.row == 7){
            cell.labelShippingOption.text = weightTitle
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 8){
            return 70
        } else if(indexPath.row == 7){
            return 60
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50))
        footerView.alpha = 0
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    //MARK: - Done Button Handlers
    
    func nameFieldDoneButtonHandler(){
        fields[1].becomeFirstResponder()
    }
    
    func brandFieldPrevButtonHandler(){
        fields[0].becomeFirstResponder()
    }
    
    func brandFieldDoneButtonHandler(){
        fields[1].resignFirstResponder()
        self.categoryCellTapGesture(UITapGestureRecognizer())
    }
    
    func priceFieldPrevButtonHandler(){
        self.categoryCellTapGesture(UITapGestureRecognizer())
    }
    
    func priceFieldDoneButtonHandler(){
        fields[3].resignFirstResponder()
    }
    
    //MARK: - Collection View Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (self.selectedTags[indexPath.row].length * 10) + 30
        return CGSize(width: cellWidth, height: 30)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tagCollectionCell", forIndexPath: indexPath) as! TagCollectionViewCell
        if(self.selectedTags.count > 0){
            cell.layer.cornerRadius = 3
            cell.tagLabel.text = self.selectedTags[indexPath.row]
            cell.tagDeleteButton.tag = indexPath.row
            cell.tagDeleteButton.addTarget(self, action: #selector(EditItemViewController.removeTag(_:)), forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 3, 0, 3)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedTags.count
    }
    
    func removeTag(sender:UIButton){
       tagCollectionView?.performBatchUpdates({ () -> Void in
            self.selectedTags.removeAtIndex(sender.tag)
            let collectionIndexPath = NSIndexPath(forItem: sender.tag, inSection: 0)
            self.tagCollectionView!.deleteItemsAtIndexPaths([collectionIndexPath])
            }, completion: { (Bool) -> Void in
                self.tagCollectionView!.reloadData()
        })
    }
    
    @IBAction func postButton(sender: UIButton) {
        self.postItem()
    }
    
    //MARK - POST Item
    func postItem(){
        self.editItemTable.endEditing(true)
        if((fields[0] as! UITextField).text!.length > 2){
            if ((fields[2] as! UITextField).text!.length > 0){
                if(Int((fields[3] as! UITextField).text!) > 0 && (fields[4] as! UITextField).text!.length>0){
                    if (Int((fields[3] as! UITextField).text!) > 999999){
                        showAlertWithMessage("Price can't be more than 999999!")
                        return
                    }else{
                        if(self.selectedTags.count > 0){
                            if (self.weightTitle.length > 0){
                                self.termsMet = true
                            }else{
                                showAlertWithMessage("Please select package weight!!")
                            }
                        } else {
                            showAlertWithMessage("Please add tags!")
                            self.termsMet = false
                            return
                        }
                    }
                } else {
                    showAlertWithMessage("Price must be more than 0.")
                    return
                }
            }else{
                showAlertWithMessage("Please select a category.")
            }
        } else {
            showAlertWithMessage("Please set item name, 3 or more characters")
            return
        }
        
        if(self.termsMet == true){
            isPostButtonTapped = true
            SVProgressHUD.show()
            if !isUploadingInProgress && !isUploadingFailed {
                self.uploadProduct()
            }else if isUploadingFailed{
                isUploadingFailed = false
                self.uploadToS3(self.uploadVideoFileURL, bucketName : Buckets.Video)
            }
        }
    }
    
    func uploadToS3(fileUrl : NSURL, bucketName : Buckets!){
        let uploadToS3: MVAwsUpload = MVAwsUpload()
        uploadToS3.delegate = self
        uploadToS3.startUpload(fileUrl, bucketName : bucketName)
    }
    
    func showAlertWithMessage(message:String){
        let alert = MOVVAlertViewController(title: "Error", message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissAndResetVideo() {
        if (self.delegate != nil) {
            self.delegate?.userDidDeselectedVideo()
        } else {
            print("Delegate MVEditItemDelegate method userDidDeselectedVideo not initialized")
        }
        videoPlayFlage = true
        MVAwsUpload.cancelAllTask()
//        NSNotificationCenter.defaultCenter().postNotificationName("videoDeselected", object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismissAndResetImage() {
        if (self.delegate != nil) {
            self.delegate?.userDidDeselectedImage()
        } else {
            print("Delegate MVEditItemDelegate method userDidDeselectedImage not initialized")
        }
//        NSNotificationCenter.defaultCenter().postNotificationName("imageDeselected", object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let index = fields?.indexOfObject(textField)
        if(textField.returnKeyType == UIReturnKeyType.Done){
            return true
        } else {
            print(fields?.count)
            fields?.objectAtIndex(index!+1) .becomeFirstResponder()
            return false
        }
    }
    
    func addRightNavItemOnView() {
        let thrashButton: UIButton = UIButton(type: UIButtonType.Custom)
        thrashButton.frame = CGRectMake(0, 0, 20, 25)
        thrashButton.setImage(UIImage(named:"thrash.png"), forState: UIControlState.Normal)
        thrashButton.addTarget(self, action: #selector(EditItemViewController.thrashButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let rightBarButton: UIBarButtonItem = UIBarButtonItem(customView: thrashButton)
        self.navigationItem.setRightBarButtonItem(rightBarButton, animated: true)
    }
    
    func thrashButtonPressed(sender:UIButton!) {
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("dismissCamera", object: nil)
    }
    
    //MARK: - Show Preview
    
    func showPreviewVideo(){
        let closeButton:UIButton = UIButton(frame: CGRectMake(CGRectGetWidth(self.view.frame)-40, 70 , 30, 30))
        closeButton.setImage(UIImage(named: "video_Close.png"), forState: .Normal)
        closeButton.addTarget(self, action:#selector(EditItemViewController.dismissPreview), forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.tag = 101
        
        playerGesture = UIGestureRecognizer(target: self, action: Selector("playVideo"))
        player = AVPlayer(URL: self.uploadVideoFileURL)
        if(player != nil){
            playerController = AVPlayerViewController()
            playerController!.player = player
            self.navigationController!.presentViewController(playerController!, animated: true, completion: {
            });
            self.player!.play()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
                // report for an error
            }
        }
    }
    
    func showPreviewImage(){
        
        let closeButton:UIButton = UIButton(frame: CGRectMake(CGRectGetWidth(self.view.frame)-40,70 , 30, 30))
        closeButton.setImage(UIImage(named: "video_Close.png"), forState: .Normal)
        closeButton.addTarget(self, action:#selector(EditItemViewController.dismissPreview), forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.tag = 101
        preview = UIImageView(frame: self.view.frame)
        
        
        let tapToCloseButton:UIButton = UIButton(frame: self.view.frame)
        tapToCloseButton.addTarget(self, action:#selector(EditItemViewController.dismissPreview), forControlEvents: UIControlEvents.TouchUpInside)
        tapToCloseButton.tag = 101
        
        let fakeGesture = UIGestureRecognizer(target: self, action: Selector("playVideo"))
        
        preview?.addGestureRecognizer(fakeGesture)
        
//        if((NSUserDefaults.standardUserDefaults().objectForKey("previewImage")) != nil){
//            var imgData = NSData(data: NSUserDefaults.standardUserDefaults().objectForKey("previewImage") as! NSData)
            preview!.setImageWithURL(self.uploadImageFileURL, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
//        } else {
//            preview!.image = UIImage(named: "AdidasFootball.jpg")
//        }
        
        preview?.alpha = 0
        closeButton.alpha = 0
        self.view.addSubview(preview!)
        self.view.addSubview(tapToCloseButton)
        self.view.addSubview(closeButton)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.preview?.alpha = 1
            closeButton.alpha = 1
        })
    }
    
    func dismissPreview() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if((self.playerController) != nil){
                self.player?.pause()
                self.player = nil
                self.playerController?.view.alpha = 0
                
            }
            
            self.preview?.alpha = 0
            self.view.viewWithTag(101)?.alpha = 0
            
            }) { (Bool) -> Void in
                if((self.playerController) != nil){
                    self.playerController?.view.removeFromSuperview()
                }
                self.preview?.removeFromSuperview()
                self.view.viewWithTag(101)?.removeFromSuperview()
                self.view.viewWithTag(101)?.removeFromSuperview()
        }
        
    }
    var visualEffectView:UIVisualEffectView?
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }

    //MARK: - MVAwsUploadDelegate
    func returnProgress(progress : Float){
        
    }
    
    func returnStatus(status : String){

    }
    
    
    func returnProgressAndStatus(progress: Float, status: String) {
        isUploadingInProgress = true
//        SVProgressHUD.showProgress(progress, status: status)
    }
    
    func uploadCompletedSuccessfully(bucket:Buckets){
//        SVProgressHUD.popActivity()
        if(bucket == Buckets.Video){
            if isPostButtonTapped{
                SVProgressHUD.show()
            }
            self.uploadToS3(self.uploadGifFileURL, bucketName: Buckets.VideoThumb)
        }else if (bucket == Buckets.VideoThumb){
            isUploadingInProgress = false
            if isPostButtonTapped{
                SVProgressHUD.show()
                self.uploadProduct()
            }
        }
    }
    
    func uploadProduct(){
        let videoFilename : String! = self.uploadVideoFileURL.lastPathComponent
        let imageFilename : String! = self.uploadGifFileURL.lastPathComponent
        
        if var categoryName = (fields[2] as! UITextField).text {
            categoryName = "#\(categoryName.componentsSeparatedByString(" ").joinWithSeparator(""))"
            if !selectedTags.contains(categoryName) {
                selectedTags.insert(categoryName, atIndex: 0)
            }
        }
        
        if var brandName = (fields[1] as! UITextField).text {
            brandName = "#\(brandName.componentsSeparatedByString(" ").joinWithSeparator(""))"
            if !selectedTags.contains(brandName) {
                selectedTags.insert(brandName, atIndex: 1)
            }
        }
        
        var tags : String = ""
        for i : Int in 0 ..< self.selectedTags.count{
            if(i < self.selectedTags.count - 1){
                tags = tags + "\(self.selectedTags[i]), "
            }
            else{
                tags = tags + "\(self.selectedTags[i])"
            }
        }
        
        SVProgressHUD.show()
        self.view.userInteractionEnabled = false
        MVDataManager.uploadProduct(MVParameters.sharedInstance.currentMVUser.id, productName: (fields[0] as! UITextField).text, price: Int((fields[3] as! UITextField).text!), quantity: ((fields[4] as! UITextField).text! as NSString).integerValue, latitude: self.userCoordinate.latitude, longitude: self.userCoordinate.longitude, previewImage: imageFilename, videoFile: videoFilename, tags: tags, parcelSizeId: self.getParcelSizeId(weightTitle) , categoryId: "\(selectedCategory.rawValue)", successBlock: { response in
            SVProgressHUD.popActivity()
            let shareUrl = response as! String
            //                self.removeVideoAndImageFromDocumentsDirectory()
            self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            let mainSt = UIStoryboard(name: "Main", bundle: nil)
            shareVC = mainSt.instantiateViewControllerWithIdentifier("shareVC")  as! MVShareViewController
            shareVC.delegate = self
            shareVC.productTitle = (self.fields[0] as! UITextField).text
            shareVC.shareUrl = shareUrl
            shareVC.shareVideo = self.uploadVideoFileURL
            shareVC.shareImg = self.shareImage
            shareVC.imgLocalPath = self.uploadImageFileURL
            shareVC.view.frame = UIScreen.mainScreen().bounds
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.addSubview(shareVC.view)
            self.view.userInteractionEnabled = true
            SVProgressHUD.dismiss()
            
            //                self.dismissViewControllerAnimated(true, completion: nil)
            //                NSNotificationCenter.defaultCenter().postNotificationName("dismissCamera", object: nil)
        }) { failure in
            print(failure)
            SVProgressHUD.popActivity()
            SVProgressHUD.dismiss()
            self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.dismissViewControllerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("dismissCamera", object: nil)
            self.view.userInteractionEnabled = true
        }
    }
    
    func saveVideoToDocumentsDirectory(){
        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(self.uploadVideoFileURL, completionBlock: nil)
//        let fileManager : NSFileManager  = NSFileManager.defaultManager()
//
//        do {
//            try fileManager.removeItemAtPath(self.uploadVideoFileURL.path!)
//        } catch let error as NSError {
//            print(error)
//        }
//
//        do {
//            try fileManager.removeItemAtPath(self.uploadImageFileURL.path!)
//        } catch let error as NSError {
//            print(error)
//        }
    }
    
    func uploadFailedMisserably() {
        SVProgressHUD.popActivity()
        if !isUploadingFailed{
            dispatch_async(dispatch_get_main_queue(), { 
                UIAlertView(title: "Error", message: "Network not reachable", delegate: nil, cancelButtonTitle: "Okay").show()
            })
        }
        isUploadingFailed = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userCoordinate = manager.location!.coordinate
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(TagsViewController){
            self.tagsViewController = segue.destinationViewController as? TagsViewController
            self.tagsViewController.selectedTags = self.selectedTags
            self.tagsViewController.delegate = self
        }
        if segue.identifier == "ShippingCellId" {
            let deliveryOptionVC = segue.destinationViewController as? DeliveryOptionsViewController
            deliveryOptionVC!.delegate = self
            deliveryOptionVC!.selectedOption = weightTitle
        }
    }
    
    func addedTag(tagsArray : Array<String>){
        videoPlayFlage = true;
        self.selectedTags = tagsArray
        editItemTable.reloadData()
    }
    
    @IBAction func tagViewTapGesture(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("AddTagsId", sender: sender)
    }
    
    @IBAction func categoryCellTapGesture(sender: UITapGestureRecognizer) {
        let categorySheet = UIAlertController.init(title: "Categories", message: "", preferredStyle: .ActionSheet)
        for category in ProductCategory.categories{
            categorySheet.addAction(UIAlertAction(title: category.stringValue, style: .Default, handler: { (alert) in
                self.searchWithAlertControllerTitle(category)
            }))
        }
        categorySheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alert) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1*Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.fields[3].becomeFirstResponder()
            }
        }))
        self.presentViewController(categorySheet, animated: true, completion: nil)
    }
    
    func searchWithAlertControllerTitle(productCategory:ProductCategory){
        self.selectedCategory = productCategory
        self.editItemTable.reloadData()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1*Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { 
            self.fields[3].becomeFirstResponder()
        }
    }
    
    
    @IBAction func onCloseButton(sender: AnyObject) {
        MVAwsUpload.cancelAllTask()
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("dismissCamera", object: nil)
    }
    
    func dissmisCameraView() {
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("dismissCameraView", object: nil)
    }
    
    func selectedOption(option: String) {
        weightTitle = option
        editItemTable.reloadData()
    }
    
    func getParcelSizeId(title:String) -> String {
        if title ==  "0 - 0.5 lbs"{ return "1" }
        else if title ==  "0 - 3 lbs"{ return "2" }
        else if title ==  "3 - 10 lbs"{ return "3" }
        else if title ==  "10 - 20 lbs"{ return "4" }
//        else if title ==  "20 - 70 lbs"{ return "5" }
        else{return "" }
    }
    
    
//MARK: - create gif methods
    
    func createGif()  {
        let asset :AVAsset = AVAsset(URL:uploadVideoFileURL)
        
        let imageArr = NSMutableArray()
        
//        if let data = NSData(contentsOfURL: uploadImageFileURL)
//        {
//            if let img1 =  UIImage(data: data)
//            {
//                
//                imageArr.addObject(rotateCameraImageToProperOrientation(img1))
//            }
//        }
        let totalTime = Int(CMTimeGetSeconds(asset.duration))
        for time in 1..<(totalTime/2)-1{
            generateThumnail(asset,fromTime: Float64(time), arr : imageArr)
        }
//        generateThumnail(asset,fromTime: Float64(totalTime/2), arr : imageArr)
//        generateThumnail(asset,fromTime: Float64(totalTime), arr : imageArr)
        
        let images = imageArr as NSArray as! [UIImage]
        createGIF(with:images,frameDelay:0.5,callback : {
            (data : NSData?, error :NSError?) in
            
        })
        
    }
    
    func generateThumnail(asset : AVAsset, fromTime:Float64, arr : NSMutableArray)
    {
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero
        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero
        let time : CMTime = CMTimeMakeWithSeconds(fromTime, 600)
        var img : UIImage!
        do
        {
            let cgImage : CGImageRef = try assetImgGenerate.copyCGImageAtTime(time, actualTime: nil)
            img  =  UIImage(CGImage: cgImage)
            img = rotateCameraImageToProperOrientation(img)
        }
        catch let error as NSError
        {
            print(error)
        }
        if img != nil
        {
            arr.addObject(img)
        }
        
    }
    
    
    func createGIF(with images: [UIImage], loopCount: Int = 0, frameDelay: Double, callback: (_ data: NSData?, error: NSError?) -> ())
    {
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        
        let documentsDirectory = NSTemporaryDirectory()
        let url = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("animated\(NSDate().timeIntervalSince1970).gif")
        
        
        
        if let url1 = url as? NSURL
        {
            let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, Int(images.count), nil)
            CGImageDestinationSetProperties(destination!, fileProperties)
            
            for i in 0..<images.count {
                CGImageDestinationAddImage(destination!, images[i].CGImage!, frameProperties)
            }
            
            if CGImageDestinationFinalize(destination!) {
                self.uploadGifFileURL = url
                callback(data: NSData(contentsOfURL: url), error: nil)
                self.editItemTable.reloadData()
            } else {
                callback(data: nil, error: nil)
            }
        } else  {
            callback(data: nil, error: nil)
        }
    }
    
    
    
    func rotateCameraImageToProperOrientation(imageSource : UIImage) -> UIImage {
        
        let imgRef = imageSource.CGImage;
        
        let width = CGFloat(CGImageGetWidth(imgRef));
        let height = CGFloat(CGImageGetHeight(imgRef));
        
        var bounds = CGRectMake(0, 0, width, height)
        
        let scaleRatio : CGFloat = 1
        
        var transform = CGAffineTransformIdentity
        let orient = imageSource.imageOrientation
        let imageSize = CGSizeMake(CGFloat(CGImageGetWidth(imgRef)), CGFloat(CGImageGetHeight(imgRef)))
        
        
        switch(imageSource.imageOrientation) {
        case .Up :
            transform = CGAffineTransformIdentity
            
        case .UpMirrored :
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            
        case .Down :
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI));
            
        case .DownMirrored :
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            
        case .Left :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0);
            
        case .LeftMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0);
            
        case .Right :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0);
            
        case .RightMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0);
            
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        if orient == .Right || orient == .Left {
            CGContextScaleCTM(context, -scaleRatio, scaleRatio);
            CGContextTranslateCTM(context, -height, 0);
        } else {
            CGContextScaleCTM(context, scaleRatio, -scaleRatio);
            CGContextTranslateCTM(context, 0, -height);
        }
        
        CGContextConcatCTM(context, transform);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
        
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return imageCopy;
    }
}
