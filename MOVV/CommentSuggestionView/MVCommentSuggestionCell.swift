//
//  MVCommentSuggestionCell.swift
//  MOVV
//
//  Created by Raushan Kumar on 26/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVCommentSuggestionCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillDetailsWithUser(user : MVUser)
    {
        displayNameLabel.text = "\(user.displayName.capitalizedString)"
        userImage.setImageWithURL(NSURL(string: user.profileImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

        if user.username.characters.count > 1{
            self.userNameLabel.text = "@\(user.username)"
        }else{
            userNameLabel.text = ""
        }
        
        MVHelper.addMOVVCornerRadiusToView(userImage)
    }
    
}
