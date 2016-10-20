//
//  ChatCell.swift
//  MOVV
//
//  Created by Martino Mamic on 26/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var systemTimeLabel: UILabel!
    @IBOutlet var chatText: UILabel!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userOneImage: UIImageView!
    @IBOutlet var chatIndicatorLeft: UIImageView!
    @IBOutlet var chatIndicatorRight: UIImageView!
    @IBOutlet var clockIcon: UIImageView!
    
    @IBOutlet var containerView: UIView!

    
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var postalCodeLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
