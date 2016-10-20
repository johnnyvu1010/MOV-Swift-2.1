//
//  HistoryProductTableViewCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 17/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class HistoryProductTableViewCell: UITableViewCell {

    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!
    @IBOutlet var productActionStatusButton: UIButton!
    @IBOutlet weak var unreadMsgCountLbl: UILabel!
    @IBOutlet weak var counterview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForBuy(myCartOffer:MyCartOffers) -> Void {
        self.productNameLabel.text = myCartOffer.offerName
        self.productPriceLabel.text = "$" + myCartOffer.offerPrice
        self.productActionStatusButton.setTitle(myCartOffer.offerStatus.uppercaseString, forState: UIControlState.Normal)
        if myCartOffer.offerStatus.lowercaseString == "accepted" {
            self.productActionStatusButton.backgroundColor = UIColor(red: 46/255.0, green: 211/255.0, blue: 62/255.0, alpha: 1)
            self.setupCounter(myCartOffer.unreadMsgCount.integerValue)
        }else{
            self.productActionStatusButton.backgroundColor = UIColor(red: 243/255.0, green: 78/255.0, blue: 29/255.0, alpha: 1)
            counterview.hidden = true
        }
    }
    
    func setupCellForSell(actionProduct:MVActionProduct) -> Void {
        self.productNameLabel.text = actionProduct.product.name;
        self.productPriceLabel.text = "$\(actionProduct.offerPrice)"
        self.productActionStatusButton.backgroundColor = UIColor(red: 46/255.0, green: 211/255.0, blue: 62/255.0, alpha: 1)
        self.productActionStatusButton.setTitle(actionProduct.action.rawValue.uppercaseString, forState: UIControlState.Normal)
        self.setupCounter(actionProduct.unreadMessageCount)
    }
    
    func setupCounter(message:Int){
        if message > 0{
            counterview.hidden = false
            counterview.layer.cornerRadius = 12;
            self.unreadMsgCountLbl.text = (message > 0) ? "\(message)" : ""
        }else{
            counterview.hidden = true
        }
    }

}
