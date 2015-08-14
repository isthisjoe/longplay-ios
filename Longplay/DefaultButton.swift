//
//  DefaultButton.swift
//  Longplay
//
//  Created by Joe Nguyen on 14/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

class DefaultButton: UIButton {
    
    // MARK: Init
    
    convenience init(title:String) {
        
        self.init(frame:CGRectZero)
        setTitle(title, forState: .Normal)
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        
        backgroundColor = UIColor.whiteColor()
        layer.borderColor = UIColor.primaryColor().CGColor
        layer.borderWidth = 0.5
        titleLabel!.font = UIFont.buttonFontWithSize(14)
        setTitleColor(UIColor.primaryColor(), forState: .Normal)
    }

}
