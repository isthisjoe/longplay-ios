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
    
    typealias DidChangeToTrackBlock = ((_ playerViewController:PlayerViewController, _ title:String, _ artist:String)->())
    var didChangeToTrackBlock:DidChangeToTrackBlock?
    
    typealias DidChangePlaybackStatusBlock = ((_ playerViewController:PlayerViewController, _ isPlaying:Bool)->())
    var didChangePlaybackStatusBlock:DidChangePlaybackStatusBlock?
    
    typealias DidUpdateAlbumProgressBlock = ((_ playerViewController:PlayerViewController, _ progress:Float)->())
    var didUpdateAlbumProgressBlock:DidUpdateAlbumProgressBlock?

    // MARK: Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.handleRemoteControlEvents()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.white
        
        albumTrackListingView.backgroundColor = UIColor.white
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
        controlView.backgroundColor = UIColor.white
        view.addSubview(controlView)
        controlView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(progressView.snp_bottom)
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(controlViewHeight)
        }
        
        let browserIcon = FAKIonIcons.naviconRoundIcon(withSize: 28)
        browserIcon?.setAttributes([NSForegroundColorAttributeName: UIColor.lpBlackColor()])
        browserButton.setAttributedTitle(browserIcon?.attributedString(), for: UIControlState())
        controlView.addSubview(browserButton)
        browserButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(controlView).offset(4)
            make.bottom.equalTo(controlView).offset(0)
            make.width.height.equalTo(controlViewHeight)
        }
        
        let playButtonSize:CGFloat = 52
        playButton.addTarget(self, action: #selector(PlayerViewController.playAction(_:)), for:.touchUpInside)
        controlView.addSubview(playButton)
        playButton.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(controlView.snp_center)
            make.width.height.equalTo(playButtonSize)
        }
    }
    
    func updatePlayButtonToPause() {
        let playButtonSize:CGFloat = 48
        let icon = FAKIonIcons.pauseIcon(withSize: playButtonSize)
        icon?.setAttributes([NSForegroundColorAttributeName:UIColor.lpBlackColor()])
        playButton.setImage(
            icon?.image(with: CGSize(width: playButtonSize, height: playButtonSize)),
            for:UIControlState())
    }
    
    func updatePlayButtonToPlay() {
        let playButtonSize:CGFloat = 48
        let icon = FAKIonIcons.playIcon(withSize: playButtonSize)
        icon?.setAttributes([NSForegroundColorAttributeName:UIColor.lpBlackColor()])
        playButton.setImage(
            icon?.image(with: CGSize(width: playButtonSize, height: playButtonSize)),
            for:UIControlState())
    }
    
    func addTargetToBrowserButton(_ target:AnyObject, action:Selector) {
        browserButton.addTarget(target, action:action, for:.touchUpInside)
    }
    
    // MARK: Actions
    
    func playAction(_ sender:AnyObject) {
        print("playAction")
        isPlaying = !isPlaying
        if let player = player {
            if player.trackListSize > 0 {6
                player.setIsPlaying(isPlaying, callback: { (error:Error?) -> Void in
                    if error != nil {
                        print("playAction error: %@", error)
                    }
                })
            } else {
                playAlbum(currentTrackIndex)
            }
        }
    }
    
    // MARK: Spotify
    
//    func loadAlbum(album:SPTAlbum, startTrackIndex:Int32?, didStartPlaying:((displayTrackName:String)->())?) {
    func loadAlbum(_ album:SPTAlbum) {
        
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
    
    func playAlbum(_ startTrackIndex:Int32?) {
        
        if let album = album {
            playAlbum(album, startTrackIndex: startTrackIndex)
        }
    }
    
    func playAlbum(_ album:SPTAlbum, startTrackIndex:Int32?) {
    
        if let
            session = session,
            let player = player {
                var trackURIs = [URL]()
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
                        self.trackListingViewController.highlightedIndexPath = IndexPath(row: Int(startTrackIndex), section: 0)
                    }
                })
                
                observeProgressOnAlbumPlayback(player)
        } else {
            if session == nil {
                print("session is nil")
            }
            if player == nil {
                print("player is nil")
            }
        }
    }
    
    func loginSession(_ player: SPTAudioStreamingController,
        session:SPTSession,
        completed:@escaping (()->())) {
            
        if player.loggedIn {
            completed()
        } else {
            player.login(with: session,
                callback: { (error:Error?) -> Void in
                    if error != nil {
                        print("error: %@", error)
                    }
                    completed()
            })
        }
    }
    
    func playTrackURIs(_ player:SPTAudioStreamingController,
        trackURIs:Array<URL>,
        trackIndex:Int32?) {
        
//        print("trackURIs: %@", trackURIs)
        let playOptions = SPTPlayOptions()
        if let trackIndex = trackIndex {
            playOptions.trackIndex = trackIndex
        }
        player.playURIs(trackURIs,
            with: playOptions,
            callback: { (error:Error?) -> Void in
                if error != nil {
                    print("playURIs error: %@", error)
                }
        })
    }
    
    // MARK: Album Playback
    
    func stopPlayback(_ callback:@escaping (()->())) {
        if let player = player {
            if player.isPlaying {
                player.stop({ (error:Error?) -> Void in
                    if error != nil {
                        print("error: %@", error)
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
    
    func resume(_ completedBlock:(()->())?) {
        if let player = player {
            if !player.isPlaying {
                player.setIsPlaying(true, callback: { (error:Error?) -> Void in
                    if error != nil {
                        print("play error: %@", error)
                    }
                    if let completedBlock = completedBlock {
                        completedBlock()
                    }                    
                })
            }
        }
    }
    
    func pause(_ completedBlock:(()->())?) {
        if let player = player {
            if player.isPlaying {
                player.setIsPlaying(false, callback: { (error:Error?) -> Void in
                    if error != nil {
                        print("pause error: %@", error)
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
            player.setIsPlaying(isPlaying, callback: { (error:Error?) -> Void in
                if error != nil {
                    print("togglePlayPause error: %@", error)
                }
            })
        }
    }
    
    // MARK: Album playback progress
    
    func observeProgressOnAlbumPlayback(_ player:SPTAudioStreamingController) {
        
        if let albumPlayback = albumPlayback {
            albumPlayback.observeAudioStreamingController(player)
            albumPlayback.progressCallback = {
                (progress:Float) in
                //                print("%f", progress)
                self.updateProgress(progress, animated:true)
                if let didUpdateAlbumProgressBlock = self.didUpdateAlbumProgressBlock {
                    didUpdateAlbumProgressBlock(self, progress)
                }
            }
        }
    }
    
    func updateProgress(_ progress:Float, animated:Bool) {
        
        progressView.setProgress(progress, animated: animated)
    }
    
    func setAlbumPlaybackProgress(_ progress:Float, animated:Bool) {
        
        if let albumPlayback = albumPlayback {
            albumPlayback.currentAlbumPlaybackPosition = TimeInterval(progress) * albumPlayback.totalDuration
            updateProgress(albumPlayback.progress, animated: false)
        }
    }
    
    // MARK: Remote control events
    
    func handleRemoteControlEvents() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget (handler: {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.resume(nil)
            return .success
        })
        commandCenter.pauseCommand.addTarget (handler: {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.pause(nil)
            return .success
        })
        commandCenter.togglePlayPauseCommand.addTarget (handler: {
            (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            self.togglePlayPause()
            return .success
        })
    }
    
    // MARK: Now Playing Info Center
    
    func configureNowPlayingInfo(_ title:String, artist:String, playbackRate:Int) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate
        ]
    }
    
    // MARK: Did play track
    
    func didPlayTrack(_ trackIndex:Int32) {
        
        highlightTrackIndex(trackIndex)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
            self.dataStore.currentAlbumTrackIndex = trackIndex
            self.dataStore.currentAlbumPlaybackProgress = self.progressView.progress
        })
    }
    
    // MARK: Highlight track playing
    
    func highlightTrackIndex(_ index:Int32) {
        
        let indexPath = IndexPath(row: Int(index), section: 0)
        var reloadIndexPaths = [indexPath]
        if let oldIndexPath = trackListingViewController.highlightedIndexPath {
            if oldIndexPath != indexPath {
                reloadIndexPaths.append(oldIndexPath)
            }
        }
        trackListingViewController.highlightedIndexPath = indexPath
        if let collectionView = trackListingViewController.collectionView {
//            print("reloadIndexPaths: %@", reloadIndexPaths)
            collectionView.reloadItems(at: reloadIndexPaths)
        }
    }
}

// MARK: -

private typealias PlayerTrackListing = PlayerViewController
extension PlayerTrackListing: UICollectionViewDelegate {
    
    func setupTrackListing(_ album:SPTAlbum) {
        
        trackListingViewController.album = album
        trackListingViewController.willMove(toParentViewController: self)
        addChildViewController(trackListingViewController)
        trackListingViewController.didMove(toParentViewController: trackListingViewController)
        albumTrackListingView.addSubview(trackListingViewController.view)
        trackListingViewController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(albumTrackListingView)
        }
    }
}

// MARK: -
private typealias PlayerAudioStreamingDelegate = PlayerViewController
extension PlayerAudioStreamingDelegate: SPTAudioStreamingDelegate {
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidLogin")
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidEncounterTemporaryConnectionError")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        print("didEncounterError: %@", error)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("didReceiveMessage: %@", message)
    }
    
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidDisconnect")
    }
}


// MARK: -
private typealias PlayerAudioStreamingPlaybackDelegate = PlayerViewController
extension PlayerAudioStreamingPlaybackDelegate: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("didChangePlaybackStatus: %@", isPlaying)
        self.isPlaying = isPlaying
        if isPlaying {
            updatePlayButtonToPause()
        } else {
            updatePlayButtonToPlay()
        }
        if let didChangePlaybackStatusBlock = didChangePlaybackStatusBlock {
            didChangePlaybackStatusBlock(self, isPlaying)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToOffset offset: TimeInterval) {
        print("didSeekToOffset: %f", offset)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [AnyHashable: Any]!) {
        if trackMetadata != nil {
            print("didChangeToTrack: %@", trackMetadata)
            if let
                title = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String,
                let artist = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String {
                    configureNowPlayingInfo(title, artist: artist, playbackRate: 1)
                    if let didChangeToTrackBlock = didChangeToTrackBlock {
                        didChangeToTrackBlock(self, title, artist)
                    }
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: URL!) {
        print("didFailToPlayTrack: %@", trackUri)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: URL!) {
        print("didStartPlayingTrack: %@", trackUri)
        if let player = player {
            didPlayTrack(player.currentTrackIndex)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: URL!) {
        print("didStopPlayingTrack: %@", trackUri)
    }
    
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidSkipToNextTrack")
    }
    
    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidBecomeActivePlaybackDevice")
    }
    
    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidLosePermissionForPlayback")
    }
    
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidPopQueue")
    }
}
