//
//  DataStore.swift
//  Longplay
//
//  Created by Joe Nguyen on 12/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

class DataStore {
    
    var spotifySessionValues:[String:AnyObject]? = UserDefaults.standard.object(forKey: "SpotifySessionValues") as? [String:AnyObject] {
        didSet {
            if let spotifySessionValues = self.spotifySessionValues {
                UserDefaults.standard.set(spotifySessionValues, forKey: "SpotifySessionValues")
            } else {
                UserDefaults.standard.removeObject(forKey: "SpotifySessionValues")
            }
        }
    }
    
    var currentAlbumURI:URL? = UserDefaults.standard.url(forKey: "CurrentAlbumURI") {
        didSet {
            if let currentAlbumURI = self.currentAlbumURI {
                UserDefaults.standard.set(currentAlbumURI, forKey: "CurrentAlbumURI")
            } else {
                UserDefaults.standard.removeObject(forKey: "CurrentAlbumURI")
            }
        }
    }
    
    var currentAlbumTrackIndex:Int32? = Int32(UserDefaults.standard.integer(forKey: "CurrentAlbumTrackIndex")) {
        didSet {
            if let currentAlbumTrackIndex = self.currentAlbumTrackIndex {
                UserDefaults.standard.set(Int(currentAlbumTrackIndex), forKey: "CurrentAlbumTrackIndex")
            } else {
                UserDefaults.standard.removeObject(forKey: "CurrentAlbumTrackIndex")
            }
        }
    }
    
    var currentAlbumPlaybackProgress:Float? = Float(UserDefaults.standard.float(forKey: "CurrentAlbumPlaybackProgress")) {
        didSet {
            if let currentAlbumPlaybackProgress = self.currentAlbumPlaybackProgress {
                UserDefaults.standard.set(currentAlbumPlaybackProgress, forKey: "CurrentAlbumPlaybackProgress")
            } else {
                UserDefaults.standard.removeObject(forKey: "CurrentAlbumPlaybackProgress")
            }
        }
    }
}



