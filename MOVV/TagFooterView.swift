//
//  TagFooterView.swift
//  MOVV
//
//  Created by Martino Mamic on 08/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class TagFooterView: UIView {

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var addTagButton: UIButton!
    @IBOutlet var tagField: UITextField!
    
    
    override func awakeFromNib() {
        doneButton.layer.cornerRadius = 4
        doneButton.clipsToBounds = true
        addTagButton.layer.borderWidth = 0.5
        addTagButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        tagField.layer.borderWidth = 0.5
        tagField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
    }
    
}
