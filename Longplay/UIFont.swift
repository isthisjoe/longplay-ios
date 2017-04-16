//
//  UIFont.swift
//  Longplay
//
//  Created by Joe Nguyen on 28/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func primaryFontWithSize(_ size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerCE-Light", size: size)!
    }
    
    class func primaryBoldFontWithSize(_ size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerCE-Bold", size: size)!
    }
    
    class func buttonFontWithSize(_ size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerLT-Cn", size: size)!
    }
    
    class func titleFontWithSize(_ size:CGFloat) -> UIFont {
        return UIFont(name: "FrutigerLT-ExtraBlackCn", size: size)!
    }
}
