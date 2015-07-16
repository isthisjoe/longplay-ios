//
//  AlbumViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 11/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesome_swift

class AlbumViewController: UIViewController {

    let album:SPTAlbum
    var playAlbumBlock:((album:SPTAlbum) -> ())?
    
    let coverArtImageView = UIImageView()
    let playButton = UIButton()
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    let albumTrackListingView = UIView()
    let trackListingViewController = TrackListViewController()
    
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
        setupTrackListing(album)
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.whiteColor()
        edgesForExtendedLayout = .None
        
        view.addSubview(coverArtImageView)
        coverArtImageView.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(0)
            make.height.equalTo(view.bounds.size.width)
        }
        
        playButton.setImage(
            UIImage.fontAwesomeIconWithName(.Play,
                textColor: UIColor.whiteColor(),
                size: CGSizeMake(50, 50)),
            forState:.Normal)
        playButton.addTarget(self, action: "playAction:", forControlEvents:.TouchUpInside)
        playButton.layer.shadowColor = UIColor.darkGrayColor().CGColor
        playButton.layer.shadowOffset = CGSizeMake(0,0)
        playButton.layer.shadowOpacity = 3
        view.addSubview(playButton)
        playButton.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(coverArtImageView.snp_center)
            make.width.height.equalTo(50)
        }
        
        let labelSpacing = 8
        let labelHeight = 30
        nameLabel.font = UIFont.systemFontOfSize(16)
        view.addSubview(nameLabel)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(coverArtImageView)
            make.top.equalTo(coverArtImageView.snp_bottom).offset(labelSpacing)
            make.height.equalTo(labelHeight)
        }
        
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
    
    func setupTrackListing(album:SPTAlbum) {
        
        albumTrackListingView.backgroundColor = UIColor.grayColor()
        view.addSubview(albumTrackListingView)
        albumTrackListingView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(artistLabel.snp_bottom)
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        trackListingViewController.album = album
        trackListingViewController.willMoveToParentViewController(self)
        addChildViewController(trackListingViewController)
        trackListingViewController.didMoveToParentViewController(trackListingViewController)
        albumTrackListingView.addSubview(trackListingViewController.view)
        trackListingViewController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(albumTrackListingView)
        }
    }
    
    // MARK: Actions
    
    func playAction(sender:AnyObject?) {
        if let
            playAlbumBlock = playAlbumBlock {
            playAlbumBlock(album: album)
        }
    }
}
