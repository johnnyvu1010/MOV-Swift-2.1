//
//  MVLikedUserCell.swift
//  MOVV
//
//  Created by Vidhan Nandi on 08/09/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVLikedUserCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configUsingObj(likedUser:MVLikedUser) {
        usernameLabel.text = likedUser.fullName
        userImageView.setImageWithURL(NSURL(string: likedUser.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        MVHelper.addMOVVCornerRadiusToView(userImageView)
    }
}
