//
//  AlbumPlayback.swift
//  Longplay
//
//  Created by Joe Nguyen on 16/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

class AlbumPlayback:NSObject {
    
    var album:SPTAlbum?
    var trackURIs:Array<URL> = []
    var trackDurations:Array<TimeInterval> = []
    var totalDuration:TimeInterval = 0
    var currentAlbumPlaybackPosition:TimeInterval = 0
    var previousPlaybackPosition:TimeInterval = 0
    var progress:Float {
        get {
            return Float(currentAlbumPlaybackPosition)/Float(totalDuration)
        }
    }
    fileprivate var kvoContext: UInt8 = 1
    var progressCallback:((_ progress:Float)->())?
    weak var controller:SPTAudioStreamingController?
    
    convenience init(album:SPTAlbum) {
        self.init()
        self.album = album
        calculateAlbumPlaybackData()
        currentAlbumPlaybackPosition = 0
    }
    
    deinit {
        if let controller = controller {
            controller.removeObserver(self, forKeyPath: "currentPlaybackPosition", context: &kvoContext)
            controller.removeObserver(self, forKeyPath: "currentTrackIndex", context: &kvoContext)
        }
    }
    
    func calculateAlbumPlaybackData() {
        if let
            album = album,
            let listPage:SPTListPage = album.firstTrackPage,
            let items = listPage.items as? [SPTPartialTrack] {
                for item:SPTPartialTrack in items {
                    if let playableUri = item.playableUri {
                        trackURIs.append(playableUri)
                    }
                    trackDurations.append(item.duration)
                    totalDuration += item.duration
                }
        }
        NSLog("trackDurations: %@", trackDurations)
        NSLog("totalDuration: %f", totalDuration)
    }
    
    func observeAudioStreamingController(_ controller: SPTAudioStreamingController) {
        
        controller.addObserver(self, forKeyPath: "currentPlaybackPosition", options:[], context: &kvoContext)
        controller.addObserver(self, forKeyPath: "currentTrackIndex", options:[], context: &kvoContext)
        self.controller = controller
    }
    
    func observeValue(forKeyPath keyPath: String, of object: Any, change: [AnyHashable: Any], context: UnsafeMutableRawPointer) {
        
        if context == &kvoContext {
            if keyPath == "currentPlaybackPosition" {
                if let player = object as? SPTAudioStreamingController {
                    if player.currentPlaybackPosition > 0.0 {
                        if previousPlaybackPosition == 0 {
                            previousPlaybackPosition = player.currentPlaybackPosition
                            currentAlbumPlaybackPosition += player.currentPlaybackPosition
//                            NSLog("%f %f %f", currentAlbumPlaybackPosition, player.currentPlaybackPosition, previousPlaybackPosition)
                        } else {
                            let delta:TimeInterval = player.currentPlaybackPosition - previousPlaybackPosition
                            currentAlbumPlaybackPosition += delta
//                            NSLog("%f %f %f", currentAlbumPlaybackPosition, player.currentPlaybackPosition, previousPlaybackPosition)
                            previousPlaybackPosition = player.currentPlaybackPosition
                        }
                    } else {
//                        NSLog("%f %f %f", currentAlbumPlaybackPosition, player.currentPlaybackPosition, previousPlaybackPosition)
                    }
                }
            }
            else if keyPath == "currentTrackIndex" {
                if object is SPTAudioStreamingController {
//                    NSLog("currentTrackIndex: %d", player.currentTrackIndex)
                }
                previousPlaybackPosition = 0
            }
//            NSLog("progress: %f", progress)
            if let progressCallback = progressCallback {
                progressCallback(progress)
            }
        }
    }
}
