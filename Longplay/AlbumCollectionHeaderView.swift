//
//  AlbumCollectionHeaderView.swift
//  Longplay
//
//  Created by Joe Nguyen on 28/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit

let AlbumCollectionHeaderViewHeight:CGFloat = 40

class AlbumCollectionHeaderView: UICollectionReusableView {

    let titleLabel = UILabel()
    
    // MARK: Init
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        
        titleLabel.font = UIFont.titleFontWithSize(18)
        titleLabel.textAlignment = NSTextAlignment.Left
        titleLabel.textColor = UIColor.blackColor()
        addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 10, 10, 10))
        }
    }

}
