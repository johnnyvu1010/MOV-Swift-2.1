//
//  LiveProductTableViewCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 17/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

enum LiveProductCellType {
    case CellTypeBuy
    case CellTypeSell
}

class LiveProductTableViewCell: UITableViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!
    @IBOutlet var productStatusButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(myCartOffer:MyCartOffers, cellType:LiveProductCellType) {
        self.productNameLabel.text = myCartOffer.offerName
        if myCartOffer.offerPrice != nil {
            self.productPriceLabel.text = "$" + myCartOffer.offerPrice
        }
        if cellType == .CellTypeBuy {
            self.productStatusButton.setTitle(myCartOffer.offerStatus, forState: UIControlState.Normal)
        }else if (cellType == .CellTypeSell){
            let offerCount = myCartOffer.offerCount
            self.productStatusButton.setTitle("\(offerCount) offer" , forState: UIControlState.Normal)
        }
        self.productImageView.setImageWithURL(NSURL(string: myCartOffer.offerImage), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }

}
