//
//  GridCell.swift
//  MOVV
//
//  Created by Martino Mamic on 13/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {
    
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemPreview: UIImageView!
    @IBOutlet var userLocationLabel: UILabel!
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var usernameLabel: TTTAttributedLabel!
    
    @IBOutlet var userIconWidth: NSLayoutConstraint!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var commetButton: UIButton!
    @IBOutlet var commentCountLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet var userTagLabel: UILabel!
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var followButton: UIButton!
   
    @IBOutlet var userProfileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
