//
//  MVUserReviewTableViewCell.swift
//  MOVV
//
//  Created by Yuki on 15/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVUserReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var userprofileImage: UIImageView!
    @IBOutlet weak var userprofileButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var star1Btn: UIButton!
    @IBOutlet weak var star2Btn: UIButton!
    @IBOutlet weak var star3Btn: UIButton!
    @IBOutlet weak var star4Btn: UIButton!
    @IBOutlet weak var star5Btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
