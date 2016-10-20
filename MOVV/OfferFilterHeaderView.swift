//
//  OfferFilterHeaderView.swift
//  MOVV
//
//  Created by Vineet Choudhary on 13/09/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

protocol OffeerFilterHeaderDelegate : NSObjectProtocol {
    func filterButtonTapped(sender:UIButton)
}

class OfferFilterHeaderView: UIView {
    weak var delegate:OffeerFilterHeaderDelegate?
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonFilter: UIButton!
    @IBAction func buttonFilterTapped(sender: UIButton) {
        self.delegate?.filterButtonTapped(sender)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
