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
        
        self.init(frame:CGRect.zero)
        setTitle(title, for: UIControlState())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        
        backgroundColor = UIColor.white
        layer.borderColor = UIColor.primaryColor().cgColor
        layer.borderWidth = 0.5
        titleLabel!.font = UIFont.buttonFontWithSize(14)
        setTitleColor(UIColor.primaryColor(), for: UIControlState())
    }

}
