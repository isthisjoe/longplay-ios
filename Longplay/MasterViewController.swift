//
//  MasterViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 10/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    var session: SPTSession?
    
    var navigationView:NavigationView?
    var browserNavigationController:BrowserNavigationController?
    var albumListViewController:AlbumListViewController?
    var player:PlayerViewController?
    var settingsViewController:UIViewController?
    var isShowingPlayer:Bool = false
    let dataStore = DataStore()
    
    // MARK: Views
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // browser
        albumListViewController = AlbumListViewController()
        if let albumListViewController = albumListViewController {
            albumListViewController.title = "Longplay"
            albumListViewController.session = session
            albumListViewController.didSelectAlbumBlock = { (album:SPTAlbum, about:String) -> () in
                self.didSelectAlbumForViewing(album, about:about)
            }
            browserNavigationController = BrowserNavigationController(rootViewController: albumListViewController)
            if let browserNavigationController = browserNavigationController {
                browserNavigationController.setNavigationBarHidden(true, animated: false)
                browserNavigationController.willMoveToParentViewController(self)
                addChildViewController(browserNavigationController)
                browserNavigationController.didMoveToParentViewController(self)
                view.addSubview(browserNavigationController.view)
                browserNavigationController.view.snp_makeConstraints {
                    (make) -> Void in
                    make.edges.equalTo(view).insets(UIEdgeInsetsMake(0, 0, NavigationViewHeight, 0))
                }
            }
        }
        
        // player
        player = PlayerViewController()
        if let player = player {
            player.session = session
            player.willMoveToParentViewController(self)
            addChildViewController(player)
            player.didMoveToParentViewController(self)
            view.addSubview(player.view)
            player.view.snp_makeConstraints {
                (make) -> Void in
                make.height.equalTo(UIScreen.mainScreen().bounds.size.height)
                make.left.right.equalTo(view)
                make.top.equalTo(view.snp_bottom).offset(-NavigationViewHeight)
            }
            player.addTargetToBrowserButton(self, action: "tappedNavigationMiddleButton:")
            // did change track callback
            player.didChangeToTrackBlock = {
                (playerViewController:PlayerViewController, title:String, artist:String) in
                self.playerDidChangeToTrack(title, artist: artist)
            }
            // did change playback status
            player.didChangePlaybackStatusBlock = {
                (playerViewController:PlayerViewController, isPlaying:Bool) in
                self.playerDidChangePlaybackStatus(isPlaying)
            }
        }
        
        // navigation view
        navigationView = NavigationView()
        if let navigationView = navigationView,
            player = player {
                navigationView.showLogoInLeftButton()
                navigationView.hideMiddleButton()
                player.view.addSubview(navigationView)
                navigationView.snp_makeConstraints({ (make) -> Void in
                    make.height.equalTo(NavigationViewHeight)
                    make.top.left.right.equalTo(player.view)
                })
                if let middleButton = navigationView.middleButton {
                    middleButton.addTarget(self, action: "tappedNavigationMiddleButton:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                if let leftButton = navigationView.leftButton {
                    leftButton.addTarget(self, action: "pushToSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                loadCurrentAlbumPlaying()
        }
    }
    
    func loadCurrentAlbumPlaying() {
        
        if hasCurrentAlbumPlaying() {
            let albumURI = dataStore.currentAlbumURI!
            var startTrackIndex = self.dataStore.currentAlbumTrackIndex
            fetchAlbum(albumURI, completed: { (album:SPTAlbum) -> () in
                self.loadAlbum(album, startTrackIndex:startTrackIndex, autoPlay:false)
            })
        }
    }
    
    // MARK: Actions
    
    func didSelectAlbumForViewing(album:SPTAlbum, about:String) {
        
        if let browserNavigationController = browserNavigationController {
            let albumViewController = AlbumViewController(album: album, about:about)
            albumViewController.playAlbumBlock = { (album:SPTAlbum) -> () in
                self.loadAlbum(album, startTrackIndex: nil, autoPlay:true)
            }
            browserNavigationController.pushViewController(albumViewController, animated: true)
            // update navigation
            if let navigationView = navigationView {
                // left
                navigationView.showChevronInLeftButton()
                if let leftButton = navigationView.leftButton {
                    for target in leftButton.allTargets() {
                        leftButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    leftButton.addTarget(self, action: "backToBrowserAction:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                // middle
                navigationView.showPlayAlbumInMiddleButton()
                if let middleButton = navigationView.middleButton {
                    for target in middleButton.allTargets() {
                        middleButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    middleButton.addTarget(albumViewController, action: "playAction:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
        }
    }
    
    func backToBrowserAction(sender:AnyObject) {
        
        if let browserNavigationController = browserNavigationController {
            browserNavigationController.popToRootViewControllerAnimated(true)
        }
        if let navigationView = navigationView {
            // left
            navigationView.showLogoInLeftButton()
            if let leftButton = navigationView.leftButton {
                for target in leftButton.allTargets() {
                    leftButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                }
                leftButton.addTarget(self, action: "pushToSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            // middle
            navigationView.hideMiddleButtonText()
            navigationView.showAlbumDetails()
            if let middleButton = navigationView.middleButton {
                for target in middleButton.allTargets() {
                    middleButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                }
                middleButton.addTarget(self, action: "tappedNavigationMiddleButton:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    
    func backToBrowserFromSettingsAction(sender:AnyObject) {
        
        if let browserNavigationController = browserNavigationController {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            browserNavigationController.view.layer.addAnimation(transition, forKey: kCATransition)
            browserNavigationController.popToRootViewControllerAnimated(false)
        }
        if let navigationView = navigationView {
            // left
            navigationView.showLogoInLeftButton()
            if let leftButton = navigationView.leftButton {
                leftButton.addTarget(self, action: "pushToSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            // middle
            if isPlayingAlbum() {
                navigationView.hideMiddleButtonText()
                navigationView.showAlbumDetails()
                if let middleButton = navigationView.middleButton {
                    for target in middleButton.allTargets() {
                        middleButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    middleButton.addTarget(self, action: "tappedNavigationMiddleButton:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
            // right
            navigationView.hideRightButton()
            if isPlayingAlbum() {
                navigationView.showPlayInRightButton()
            }
        }
    }
    
    func pushToSettingsAction(sender:AnyObject) {
        
        if settingsViewController == nil {
            settingsViewController = UIViewController()
        }
        if let browserNavigationController = browserNavigationController,
            settingsViewController = settingsViewController {
                settingsViewController.view.backgroundColor = UIColor.darkGrayColor()
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                browserNavigationController.view.layer.addAnimation(transition, forKey: kCATransition)
                browserNavigationController.pushViewController(settingsViewController, animated: false)
        }
        if let navigationView = navigationView {
            // left
            navigationView.hideLeftButton()
            if let rightButton = navigationView.rightButton {
                rightButton.addTarget(self, action: "backToBrowserFromSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            // middle
            navigationView.hideMiddleButton()
            navigationView.hideAlbumDetails()
            // right
            navigationView.showChevronInRightButton()
        }
    }
    
    func tappedNavigationMiddleButton(sender:AnyObject) {
        
        let damping:CGFloat = 0.85
        if let player = player,
            browserNavigationController = browserNavigationController,
            navigationView = navigationView {
                if isShowingPlayer {
                    // hide player
                    // animate player view entering
                    view.layoutIfNeeded()
                    player.view.snp_remakeConstraints({ (make) -> Void in
                        make.height.equalTo(UIScreen.mainScreen().bounds.size.height)
                        make.left.right.equalTo(view)
                        make.top.equalTo(view.snp_bottom).offset(-NavigationViewHeight)
                    })
                    browserNavigationController.view.snp_remakeConstraints({ (make) -> Void in
                        make.edges.equalTo(view).insets(UIEdgeInsetsMake(0, 0, NavigationViewHeight, 0))
                    })
                    UIView.animateWithDuration(0.5,
                        delay: 0.0,
                        usingSpringWithDamping: damping,
                        initialSpringVelocity: 0.0,
                        options: UIViewAnimationOptions(0),
                        animations: { () -> Void in
                            self.view.layoutIfNeeded()
                            // show navigation
                            navigationView.alpha = 1.0
                        },
                        completion: nil)
                    isShowingPlayer = false
                } else {
                    // show player
                    // expand player height
                    player.view.snp_remakeConstraints({ (make) -> Void in
                        make.height.equalTo(UIScreen.mainScreen().bounds.size.height)
                        make.left.right.equalTo(view)
                        make.top.equalTo(view.snp_bottom).offset(-NavigationViewHeight)
                    })
                    // animate player view entering
                    view.layoutIfNeeded()
                    player.view.snp_remakeConstraints({ (make) -> Void in
                        make.edges.equalTo(view)
                    })
                    browserNavigationController.view.snp_remakeConstraints({ (make) -> Void in
                        make.height.equalTo(UIScreen.mainScreen().bounds.size.height - NavigationViewHeight)
                        make.left.right.equalTo(view)
                        make.bottom.equalTo(player.view.snp_top)
                    })
                    UIView.animateWithDuration(0.5,
                        delay: 0.0,
                        usingSpringWithDamping: damping,
                        initialSpringVelocity: 0.0,
                        options: UIViewAnimationOptions(0),
                        animations: { () -> Void in
                            self.view.layoutIfNeeded()
                            // hide navigation
                            navigationView.alpha = 0.0
                        },
                        completion: nil)
                    isShowingPlayer = true
                }
        }
    }
    
    // MARK: Player
    
    func loadAlbum(album:SPTAlbum, startTrackIndex:Int32?, autoPlay:Bool) {
        if let player = player {
            player.album = album
            player.stopPlayback({ () -> () in
                player.loadAlbum(album, startTrackIndex: startTrackIndex, autoPlay: autoPlay)
//                player.loadAlbum(album, startTrackIndex:startTrackIndex, didStartPlaying: { (firstTrackName) -> () in
//                    // update navigation
//                    if let navigationView = self.navigationView {
//                        // middle
//                        let topLabelText = "1. " + firstTrackName
//                        let bottomLabelText = album.name + " - " + album.artists.first!.name
//                        navigationView.populateAlbumDetails(topLabelText, bottomLabelText: bottomLabelText)
//                        navigationView.showAlbumDetails()
//                        if let middleButton = navigationView.middleButton {
//                            for target in middleButton.allTargets() {
//                                middleButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
//                            }
//                            middleButton.addTarget(self, action: "tappedNavigationMiddleButton:", forControlEvents: UIControlEvents.TouchUpInside)
//                        }
//                        // right
//                        navigationView.showPauseInRightButton()
//                        if let rightButton = navigationView.rightButton {
//                            for target in rightButton.allTargets() {
//                                rightButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
//                            }
//                            rightButton.addTarget(self, action: "pausePlayer:", forControlEvents: UIControlEvents.TouchUpInside)
//                        }
//                    }
//                })
            })
        }
    }
    
    func isPlayingAlbum() -> Bool {
        if let player = player {
            return player.isPlaying
        }
        return false
    }
    
    func pausePlayer(sender:AnyObject) {
        if let player = player {
            player.pause({ () -> () in
                if let navigationView = self.navigationView {
                    navigationView.showPlayInRightButton()
                    if let rightButton = navigationView.rightButton {
                        for target in rightButton.allTargets() {
                            rightButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                        }
                        rightButton.addTarget(self, action: "resumePlayer:", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                }
            })
        }
    }
    
    func resumePlayer(sender:AnyObject) {
        if let player = player {
            player.play({ () -> () in
                if let navigationView = self.navigationView {
                    navigationView.showPauseInRightButton()
                    if let rightButton = navigationView.rightButton {
                        for target in rightButton.allTargets() {
                            rightButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                        }
                        rightButton.addTarget(self, action: "pausePlayer:", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                }
            })
        }
    }
    
    func playerDidChangeToTrack(title:String, artist:String) {
        // update navigation
        if let navigationView = self.navigationView {
            // middle
            let topLabelText = title
            let bottomLabelText = artist
            navigationView.populateAlbumDetails(topLabelText, bottomLabelText: bottomLabelText)
            navigationView.showAlbumDetails()
            if let middleButton = navigationView.middleButton {
                for target in middleButton.allTargets() {
                    middleButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                }
                middleButton.addTarget(self, action: "tappedNavigationMiddleButton:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            navigationView.showMiddleButton() 
        }
    }
    
    func playerDidChangePlaybackStatus(isPlaying:Bool) {
        // update navigation
        if let navigationView = self.navigationView {
            // right
            if isPlaying {
                navigationView.showPauseInRightButton()
                if let rightButton = navigationView.rightButton {
                    for target in rightButton.allTargets() {
                        rightButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    rightButton.addTarget(self, action: "pausePlayer:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            } else {
                navigationView.showPlayInRightButton()
                if let rightButton = navigationView.rightButton {
                    for target in rightButton.allTargets() {
                        rightButton.removeTarget(target, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    rightButton.addTarget(self, action: "resumePlayer:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
        }
    }
}

private typealias MasterViewController_LoadCurrentAlbum = MasterViewController
extension MasterViewController_LoadCurrentAlbum {
    
    func hasCurrentAlbumPlaying() -> Bool {
        
        if let currentAlbumURI = dataStore.currentAlbumURI {
            return true
        }
        return false
    }
    
    func fetchAlbum(albumURI:NSURL, completed:((album:SPTAlbum)->())?) {
        
        if let session = session,
            accessToken = session.accessToken {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    SPTAlbum.albumWithURI(albumURI, accessToken: accessToken, market: nil, callback: {
                        (error:NSError!, result:AnyObject!) -> Void in
                        println(result)
                        if error != nil {
                            NSLog("error: %@", error)
                        } else {
                            var album = result as! SPTAlbum
                            if let completed = completed {
                                completed(album:album)
                            }
                        }
                    })
                })
        }
    }
}


