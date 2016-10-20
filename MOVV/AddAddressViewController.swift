//
//  AddAddressViewController.swift
//  MOVV
//
//  Created by Yuki on 14/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class AddAddressViewController: UIViewController {

    @IBOutlet weak var txt_streetAdr: UITextField!
    
    @IBOutlet weak var txt_locality: UITextField!
    
    @IBOutlet weak var txt_region: UITextField!
    
    @IBOutlet weak var txt_postalcode: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //Button Action
    
    @IBAction func btnBackClicked(sender: AnyObject) {
        
    }

    @IBAction func btnSaveClicked(sender: AnyObject) {
        
    }
    
    
}
