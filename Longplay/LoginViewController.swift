//
//  LoginViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 30/05/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpotify()
    }
    
    func setupSpotify() {
        SPTAuth.defaultInstance().clientID = "d1ee9fb41d4245fe8f7ec6a5a7298c75"
        SPTAuth.defaultInstance().redirectURL = NSURL(string: "longplay-app://login-callback")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope,SPTAuthUserLibraryReadScope,SPTAuthUserLibraryModifyScope]
        var loginURL:NSURL = SPTAuth.defaultInstance().loginURL
        UIApplication.sharedApplication().openURL(loginURL)
    }
}
