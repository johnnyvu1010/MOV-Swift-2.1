//
//  BuyerSellerChatTableViewCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 25/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

protocol ShipActionDelegate : NSObjectProtocol {
    func shipActionKeep()
    func shipActionReturn()
    func userProfileTappedAction(cell:BuyerSellerChatTableViewCell)
}

class BuyerSellerChatTableViewCell: UITableViewCell {
    
    weak var delegate: ShipActionDelegate!
    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var buttonUser: UIButton!
    @IBOutlet weak var buttonMessageBG: UIButton!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelMessageTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func buyerIdentifier()->String{
        return "BuyerChatTableViewCell"
    }
    
    class func sellerIdentifier()->String{
        return "SellerChatTableViewCell"
    }
    
    class  func movIdentifer()->String{
        return "MovChatTableViewCell"
    }
    
    class func shipActionIdentifer()->String{
        return "ShipActionTableViewCell"
    }
    
    func configCellWithTextMessage(message:MVMessageDetails){
        if message.messageType == MVMessageType.Text {
            imageViewUser.setImageWithURL(NSURL(string:message.sentFromUser.profileImage), usingActivityIndicatorStyle: .Gray)
        }else{
            imageViewUser.image = UIImage(named: "movv_icon")
        }
        if(message.messageType == MVMessageType.Review){
            let attribute = [ NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            labelMessage.attributedText = NSAttributedString(string: message.message, attributes: attribute)
        }else if message.message.length > 25{
            let urlString = message.message.substringFromIndex(message.message.startIndex.advancedBy(21));
            let attribute = [ NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            if let url = NSURL(string: urlString) where (UIApplication.sharedApplication().canOpenURL(url)){
                let attributedText = NSMutableAttributedString(string: message.message)
                attributedText.addAttributes(attribute, range: NSRange.init(location: 21, length: urlString.length));
                labelMessage.attributedText = attributedText
            }else{
                labelMessage.text = message.message
            }
        }else{
            labelMessage.text = message.message
        }
        labelMessageTime.text = message.sentDate
    }

    @IBAction func buttonKeepTapped(sender: UIButton) {
        self.delegate?.shipActionKeep()
    }
    
    @IBAction func buttonReturnTapped(sender: UIButton) {
        self.delegate?.shipActionReturn()
    }
    
    @IBAction func buttonBuyerProfileTapped(sender: UIButton) {
        self.delegate?.userProfileTappedAction(self)
    }
}
