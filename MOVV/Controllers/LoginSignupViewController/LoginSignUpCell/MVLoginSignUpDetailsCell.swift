//
//  MVLoginSignUpDetailsCell.swift
//  MOVV
//
//  Created by Vineet Choudhary on 20/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit


enum LoginUserDataType : Int {
    case Username = 0, Password
}

enum SignUpUserDataType : Int {
    case FirstName = 0,LastName, Email, Username, Password
}

protocol MVLoginSignUPDetailsCellDelegate :NSObjectProtocol {
    func currentFirstResponder(textField:UITextField)
}

class MVLoginSignUpDetailsCell: UITableViewCell {

    var isLogin = true
    var currentUser : MVLoginSignUpUser!
    weak var delegate : MVLoginSignUPDetailsCellDelegate!
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var datatextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillDetailsWithLoginUser(user : MVLoginSignUpUser)
    {
        isLogin = true
        currentUser = user
        datatextField.secureTextEntry = false
        switch LoginUserDataType(rawValue : self.tag)! {
       
        case .Username:
            dataLabel.text = "Email"
            datatextField.placeholder = "Email"
            if user.firstName != nil
            {
                datatextField.text = user.userName
            }
        case .Password:
            dataLabel.text = "Password"
            datatextField.placeholder = "******"
            datatextField.secureTextEntry = true
            if user.password != nil
            {
                datatextField.text = user.password
            }
        }
    }
    

    
    func fillDetailsWithSignUpUser(user : MVLoginSignUpUser)
    {
        isLogin = false
        currentUser = user
        datatextField.secureTextEntry = false
        datatextField.autocapitalizationType = .None
        switch SignUpUserDataType(rawValue : self.tag)! {
        case .FirstName:
            dataLabel.text = "First Name"
            datatextField.placeholder = "First Name"
            datatextField.autocapitalizationType = .Words
            if user.firstName != nil
            {
                datatextField.text = user.firstName
            }
        case .LastName:
            dataLabel.text = "Last Name"
            datatextField.placeholder = "Last Name"
            datatextField.autocapitalizationType = .Words
            if user.lastName != nil
            {
                datatextField.text = user.lastName
            }
        case .Email:
            dataLabel.text = "Email"
            datatextField.placeholder = "Email"
            if user.email != nil
            {
                datatextField.text = user.email
            }
        case .Username:
            dataLabel.text = "Username"
            datatextField.placeholder = "Username"
            if user.userName != nil
            {
                datatextField.text = user.userName
            }
        case .Password:
            dataLabel.text = "Password"
            datatextField.placeholder = "******"
            datatextField.secureTextEntry = true
            if user.password != nil
            {
                datatextField.text = user.password
            }
        }
        
    }
    
}

extension MVLoginSignUpDetailsCell : UITextFieldDelegate
{

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = NSString(string: textField.text!)
        let text = currentText.stringByReplacingCharactersInRange(range, withString: string)
        if isLogin
        {
            switch LoginUserDataType(rawValue: self.tag)! {
            case .Username:
                currentUser.email = text
            case .Password:
                currentUser.password = text
            }
        }
        else
        {
            switch SignUpUserDataType(rawValue: self.tag)! {
            case .Username:
                currentUser.userName = text
            case .Password:
                currentUser.password = text
            case .FirstName:
                currentUser.firstName = text
            case .LastName:
                currentUser.lastName = text
            case .Email:
                currentUser.email = text
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.delegate?.currentFirstResponder(textField)
    }
}
