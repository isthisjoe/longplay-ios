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
    
    var currentAlbumTrackURI:NSURL? = NSUserDefaults.standardUserDefaults().URLForKey("CurrentAlbumTrackURI") {
        didSet {
            if let currentAlbumTrackURI = self.currentAlbumTrackURI {
                NSUserDefaults.standardUserDefaults().setURL(currentAlbumTrackURI, forKey: "CurrentAlbumTrackURI")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("CurrentAlbumTrackURI")
            }
        }
    }
}
