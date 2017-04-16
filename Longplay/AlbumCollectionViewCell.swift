//
//  AlbumCollectionViewCell.swift
//  Longplay
//
//  Created by Joe Nguyen on 11/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    let thumbImageView = UIImageView()
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    var didLayoutSubviews = false

    override func layoutSubviews() {
        if !didLayoutSubviews {
            addSubview(thumbImageView)
            thumbImageView.snp_makeConstraints { (make) -> Void in
                make.top.equalTo(0)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(bounds.size.width)
            }
            
            let labelContentHeight = bounds.size.height - bounds.size.width
            let labelSpacing = labelContentHeight * 0.05
            let labelHeight = labelContentHeight * 0.475
            
            nameLabel.font = UIFont.primaryBoldFontWithSize(11)
            addSubview(nameLabel)
            nameLabel.snp_makeConstraints { (make) -> Void in
                make.left.right.equalTo(thumbImageView)
                make.top.equalTo(thumbImageView.snp_bottom).offset(labelSpacing)
                make.height.equalTo(labelHeight)
            }
            
            artistLabel.font = UIFont.primaryFontWithSize(11)
            addSubview(artistLabel)
            artistLabel.snp_makeConstraints { (make) -> Void in
                make.left.right.equalTo(nameLabel)
                make.top.equalTo(nameLabel.snp_bottom)
                make.height.equalTo(labelHeight)
            }
            didLayoutSubviews = true
        }
    }
    
    func configureCellWithViewModel(_ viewModel:AlbumViewModel) {
        
        self.thumbImageView.sd_setImage(with: viewModel.coverThumbURL as URL!)
        self.nameLabel.text = viewModel.title
        self.artistLabel.text = viewModel.artistName
    }
}
