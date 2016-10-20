//
//  ProfileCollectionViewCell.swift
//  MOVV
//
//  Created by Martino Mamic on 27/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

protocol ProfileCollectionViewCellDelegate
{
    func onTouchShareButton(cell:UICollectionViewCell)
    func likesCountTapped(tag:Int)
}

class ProfileCollectionViewCell: UICollectionViewCell {

    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemTagsLabel: UILabel!
    
    @IBOutlet var userName: TTTAttributedLabel!
    @IBOutlet var locationLabel: UILabel!

    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var commentCountLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var reviewLabel: UILabel!
    
    @IBOutlet var actionLabel: TTTAttributedLabel!
    
    @IBOutlet var actionImage: UIImageView!
    @IBOutlet var userProfileImage: UIImageView!
    
    @IBOutlet var starButton1: UIButton!
    @IBOutlet var starButton2: UIButton!
    @IBOutlet var starButton3: UIButton!
    @IBOutlet var starButton4: UIButton!
    @IBOutlet var starButton5: UIButton!
    @IBOutlet var userProfileButton: UIButton!
    
    @IBOutlet var notificationButton: UIButton!
    
    
    @IBOutlet var itemDetailsButton: UIButton!
    @IBOutlet var profileButton: UIButton!
    
    var delegate:ProfileCollectionViewCellDelegate? = nil
    
//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        var attributes = layoutAttributes.copy()
//        self.frame = attributes.frame
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//        var fontSize = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleHeadline).pointSize * 1.4
//        
//        self.reviewLabel.font = UIFont(name: self.reviewLabel.font.familyName, size: fontSize)
//        var size = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//        attributes.size = size
//        return attributes as! UICollectionViewLayoutAttributes
//    }
    
    @IBAction func likeCountPressed(sender: AnyObject) {
        delegate?.likesCountTapped(self.tag)
    }
    @IBAction func onTouchShareButton(sender: AnyObject) {
        if (delegate != nil) {
            self.delegate?.onTouchShareButton(self)
        } else {
            print("ERROR Delegate MOVVItemCellDeleagete action onTouchShareButton not implemented")
        }
    }
    
    
}
