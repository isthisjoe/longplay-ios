//
//  PlayerViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 10/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesome_swift

class PlayerViewController: UIViewController {

    var browserButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBrowserButton()
    }
    
    func setupBrowserButton() {
        browserButton = UIButton()
        browserButton!.titleLabel!.font = UIFont.fontAwesomeOfSize(30)
        browserButton!.setTitle(String.fontAwesomeIconWithName(.ThLarge), forState: .Normal)
        if let browserButton = browserButton {
            view.addSubview(browserButton)
            browserButton.snp_makeConstraints({ (make) -> Void in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.top.equalTo(20)
                make.left.equalTo(20)
            })
        }
    }
    
    func addTargetToBrowserButton(target:AnyObject, action:Selector) {
        if let browserButton = browserButton {
            browserButton.addTarget(target, action:action, forControlEvents:.TouchUpInside)
        }
    }
}
