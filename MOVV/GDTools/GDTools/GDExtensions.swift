//
//  GDExtensions.swift
//  GDTools
//
//  Created by Ivan Barisic on 25/02/16.
//  Copyright © 2016 Gauss Development. All rights reserved.
//

import UIKit

public extension Array where Element: Equatable {
    public mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

public extension String {
    
    /**
     Used to fetch NSDate object from string, if dateFormat is nil format used is: yyyy-MM-dd'T'HH:mm:ss.SSSZ
     
     - parameter dateFormat: String used as date format
     
     - returns: NSDate object
     */
    public func dateForFormat(dateFormat: String?) -> NSDate? {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        if dateFormat == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = dateFormat!
        }
        
        return dateFormatter.dateFromString(self)
    }
    
    public func dateForFormat(dateFormat: String?, locale: NSLocale?, dateStyle: NSDateFormatterStyle?) -> NSDate? {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        
        if (locale != nil) {
            dateFormatter.locale = locale!
        }
        
        if (dateStyle != nil) {
            dateFormatter.dateStyle = dateStyle!
        }
        if dateFormat == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = dateFormat!
        }
        
        return dateFormatter.dateFromString(self)
    }
}

public extension NSDate {
    
    /**
     Used to fetch string for given date format, if no format is set medium style will be used.
     
     - parameter dateFormat: String indicating date format
     
     - returns: String object
     */
    public func stringForDateInFormat(dateFormat: String?) -> String? {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        if dateFormat == nil {
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        } else {
            dateFormatter.dateFormat = dateFormat!
        }
        
        return dateFormatter.stringFromDate(self)
    }
    
    public func stringForDateInFormat(dateFormat: String?, locale: NSLocale??) -> String? {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        if (locale != nil) {
            dateFormatter.locale = locale!
        }

        if dateFormat == nil {
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        } else {
            dateFormatter.dateFormat = dateFormat!
        }
        
        return dateFormatter.stringFromDate(self)
    }
}


public extension UIApplication {
    
    /**
     Used to fetch most top view controller
     
     - returns: UIViewController if exists
     */
    public class func topViewController(base: UIViewController? = UIApplication.sharedApplication.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController  where top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
    /**
     Used to print all font names
     */
    public class func getAllFontNames() {
        
        for family in UIFont.familyNames() {
            print(family)
            
            for name in UIFont.fontNamesForFamilyName(family) {
                print(name)
            }
        }
    }
}

public extension NSBundle {
    
    public class var applicationVersionNumber: String {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "N/A"
    }
    
    public class var applicationBuildNumber: String {
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "N/A"
    }
}
