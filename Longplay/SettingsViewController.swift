//
//  SettingsViewController.swift
//  Longplay
//
//  Created by Joe Nguyen on 14/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit

class SettingsViewController: UIViewController {
    
    var session: SPTSession?
    
    let textLabel = UILabel()
    let logoutButton = DefaultButton(title: "Log me out")
    
    override func viewDidLoad() {
        
        setupViews()
    }
    
    func setupViews() {
        
        view.backgroundColor = UIColor.white
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) -> Void in
            make.top.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            make.height.greaterThanOrEqualTo(100)
        }
        
        let boldFont = UIFont.primaryBoldFontWithSize(14)
        let font = UIFont.primaryFontWithSize(14)
        let attributedText = NSMutableAttributedString()
        attributedText.append(
            NSAttributedString(string: "Longplay",
                attributes: [NSFontAttributeName: boldFont,
                    NSForegroundColorAttributeName: UIColor.lpBlackColor(),
                    NSKernAttributeName: 0.1]))
        attributedText.append(
            NSAttributedString(string: " is a music player that plays\nwhole albums from start to finish.\n\nNo skipping, no shuffling.\n\nAlbums are selected weekly from\nlegit music peeps and publications.\n\nYou logged in to Spotify with username:\n",
                attributes: [NSFontAttributeName: font,
                    NSForegroundColorAttributeName: UIColor.lpBlackColor(),
                    NSKernAttributeName: 0.1]))
        if let session = session,
            let username = session.canonicalUsername {
                attributedText.append(
                    NSAttributedString(string: username,
                        attributes: [NSFontAttributeName: boldFont,
                            NSForegroundColorAttributeName: UIColor.lpBlackColor(),
                            NSKernAttributeName: 0.1]))
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        attributedText.addAttribute(NSParagraphStyleAttributeName,
            value:paragraph,
            range:NSRange(location:0, length:attributedText.length))
        textLabel.numberOfLines = 0
        textLabel.attributedText = attributedText
        textLabel.sizeToFit()
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(textLabel.snp.bottom).offset(25)
            make.left.equalTo(textLabel)
            make.width.equalTo(91)
            make.height.equalTo(29)
        }
        logoutButton.addTarget(self, action: #selector(SettingsViewController.logoutAction(_:)), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    func logoutAction(_ sender:AnyObject) {
        
    }
}
