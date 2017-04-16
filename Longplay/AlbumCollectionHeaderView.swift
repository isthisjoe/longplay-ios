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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        
        titleLabel.font = UIFont.titleFontWithSize(18)
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.textColor = UIColor.lpBlackColor()
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(10, 10, 10, 10))
        }
    }

}
