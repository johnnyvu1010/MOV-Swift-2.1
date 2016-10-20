//
//  EditItemCell.swift
//  MOVV
//
//  Created by Martino Mamic on 07/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit
import FBSDKShareKit

class EditItemCell: UITableViewCell {
    
    @IBOutlet var progressView: UIProgressView! //AWS
    @IBOutlet var statusLabel: UILabel! //AWS
    
    var checked:Bool!

    @IBOutlet var videoPreview: UIImageView!
    @IBOutlet var dismissAndRecordVideo: UIButton!

    @IBOutlet var titleField: UITextField!
    @IBOutlet var brandField: UITextField!
    @IBOutlet var priceField: UITextField!
    @IBOutlet var categoryField: UITextField!
    @IBOutlet var quantityField: UITextField!
    @IBOutlet var labelTags: UILabel!
    @IBOutlet var labelShippingOption: UILabel!
    
    @IBOutlet var postButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}



