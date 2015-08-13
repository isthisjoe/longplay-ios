//
//  AlbumProgressView.swift
//  Longplay
//
//  Created by Joe Nguyen on 13/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

class AlbumProgressView: UIProgressView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(progressViewStyle style: UIProgressViewStyle) {
        super.init(progressViewStyle:style)
        setup()
    }
    
    func setup() {
        trackTintColor = UIColor.primaryLightColor()
        progressTintColor = UIColor.primaryColor()
    }
}
