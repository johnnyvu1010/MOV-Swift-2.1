//
//  OfferBuyerDetailsTableViewCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 16/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class OfferBuyerDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet var buyerImage: UIImageView!
    @IBOutlet var buyerName: UILabel!
    @IBOutlet var buyerOfferType: UILabel!
    @IBOutlet var buyerOfferPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupCell(productOffer:ProductOffer){
        self.buyerOfferPrice.text = "$ \(productOffer.offerPrice as String)"
        self.buyerName.text = productOffer.offerUserFullName as String
        self.buyerOfferType.text = (productOffer.offerDeliveryOption == DeliveryOption.Ship) ? "SHIP" : "MEET"
        self.buyerImage.setImageWithURL(NSURL(string: productOffer.offerUserProfileImage as String), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }
}
