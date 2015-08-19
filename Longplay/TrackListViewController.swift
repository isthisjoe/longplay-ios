//
//  TrackListViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 16/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

let TrackListCollectionViewCellReuseIdentifier = "TrackListCollectionViewCellReuseIdentifier"
let TrackListHeaderViewReuseIdentifier = "TrackListHeaderViewReuseIdentifier"

class TrackListViewController: UIViewController {

    var flowLayout:UICollectionViewFlowLayout?
    var collectionView:TrackListCollectionView?
    var album:SPTAlbum? {
        didSet {
            if let album = self.album {
                self.albumViewModel = AlbumViewModel(album: album)
            }
            if let collectionView = collectionView {
                collectionView.reloadData()
            }
        }
    }
    var albumViewModel:AlbumViewModel?
    var items:Array<AnyObject>? {
        if let
            album = album,
            firstTrackPage = album.firstTrackPage,
            items = firstTrackPage.items {
                return items
        } else {
            return nil
        }
    }
    var highlightedIndexPath:NSIndexPath?

    class func createFlowLayout() -> UICollectionViewFlowLayout {
        
        let flowLayout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let spacing:CGFloat = 10
        let itemSizeWidth:CGFloat = screenWidth
        let itemSizeHeight:CGFloat = 20.0
        flowLayout.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight)
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 14, 0)
        return flowLayout
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        flowLayout = TrackListViewController.createFlowLayout()
        
        collectionView = TrackListCollectionView(frame:CGRectZero, collectionViewLayout:flowLayout!)
        if let collectionView = collectionView {
            collectionView.delaysContentTouches = false
            collectionView.canCancelContentTouches = true
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.whiteColor()
            collectionView.registerClass(TrackListCollectionViewCell.self,
                forCellWithReuseIdentifier: TrackListCollectionViewCellReuseIdentifier)
            collectionView.registerClass(TrackListHeaderView.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: TrackListHeaderViewReuseIdentifier)
            collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.addSubview(collectionView)
            collectionView.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(view)
            }
        }
    }
}

private typealias TrackListDataSource = TrackListViewController
extension TrackListDataSource: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if let items = items {
            count = items.count
        }
        return count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TrackListCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! TrackListCollectionViewCell
        if let
            items = items,
            track = items[indexPath.row] as? SPTPartialTrack {
                let viewModel = TrackListViewModel(track: track)
                cell.configureCellWithViewModel(viewModel)
                if let highlightedIndexPath = highlightedIndexPath {
                    cell.highlightedTrack = highlightedIndexPath.isEqual(indexPath)
                }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
            var reusableView:UICollectionReusableView?
            if kind == UICollectionElementKindSectionHeader {
                if let trackListHeaderView =
                    collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                        withReuseIdentifier: TrackListHeaderViewReuseIdentifier,
                        forIndexPath: indexPath) as? TrackListHeaderView,
                    albumViewModel = albumViewModel {
                        trackListHeaderView.coverArtImageView.sd_setImageWithURL(albumViewModel.coverThumbURL)
                        trackListHeaderView.nameLabel.text = albumViewModel.title
                        trackListHeaderView.artistLabel.text = albumViewModel.artistName
                        reusableView = trackListHeaderView
                }
            }
            return reusableView!
    }
}

private typealias TrackListDelegateFlowLayout = TrackListViewController
extension TrackListDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSizeMake(collectionView.bounds.size.width, TrackListHeaderView.calculateHeight())
        }
        return CGSizeZero
    }
}



