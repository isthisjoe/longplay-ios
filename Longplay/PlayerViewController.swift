//
//  PlayerViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 10/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesome_swift

class PlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    var browserButton:UIButton?
    
    var session: SPTSession?
    var player: SPTAudioStreamingController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBrowserButton()
    }
    
    func setupBrowserButton() {
        browserButton = UIButton()
        browserButton!.titleLabel!.font = UIFont.fontAwesomeOfSize(30)
        browserButton!.setTitle(String.fontAwesomeIconWithName(.ThLarge), forState: .Normal)
        if let browserButton = browserButton {
            view.addSubview(browserButton)
            browserButton.snp_makeConstraints({ (make) -> Void in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.top.equalTo(20)
                make.left.equalTo(20)
            })
        }
    }
    
    func addTargetToBrowserButton(target:AnyObject, action:Selector) {
        if let browserButton = browserButton {
            browserButton.addTarget(target, action:action, forControlEvents:.TouchUpInside)
        }
    }
    
    // MARK: - Spotify 
    
    func playSpotifyURI(uri:String?) {
        player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        if let
            uri = uri,
            session = session,
            player = player,
            url = NSURL(string: uri) {
                player.delegate = self
                player.playbackDelegate = self
                
                SPTAlbum.albumWithURI(url,
                    accessToken: session.accessToken,
                    market: nil,
                    callback: { (error:NSError!, result:AnyObject!) -> Void in
                        
                        if let album:SPTAlbum = result as? SPTAlbum {
                            
                            var trackURIs = [NSURL]()
                            if let listPage:SPTListPage = album.firstTrackPage,
                                let items = listPage.items as? [SPTPartialTrack] {
                                    NSLog("items: %@", items)
                                    for item:SPTPartialTrack in items {
                                        trackURIs.append(item.playableUri)
                                    }
                            }
                            
                            player.loginWithSession(session,
                                callback: { (error:NSError!) -> Void in
                                    if error != nil {
                                        NSLog("error: %@", error)
                                    }
                                    NSLog("trackURIs: %@", trackURIs)
                                    player.playURIs(trackURIs, withOptions: nil,
                                        callback: { (error:NSError!) -> Void in
                                            if error != nil {
                                                NSLog("error: %@", error)
                                            }
                                    })
                            })
                        }
                })
                
        }
    }
    
    // MARK: - SPTAudioStreamingDelegate
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidLogin")
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidEncounterTemporaryConnectionError")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        NSLog("didEncounterError")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        NSLog("didReceiveMessage: %@", message)
    }
    
    func audioStreamingDidDisconnect(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidDisconnect")
    }
    
    
    // MARK: - SPTAudioStreamingPlaybackDelegate
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        NSLog("didChangePlaybackStatus: %@", isPlaying)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        NSLog("didStartPlayingTrack: %@", trackUri)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        NSLog("didFailToPlayTrack: %@", trackUri)
    }
}
