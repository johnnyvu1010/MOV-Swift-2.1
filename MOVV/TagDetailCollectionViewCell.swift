//
//  TagDetailCollectionViewCell.swift
//  MOVV
//
//  Created by Divya Saraswati on 28/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit
import QuartzCore
class TagDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var profileViewBtn: UIButton!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.profilePic.layer.cornerRadius=4
//        self.profilePic.layer.masksToBounds=true
//        // Initialization code
//    }
    func configureCellWIthDict(dict:NSDictionary) -> Void {
        
    }
}

