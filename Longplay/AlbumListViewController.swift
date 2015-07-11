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
    
    var data:Array<Dictionary<String,String>>?
    
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
            ["thumb_path": "https://i.scdn.co/image/2bd3041e2a047fd847ab3d95eb2a2b91b68c3780",
                "name":"TRON: Legacy Reconfigured",
                "artist":"Daft Punk",
                "uri":"spotify:album:382ObEPsp2rxGrnsizN5TX"],
            ["thumb_path": "https://i.scdn.co/image/28897846639005afabda0a3136b3ed824ae54bef",
                "name":"Human After All",
                "artist":"Daft Punk",
                "uri":"spotify:album:1A2GTWGtFfWp7KSQTwWOyo"],
            ["thumb_path": "https://i.scdn.co/image/8e46b102398b42b322dc1e938eb12e93acceaff2",
                "name":"Discovery",
                "artist":"Daft Punk",
                "uri":"spotify:album:2noRn2Aes5aoNVsU6iWThc"]]
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
}



