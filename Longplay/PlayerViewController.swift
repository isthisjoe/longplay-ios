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
import MediaPlayer

class PlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    var browserButton:UIButton?
    
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
    
    let coverArtImageView = UIImageView()
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    let albumTrackListingView = UIView()
    let trackListingViewController = TrackListViewController()
    let progressView = UIProgressView()
    let controlView = UIView()
    let playButton = UIButton()
    var isPlaying:Bool = false

    // MARK: Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupBrowserButton()
        self.handleRemoteControlEvents()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(coverArtImageView)
        coverArtImageView.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(0)
            make.height.equalTo(view.bounds.size.width)
        }
        
        let labelSpacing = 8
        let labelHeight = 30
        nameLabel.font = UIFont.systemFontOfSize(16)
        view.addSubview(nameLabel)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(coverArtImageView.snp_bottom).offset(labelSpacing)
            make.left.right.equalTo(coverArtImageView)
            make.height.equalTo(labelHeight)
        }
        
        artistLabel.font = UIFont.systemFontOfSize(16)
        view.addSubview(artistLabel)
        artistLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp_bottom)
            make.left.right.equalTo(nameLabel)
            make.height.equalTo(labelHeight)
        }
        
        albumTrackListingView.backgroundColor = UIColor.grayColor()
        view.addSubview(albumTrackListingView)
        albumTrackListingView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(artistLabel.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        let progressViewHeight:CGFloat = 10.0
        progressView.trackTintColor = UIColor.blueColor()
        progressView.progressTintColor = UIColor.greenColor()
        view.addSubview(progressView)
        progressView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(albumTrackListingView.snp_bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(progressViewHeight)
        }
        
        let controlViewHeight = 60.0
        controlView.backgroundColor = UIColor.darkGrayColor()
        view.addSubview(controlView)
        controlView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(progressView.snp_bottom)
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(controlViewHeight)
        }
        
        let playButtonSize:CGFloat = 50.0
        updatePlayButtonToPause()
        playButton.addTarget(self, action: "playAction:", forControlEvents:.TouchUpInside)
        controlView.addSubview(playButton)
        playButton.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(controlView.snp_center)
            make.width.height.equalTo(playButtonSize)
        }
    }
    
    func updatePlayButtonToPause() {
        let playButtonSize:CGFloat = 50.0
        playButton.setImage(
            UIImage.fontAwesomeIconWithName(.Pause,
                textColor: UIColor.whiteColor(),
                size: CGSizeMake(playButtonSize, playButtonSize)),
            forState:.Normal)
    }
    
    func updatePlayButtonToPlay() {
        let playButtonSize:CGFloat = 50.0
        playButton.setImage(
            UIImage.fontAwesomeIconWithName(.Play,
                textColor: UIColor.whiteColor(),
                size: CGSizeMake(playButtonSize, playButtonSize)),
            forState:.Normal)
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
    
    func finishedViewTransition() {
        if album != nil {
            playAlbum(album!)
        }
    }
    
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
    
    // MARK: - Spotify
    
    func playAlbum(album:SPTAlbum) {
        
        if let player = player {
            if player.isPlaying {
                return
            }
        }
        
        populateAlbumData(album)
        
        setupTrackListing(album)
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
            player!.delegate = self
            player!.playbackDelegate = self
        }
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
    
    func populateAlbumData(album:SPTAlbum) {
        
        if let albumURL = album.largestCover.imageURL {
            self.coverArtImageView.sd_setImageWithURL(albumURL)
        }
        
        self.nameLabel.text = album.name
        
        let artists = album.artists
        if artists.count > 0 {
            let artist = artists[0] as! SPTPartialArtist
            artistLabel.text = artist.name
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
        NSLog("didEncounterError: %@", error)
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
            }
        } else {
            callback()
        }
    }
    
    func play() {
        if let player = player {
            if !player.isPlaying {
                player.setIsPlaying(true, callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("play error: %@", error)
                    }
                    self.updatePlayButtonToPause()
                })
            }
        }
    }
    
    func pause() {
        if let player = player {
            if player.isPlaying {
                player.setIsPlaying(false, callback: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("pause error: %@", error)
                    }
                    self.updatePlayButtonToPlay()
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
            self.play()
            return .Success
        }
        commandCenter.pauseCommand.addTargetWithHandler {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.pause()
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
}
