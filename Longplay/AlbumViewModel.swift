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
    
    init(dictionary:Dictionary<String,String>) {
        super.init()
        if let thumbPath = dictionary["thumb_path"] as String! {
            coverThumbURL = NSURL(string: thumbPath)
        }
        title = dictionary["name"] as String!
        artistName = dictionary["artist"] as String!
    }
}
