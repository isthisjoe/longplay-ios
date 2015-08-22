//
//  UIView_Helper.swift
//  Longplay
//
//  Created by Joe Nguyen on 21/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

let UIViewDefaultAnimationDuration:NSTimeInterval = 0.3

extension UIView {
    
    class func animateWithDefaultDuration(animations: () -> Void) {
        UIView.animateWithDuration(UIViewDefaultAnimationDuration, animations: animations)
    }
    
    class func animateWithDefaultDuration(animations: () -> Void,
        completion: ((Bool) -> Void)?) {
            UIView.animateWithDuration(UIViewDefaultAnimationDuration,
                animations: animations,
                completion: completion)
    }
}
