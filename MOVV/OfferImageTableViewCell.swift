//
//  OfferImageTableViewCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 16/06/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class OfferImageTableViewCell: UITableViewCell {

    @IBOutlet var productName: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupCell(product:MVProduct){
        self.productName.text = product.name as String
        self.productPrice.text = "$" + String(product.price)
        self.productImage.setImageWithURL(NSURL(string: product.previewImage as String), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }

}
