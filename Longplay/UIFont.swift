//
//  UIFont.swift
//  Longplay
//
//  Created by Joe Nguyen on 28/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func primaryFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerCE-Light", size: size)!
    }
    
    class func primaryBoldFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerCE-Bold", size: size)!
    }
    
    class func buttonFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerLT-Cn", size: size)!
    }
    
    class func titleFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerLT-ExtraBlackCn", size: size)!
    }
}