//
//  TrackListViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 16/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

let TrackListCollectionViewCellReuseIdentifier = "TrackListCollectionViewCellReuseIdentifier"

class TrackListViewController: UICollectionViewController {

    var album:SPTAlbum? {
        didSet {
            if let collectionView = collectionView {
                collectionView.reloadData()
            }
        }
    }
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
    
    init() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let spacing:CGFloat = 10
        let itemSizeWidth:CGFloat = screenWidth
        let itemSizeHeight:CGFloat = 20.0
        layout.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        super.init(collectionViewLayout: layout)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView!.backgroundColor = UIColor.whiteColor()

        // Register cell classes
        self.collectionView!.registerClass(TrackListCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackListCollectionViewCellReuseIdentifier)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if let items = items {
            count = items.count
        }
        return count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TrackListCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! TrackListCollectionViewCell
        if let
            items = items,
            track = items[indexPath.row] as? SPTPartialTrack {
                let viewModel = TrackListViewModel(track: track)
                cell.configureCellWithViewModel(viewModel)
        }
        return cell
    }
}
