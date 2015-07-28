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
    
    // MARK: Views
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // browser
        albumListViewController = AlbumListViewController()
        if let albumListViewController = albumListViewController {
            albumListViewController.title = "Longplay"
            albumListViewController.session = session
            albumListViewController.playAlbumBlock = { (album:SPTAlbum) -> () in
                if let player = self.player {
                    player.album = album
                    player.stopPlayback({ () -> () in
                        //                    self.playerAction(nil)
                    })
                }
            }
            albumListViewController.didSelectAlbumBlock = { (album:SPTAlbum) -> () in
                self.didSelectAlbumForViewing(album)
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
        }
        
        // navigation view
        navigationView = NavigationView()
        if let navigationView = navigationView,
            player = player {
                player.view.addSubview(navigationView)
                navigationView.snp_makeConstraints({ (make) -> Void in
                    make.height.equalTo(NavigationViewHeight)
                    make.top.left.right.equalTo(player.view)
                })
                if let middleButton = navigationView.middleButton {
                    navigationView.middleButton?.addTarget(self, action: "tappedNavigationMiddleButton:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                if let leftButton = navigationView.leftButton {
                    leftButton.addTarget(self, action: "pushToSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
                }
        }
    }
    
    // MARK: Actions
    
    func didSelectAlbumForViewing(album:SPTAlbum) {
        
        if let browserNavigationController = browserNavigationController {
            let albumViewController = AlbumViewController(album: album)
            albumViewController.playAlbumBlock = { (album:SPTAlbum) -> () in
                self.playAlbum(album)
            }
            browserNavigationController.pushViewController(albumViewController, animated: true)
            // update navigation
            if let navigationView = navigationView {
                navigationView.showChevronInLeftButton()
                if let leftButton = navigationView.leftButton {
                    leftButton.addTarget(self, action: "backToBrowserAction:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
        }
    }
    
    func backToBrowserAction(sender:AnyObject) {
        
        if let browserNavigationController = browserNavigationController {
            browserNavigationController.popToRootViewControllerAnimated(true)
        }
        if let navigationView = navigationView {
            navigationView.showLogoInLeftButton()
            if let leftButton = navigationView.leftButton {
                leftButton.addTarget(self, action: "pushToSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            navigationView.hideRightButton()
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
            navigationView.showLogoInLeftButton()
            if let leftButton = navigationView.leftButton {
                leftButton.addTarget(self, action: "pushToSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            navigationView.hideRightButton()
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
            navigationView.showChevronInRightButton()
            navigationView.hideLeftButton()
            if let rightButton = navigationView.rightButton {
                rightButton.addTarget(self, action: "backToBrowserFromSettingsAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
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
                        },
                        completion: nil)
                    isShowingPlayer = true
                }
        }
    }
    
    // MARK: Player
    
    func playAlbum(album:SPTAlbum) {
        if let player = self.player {
            player.album = album
            player.stopPlayback({ () -> () in
                player.playAlbum(album, didStartPlaying: { (firstTrackName) -> () in
                    if let navigationView = self.navigationView {
                        let topLabelText = "1. " + firstTrackName
                        let bottomLabelText = album.name + " - " + album.artists.first!.name
                        navigationView.showAlbumDetails(topLabelText, bottomLabelText: bottomLabelText)
                    }
                })
            })
        }
    }
}
