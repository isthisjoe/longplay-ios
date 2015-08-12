//
//  PlayerViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 10/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesomeKit
import MediaPlayer

class PlayerViewController: UIViewController {

    var session: SPTSession?
    var album:SPTAlbum? {
        didSet {
            albumPlayback = AlbumPlayback(album: self.album!)
        }
    }
    var albumPlayback:AlbumPlayback? {
        didSet {
            self.didSetAlbumPlayback()
        }
    }
    var player: SPTAudioStreamingController?
    
    let albumTrackListingView = UIView()
    var albumTrackListingViewTopOffset:CGFloat = 0
    let trackListingViewController = TrackListViewController()
    let progressView = UIProgressView()
    let controlView = UIView()
    let browserButton = UIButton()
    let playButton = UIButton()
    var isPlaying:Bool = false
    
    let dataStore = DataStore()

    // MARK: Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.handleRemoteControlEvents()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.whiteColor()
        
        albumTrackListingView.backgroundColor = UIColor.whiteColor()
        view.addSubview(albumTrackListingView)
        albumTrackListingView.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(view)
        }
        
        let progressViewHeight:CGFloat = 10.0
        progressView.trackTintColor = UIColor.primaryLightColor()
        progressView.progressTintColor = UIColor.primaryColor()
        view.addSubview(progressView)
        progressView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(albumTrackListingView.snp_bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(progressViewHeight)
        }
        
        let controlViewHeight = 72.0
        controlView.backgroundColor = UIColor.whiteColor()
        view.addSubview(controlView)
        controlView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(progressView.snp_bottom)
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(controlViewHeight)
        }
        
        let browserIcon = FAKIonIcons.naviconRoundIconWithSize(28)
        browserIcon.setAttributes([NSForegroundColorAttributeName: UIColor.lpBlackColor()])
        browserButton.setAttributedTitle(browserIcon.attributedString(), forState: .Normal)
        controlView.addSubview(browserButton)
        browserButton.snp_makeConstraints({ (make) -> Void in
            make.left.equalTo(controlView).offset(29)
            make.bottom.equalTo(controlView).offset(-19)
            make.width.height.equalTo(32)
        })
        
        let playButtonSize:CGFloat = 52
        updatePlayButtonToPause()
        playButton.addTarget(self, action: "playAction:", forControlEvents:.TouchUpInside)
        controlView.addSubview(playButton)
        playButton.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(controlView.snp_center)
            make.width.height.equalTo(playButtonSize)
        }
    }
    
    func updatePlayButtonToPause() {
        let playButtonSize:CGFloat = 48
        let icon = FAKIonIcons.pauseIconWithSize(playButtonSize)
        icon.setAttributes([NSForegroundColorAttributeName:UIColor.lpBlackColor()])
        playButton.setImage(
            icon.imageWithSize(CGSizeMake(playButtonSize, playButtonSize)),
            forState:.Normal)
    }
    
    func updatePlayButtonToPlay() {
        let playButtonSize:CGFloat = 48
        let icon = FAKIonIcons.playIconWithSize(playButtonSize)
        icon.setAttributes([NSForegroundColorAttributeName:UIColor.lpBlackColor()])
        playButton.setImage(
            icon.imageWithSize(CGSizeMake(playButtonSize, playButtonSize)),
            forState:.Normal)
    }
    
    func addTargetToBrowserButton(target:AnyObject, action:Selector) {
        browserButton.addTarget(target, action:action, forControlEvents:.TouchUpInside)
    }
    
    func finishedViewTransition() {
        if let album = album {
            playAlbum(album, didStartPlaying: nil)
        }
    }
    
    // MARK: Actions
    
    func playAction(sender:AnyObject) {
        NSLog("playAction")
        if isPlaying {
            updatePlayButtonToPlay()
        } else {
            updatePlayButtonToPause()
        }
        isPlaying = !isPlaying
        if let player = player {
            player.setIsPlaying(isPlaying, callback: { (error:NSError!) -> Void in
                if error != nil {
                    NSLog("playAction error: %@", error)
                }
            })
        }
    }
    
    // MARK: Spotify
    
    func playAlbum(album:SPTAlbum, didStartPlaying:((firstTrackName:String)->())?) {
        
        if let player = player {
            if player.isPlaying {
                return
            }
        }
        
        dataStore.currentAlbumURI = album.uri
        
        setupTrackListing(album)
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
            player!.delegate = self
            player!.playbackDelegate = self
        }
        if let
            session = session,
            player = player {
                var firstTrackName:String?
                var trackURIs = [NSURL]()
                if let listPage:SPTListPage = album.firstTrackPage,
                    let items = listPage.items as? [SPTPartialTrack] {
                        if let firstTrack = items.first {
                            firstTrackName = firstTrack.name
                        }
                        for item:SPTPartialTrack in items {
                            trackURIs.append(item.playableUri)
                        }
                }
                
                playTracks(player, session: session, trackURIs: trackURIs)
                
                if let albumPlayback = albumPlayback {
                    albumPlayback.observeAudioStreamingController(player)
                    albumPlayback.progressCallback = {
                        (progress:Float) in
//                        NSLog("%f", progress)
                        self.progressView.setProgress(progress, animated: true)
                    }
                }
                
                isPlaying = true
                
                self.updatePlayButtonToPause()
                
                if let didStartPlaying = didStartPlaying,
                    firstTrackName = firstTrackName {
                        didStartPlaying(firstTrackName:firstTrackName)
                }
        } else {
            if session == nil {
                NSLog("session is nil")
            }
            if player == nil {
                NSLog("player is nil")
            }
        }
    }
    
    func playTracks(player:SPTAudioStreamingController, session:SPTSession, trackURIs:Array<NSURL>) {

        let playTrackURIs = { (trackURIs:Array<NSURL>) -> () in
            player.playURIs(trackURIs, withOptions: nil,
                callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("error: %@", error)
                    }
            })
        }
        NSLog("trackURIs: %@", trackURIs)
        if player.loggedIn {
            playTrackURIs(trackURIs)
        } else {
            player.loginWithSession(session,
                callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("error: %@", error)
                    }
                    playTrackURIs(trackURIs)
            })
        }
    }
    
    // MARK: Album Playback
    
    func didSetAlbumPlayback() {
  
    }
    
    func stopPlayback(callback:(()->())) {
        if let player = player {
            if player.isPlaying {
                player.stop({ (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("error: %@", error)
                    }
                    callback()
                })
            } else {
                callback()
            }
        } else {
            callback()
        }
    }
    
    func play(completedBlock:(()->())?) {
        if let player = player {
            if !player.isPlaying {
                player.setIsPlaying(true, callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("play error: %@", error)
                    }
                    self.updatePlayButtonToPause()
                    if let completedBlock = completedBlock {
                        completedBlock()
                    }                    
                })
            }
        }
    }
    
    func pause(completedBlock:(()->())?) {
        if let player = player {
            if player.isPlaying {
                player.setIsPlaying(false, callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("pause error: %@", error)
                    }
                    self.updatePlayButtonToPlay()
                    if let completedBlock = completedBlock {
                        completedBlock()
                    }
                })
            }
        }
    }
    
    func togglePlayPause() {
        if let player = player {
            let isPlaying = !player.isPlaying
            player.setIsPlaying(isPlaying, callback: { (error:NSError!) -> Void in
                if error != nil {
                    NSLog("togglePlayPause error: %@", error)
                }
                if isPlaying {
                    self.updatePlayButtonToPause()
                } else {
                    self.updatePlayButtonToPlay()
                }
            })
        }
    }
    
    // MARK: Remote control events
    
    func handleRemoteControlEvents() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTargetWithHandler {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.play(nil)
            return .Success
        }
        commandCenter.pauseCommand.addTargetWithHandler {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.pause(nil)
            return .Success
        }
        commandCenter.togglePlayPauseCommand.addTargetWithHandler {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.togglePlayPause()
            return .Success
        }
    }
    
    // MARK: Now Playing Info Center
    
    func configureNowPlayingInfo(title:String, artist:String, playbackRate:Int) {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate
        ]
    }
    
    // MARK: Highlight track playing
    
    func highlightTrackIndex(index:Int) {
        
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        var reloadIndexPaths = [indexPath]
        if let oldIndexPath = trackListingViewController.highlightedIndexPath {
            reloadIndexPaths.append(oldIndexPath)
        }
        NSLog("indexPath: %@", indexPath)
        trackListingViewController.highlightedIndexPath = indexPath
        if let collectionView = trackListingViewController.collectionView {
            NSLog("reloadIndexPaths: %@", reloadIndexPaths)
            collectionView.reloadItemsAtIndexPaths(reloadIndexPaths)
        }
    }
    
    // MARK: Did play track
    
    func didPlayTrack(trackURI:NSURL) {
        
        dataStore.currentAlbumTrackURI = trackURI
    }
}

// MARK: -

private typealias PlayerTrackListing = PlayerViewController
extension PlayerTrackListing: UICollectionViewDelegate {
    
    func setupTrackListing(album:SPTAlbum) {
        
        trackListingViewController.album = album
        trackListingViewController.willMoveToParentViewController(self)
        addChildViewController(trackListingViewController)
        trackListingViewController.didMoveToParentViewController(trackListingViewController)
        albumTrackListingView.addSubview(trackListingViewController.view)
        trackListingViewController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(albumTrackListingView)
        }
    }
}

// MARK: -
private typealias PlayerAudioStreamingDelegate = PlayerViewController
extension PlayerAudioStreamingDelegate: SPTAudioStreamingDelegate {
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidLogin")
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidEncounterTemporaryConnectionError")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        NSLog("didEncounterError: %@", error)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        NSLog("didReceiveMessage: %@", message)
    }
    
    func audioStreamingDidDisconnect(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidDisconnect")
    }
}


// MARK: -
private typealias PlayerAudioStreamingPlaybackDelegate = PlayerViewController
extension PlayerAudioStreamingPlaybackDelegate: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        NSLog("didChangePlaybackStatus: %@", isPlaying)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didSeekToOffset offset: NSTimeInterval) {
        NSLog("didSeekToOffset: %f", offset)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if trackMetadata != nil {
            NSLog("didChangeToTrack: %@", trackMetadata)
            if let
                title = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String,
                artist = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String {
                    configureNowPlayingInfo(title, artist: artist, playbackRate: 1)
            }
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        NSLog("didFailToPlayTrack: %@", trackUri)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        NSLog("didStartPlayingTrack: %@", trackUri)
        if let player = player {
            highlightTrackIndex(Int(player.currentTrackIndex))
            didPlayTrack(player.currentTrackURI)
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        NSLog("didStopPlayingTrack: %@", trackUri)
    }
    
    func audioStreamingDidSkipToNextTrack(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidSkipToNextTrack")
    }
    
    func audioStreamingDidBecomeActivePlaybackDevice(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidBecomeActivePlaybackDevice")
    }
    
    func audioStreamingDidLosePermissionForPlayback(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidLosePermissionForPlayback")
    }
    
    func audioStreamingDidPopQueue(audioStreaming: SPTAudioStreamingController!) {
        NSLog("audioStreamingDidPopQueue")
    }
}
