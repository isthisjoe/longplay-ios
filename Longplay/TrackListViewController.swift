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
            let firstTrackPage = album.firstTrackPage,
            let items = firstTrackPage.items {
                return items as Array<AnyObject>?
        } else {
            return nil
        }
    }
    var highlightedIndexPath:IndexPath?

    class func createFlowLayout() -> UICollectionViewFlowLayout {
        
        let flowLayout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.size.width
        let spacing:CGFloat = 10
        let itemSizeWidth:CGFloat = screenWidth
        let itemSizeHeight:CGFloat = 20.0
        flowLayout.itemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 14, 0)
        return flowLayout
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        flowLayout = TrackListViewController.createFlowLayout()
        
        collectionView = TrackListCollectionView(frame:CGRect.zero, collectionViewLayout:flowLayout!)
        if let collectionView = collectionView {
            collectionView.delaysContentTouches = false
            collectionView.canCancelContentTouches = true
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.white
            collectionView.register(TrackListCollectionViewCell.self,
                forCellWithReuseIdentifier: TrackListCollectionViewCellReuseIdentifier)
            collectionView.register(TrackListHeaderView.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: TrackListHeaderViewReuseIdentifier)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(collectionView)
            collectionView.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(view)
            }
        }
    }
}

private typealias TrackListDataSource = TrackListViewController
extension TrackListDataSource: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if let items = items {
            count = items.count
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackListCollectionViewCellReuseIdentifier, for: indexPath) as! TrackListCollectionViewCell
        if let
            items = items,
            let track = items[indexPath.row] as? SPTPartialTrack {
                let viewModel = TrackListViewModel(track: track)
                cell.configureCellWithViewModel(viewModel)
                if let highlightedIndexPath = highlightedIndexPath {
                    cell.highlightedTrack = highlightedIndexPath == indexPath
                }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
            
            var reusableView:UICollectionReusableView?
            if kind == UICollectionElementKindSectionHeader {
                if let trackListHeaderView =
                    collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                        withReuseIdentifier: TrackListHeaderViewReuseIdentifier,
                        for: indexPath) as? TrackListHeaderView,
                    let albumViewModel = albumViewModel {
                        trackListHeaderView.coverArtImageView.sd_setImage(with: albumViewModel.coverThumbURL as URL!)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.bounds.size.width, height: TrackListHeaderView.calculateHeight())
        }
        return CGSize.zero
    }
}



