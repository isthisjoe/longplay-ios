//
//  AlbumViewModel.swift
//  Longplay
//
//  Created by Joe Nguyen on 11/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

class AlbumViewModel: NSObject {

    var coverThumbURL:NSURL?
    var title:String?
    var artistName:String?
    
    init(album:SPTAlbum) {
        super.init()
        if album.largestCover != nil {
            let smallestCover = album.largestCover
            if smallestCover.imageURL != nil {
                let imageURL = smallestCover.imageURL as NSURL
                coverThumbURL = imageURL
            }
        }
        if album.name != nil {
            title = album.name
        }
        if album.artists != nil &&
            album.artists.count > 0 {
                let firstArtist = album.artists.first as! SPTPartialArtist
                artistName = firstArtist.name
        }
    }
}
