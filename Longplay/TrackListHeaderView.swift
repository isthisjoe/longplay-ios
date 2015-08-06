//
//  TrackListHeaderView.swift
//  Longplay
//
//  Created by Joe Nguyen on 1/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

let TrackListHeaderViewHeight:CGFloat = 76

class TrackListHeaderView: UICollectionReusableView {
    
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    
    // MARK: Init
    
    init() {
        
        super.init(frame:CGRectZero)
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
        
        let labelSpacing = 8
        let labelHeight = 30
        let sideSpacing:CGFloat = 14
        nameLabel.font = UIFont.primaryBoldFontWithSize(20)
        addSubview(nameLabel)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(labelSpacing)
            make.left.equalTo(self).offset(sideSpacing)
            make.right.equalTo(self).offset(-sideSpacing)
            make.height.equalTo(labelHeight)
        }
        
        artistLabel.font = UIFont.primaryFontWithSize(20)
        addSubview(artistLabel)
        artistLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp_bottom)
            make.left.right.equalTo(nameLabel)
            make.height.equalTo(labelHeight)
        }
    }

}
