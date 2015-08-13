//
//  DataStore.swift
//  Longplay
//
//  Created by Joe Nguyen on 12/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

class DataStore {
    
    var spotifySessionValues:[String:AnyObject]? = NSUserDefaults.standardUserDefaults().objectForKey("SpotifySessionValues") as? [String:AnyObject] {
        didSet {
            if let spotifySessionValues = self.spotifySessionValues {
                NSUserDefaults.standardUserDefaults().setObject(spotifySessionValues, forKey: "SpotifySessionValues")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("SpotifySessionValues")
            }
        }
    }
    
    var currentAlbumURI:NSURL? = NSUserDefaults.standardUserDefaults().URLForKey("CurrentAlbumURI") {
        didSet {
            if let currentAlbumURI = self.currentAlbumURI {
                NSUserDefaults.standardUserDefaults().setURL(currentAlbumURI, forKey: "CurrentAlbumURI")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("CurrentAlbumURI")
            }
        }
    }
    
    var currentAlbumTrackIndex:Int32? = Int32(NSUserDefaults.standardUserDefaults().integerForKey("CurrentAlbumTrackIndex")) {
        didSet {
            if let currentAlbumTrackIndex = self.currentAlbumTrackIndex {
                NSUserDefaults.standardUserDefaults().setInteger(Int(currentAlbumTrackIndex), forKey: "CurrentAlbumTrackIndex")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("CurrentAlbumTrackIndex")
            }
        }
    }
}
