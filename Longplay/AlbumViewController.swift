//
//  AlbumViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 11/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesomeKit

let AlbumViewControllerCoverArtImageViewSize:CGFloat = 100

class AlbumViewController: UIViewController {

    let album:SPTAlbum
    let about:String
    var playAlbumBlock:((_ album:SPTAlbum) -> ())?
    
    let coverArtImageView = UIImageView()
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    let aboutTextView = UITextView()
    
    init(album:SPTAlbum, about:String) {
        self.album = album
        self.about = about
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.album = SPTAlbum()
        self.about = ""
        super.init(coder:aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.album = SPTAlbum()
        self.about = ""
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        
        view.backgroundColor = UIColor.white
        let spacing = 10
        
        view.addSubview(coverArtImageView)
        coverArtImageView.snp.makeConstraints { (make) -> Void in
            make.top.left.equalTo(view).offset(spacing)
            make.width.height.equalTo(AlbumViewControllerCoverArtImageViewSize)
        }
        
        let labelHeight = 20
        nameLabel.font = UIFont.primaryBoldFontWithSize(20)
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view).offset(spacing)
            make.left.equalTo(coverArtImageView.snp.right).offset(spacing)
            make.right.equalTo(view).offset(-spacing)
            make.height.greaterThanOrEqualTo(labelHeight)
        }
        
        let labelSpacing = 5
        artistLabel.font = UIFont.primaryFontWithSize(20)
        view.addSubview(artistLabel)
        artistLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp.bottom).offset(labelSpacing)
            make.left.equalTo(coverArtImageView.snp.right).offset(spacing)
            make.right.equalTo(view).offset(-spacing)
            make.height.greaterThanOrEqualTo(labelHeight)
        }
        
        view.addSubview(aboutTextView)
        aboutTextView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(coverArtImageView.snp.bottom).offset(14)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.bottom.equalTo(view).offset(-10)
        }

        if let albumURL = album.largestCover.imageURL {
            coverArtImageView.sd_setImage(with: albumURL)
        }
        
        nameLabel.text = album.name
        nameLabel.numberOfLines = 2
        
        let artists = album.artists
        if (artists?.count)! > 0 {
            let artist = artists?[0] as! SPTPartialArtist
            artistLabel.text = artist.name
            artistLabel.numberOfLines = 2
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.hyphenationFactor = 1.0
        let aboutAttributedText = NSAttributedString(string: about,
            attributes: [NSParagraphStyleAttributeName:paragraph,
                NSKernAttributeName:CGFloat(0.1),
                NSFontAttributeName:UIFont.primaryFontWithSize(14)])
        aboutTextView.attributedText = aboutAttributedText
        aboutTextView.sizeToFit()
        aboutTextView.isEditable = false
        aboutTextView.isSelectable = false
        aboutTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    // MARK: Actions
    
    func playAction(_ sender:AnyObject?) {
        if let
            playAlbumBlock = playAlbumBlock {
            playAlbumBlock(album)
        }
    }
}
