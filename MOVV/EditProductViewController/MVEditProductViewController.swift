//
//  MVEditProductViewController.swift
//  MOVV
//
//  Created by Raushan Kumar on 29/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import SVProgressHUD

class MVEditProductViewController: UIViewController,TagsViewControllerDelegate{

    var item : MVProduct!
    var selectedTags = Array<String>()
    var initialCategory : String!
    var initialTitle : String!
    var initialtags : String!
    var updateCategory : String!
    @IBOutlet weak var dataTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        item.tags = NSMutableArray(array: selectedTags).componentsJoinedByString(", ")
        dataTable.reloadData()
    }

    //MARK:- Ui setup methods
    
    func setUpView(){
        initialtags = item.tags
        initialCategory = item.categoryId
        initialTitle = item.name
        selectedTags.appendContentsOf(item.tags.componentsSeparatedByString(", "))
        dataTable.registerNib(UINib(nibName: "MVEditProductViewCell", bundle: nil), forCellReuseIdentifier:"EditProductViewCell" )
        dataTable.estimatedRowHeight = 44
        dataTable.rowHeight = UITableViewAutomaticDimension
        dataTable.reloadData()
    }
    
    
     func showCategory() {
        let categorySheet = UIAlertController.init(title: "Categories", message: "", preferredStyle: .ActionSheet)
        for category in ProductCategory.categories{
            categorySheet.addAction(UIAlertAction(title: category.stringValue, style: .Default, handler: { (alert) in
                self.updateView(category)
            }))
        }
        categorySheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(categorySheet, animated: true, completion: nil)
    }
    
    func updateView(category : ProductCategory){
        selectedTags[0] = "#\(category.stringValue)"
        item.tags = selectedTags.joinWithSeparator(", ")
        item.categoryId = "\(category.rawValue)"
        dataTable.reloadData()
    }
    
    func showTagsViewController(){
        if let storyboard = UIStoryboard(name: "Main", bundle: nil) as? UIStoryboard{
            if let viewController = storyboard.instantiateViewControllerWithIdentifier("TagsViewController") as? TagsViewController{
                viewController.delegate = self
                var temp = selectedTags
                temp.removeRange(Range(0..<2))
                viewController.selectedTags = temp
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func addedTag(tagsArray: Array<String>) {
        var newTags = tagsArray
        if selectedTags.count > -1{
            newTags.insert(selectedTags[0], atIndex: 0)
        }
        if selectedTags.count > 0{
            newTags.insert(selectedTags[1], atIndex: 1)
        }
        selectedTags.removeAll()
        selectedTags.appendContentsOf(newTags)
    }
}

//MARK:- tableview datasource and delegate

extension MVEditProductViewController :UITableViewDataSource , UITableViewDelegate
{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if let cell = tableView.dequeueReusableCellWithIdentifier("EditProductViewCell") as? MVEditProductViewCell{
            cell.tag = indexPath.row
            cell.fillDetailsWithCart(item, editType: EditProductFieldType(rawValue : indexPath.row)!)
            cell.selectionStyle = .None
            return cell
        }
        let cell = UITableViewCell()
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch  EditProductFieldType(rawValue : indexPath.row)!{
        case .Category:
            showCategory()
        case .Tags:
            showTagsViewController()
        default:
            return
        }
    }
    
    func validateFields()-> Bool{
        if item.name.characters.count == 0{
            showMessage(EditProductFieldType.Title.errorMsg)
            return false
        } else if item.categoryId.characters.count == 0 {
            showMessage(EditProductFieldType.Category.errorMsg)
            return false
        } else if item.tags.characters.count == 0 {
            showMessage(EditProductFieldType.Tags.errorMsg)
            return false
        }
        return true
    }
    
    func showMessage(message :String?){
        let alert:UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateBtnTaped(sender: AnyObject) {
        if validateFields(){
            let refreshAlert = UIAlertController(title: "", message: "Your edits will upload within 5 minutes", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                self.updateProduct()
            }))
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        SVProgressHUD.show()
        let parameters :  NSDictionary! = ["user_id":"\(item.user.id)" ,"product_id":"\(item.id)"]
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: "product-delete/", successBlock: { response in
            SVProgressHUD.dismiss()
            self.navigationController?.dismissViewControllerAnimated(true, completion:nil)
        }) { failure in
            print(failure)
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func gotoBackTaped(sender: AnyObject) {
        item.categoryId = initialCategory
        item.name = initialTitle
        item.tags = initialtags
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func updateProduct(){
        SVProgressHUD.show()
        let parameters :  NSDictionary! = ["user_id":"\(item.user.id)" ,"product_id":"\(item.id)","name":"\(item.name)" ,"price":"\(item.price)" , "tags":"\(item.tags)","category_id":"\(item.categoryId)","parcel_size_id":"\(item.parcelSizeId)"]
        
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: "edit-product/", successBlock: { response in
            SVProgressHUD.dismiss()
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
        }) { failure in
            print(failure)
            SVProgressHUD.dismiss()
        }
    }
}
