//
//  LoginSignUpImageCell.swift
//  MOVV
//
//  Created by Vidhan Nandi on 08/09/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
protocol LoginSignUpImageCellDelegate:NSObjectProtocol {
    func userImageTapped()
}
class LoginSignUpImageCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!

    weak var delegate:LoginSignUpImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor(red: 58/255, green: 245/255, blue: 22/255, alpha: 1).CGColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureForImage(image:UIImage?) {
        if let img = image {
            userImageView.image = img
            userImageView.contentMode = .ScaleAspectFill
        }else{
            userImageView.image = UIImage(named: "cameraAddImage")
            userImageView.contentMode = .Center
        }
    }
    @IBAction func userImageAction(sender: AnyObject) {
        delegate?.userImageTapped()
    }
}
