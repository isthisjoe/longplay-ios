//
//  AlbumListViewController.swift
//  
//
//  Created by Joe Nguyen on 30/05/2015.
//
//

import UIKit
import SnapKit

let AlbumListCellReuseIdentifier = "AlbumListCellReuseIdentifier"

class AlbumListViewController: UITableViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var session: SPTSession?
    var player: SPTAudioStreamingController?
    
    var data:Array<Dictionary<String,String>>?

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init!(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recommended Albums"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: AlbumListCellReuseIdentifier)
        self.setupData()
    }
    
    func setupData() {
        let spotifyURIs = [[
            "artist":"A$AP Rocky",
            "name":"AT.LONG.LAST.A$AP",
            "uri":"spotify:album:3arNdjotCvtiiLFfjKngMc"]]
        data = spotifyURIs
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        if let data = data {
            count = data.count
        }
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: AlbumListCellReuseIdentifier)
        if let data = data {
            let album = data[indexPath.row]
            cell.textLabel!.text = album["name"]
            cell.detailTextLabel!.text = album["artist"]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let data = data {
            let album = data[indexPath.row]
            let uri = album["uri"]
            self.playSpotifyURI(uri)
        }
    }
    
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
