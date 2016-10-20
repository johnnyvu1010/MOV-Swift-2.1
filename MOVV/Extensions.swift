//
//  Extensions.swift
//  MOVV
//
//  Created by Martino Mamic on 25/04/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit


extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}

extension String {
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func replace(pattern: String, with: String) -> String? {
        let regexp = try? NSRegularExpression(pattern: pattern, options: [])
        return regexp?.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.length), withTemplate: with)
    }
    
    func toFloat() -> Float {
        return (self as NSString).floatValue
    }
    
    func indexOfCharacter(char: Character) -> Int? {
        if let idx = self.characters.index(of: char) {
            return self.startIndex.distanceTo(idx)
        }
        return nil
    }
}

extension UIView {
    func removeAllSubviews() {
//        subviews.map { $0.removeFromSuperview() }
    }
}

extension UIImageView {
    var toCircle:Bool {
        get {
            return layer.cornerRadius == frame.size.width / 2 && clipsToBounds
        }
        set (value) {
            if (value) {
                layer.cornerRadius = frame.size.width / 2
                clipsToBounds = true
            } else {
                layer.cornerRadius = 0
                clipsToBounds = false
            }
        }
    }
}

extension UITextField {
    func boldFont() {
        font = UIFont.boldSystemFont(ofSize: font!.pointSize)
    }
    
    func highlight() {
        boldFont()
        textColor = UIColor.green
    }
}

extension Array {
    // http://stackoverflow.com/questions/24102024/how-to-check-if-an-element-is-in-an-array
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({ $0 as? T == obj }).count > 0
    }
    
    func contains<T where T : Equatable>(obj: AnyObject?, compare: @escaping (_ lhs: T?, _ rhs:AnyObject?) -> Bool) -> Bool {
        return self.filter({ compare(($0 as? T), obj) }).count > 0
    }
}
