//
//  ContactTextFieldTableViewCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 22/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class ContactTextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitleHint: UILabel!
    @IBOutlet weak var labelRequiredHint: UILabel!
    @IBOutlet weak var textFieldDetails: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    

}
