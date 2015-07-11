//
//  AlbumViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 11/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit

class AlbumViewController: UIViewController {

    let album:SPTAlbum
    
    let coverArtImageView = UIImageView()
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    
    init(album:SPTAlbum) {
        self.album = album
        super.init(nibName:nil, bundle:nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.album = SPTAlbum()
        super.init(coder:aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.album = SPTAlbum()
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.whiteColor()
        
//        coverArtImageView.backgroundColor = UIColor.darkGrayColor()
        view.addSubview(coverArtImageView)
        coverArtImageView.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(0)
            make.height.equalTo(view.bounds.size.width)
        }
        
        let labelSpacing = 8
        let labelHeight = 30
//        nameLabel.backgroundColor = UIColor.grayColor()
        nameLabel.font = UIFont.systemFontOfSize(16)
        view.addSubview(nameLabel)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(coverArtImageView)
            make.top.equalTo(coverArtImageView.snp_bottom).offset(labelSpacing)
            make.height.equalTo(labelHeight)
        }
        
//        artistLabel.backgroundColor = UIColor.lightGrayColor()
        artistLabel.font = UIFont.systemFontOfSize(16)
        view.addSubview(artistLabel)
        artistLabel.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp_bottom)
            make.height.equalTo(labelHeight)
        }

        if let albumURL = album.largestCover.imageURL {
            self.coverArtImageView.sd_setImageWithURL(albumURL)
        }
        
        self.nameLabel.text = album.name
        
        let artists = album.artists
        if artists.count > 0 {
            let artist = artists[0] as! SPTPartialArtist
            artistLabel.text = artist.name
        }
    }
}
