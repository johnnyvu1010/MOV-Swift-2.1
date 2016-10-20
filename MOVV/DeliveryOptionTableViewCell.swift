//
//  DeliveryOptionTableViewCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 01/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class DeliveryOptionTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSubtitle: UILabel!
    @IBOutlet var imageViewCheck: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
