//
//  NewsFollowingTableViewCell.swift
//  MOVV
//
//  Created by Ivan Barisic on 07/08/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

protocol NewsFollovingTableViewCellDelegate
{
    func onTouchItemImageButtonInCell(cell:UITableViewCell)
    func onTouchCommentButtonInCell(cell:UITableViewCell)
}

class NewsFollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var userInfoLabel: TTTAttributedLabel!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var constarintImageHeight: NSLayoutConstraint!
    var delegate:NewsFollovingTableViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Actions
    @IBAction func onTouchItemImageButton(sender: AnyObject) {
        if (delegate != nil) {
            self.delegate?.onTouchItemImageButtonInCell(self)
        }
    }

    @IBAction func onTouchCommentButton(sender: AnyObject) {
        if (delegate != nil) {
            self.delegate?.onTouchCommentButtonInCell(self)
        }
    }
}
