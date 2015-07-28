//
//  TrackListCollectionViewCell.swift
//  Longplay
//
//  Created by Joe Nguyen on 16/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit

class TrackListViewModel {
    
    var title:String?
    
    convenience init(track:SPTPartialTrack) {
        self.init()
        if let name = track.name {
            self.title = String(track.trackNumber) + ". " + name
        }
    }
}

class TrackListCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    var didLayoutSubviews = false
    
    override func layoutSubviews() {

        if !didLayoutSubviews {
            titleLabel.font = UIFont.primaryFontWithSize(14)
            addSubview(titleLabel)
            let titleLabelOffset:CGFloat = 2.0
            titleLabel.snp_makeConstraints({ (make) -> Void in
                make.edges.equalTo(self).insets(UIEdgeInsetsMake(titleLabelOffset, 14, titleLabelOffset, 14))
            })
        }
    }
    
    func configureCellWithViewModel(viewModel:TrackListViewModel) {
        
        titleLabel.text = viewModel.title
    }
}
