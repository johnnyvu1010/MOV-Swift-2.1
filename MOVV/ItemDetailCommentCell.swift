//
//  ItemDetailCommentCell.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 13.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit

protocol ItemDetailCommentCellDelegate :NSObjectProtocol {
    func userSelectedAtList(user: MVUser)
}

class ItemDetailCommentCell: UITableViewCell,TTTAttributedLabelDelegate {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var usernameLabel: TTTAttributedLabel!
    @IBOutlet var commentLabel: TTTAttributedLabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var userProfileButton: UIButton!
    
    var currentStr : NSString!
    weak var delegate : ItemDetailCommentCellDelegate!
    var userArr = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCommentView(comment : MVComment)
    {
        userArr.removeAllObjects()
        if comment.mentioneduser.count == 0
        {
            userArr.addObject(MVUser( dictionary: NSDictionary(objects: ["Ramson vero","http://keenthemes.com/preview/metronic/theme/assets/pages/media/profile/profile_user.jpg",(0)], forKeys: ["display_name","profile_image","id"])))
            userArr.addObject(MVUser( dictionary: NSDictionary(objects: ["Raj kemo","https://www.scrum.org/Portals/0/Users/151/51/151/Gunther%20Verheyen%202014.JPG",(1)], forKeys: ["display_name","profile_image","id"])))
            userArr.addObject(MVUser( dictionary: NSDictionary(objects: ["Rango Desuja","https://earthdata.nasa.gov/media/jun-wang-user-profile-image.jpg",(2)], forKeys: ["display_name","profile_image","id"])))
            userArr.addObject(MVUser( dictionary: NSDictionary(objects: ["Ramson vero","http://keenthemes.com/preview/metronic/theme/assets/pages/media/profile/profile_user.jpg",(3)], forKeys: ["display_name","profile_image","id"])))
            userArr.addObject(MVUser( dictionary: NSDictionary(objects: ["Raj kemo","https://www.scrum.org/Portals/0/Users/151/51/151/Gunther%20Verheyen%202014.JPG",(4)], forKeys: ["display_name","profile_image","id"])))
            userArr.addObject(MVUser( dictionary: NSDictionary(objects: ["Rango Desuja","https://earthdata.nasa.gov/media/jun-wang-user-profile-image.jpg",(5)], forKeys: ["display_name","profile_image","id"])))
        }
        else
        {
            userArr.addObjectsFromArray(comment.mentioneduser)
        }
        commentLabel.attributedText = getAttributedTextWithText(NSString(format:"\(comment.comment)"))
    }
    
    func getAttributedTextWithText(text : NSString) -> NSAttributedString
    {
        currentStr = text
        let attributedText = NSMutableAttributedString()
        var count = 0
        for subStr in text.componentsSeparatedByString(" ") {
            if count > 0
            {
                attributedText.appendAttributedString(updatePlainString(" "))
            }
            if checkSubStringIsUser(subStr)
            {
                attributedText.appendAttributedString(updateAccordingUser(subStr,mutStr: attributedText))
            }
            else
            {
                attributedText.appendAttributedString(updatePlainString(subStr))
            }
            count += 1
        }
        
        return attributedText
    }
    
    func checkSubStringIsUser(subString :  String) -> Bool
    {
        if subString.containsString("user_data_$_#_")
        {
            return true
        }
        return false
    }
    
    func updateAccordingUser(userStr:String , mutStr : NSMutableAttributedString) -> NSMutableAttributedString {
        if let id = userStr.componentsSeparatedByString("user_data_$_#_").last
        {
            if let user = getUserWithId(Int(id)!)
            {
                let attributedString = getAttributedStrWithName(NSString(string: user.displayName).capitalizedString as String, link: "\(id)")
                
                let url = NSURL(string :"\(id)")
                commentLabel.linkAttributes = NSDictionary(dictionary: [kCTForegroundColorAttributeName : MOVVGreen]) as [NSObject : AnyObject]
                commentLabel.addLinkToURL(url, withRange: NSMakeRange(mutStr.length, user.displayName.length ))
                
                return attributedString
            }
        }
        return NSMutableAttributedString()
    }
    
    func updatePlainString(str : String) -> NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttributes([NSFontAttributeName : commentLabel.font!,NSForegroundColorAttributeName : UIColor.blackColor()], range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func getAttributedStrWithName(name : String, link :String) -> NSMutableAttributedString
    {
        let htmlString  = String(format: name)
        let documentOption = NSDictionary(object: NSHTMLTextDocumentType, forKey: NSDocumentTypeDocumentAttribute)
        
        let dataStr = htmlString.dataUsingEncoding(NSUnicodeStringEncoding)!
        let attributedStr: NSAttributedString?
        do {
            attributedStr = try NSAttributedString(data:dataStr , options: documentOption as! [String : AnyObject], documentAttributes: nil)
        } catch _ {
            attributedStr = NSAttributedString(string: "", attributes: [NSFontAttributeName :commentLabel.font])
        }
        let mutStr = NSMutableAttributedString(attributedString: attributedStr!)
        
        let range =  NSMakeRange(0, attributedStr!.length)
        mutStr.addAttributes([NSFontAttributeName:commentLabel.font], range:range)
        mutStr.addAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: range)
        mutStr.addAttributes([NSBackgroundColorAttributeName: UIColor.bt_colorFromHex("CCCCCC", alpha: 1)] , range: range)
        mutStr.addAttributes([kCTForegroundColorAttributeName as String:MOVVGreen], range: range)
        if let url = NSURL(string: link) {
            mutStr.addAttributes([NSLinkAttributeName : url], range: NSMakeRange(0, attributedStr!.length))
        }
        return mutStr
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if delegate != nil
        {
            if let user = getUserWithId(Int(url.absoluteString)!)
            {
                delegate.userSelectedAtList(user)
            }
        }
    }
    
    func getUserWithId(userId: Int) -> MVUser?
    {
        for user in userArr
        {
            if let userObj = user as? MVUser
            {
                if userObj.id == userId
                {
                    return userObj
                }
            }
        }
        return nil
    }
}
