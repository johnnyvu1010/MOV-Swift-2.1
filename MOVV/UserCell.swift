//
//  UserCell.swift
//  MOVV
//
//  Created by Martino Mamic on 13/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet var followButton: UIButton!
    @IBOutlet var hashtag: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userProfileButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
