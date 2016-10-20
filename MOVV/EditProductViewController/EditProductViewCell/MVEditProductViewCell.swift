//
//  MVEditProductViewCell.swift
//  MOVV
//
//  Created by Raushan Kumar on 29/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

class MVEditProductViewCell: UITableViewCell {

    var currentProduct : MVProduct!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillDetailsWithCart(item : MVProduct, editType : EditProductFieldType)
    {
        currentProduct = item
        valueLabel.hidden = false
        valueTextField.hidden = false
        titleLbl.text = editType.desc
        switch editType {
        case .Title:
            valueLabel.hidden = true
            valueTextField.text = item.name
            valueLabel.text = item.name
            
        case .Category:
            valueTextField.hidden = true
            if item.categoryId.length > 0{
                if let category = ProductCategory(rawValue : Int(item.categoryId)!){
                    valueLabel.text = category.stringValue
                }
            }
            
        case .Tags:
            valueTextField.hidden = true
            valueLabel.text = item.tags
        }
    }
    
}


extension MVEditProductViewCell : UITextFieldDelegate
{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let currentText = NSString(string: textField.text!)
        let text = currentText.stringByReplacingCharactersInRange(range, withString: string)
        currentProduct.name = text
        return true
    }
}
