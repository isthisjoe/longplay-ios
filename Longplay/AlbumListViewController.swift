//
//  AlbumListViewController.swift
//  
//
//  Created by Joe Nguyen on 30/05/2015.
//
//

import UIKit

let AlbumCollectionViewCellReuseIdentifier = "AlbumCollectionViewCellReuseIdentifier"
let AlbumCollectionHeaderViewReuseIdentifier = "AlbumCollectionHeaderViewReuseIdentifier"
let AlbumCollectionFooterViewReuseIdentifier = "AlbumCollectionFooterViewReuseIdentifier"
let AlbumCollectionFooterViewHeight:CGFloat = 0.5

class AlbumListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var session: SPTSession?
    var albumData: [[[String:String]]]?
    var flattenedAlbumData: [[String:String]]?
    var data:[[SPTAlbum]]?
    var didSelectAlbumBlock:((_ album:SPTAlbum, _ about:String)->())?
    var albumLoadingView:UIActivityIndicatorView?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.size.width
        let spacing:CGFloat = 10
//        let sectionSpacing:CGFloat = 10
        let numberOfItemsPerRow:CGFloat = 3
        let itemSizeWidth:CGFloat = (screenWidth - (spacing * (numberOfItemsPerRow + 1)))/numberOfItemsPerRow
        let itemSizeHeight:CGFloat = itemSizeWidth + (itemSizeWidth * 0.3)
        layout.itemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing/2
        layout.sectionInset = UIEdgeInsetsMake(0, spacing, spacing, spacing)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: AlbumCollectionHeaderViewHeight)
        super.init(collectionViewLayout: layout)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let collectionView = collectionView {
            collectionView.backgroundColor = UIColor.white
            collectionView.register(AlbumCollectionViewCell.self,
                forCellWithReuseIdentifier: AlbumCollectionViewCellReuseIdentifier)
            collectionView.register(AlbumCollectionHeaderView.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: AlbumCollectionHeaderViewReuseIdentifier)
            collectionView.register(UICollectionReusableView.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                withReuseIdentifier: AlbumCollectionFooterViewReuseIdentifier)
        }
        self.setupData()
    }
    
    func setupData() {
        if let path = Bundle.main.path(forResource: "albumData", ofType: "plist") {
            albumData = NSArray(contentsOfFile: path) as? [[[String:String]]]
        }
        if let
            albumData = albumData,
            let session = session,
            let accessToken = session.accessToken {
            // flatten the albumData array
            self.flattenedAlbumData = albumData.flatMap { $0 }
            // dispatch group for async processing
            let group = DispatchGroup()
            var count = 0
            for collection in albumData {
                group.enter()
                let albumURIs = collection.map({URL(string:$0["uri"]! as String)!})
                let index = count
                DispatchQueue.global().async {
                    SPTAlbum.albums(withURIs: albumURIs,
                                    accessToken: accessToken,
                                    market: nil,
                                    callback: { (error:Error?, result:Any?) in
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            if let result = result as? [SPTAlbum] {
                                                if self.data == nil {
                                                    // populate data with empty arrays
                                                    self.data = []
                                                    while self.data!.count < albumData.count {
                                                        self.data!.append([])
                                                    }
                                                }
                                                self.data![index] = sortAlbums(result)
                                            }
                                            group.leave()
                                        })
                    })
                }
                count += 1
            }
            // reload data when all album data received
            group.notify(queue: DispatchQueue.main, execute: { () -> Void in
                self.collectionView!.reloadData()
            })
        }
    }
}

// sort by release date or release year if the date is not present
func sortAlbums(_ albums:[SPTAlbum]) -> [SPTAlbum] {
    
    let sortedAlbums = albums.sorted { (alb1, alb2) -> Bool in
        if alb1.releaseYear != 0 ||
            alb2.releaseYear != 0 {
                if let releaseDate1 = alb1.releaseDate,
                    let releaseDate2 = alb2.releaseDate {
                        return releaseDate1.compare(releaseDate2) == .orderedAscending
                } else {
                    return alb1.releaseYear < alb2.releaseYear
                }
        } else {
            return false
        }
    }
    return sortedAlbums
}

private typealias AlbumListCollectionViewDataSource = AlbumListViewController
extension AlbumListCollectionViewDataSource {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let data = data {
            hideAlbumListLoading()
            return data.count
        }
        showAlbumListLoading()
        return 0
    }
    
    func showAlbumListLoading() {
        
        if albumLoadingView == nil {
            albumLoadingView = UIActivityIndicatorView(activityIndicatorStyle:.gray)
        }
        if let albumLoadingView = albumLoadingView {
            if albumLoadingView.superview == nil {
                view.addSubview(albumLoadingView)
                albumLoadingView.snp.makeConstraints { (make) -> Void in
                    make.center.equalTo(view)
                }
                albumLoadingView.alpha = 0.0
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    albumLoadingView.alpha = 1.0
                })
            }
            if !albumLoadingView.isAnimating {
                albumLoadingView.startAnimating()
            }
        }
    }
    
    func hideAlbumListLoading() {
        
        if let albumLoadingView = albumLoadingView {
            if albumLoadingView.alpha == 1.0 {
                UIView.animate(withDuration: 0.3,
                    animations: { () -> Void in
                        albumLoadingView.alpha = 1.0
                    },
                    completion: { (finished:Bool) -> Void in
                        albumLoadingView.removeFromSuperview()
                        self.albumLoadingView = nil
                })
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = data,
            let collection = data[section] as [SPTAlbum]? {
                return collection.count
        }
        return 0
    }
}

private typealias AlbumListCollectionViewDelegate = AlbumListViewController
extension AlbumListCollectionViewDelegate {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView:UICollectionReusableView? = nil
        if kind == UICollectionElementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                                withReuseIdentifier: AlbumCollectionHeaderViewReuseIdentifier,
                                                                                for: indexPath) as? AlbumCollectionHeaderView {
                switch indexPath.section {
                case 0:
                    headerView.titleLabel.text = "LATEST"
                    break
                case 1:
                    headerView.titleLabel.text = "CLASSICS"
                    break
                default:
                    break
                }
                reusableView = headerView
            }
        }
        if kind == UICollectionElementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                             withReuseIdentifier: AlbumCollectionFooterViewReuseIdentifier,
                                                                             for: indexPath)
            let lineView = UIView()
            lineView.backgroundColor = UIColor.darkGray
            footerView.addSubview(lineView)
            lineView.snp.makeConstraints { (make) -> Void in
                make.edges.equalTo(footerView).inset(UIEdgeInsetsMake(0, 10, 0, 10))
            }
            reusableView = footerView
        }
        return reusableView!
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCollectionViewCellReuseIdentifier,
                for: indexPath) as! AlbumCollectionViewCell
            if let data = data,
                let collection = data[indexPath.section] as [SPTAlbum]?,
                let album = collection[indexPath.row] as SPTAlbum? {
                    let albumViewModel = AlbumViewModel(album:album)
                    cell.configureCellWithViewModel(albumViewModel)
            }
            return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let data = data,
            let flattenedAlbumData = flattenedAlbumData,
            let collection = data[indexPath.section] as [SPTAlbum]?,
            let album = collection[indexPath.row] as SPTAlbum? {
                let about = flattenedAlbumData.filter({$0["uri"] == album.uri.absoluteString}).map({$0["about"]!}).first!
                if let didSelectAlbumBlock = didSelectAlbumBlock {
                    didSelectAlbumBlock(album, about)
                }
        }
    }
}

private typealias AlbumListDelegateFlowLayout = AlbumListViewController
extension AlbumListDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let data = data {
            if section < data.count - 1 {
                return CGSize(width: UIScreen.main.bounds.size.width, height: AlbumCollectionFooterViewHeight)
            }
        }
        return CGSize.zero
    }
}



