//
//  MVLoginSignUpViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 20/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD
import IQKeyboardManager

enum ViewControllerDataType : Int {
    case Login, Signup
}


class MVLoginSignUpViewController: UIViewController, MVLoginSignUPDetailsCellDelegate {

    var footerView : MVLoginSignUpFooterView!
    var currentUser = MVLoginSignUpUser()
    var controllerType = ViewControllerDataType(rawValue : 0)!
    var selectedImage:UIImage?
    var uploadImage : MVAwsUpload! = nil
    var avatarFilePath, avatarFileName:String?
    var returnKeyHandler:IQKeyboardReturnKeyHandler!
    var firstResponder:UITextField!
    @IBOutlet weak var dataTable: UITableView!
    //MARK:- Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    var visualEffectView:UIVisualEffectView?
    func addBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        //        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.frame = CGRectMake(0, 0, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 64)
        visualEffectView!.userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[0].addSubview(visualEffectView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        //        returnKeyHandler = IQKeyboardReturnKeyHandler.init(viewController: self)
        if(controllerType == .Login && (visualEffectView == nil || !visualEffectView!.isDescendantOfView(self.navigationController!.navigationBar))){
            addBlurEffect()
        }
        self.navigationController?.navigationBarHidden = false
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addFooter()
    }


    //MARK:- Ui setup methods

    func setUpView()
    {
        dataTable.registerNib(UINib(nibName: "MVLoginSignUpDetailsCell", bundle: nil), forCellReuseIdentifier:"MVLoginSignUpDetailsCell" )
        dataTable.registerNib(UINib(nibName: "MVLoginSignUpConfirmationCell", bundle: nil), forCellReuseIdentifier:"MVLoginSignUpConfirmationCell" )
        dataTable.registerNib(UINib(nibName: String(LoginSignUpImageCell), bundle: nil), forCellReuseIdentifier:String(LoginSignUpImageCell))
        dataTable.estimatedRowHeight = 200
        dataTable.rowHeight = UITableViewAutomaticDimension
        addFooter()
        dataTable.reloadData()
        self.uploadImage = MVAwsUpload()
        self.uploadImage.delegate = self
    }
}
//MARK:- MVAwsUploadDelegate
extension MVLoginSignUpViewController:MVAwsUploadDelegate{
    func returnProgress(progress : Float) {
        print(progress)
    }

    func returnStatus(status : String) {
        print(status)
    }

    func returnProgressAndStatus(progress: Float, status: String) {
        SVProgressHUD.showProgress(progress, status: status)
    }

    func uploadCompletedSuccessfully(bucket:Buckets) {
        sendSignupRequest()
    }

    func uploadFailedMisserably() {
        SVProgressHUD.dismiss()
        self.showMessage("Image uploading failed.")
    }

}
//MARK:- ImageUploadRelatedMethods
extension MVLoginSignUpViewController:LoginSignUpImageCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    func uploadUserImage() {
        avatarFileName = "profile_" + MVHelper.generateIdentifierWithLength(15)
        avatarFilePath = MVHelper.saveFileToDocumentsDirectoryWithNameAndExtension(selectedImage!, filename: "/\(avatarFileName!)", ext: "jpg")
        let avatarFilePathURL : NSURL! = NSURL(fileURLWithPath: avatarFilePath!)
        self.avatarFileName = avatarFileName! + ".jpg"
        SVProgressHUD.show()
        self.uploadImage.startUpload(avatarFilePathURL, bucketName: Buckets.Image)
    }

    func userImageTapped() {
        dispatch_async(dispatch_get_main_queue(), {
            self.presentImagePicker()
        })
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let tempImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            let image = tempImage.resizeImageInAspectRatio(600)
            selectedImage = image
            dataTable.reloadData()
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func presentImagePicker() {
        let alertController = MOVVAlertViewController(title: nil, message: "Choose photo or take new", preferredStyle: .ActionSheet)
        alertController.shouldAutorotate()
        let oneAction = UIAlertAction(title: "Choose from library", style: .Default) { (_) in
            let imagePicker = CameraViewController()
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:MOVVGreen]
            UIBarButtonItem.appearance().tintColor = MOVVGreen
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            imagePicker.sourceType = .SavedPhotosAlbum
            imagePicker.navigationItem.title = "Choose photo"
            self.navigationController!.presentViewController(imagePicker, animated: true, completion: nil)
        }

        let twoAction = UIAlertAction(title: "Take new picture", style: .Default) { (_) in
            let imagePicker = CameraViewController()
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            imagePicker.sourceType = .Camera
            imagePicker.navigationItem.title = "Take new picture"
            imagePicker.navigationController?.setNeedsStatusBarAppearanceUpdate()
            self.navigationController!.presentViewController(imagePicker, animated: true, completion: nil)


        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        alertController.addAction(oneAction)
        alertController.addAction(twoAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) {
        }
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
}

//MARK:- tableview datasource and delegate

extension MVLoginSignUpViewController :UITableViewDataSource , UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            switch controllerType {
            case .Login:
                self.navigationItem.title = "Login"
                return 2
            default:
                self.navigationItem.title = "Signup"
                return 6
            }
        }else{
            return 1
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let cell = tableView.dequeueReusableCellWithIdentifier("MVLoginSignUpDetailsCell") as? MVLoginSignUpDetailsCell{
                switch controllerType {
                case .Login:
                    cell.tag = indexPath.row
                    cell.datatextField.tag = indexPath.row
                    cell.delegate = self
                    cell.fillDetailsWithLoginUser(currentUser)
                    cell.datatextField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(MVLoginSignUpViewController.textFieldPrevAction(_:)), nextAction: #selector(MVLoginSignUpViewController.textFieldNextAction(_:)), doneAction: #selector(MVLoginSignUpViewController.textFieldNextAction(_:)))
                default:
                    cell.tag = indexPath.row - 1
                    if indexPath.row == 0{
                        if let cell = tableView.dequeueReusableCellWithIdentifier(String(LoginSignUpImageCell)) as? LoginSignUpImageCell{
                            cell.configureForImage(selectedImage)
                            cell.delegate = self
                            return cell
                        }
                    }else{
                        cell.datatextField.tag = indexPath.row - 1
                        cell.fillDetailsWithSignUpUser(currentUser)
                        cell.delegate = self
                        cell.datatextField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(MVLoginSignUpViewController.textFieldPrevAction(_:)), nextAction: #selector(MVLoginSignUpViewController.textFieldNextAction(_:)), doneAction: #selector(MVLoginSignUpViewController.textFieldNextAction(_:)))
                    }
                }
                cell.selectionStyle = .None
                return cell
            }
        }
        else if indexPath.section == 1
        {
            if let cell = tableView.dequeueReusableCellWithIdentifier("MVLoginSignUpConfirmationCell") as? MVLoginSignUpConfirmationCell{
                switch controllerType {
                case .Login:
                    cell.doneBtn.setTitle("LOGIN", forState: .Normal)
                default:
                    cell.doneBtn.setTitle("SIGN UP", forState: .Normal)
                }
                cell.doneBtn.addTarget(self, action: #selector(MVLoginSignUpViewController.doneBtnTaped), forControlEvents: .TouchUpInside)
                cell.selectionStyle = .None
                return cell
            }
        }
        else{
        }
        let cell = UITableViewCell()
        cell.selectionStyle = .None
        return cell
    }

    func currentFirstResponder(textField: UITextField) {
        
    }

    func textFieldPrevAction(button:IQBarButtonItem){
        if IQKeyboardManager.sharedManager().canGoPrevious{
            IQKeyboardManager.sharedManager().goPrevious()
        }
    }

    func textFieldNextAction(button:IQBarButtonItem){
        if IQKeyboardManager.sharedManager().canGoNext{
            IQKeyboardManager.sharedManager().goNext()
        }else{
            IQKeyboardManager.sharedManager().resignFirstResponder()
        }
    }

    func doneBtnTaped() {
        self.view.endEditing(true)
        if self.validateFields(){
            switch controllerType {
            case .Login:
                self.sendLoginRequest()
            default:
                self.uploadUserImage()
            }
        }
    }

    func validateFields()-> Bool{
        switch controllerType {
        case .Login:
            if currentUser.email != nil && currentUser.email?.characters.count > 0{
                if isValidEmail(currentUser.email!) {
                    if currentUser.password != nil && currentUser.password?.characters.count > 0{
                        return true
                    }else{
                        showMessage("Password is required.")
                    }
                }else{
                    showMessage("Please enter valid email.")
                }
            }else{
                showMessage("Email is required.")
            }
        default:
            if selectedImage != nil{
                if currentUser.firstName != nil && currentUser.firstName?.characters.count > 0{
                    if currentUser.lastName != nil && currentUser.lastName?.characters.count > 0{
                        if currentUser.email != nil && currentUser.email?.characters.count > 0{
                            if isValidEmail(currentUser.email!){
                                if currentUser.userName != nil && currentUser.userName?.characters.count > 0{
                                    if currentUser.password != nil && currentUser.password?.characters.count > 0{
                                        return true
                                    }
                                    else{
                                        showMessage("Password is required.")
                                    }
                                }else{
                                    showMessage("Username is required.")
                                }
                            }else{
                                showMessage("Please enter valid email.")
                            }
                        }else{
                            showMessage("Email is required.")
                        }
                    }else{
                        showMessage("Last Name is required.")
                    }
                }else{
                    showMessage("First Name is required.")
                }
            }else{
                showMessage("Image is required.")
            }
        }
        return false
    }

    func isValidEmail(email:String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(email, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, email.characters.count)) != nil
        } catch {
            return false
        }
    }

    func sendLoginRequest(){
        let request : String! = "user-login/"
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(currentUser.getDict(), request: request, successBlock: { response in
            SVProgressHUD.dismiss()
            self.showHome(response as! NSDictionary)
        }) { failure in
            SVProgressHUD.dismiss()
            self.showMessage(failure)
        }
    }

    func sendSignupRequest(){
        let request : String! = "user-register/"
        SVProgressHUD.show()
        let dict = currentUser.getDict()
        dict["profile_image"] = avatarFileName
        MVSyncManager.getDataFromServerUsingPOST(dict, request: request, successBlock: { response in
            SVProgressHUD.dismiss()
            self.showHome(response as! NSDictionary)
        }) { failure in
            SVProgressHUD.dismiss()
            self.showMessage(failure)
        }
    }

    func showMessage(message :String?){
        let alert:UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func addFooter(){
        if let view = MVLoginSignUpFooterView.getInstance(){
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 85)
            dataTable.tableFooterView = view
            switch controllerType {
            case .Login:
                view.loginBtn.hidden = true
            default:
                view.signUpBtn.hidden = true
            }
            view.loginBtn.addTarget(self, action: #selector(MVLoginSignUpViewController.goToLogin), forControlEvents: .TouchUpInside)
            view.signUpBtn.addTarget(self, action: #selector(MVLoginSignUpViewController.goToSignUp), forControlEvents: .TouchUpInside)
        }

    }

    func showHome(responseMessage:NSDictionary){
        let userDict : NSDictionary! = (responseMessage.objectForKey("user") as! NSArray).firstObject as! NSDictionary
        let user : MVUser! = MVUser(dictionary: userDict)
        MVParameters.sharedInstance.currentMVUser = user
        user.save()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userLoggedIn")
        if let token = MVParameters.sharedInstance.devicePushToken {
            MVDataManager.registerForNotifications(user.id, token: token, successBlock: { response in
                print(response)
            }) { failure in
                print(failure)
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("tabBarVC") as! CustomTabBarController
        self.presentViewController(initialViewController, animated: true, completion: {
            if self.controllerType == .Signup{
                if let check = NSUserDefaults.standardUserDefaults().valueForKey("onboardingShown") as? Bool{
                    if !check{
                        self.showOnBoarding(initialViewController)
                    }
                }else{
                    self.showOnBoarding(initialViewController)
                }
            }else{
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })

    }

    func showOnBoarding(initialViewController:CustomTabBarController){
        initialViewController.insNew = true
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: "onboardingShown")
        NSUserDefaults.standardUserDefaults().synchronize()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("viewPreviewVC") as! PreviewVideoController
        controller.modalPresentationStyle = .Popover
        initialViewController.presentViewController(controller, animated: true, completion: nil);
    }
    
    func goToLogin(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func goToSignUp(){
        if let viewController = MVLoginSignUpViewController(nibName: "MVLoginSignUpViewController", bundle: nil) as? MVLoginSignUpViewController
        {
            viewController.controllerType = ViewControllerDataType.Signup
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}