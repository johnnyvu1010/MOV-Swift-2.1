//
//  MVNavigationController.swift
//  MOVV
//
//  Created by Nikolai on 04/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import Branch
import SVProgressHUD


class MVNavigationController: MOVVNavigationController, BranchDeepLinkingController, MVItemDetailVCDelegate {

    private var itemVC: ItemDetailViewController? = nil
    var deepLinkingCompletionDelegate: BranchDeepLinkingControllerCompletionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.itemVC = self.viewControllers.first as? ItemDetailViewController
        self.itemVC?.isPresentedViaDeepLink = true
        self.itemVC?.navControllerDelegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Deeplinking
    func configureControlWithData(data: [NSObject : AnyObject]!) {
        print(data)
        guard let productId: String = data["product_id"] as? String else {
            print("Error while initializig")
            assertionFailure("Error while initializig app via deeplinking")
            return
        }
        
        SVProgressHUD.show()
        MVDataManager.fetchProduct(productId, successBlock: { (procduct) in
        dispatch_async(dispatch_get_main_queue(), {
        SVProgressHUD.popActivity()
        if self.itemVC != nil {
            self.itemVC!.productDetail = procduct
            self.itemVC!.itemDetailsTable.reloadData()
            self.itemVC!.fetchData()
        }
        })
        
        
        }) { (e) in
            dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.popActivity()
            print(e)
            self.deepLinkingCompletionDelegate!.deepLinkingControllerCompleted()
            })
                
        }
        print("Item ID: \(productId)")
        // show the picture
    }
    
    func onTouchCloseButton() {
        self.deepLinkingCompletionDelegate!.deepLinkingControllerCompleted()
    }
    
    
}
