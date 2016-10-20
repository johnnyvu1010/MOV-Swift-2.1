//
//  MVVideoLikesTableViewCell.swift
//  MOVV
//
//  Created by Yuki on 31/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVVideoLikesTableViewCell: UITableViewCell {

    @IBOutlet weak var likedUserImageView: UIImageView!
    @IBOutlet weak var likedUserNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
