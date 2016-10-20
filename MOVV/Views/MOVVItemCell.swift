//
//  MOVVItemCell.swift
//  MOVV
//
//  Created by Martino Mamic on 30/04/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

protocol MOVVItemCellDelegate
{
    func onTouchShareButton(cell:UITableViewCell)
    func onTouchOfferButton(cell:UITableViewCell)
    func tapGestureLikeRecognizer(sender:UITapGestureRecognizer)
    func tapGestureShowDetailsRecognizer(sender:UITapGestureRecognizer)
    func likeCountTapped(tag:Int)
}

class MOVVItemCell: UITableViewCell {

    @IBOutlet var graditentView: UIView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var checkinButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var avatarButton: UIButton!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var notificationButton: UIButton!
    @IBOutlet var itemDetailsButton: UIButton!
    @IBOutlet var userProfileButton: UIButton!
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var homeBuyButton: UIButton!
    @IBOutlet var subMenuView: UIView!
    
    @IBOutlet var _heartButton: UIButton!
    @IBOutlet var _commentButton: UIButton!
    @IBOutlet var _shareButton: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var commentCountLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var actionLabel: UILabel!
    @IBOutlet var itemTagsLabel: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var otherUserName: UILabel!
    @IBOutlet var hashtag: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var noCommentsLabel: UILabel!
    @IBOutlet var transactionLabel: UILabel!
    
    @IBOutlet var itemName: TTTAttributedLabel!
    @IBOutlet var usernameLabel: TTTAttributedLabel!
    @IBOutlet var newsLabel: TTTAttributedLabel!
    
    @IBOutlet var myFollowersView: UIView!
    @IBOutlet var reviewView: UIView!
    @IBOutlet var newsView: UIView!
    @IBOutlet var myItemsView: UIView!
    @IBOutlet var playerView: UIView!
    
    @IBOutlet var actionImage: UIImageView!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var userImage: UIImageView!

    var tapGestureLike : UITapGestureRecognizer!
    var tapGestureDetails : UITapGestureRecognizer!
    
    var delegate:MOVVItemCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = UIEdgeInsetsZero
        self.tapGestureLike = UITapGestureRecognizer(target: self, action: #selector(MOVVItemCell.likeTapGesture(_:)))
        tapGestureLike.numberOfTapsRequired = 2
        self.tapGestureDetails = UITapGestureRecognizer(target: self, action: #selector(MOVVItemCell.showDetailsTapGesture(_:)))
        self.itemImage?.gestureRecognizers = [tapGestureLike, tapGestureDetails]
        if(self.itemImage != nil){
            self.itemImage.clipsToBounds = true
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func onTouchShareButton(sender: AnyObject) {
        if (delegate != nil) {
            self.delegate?.onTouchShareButton(self)
        } else {
            print("ERROR Delegate MOVVItemCellDeleagete action onTouchShareButton not implemented")
        }
    }
    
    @IBAction func offerButtonTapped(sender: UIButton) {
        if delegate != nil {
            self.delegate!.onTouchOfferButton(self)
        }
    }
    
    func likeTapGesture(sender:UITapGestureRecognizer){
        if delegate != nil {
            self.delegate?.tapGestureLikeRecognizer(sender)
        }
    }
    
    func showDetailsTapGesture(sender:UITapGestureRecognizer){
        if delegate != nil {
            self.delegate?.tapGestureShowDetailsRecognizer(sender)
        }
    }
    @IBAction func likeCounTapped(sender: AnyObject) {
        self.delegate?.likeCountTapped(self.tag)
    }
}

