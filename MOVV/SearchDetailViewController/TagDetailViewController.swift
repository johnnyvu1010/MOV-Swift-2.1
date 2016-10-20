//
//  TagDetailViewController.swift
//  MOVV
//
//  Created by Divya Saraswati on 28/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import QuartzCore
import SVProgressHUD

class TagDetailViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    var tagName:String!
    @IBOutlet var collectionViewTags: UICollectionView!
    var productList:[MVProduct]! = [MVProduct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredStatusBarStyle()
        self.supportedInterfaceOrientations()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarVideo"), forBarMetrics: .Default)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = false
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.userInteractionEnabled = true
        self.title = tagName
        self.edgesForExtendedLayout=UIRectEdge.None
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().postNotification(showTabbarNotification)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navbarVideo"), forBarMetrics: UIBarMetrics.Default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Load Data
    func loadData(){
        let request : String! = "tag-products"
        let parameters :  NSDictionary! = ["tag":tagName]
        SVProgressHUD.show()
        MVSyncManager.getDataFromServerUsingPOST(parameters, request: request, successBlock: { response in
            SVProgressHUD.popActivity()
            let products = response.valueForKey("products") as? NSArray
            products?.enumerateObjectsUsingBlock({ (obj, idx, stop) in
                self.productList.append(MVProduct.init(dictionary: obj as! NSDictionary))
            })
            self.collectionViewTags.reloadData()
        }) { failure in
            SVProgressHUD.popActivity()
            let alert:UIAlertController = UIAlertController.init(title: "", message:"Something goes wrong. Please try again."  as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel){ (action) in
                });
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Collection View Delegate
   
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = CGRectGetWidth(collectionView.bounds)
        return CGSize(width: screenWidth/2-5, height: screenWidth/2+5)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagDetailCollectionViewCell", forIndexPath: indexPath)as! TagDetailCollectionViewCell
        cell.productImage.layer.cornerRadius=4.0
        cell.productImage.layer.masksToBounds=true
        let product:MVProduct = productList[indexPath.row]
        cell.productImage.setImageWithURL(NSURL(string: product.previewImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        cell.profilePic.setImageWithURL(NSURL(string: product.user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        cell.productName.text = product.name
        cell.productPrice.text = "$ \(product.price)"
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let productViewController = main.instantiateViewControllerWithIdentifier("videoPlayID")  as! VideoPlayViewController
        productViewController.productDetail = productList[indexPath.row]
        self.navigationController!.pushViewController(productViewController, animated: true)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}
