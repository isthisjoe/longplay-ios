//
//  AlbumProgressView.swift
//  Longplay
//
//  Created by Joe Nguyen on 13/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

class AlbumProgressView: UIProgressView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup() {
        trackTintColor = UIColor.primaryLightColor()
        progressTintColor = UIColor.primaryColor()
    }
}
