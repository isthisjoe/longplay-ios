//
//  LaunchViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 13/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit

class LaunchViewController: UIViewController {

    let launchImageView = UIImageView(image: UIImage(named: "logo.png"))

    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(launchImageView)
        launchImageView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(view)
        }
    }
}
