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
        var loginURL:NSURL = SPTAuth.defaultInstance().loginURL
        UIApplication.sharedApplication().openURL(loginURL)
    }
}
