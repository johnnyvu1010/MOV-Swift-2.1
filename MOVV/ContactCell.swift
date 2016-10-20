//
//  ContactCell.swift
//  MOVV
//
//  Created by Martino Mamic on 17/07/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

protocol ContactCellDelegate {
    func onTouchSendButton(isSendSMS:Bool, forCell:UITableViewCell)
}

class ContactCell: UITableViewCell {

    @IBOutlet var contactNameLabel: UILabel!
    @IBOutlet var contactDetailsLabel: UILabel!
    @IBOutlet var sendSMSButton: UIButton!
    var isSendSMS:Bool!
    var delegate:ContactCellDelegate? = nil
    
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

    @IBAction func onTouchSendButton(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.onTouchSendButton(self.isSendSMS, forCell:self)
        }
    }
}
