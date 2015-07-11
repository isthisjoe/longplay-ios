//
//  MasterViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 10/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import FontAwesome_swift

class MasterViewController: UIViewController {
    
    var session: SPTSession?
    var browser:BrowserNavigationController?
    var albumListViewController:AlbumListViewController?
    var player:PlayerViewController?
    
    // MARK: Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumListViewController = AlbumListViewController()
        albumListViewController!.title = "Longplay"
        albumListViewController!.session = session
        albumListViewController!.playAlbumBlock = { (album:SPTAlbum) -> () in
            if let player = self.player {
                player.album = album
            }
            self.playerAction(nil)
        }
        browser = BrowserNavigationController(rootViewController: albumListViewController!)

        player = PlayerViewController()
        player!.session = session
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let
            browser = browser,
            player = player {
                browser.willMoveToParentViewController(self)
                addChildViewController(browser)
                view.addSubview(browser.view)
                browser.didMoveToParentViewController(self)
                
                albumListViewController!.navigationItem.rightBarButtonItem =
                    UIBarButtonItem(
                        image: UIImage.fontAwesomeIconWithName(FontAwesome.DotCircleO,
                            textColor: UIColor.blackColor(),
                            size: CGSizeMake(30, 30)),
                        style: UIBarButtonItemStyle.Done,
                        target: self,
                        action: "playerAction:")
                
                player.willMoveToParentViewController(self)
                addChildViewController(player)
                var playerFrame = player.view.frame
                playerFrame.origin.x = view.frame.size.width
                player.view.frame = playerFrame
                view.addSubview(player.view)
                player.didMoveToParentViewController(self)
                
                player.addTargetToBrowserButton(self, action: "browserAction:")
        }
    }
    
    // MARK: Actions
    
    func playerAction(sender:AnyObject?) {
        if let
            browser = browser,
            player = player {
                var browserFrame = browser.view.frame
                browserFrame.origin.x = -view.frame.size.width
                var playerFrame = player.view.frame
                playerFrame.origin.x = 0.0
                UIView.animateWithDuration(0.3,
                    animations: { () -> Void in
                        browser.view.frame = browserFrame
                        player.view.frame = playerFrame
                    },
                    completion: { (finished) -> Void in
                        if finished {
                            player.finishedViewTransition()
                        }
                })
        }
    }
    
    func browserAction(sender:AnyObject?) {
        if let
            browser = browser,
            player = player {
                var browserFrame = browser.view.frame
                browserFrame.origin.x = 0
                var playerFrame = player.view.frame
                playerFrame.origin.x = view.frame.size.width
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    browser.view.frame = browserFrame
                    player.view.frame = playerFrame
                })
        }
    }
}
