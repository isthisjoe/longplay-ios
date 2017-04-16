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
    var settingsViewController:SettingsViewController?
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
                browserNavigationController.willMove(toParentViewController: self)
                addChildViewController(browserNavigationController)
                browserNavigationController.didMove(toParentViewController: self)
                view.addSubview(browserNavigationController.view)
                browserNavigationController.view.snp.makeConstraints {
                    (make) -> Void in
                    make.edges.equalTo(view).inset(UIEdgeInsetsMake(0, 0, NavigationViewHeight, 0))
                }
            }
        }
        
        // player
        player = PlayerViewController()
        if let player = player {
            player.session = session
            player.willMove(toParentViewController: self)
            addChildViewController(player)
            player.didMove(toParentViewController: self)
            view.addSubview(player.view)
            player.view.snp.makeConstraints {
                (make) -> Void in
                make.height.equalTo(UIScreen.main.bounds.size.height)
                make.left.right.equalTo(view)
                make.top.equalTo(view.snp.bottom).offset(-NavigationViewHeight)
            }
            player.addTargetToBrowserButton(self, action: #selector(MasterViewController.tappedNavigationMiddleButton(_:)))
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
            // did update album progress
            player.didUpdateAlbumProgressBlock = {
                (playerViewController:PlayerViewController, progress:Float) in
                self.playerDidUpdateAlbumProgress(progress)
            }
        }
        
        // navigation view
        navigationView = NavigationView()
        if let navigationView = navigationView,
            let player = player {
                navigationView.showLogoInLeftButton()
                navigationView.hideMiddleButton()
                player.view.addSubview(navigationView)
                navigationView.snp.makeConstraints { (make) -> Void in
                    make.height.equalTo(NavigationViewHeight)
                    make.top.left.right.equalTo(player.view)
                }
                if let middleButton = navigationView.middleButton {
                    middleButton.addTarget(self, action: #selector(MasterViewController.tappedNavigationMiddleButton(_:)), for: UIControlEvents.touchUpInside)
                }
                if let leftButton = navigationView.leftButton {
                    leftButton.addTarget(self, action: #selector(MasterViewController.pushToSettingsAction(_:)), for: UIControlEvents.touchUpInside)
                }
                loadCurrentAlbumPlaying()
        }
    }
    
    func loadCurrentAlbumPlaying() {
        
        if hasCurrentAlbumPlaying() {
            let albumURI = dataStore.currentAlbumURI!
            let startTrackIndex = self.dataStore.currentAlbumTrackIndex
            fetchAlbum(albumURI as URL, completed: {
                (album:SPTAlbum) -> () in
                
                self.loadAlbum(album)
                
                let progress = self.dataStore.currentAlbumPlaybackProgress
                
                // update nav view
                if let navigationView = self.navigationView {
                    if let progress = progress {
                        navigationView.updateProgressView(progress)
                    }
                    // find track that will play
                    if let track = self.trackInAlbum(album, index: startTrackIndex),
                        let artists = track.artists as? [SPTPartialArtist],
                        let firstArtist = artists.first {
                            // middle
                            self.playerDidChangeToTrack(track.name, artist:firstArtist.name)
                            // right
                            self.navigationViewShowPlayInRightButton()
                    }
                }
                
                // update player
                if let player = self.player {
                    if let startTrackIndex = startTrackIndex {
                        player.currentTrackIndex = startTrackIndex
                    }
                    if let progress = progress {
                        player.setAlbumPlaybackProgress(progress, animated: false)
                    }
                }
            })
        }
    }
    
    func trackInAlbum(_ album:SPTAlbum, index:Int32?) -> SPTPartialTrack? {
        var startIndex:Int32? = index
        if startIndex == nil {
            startIndex = 0
        }
        var track:SPTPartialTrack?
        if let listPage:SPTListPage = album.firstTrackPage,
            let items = listPage.items as? [SPTPartialTrack] {
                track = items[Int(startIndex!)]
        }
        return track
    }
    
    // MARK: Actions
    
    func didSelectAlbumForViewing(_ album:SPTAlbum, about:String) {
        
        if let browserNavigationController = browserNavigationController {
            let albumViewController = AlbumViewController(album: album, about:about)
            albumViewController.playAlbumBlock = { (album:SPTAlbum) -> () in
                self.loadAlbum(album)
                self.playAlbum(nil)
                self.showPlayer()
            }
            browserNavigationController.pushViewController(albumViewController, animated: true)
            // update navigation
            if let navigationView = navigationView {
                // left
                navigationView.showChevronInLeftButton()
                if let leftButton = navigationView.leftButton {
                    for target in leftButton.allTargets {
                        leftButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                    }
                    leftButton.addTarget(self, action: #selector(MasterViewController.backToBrowserAction(_:)), for: UIControlEvents.touchUpInside)
                }
                // middle
                if !isAlbumLoadedIntoPlayer(album) {
                    // middle
                    navigationView.showPlayAlbumInMiddleButton()
                    if let middleButton = navigationView.middleButton {
                        for target in middleButton.allTargets {
                            middleButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                        }
                        middleButton.addTarget(albumViewController, action: #selector(AlbumViewController.playAction), for: .touchUpInside)
                    }
                    // right
                    navigationView.hideRightButton()
                }
            }
        }
    }
    
    func backToBrowserAction(_ sender:AnyObject) {
        
        if let browserNavigationController = browserNavigationController {
            browserNavigationController.popToRootViewController(animated: true)
        }
        if let navigationView = navigationView {
            // left
            navigationView.showLogoInLeftButtonAnimated(true)
            if let leftButton = navigationView.leftButton {
                for target in leftButton.allTargets {
                    leftButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                }
                leftButton.addTarget(self, action: #selector(MasterViewController.pushToSettingsAction(_:)), for: UIControlEvents.touchUpInside)
            }
            // middle
            navigationView.hideMiddleButtonText()
            navigationView.showAlbumDetails()
            if let middleButton = navigationView.middleButton {
                for target in middleButton.allTargets {
                    middleButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                }
                middleButton.addTarget(self, action: #selector(MasterViewController.tappedNavigationMiddleButton(_:)), for: UIControlEvents.touchUpInside)
            }
            if isAlbumLoadedInPlayer() {
                navigationView.showRightButton()
            }
        }
    }
    
    func backToBrowserFromSettingsAction(_ sender:AnyObject) {
        
        if let browserNavigationController = browserNavigationController {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            browserNavigationController.view.layer.add(transition, forKey: kCATransition)
            browserNavigationController.popToRootViewController(animated: false)
        }
        if let navigationView = navigationView {
            // left
            navigationView.showLogoInLeftButtonAnimated(true)
            if let leftButton = navigationView.leftButton {
                leftButton.addTarget(self, action: #selector(MasterViewController.pushToSettingsAction(_:)), for: UIControlEvents.touchUpInside)
            }
            // middle
            if isAlbumLoadedInPlayer() {
                navigationView.hideMiddleButtonText()
                navigationView.showAlbumDetails()
                if let middleButton = navigationView.middleButton {
                    for target in middleButton.allTargets {
                        middleButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                    }
                    middleButton.addTarget(self, action: #selector(MasterViewController.tappedNavigationMiddleButton(_:)), for: UIControlEvents.touchUpInside)
                }
            }
            // right
            if let rightButton = navigationView.rightButton {
                for target in rightButton.allTargets {
                    rightButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                }
                if isAlbumLoadedInPlayer() {
                    if isPlaying() {
                        navigationViewShowPauseInRightButton()
                    } else {
                        navigationViewShowPlayInRightButton()
                    }
                } else {
                    navigationView.hideRightButton()
                }
            }
        }
    }
    
    func pushToSettingsAction(_ sender:AnyObject) {
        
        if settingsViewController == nil {
            settingsViewController = SettingsViewController()
        }
        if let browserNavigationController = browserNavigationController,
            let settingsViewController = settingsViewController {
                
                settingsViewController.session = session
                
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                browserNavigationController.view.layer.add(transition, forKey: kCATransition)
                browserNavigationController.pushViewController(settingsViewController, animated: false)
        }
        if let navigationView = navigationView {
            // left
            navigationView.hideLeftButton()
            // right
            if let rightButton = navigationView.rightButton {
                for target in rightButton.allTargets {
                    rightButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                }
                rightButton.addTarget(self, action: #selector(MasterViewController.backToBrowserFromSettingsAction(_:)), for: UIControlEvents.touchUpInside)
            }
            navigationView.showChevronInRightButton()
        }
    }
    
    func tappedNavigationMiddleButton(_ sender:AnyObject) {
        
        showPlayer()
    }
    
    func showPlayer() {
        
        let damping:CGFloat = 0.85
        if let player = player,
            let browserNavigationController = browserNavigationController,
            let navigationView = navigationView {
                if isShowingPlayer {
                    // hide player
                    // animate player view entering
                    view.layoutIfNeeded()
                    player.view.snp.remakeConstraints { (make) -> Void in
                        make.height.equalTo(UIScreen.main.bounds.size.height)
                        make.left.right.equalTo(view)
                        make.top.equalTo(view.snp.bottom).offset(-NavigationViewHeight)
                    }
                    browserNavigationController.view.snp.remakeConstraints { (make) -> Void in
                        make.edges.equalTo(view).inset(UIEdgeInsetsMake(0, 0, NavigationViewHeight, 0))
                    }
                    UIView.animate(withDuration: 0.5,
                        delay: 0.0,
                        usingSpringWithDamping: damping,
                        initialSpringVelocity: 0.0,
                        options: UIViewAnimationOptions(rawValue: 0),
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
                    player.view.snp.remakeConstraints { (make) -> Void in
                        make.height.equalTo(UIScreen.main.bounds.size.height)
                        make.left.right.equalTo(view)
                        make.top.equalTo(view.snp.bottom).offset(-NavigationViewHeight)
                    }
                    // animate player view entering
                    view.layoutIfNeeded()
                    player.view.snp.remakeConstraints { (make) -> Void in
                        make.edges.equalTo(view)
                    }
                    browserNavigationController.view.snp.remakeConstraints { (make) -> Void in
                        make.height.equalTo(UIScreen.main.bounds.size.height - NavigationViewHeight)
                        make.left.right.equalTo(view)
                        make.bottom.equalTo(player.view.snp.top)
                    }
                    UIView.animate(withDuration: 0.5,
                        delay: 0.0,
                        usingSpringWithDamping: damping,
                        initialSpringVelocity: 0.0,
                        options: UIViewAnimationOptions(rawValue: 0),
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
    
    func loadAlbum(_ album:SPTAlbum) {
        if let player = player {
            player.album = album
            player.stopPlayback({ () -> () in
                player.loadAlbum(album)
            })
        }
    }
    
    func playAlbum(_ startTrackIndex:Int32?) {
        if let player = player {
            player.playAlbum(startTrackIndex)
        }
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            return player.isPlaying
        }
        return false
    }
    
    func isAlbumLoadedInPlayer() -> Bool {
        if let player = player,
            let _ = player.album {
                return true
        }
        return false
    }
    
    func isAlbumLoadedIntoPlayer(_ album:SPTAlbum) -> Bool {
        if let player = player,
            let playerAlbum = player.album {
                return album.uri == playerAlbum.uri
        }
        return false
    }
    
    func pausePlayer(_ sender:AnyObject) {
        if let player = player {
            player.pause({ () -> () in
                self.navigationViewShowPlayInRightButton()
            })
        }
    }
    
    func resumePlayer(_ sender:AnyObject) {
        if let player = player {
            print("isPlaying: %@", isPlaying())
            if player.player!.trackListSize > 0 {
                player.resume({ () -> () in
                    if self.navigationView != nil {
                        self.navigationViewShowPauseInRightButton()
                    }
                })
            } else {
                let startTrackIndex = self.dataStore.currentAlbumTrackIndex
                player.playAlbum(startTrackIndex)
            }
        }
    }
    
    func playerDidChangeToTrack(_ title:String, artist:String) {
        // update navigation
        if let navigationView = self.navigationView {
            // middle
            let topLabelText = title
            let bottomLabelText = artist
            navigationView.populateAlbumDetails(topLabelText, bottomLabelText: bottomLabelText)
            navigationView.showAlbumDetails()
            if let middleButton = navigationView.middleButton {
                for target in middleButton.allTargets {
                    middleButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                }
                middleButton.addTarget(self, action: #selector(MasterViewController.tappedNavigationMiddleButton(_:)), for: UIControlEvents.touchUpInside)
            }
            navigationView.showMiddleButton() 
        }
    }
    
    func playerDidChangePlaybackStatus(_ isPlaying:Bool) {
        // update navigation
        if self.navigationView != nil {
            // right
            if isPlaying {
                navigationViewShowPauseInRightButton()
            } else {
                navigationViewShowPlayInRightButton()
            }
        }
    }
    
    func playerDidUpdateAlbumProgress(_ progress:Float) {
        // update navigation
        if let navigationView = self.navigationView {
            navigationView.updateProgressView(progress)
        }
    }
    
    // MARK: Navigation View
    
    func navigationViewShowPlayInRightButton() {
        
        if let navigationView = navigationView {
            navigationView.showPlayInRightButton()
            if let rightButton = navigationView.rightButton {
                for target in rightButton.allTargets {
                    rightButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                }
                rightButton.addTarget(self, action: #selector(MasterViewController.resumePlayer(_:)), for: UIControlEvents.touchUpInside)
            }
        }
    }
    
    func navigationViewShowPauseInRightButton() {
        
        if let navigationView = navigationView {
            navigationView.showPauseInRightButton()
            if let rightButton = navigationView.rightButton {
                for target in rightButton.allTargets {
                    rightButton.removeTarget(target, action: nil, for: UIControlEvents.touchUpInside)
                }
                rightButton.addTarget(self, action: #selector(MasterViewController.pausePlayer(_:)), for: UIControlEvents.touchUpInside)
            }
        }
    }
}

private typealias MasterViewController_LoadCurrentAlbum = MasterViewController
extension MasterViewController_LoadCurrentAlbum {
    
    func hasCurrentAlbumPlaying() -> Bool {
        
        if dataStore.currentAlbumURI != nil {
            return true
        }
        return false
    }
    
    func fetchAlbum(_ albumURI:URL, completed:((_ album:SPTAlbum)->())?) {
        
        if let session = session,
            let accessToken = session.accessToken {
            DispatchQueue.global().async(execute: { () -> Void in
                SPTAlbum.album(withURI: albumURI,
                               accessToken: accessToken,
                               market: nil,
                               callback: { (error: Error?, result:Any?) in
                                print(result!)
                                if let error = error {
                                    print("error: %@", error)
                                } else {
                                    let album = result as! SPTAlbum
                                    if let completed = completed {
                                        completed(album)
                                    }
                                }
                })
            })
        }
    }
}


