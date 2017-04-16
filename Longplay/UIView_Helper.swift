//
//  UIView_Helper.swift
//  Longplay
//
//  Created by Joe Nguyen on 21/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

let UIViewDefaultAnimationDuration:TimeInterval = 0.3

extension UIView {
    
    class func animateWithDefaultDuration(_ animations: @escaping () -> Void) {
        UIView.animate(withDuration: UIViewDefaultAnimationDuration, animations: animations)
    }
    
    class func animateWithDefaultDuration(_ animations: @escaping () -> Void,
        completion: ((Bool) -> Void)?) {
            UIView.animate(withDuration: UIViewDefaultAnimationDuration,
                animations: animations,
                completion: completion)
    }
}
