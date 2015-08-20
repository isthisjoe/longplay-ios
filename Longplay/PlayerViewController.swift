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
    var albumPlayback:AlbumPlayback?
    var player: SPTAudioStreamingController?
    
    let albumTrackListingView = UIView()
    var albumTrackListingViewTopOffset:CGFloat = 0
    let trackListingViewController = TrackListViewController()
    let progressView = AlbumProgressView()
    let controlView = UIView()
    let browserButton = UIButton()
    let playButton = UIButton()
    var isPlaying:Bool = false
    let dataStore = DataStore()
    var currentTrackIndex:Int32 = 0
    
    typealias DidChangeToTrackBlock = ((playerViewController:PlayerViewController, title:String, artist:String)->())
    var didChangeToTrackBlock:DidChangeToTrackBlock?
    
    typealias DidChangePlaybackStatusBlock = ((playerViewController:PlayerViewController, isPlaying:Bool)->())
    var didChangePlaybackStatusBlock:DidChangePlaybackStatusBlock?
    
    typealias DidUpdateAlbumProgressBlock = ((playerViewController:PlayerViewController, progress:Float)->())
    var didUpdateAlbumProgressBlock:DidUpdateAlbumProgressBlock?

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
        browserButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(controlView).offset(4)
            make.bottom.equalTo(controlView).offset(0)
            make.width.height.equalTo(controlViewHeight)
        }
        
        let playButtonSize:CGFloat = 52
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
    
    // MARK: Actions
    
    func playAction(sender:AnyObject) {
        NSLog("playAction")
        isPlaying = !isPlaying
        if let player = player {
            if player.trackListSize > 0 {
                player.setIsPlaying(isPlaying, callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("playAction error: %@", error)
                    }
                })
            } else {
                playAlbum(currentTrackIndex)
            }
        }
    }
    
    // MARK: Spotify
    
//    func loadAlbum(album:SPTAlbum, startTrackIndex:Int32?, didStartPlaying:((displayTrackName:String)->())?) {
    func loadAlbum(album:SPTAlbum) {
        
        if let player = player {
            if player.isPlaying {
                return
            }
        }
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
            player!.delegate = self
            player!.playbackDelegate = self
        }
        
        dataStore.currentAlbumURI = album.uri
        
        setupTrackListing(album)
        
        updatePlayButtonToPlay()
        
        updateProgress(0, animated: false)
    }
    
    func playAlbum(startTrackIndex:Int32?) {
        
        if let album = album {
            playAlbum(album, startTrackIndex: startTrackIndex)
        }
    }
    
    func playAlbum(album:SPTAlbum, startTrackIndex:Int32?) {
    
        if let
            session = session,
            player = player {
                var trackURIs = [NSURL]()
                if let listPage:SPTListPage = album.firstTrackPage,
                    let items = listPage.items as? [SPTPartialTrack] {
                        for item:SPTPartialTrack in items {
                            trackURIs.append(item.playableUri)
                        }
                }

                self.loginSession(player, session: session, completed: { () -> () in
                    self.playTrackURIs(player,
                        trackURIs:trackURIs,
                        trackIndex:startTrackIndex)
                    if let startTrackIndex = startTrackIndex {
                        self.trackListingViewController.highlightedIndexPath = NSIndexPath(forRow: Int(startTrackIndex), inSection: 0)
                    }
                })
                
                observeProgressOnAlbumPlayback(player)
        } else {
            if session == nil {
                NSLog("session is nil")
            }
            if player == nil {
                NSLog("player is nil")
            }
        }
    }
    
    func loginSession(player: SPTAudioStreamingController,
        session:SPTSession,
        completed:(()->())) {
            
        if player.loggedIn {
            completed()
        } else {
            player.loginWithSession(session,
                callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("error: %@", error)
                    }
                    completed()
            })
        }
    }
    
    func playTrackURIs(player:SPTAudioStreamingController,
        trackURIs:Array<NSURL>,
        trackIndex:Int32?) {
        
//        NSLog("trackURIs: %@", trackURIs)
        let playOptions = SPTPlayOptions()
        if let trackIndex = trackIndex {
            playOptions.trackIndex = trackIndex
        }
        player.playURIs(trackURIs,
            withOptions: playOptions,
            callback: { (error:NSError!) -> Void in
                if error != nil {
                    NSLog("playURIs error: %@", error)
                }
        })
    }
    
    // MARK: Album Playback
    
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
    
    func resume(completedBlock:(()->())?) {
        if let player = player {
            if !player.isPlaying {
                player.setIsPlaying(true, callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("play error: %@", error)
                    }
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
            })
        }
    }
    
    // MARK: Album playback progress
    
    func observeProgressOnAlbumPlayback(player:SPTAudioStreamingController) {
        
        if let albumPlayback = albumPlayback {
            albumPlayback.observeAudioStreamingController(player)
            albumPlayback.progressCallback = {
                (progress:Float) in
                //                NSLog("%f", progress)
                self.updateProgress(progress, animated:true)
                if let didUpdateAlbumProgressBlock = self.didUpdateAlbumProgressBlock {
                    didUpdateAlbumProgressBlock(playerViewController: self, progress: progress)
                }
            }
        }
    }
    
    func updateProgress(progress:Float, animated:Bool) {
        
        progressView.setProgress(progress, animated: animated)
    }
    
    func setAlbumPlaybackProgress(progress:Float, animated:Bool) {
        
        if let albumPlayback = albumPlayback {
            albumPlayback.currentAlbumPlaybackPosition = NSTimeInterval(progress) * albumPlayback.totalDuration
            updateProgress(albumPlayback.progress, animated: false)
        }
    }
    
    // MARK: Remote control events
    
    func handleRemoteControlEvents() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTargetWithHandler {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.resume(nil)
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
    
    // MARK: Did play track
    
    func didPlayTrack(trackIndex:Int32) {
        
        highlightTrackIndex(trackIndex)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.dataStore.currentAlbumTrackIndex = trackIndex
            self.dataStore.currentAlbumPlaybackProgress = self.progressView.progress
        })
    }
    
    // MARK: Highlight track playing
    
    func highlightTrackIndex(index:Int32) {
        
        let indexPath = NSIndexPath(forRow: Int(index), inSection: 0)
        var reloadIndexPaths = [indexPath]
        if let oldIndexPath = trackListingViewController.highlightedIndexPath {
            if oldIndexPath != indexPath {
                reloadIndexPaths.append(oldIndexPath)
            }
        }
        trackListingViewController.highlightedIndexPath = indexPath
        if let collectionView = trackListingViewController.collectionView {
//            NSLog("reloadIndexPaths: %@", reloadIndexPaths)
            collectionView.reloadItemsAtIndexPaths(reloadIndexPaths)
        }
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
        self.isPlaying = isPlaying
        if isPlaying {
            updatePlayButtonToPause()
        } else {
            updatePlayButtonToPlay()
        }
        if let didChangePlaybackStatusBlock = didChangePlaybackStatusBlock {
            didChangePlaybackStatusBlock(playerViewController: self, isPlaying: isPlaying)
        }
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
                    if let didChangeToTrackBlock = didChangeToTrackBlock {
                        didChangeToTrackBlock(playerViewController:self, title: title, artist: artist)
                    }
            }
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        NSLog("didFailToPlayTrack: %@", trackUri)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        NSLog("didStartPlayingTrack: %@", trackUri)
        if let player = player {
            didPlayTrack(player.currentTrackIndex)
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
