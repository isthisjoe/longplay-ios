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
    var didSelectAlbumBlock:((album:SPTAlbum, about:String)->())?
    var albumLoadingView:UIActivityIndicatorView?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let spacing:CGFloat = 10
        let sectionSpacing:CGFloat = 10
        let numberOfItemsPerRow:CGFloat = 3
        let itemSizeWidth:CGFloat = (screenWidth - (spacing * (numberOfItemsPerRow + 1)))/numberOfItemsPerRow
        let itemSizeHeight:CGFloat = itemSizeWidth + (itemSizeWidth * 0.3)
        layout.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing/2
        layout.sectionInset = UIEdgeInsetsMake(0, spacing, spacing, spacing)
        layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, AlbumCollectionHeaderViewHeight)
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
        if let collectionView = collectionView {
            collectionView.backgroundColor = UIColor.whiteColor()
            collectionView.registerClass(AlbumCollectionViewCell.self,
                forCellWithReuseIdentifier: AlbumCollectionViewCellReuseIdentifier)
            collectionView.registerClass(AlbumCollectionHeaderView.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: AlbumCollectionHeaderViewReuseIdentifier)
            collectionView.registerClass(UICollectionReusableView.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                withReuseIdentifier: AlbumCollectionFooterViewReuseIdentifier)
        }
        self.setupData()
    }
    
    func setupData() {
        if let path = NSBundle.mainBundle().pathForResource("albumData", ofType: "plist") {
            albumData = NSArray(contentsOfFile: path) as? [[[String:String]]]
        }
        if let
            albumData = albumData,
            session = session,
            accessToken = session.accessToken {
                // flatten the albumData array 
                self.flattenedAlbumData = albumData.flatMap { $0 }
                // dispatch group for async processing
                let group = dispatch_group_create()
                var count = 0
                for collection in albumData {
                    dispatch_group_enter(group)
                    let albumURIs = collection.map({NSURL(string:$0["uri"]! as String)!})
                    let index = count
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        SPTAlbum.albumsWithURIs(albumURIs,
                            accessToken: accessToken,
                            market: nil,
                            callback: {
                                (error:NSError!, result:AnyObject!) -> Void in
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
                                    dispatch_group_leave(group)
                                })
                        })
                    })
                    count++
                }
                // reload data when all album data received
                dispatch_group_notify(group, dispatch_get_main_queue(), { () -> Void in
                    self.collectionView!.reloadData()
                })
        }
    }
}

// sort by release date or release year if the date is not present
func sortAlbums(albums:[SPTAlbum]) -> [SPTAlbum] {
    
    let sortedAlbums = albums.sorted { (alb1, alb2) -> Bool in
        if alb1.releaseYear != 0 ||
            alb2.releaseYear != 0 {
                if let releaseDate1 = alb1.releaseDate,
                    let releaseDate2 = alb2.releaseDate {
                        return releaseDate1.compare(releaseDate2) == .OrderedAscending
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
extension AlbumListCollectionViewDataSource: UICollectionViewDataSource {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let data = data {
            hideAlbumListLoading()
            return data.count
        }
        showAlbumListLoading()
        return 0
    }
    
    func showAlbumListLoading() {
        
        if albumLoadingView == nil {
            albumLoadingView = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
        }
        if let albumLoadingView = albumLoadingView {
            if albumLoadingView.superview == nil {
                view.addSubview(albumLoadingView)
                albumLoadingView.snp_makeConstraints { (make) -> Void in
                    make.center.equalTo(view)
                }
                albumLoadingView.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    albumLoadingView.alpha = 1.0
                })
            }
            if !albumLoadingView.isAnimating() {
                albumLoadingView.startAnimating()
            }
        }
    }
    
    func hideAlbumListLoading() {
        
        if let albumLoadingView = albumLoadingView {
            if albumLoadingView.alpha == 1.0 {
                UIView.animateWithDuration(0.3,
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

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = data,
            collection = data[section] as [SPTAlbum]? {
                return collection.count
        }
        return 0
    }
}

private typealias AlbumListCollectionViewDelegate = AlbumListViewController
extension AlbumListCollectionViewDelegate: UICollectionViewDelegate {
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView:UICollectionReusableView? = nil
        if kind == UICollectionElementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                withReuseIdentifier: AlbumCollectionHeaderViewReuseIdentifier,
                forIndexPath: indexPath) as? AlbumCollectionHeaderView {
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
            if let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter,
                withReuseIdentifier: AlbumCollectionFooterViewReuseIdentifier,
                forIndexPath: indexPath) as? UICollectionReusableView {
                    let lineView = UIView()
                    lineView.backgroundColor = UIColor.darkGrayColor()
                    footerView.addSubview(lineView)
                    lineView.snp_makeConstraints({ (make) -> Void in
                        make.edges.equalTo(footerView).insets(UIEdgeInsetsMake(0, 10, 0, 10))
                    })
                    reusableView = footerView
            }
        }
        return reusableView!
    }
    
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                AlbumCollectionViewCellReuseIdentifier,
                forIndexPath: indexPath) as! AlbumCollectionViewCell
            if let data = data,
                collection = data[indexPath.section] as [SPTAlbum]?,
                album = collection[indexPath.row] as SPTAlbum? {
                    let albumViewModel = AlbumViewModel(album:album)
                    cell.configureCellWithViewModel(albumViewModel)
            }
            return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let data = data,
            flattenedAlbumData = flattenedAlbumData,
            collection = data[indexPath.section] as [SPTAlbum]?,
            album = collection[indexPath.row] as SPTAlbum? {
                let about = flattenedAlbumData.filter({$0["uri"] == album.uri.absoluteString!}).map({$0["about"]!}).first!
                if let didSelectAlbumBlock = didSelectAlbumBlock {
                    didSelectAlbumBlock(album: album, about: about)
                }
        }
    }
}

private typealias AlbumListDelegateFlowLayout = AlbumListViewController
extension AlbumListDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let data = data {
            if section < data.count - 1 {
                return CGSizeMake(UIScreen.mainScreen().bounds.size.width, AlbumCollectionFooterViewHeight)
            }
        }
        return CGSizeZero
    }
}



