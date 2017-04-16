//
//  TrackListHeaderView.swift
//  Longplay
//
//  Created by Joe Nguyen on 1/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

let TrackListHeaderViewCoverArtImageViewHeight:CGFloat = UIScreen.main.bounds.size.width
let TrackListHeaderViewLabelSpacing:CGFloat = 8
let TrackListHeaderViewLabelHeight:CGFloat = 30

class TrackListHeaderView: UICollectionReusableView {
    
    let coverArtImageView = UIImageView()
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    
    // MARK: Init
    
    init() {
        
        super.init(frame:CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        
        addSubview(coverArtImageView)
        coverArtImageView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self)
            make.height.equalTo(TrackListHeaderViewCoverArtImageViewHeight)
        }
        
        let sideSpacing:CGFloat = 14
        nameLabel.font = UIFont.primaryBoldFontWithSize(20)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(coverArtImageView.snp.bottom).offset(TrackListHeaderViewLabelSpacing)
            make.left.equalTo(self).offset(sideSpacing)
            make.right.equalTo(self).offset(-sideSpacing)
            make.height.equalTo(TrackListHeaderViewLabelHeight)
        }
        
        artistLabel.font = UIFont.primaryFontWithSize(20)
        addSubview(artistLabel)
        artistLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.right.equalTo(nameLabel)
            make.height.equalTo(TrackListHeaderViewLabelHeight)
        }
    }
    
    class func calculateHeight() -> CGFloat {
        return TrackListHeaderViewCoverArtImageViewHeight +
            TrackListHeaderViewLabelSpacing +
            TrackListHeaderViewLabelHeight +
            TrackListHeaderViewLabelHeight +
        TrackListHeaderViewLabelSpacing
    }
}
