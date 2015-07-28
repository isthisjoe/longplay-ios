//
//  AlbumListViewController.swift
//  
//
//  Created by Joe Nguyen on 30/05/2015.
//
//

import UIKit

let AlbumCollectionViewCellReuseIdentifier = "AlbumCollectionViewCellReuseIdentifier"

class AlbumListViewController: UICollectionViewController {
    
    var session: SPTSession?
    var data:[SPTAlbum]?
    var playAlbumBlock:((album:SPTAlbum) -> ())?
    var didSelectAlbumBlock:((album:SPTAlbum)->())?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let spacing:CGFloat = 10
        let numberOfItemsPerRow:CGFloat = 3
        let itemSizeWidth:CGFloat = (screenWidth - (spacing * (numberOfItemsPerRow + 1)))/numberOfItemsPerRow
        let itemSizeHeight:CGFloat = itemSizeWidth + (itemSizeWidth * 0.3)
        layout.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing/2
        layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
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
        self.collectionView!.registerClass(AlbumCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumCollectionViewCellReuseIdentifier)
        self.setupData()
    }
    
    func setupData() {
        var albumsList: NSArray?
        if let path = NSBundle.mainBundle().pathForResource("album_ids", ofType: "plist") {
            albumsList = NSArray(contentsOfFile: path)
        }
        if let
            albumsList = albumsList as? Array<Dictionary<String,String>>,
            session = session,
            accessToken = session.accessToken {
                let albumURIs = albumsList.map({NSURL(string:$0["uri"]! as String)!})
                SPTAlbum.albumsWithURIs(albumURIs,
                    accessToken: accessToken,
                    market: nil,
                    callback: {
                        (error:NSError!, result:AnyObject!) -> Void in
                        if let result = result as? [SPTAlbum] {
                            self.data = result
                            self.collectionView!.reloadData()
                        }
                })
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = data {
            return data.count
        } else {
            return 0
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                AlbumCollectionViewCellReuseIdentifier,
                forIndexPath: indexPath) as! AlbumCollectionViewCell
            if let
                data = data,
                album = data[indexPath.row] as SPTAlbum? {
                    let albumViewModel = AlbumViewModel(album:album)
                    cell.configureCellWithViewModel(albumViewModel)
            }
            return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let
            data = data,
            album = data[indexPath.row] as SPTAlbum? {
                if let didSelectAlbumBlock = didSelectAlbumBlock {
                    didSelectAlbumBlock(album: album)
                }
        }
    }
}



