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
    var data:Array<Dictionary<String,String>>?
    var playAlbumBlock:((album:SPTAlbum) -> ())?
    
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
        self.collectionView!.reloadData()
    }
    
    func setupData() {
        let spotifyURIs = [
            ["thumb_path": "https://i.scdn.co/image/7d6bdfa7a2e53574f9a6dad8c699df86865df652",
                "name":"All In All",
                "artist":"Bob Moses",
                "uri":"spotify:album:3OMktTWq6op5qTgMsvlRtN"],
            ["thumb_path": "https://i.scdn.co/image/5020a71a285a2063573d388167471c84678e3e71",
                "name":"In Colour",
                "artist":"Jamie xx",
                "uri":"spotify:album:0AVPusXNzK1jWwefBiPJ5I"],
            ["thumb_path": "https://i.scdn.co/image/1ecf766883e94af4a8a9145a4ff93f7e30872cb8",
                "name":"Xen",
                "artist":"Arca",
                "uri":"spotify:album:5FLsmazQWaDK9JGqdzHlN4"],
            ["thumb_path": "https://i.scdn.co/image/73930624d021a616dbf431ec19779b2e635b468c",
                "name":"Currents",
                "artist":"Tame Impala",
                "uri":"spotify:album:79dL7FLiJFOO0EoehUHQBv"],
            ["thumb_path": "https://i.scdn.co/image/63143db64dd7f83e599b5625ffc8e051d72bda38",
                "name":"Wildheart",
                "artist":"Miguel",
                "uri":"spotify:album:6b5WANFyoXhaMTXPqLF6ez"],
            ["thumb_path": "https://i.scdn.co/image/46055422ddb4839f5ec9125c7752ab9391311bcb",
                "name":"Summertime '06",
                "artist":"Vince Staples",
                "uri":"spotify:album:4Csoz10NhNJOrCTUoPBdUD"]]
        data = spotifyURIs
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
                dictionary = data[indexPath.row] as Dictionary<String,String>? {
                    let albumViewModel = AlbumViewModel(dictionary:dictionary)
                    cell.configureCellWithViewModel(albumViewModel)
            }
            return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let
            data = data,
            dictionary = data[indexPath.row] as Dictionary<String,String>? {
                if let
                    albumURI = dictionary["uri"] as String!,
                    albumURL = NSURL(string: albumURI) {
                        loadSPTAlbum(albumURL, completed: { (album) -> () in
                            if let
                                album = album as SPTAlbum!,
                                navigationController = self.navigationController {
                                    let albumViewController = AlbumViewController(album: album)
                                    albumViewController.playAlbumBlock = { (album:SPTAlbum) -> () in
                                        if let playAlbumBlock = self.playAlbumBlock {
                                            playAlbumBlock(album: album)
                                        }
                                    }
                                    navigationController.pushViewController(albumViewController, animated: true)
                            }
                        })
                }
        }
    }
    
    func loadSPTAlbum(albumURL:NSURL, completed: ((album:SPTAlbum?)->())) {
        if let session = session {
            SPTAlbum.albumWithURI(albumURL,
                accessToken: session.accessToken,
                market: nil,
                callback: { (error:NSError!, result:AnyObject!) -> Void in
                    if let album:SPTAlbum = result as? SPTAlbum {
                        completed(album: album)
                    } else {
                        completed(album: nil)
                    }
            })
        }
    }
}



