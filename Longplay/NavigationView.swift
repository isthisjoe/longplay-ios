//
//  NavigationView.swift
//  LongplayUI
//
//  Created by Joe Nguyen on 26/07/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesomeKit

let NavigationViewHeight:CGFloat = 50.5
let NavigationViewLeftButtonHeight:CGFloat = 50
let NavigationViewRightButtonHeight:CGFloat = 50
let NavigationViewTopLabelTopSpacing:CGFloat = 8
let NavigationViewTopLabelSideSpacing:CGFloat = 14
let NavigationViewTopLabelHeight:CGFloat = 20
let NavigationViewBottomLabelHeight:CGFloat = 15
let NavigationViewBottomLabelBottomSpacing:CGFloat = 8

class NavigationView: UIView {
    
    let logoImage = UIImage(named: "app_logo")
    let chevronLeftImage = FAKIonIcons.chevronLeftIconWithSize(20).imageWithSize(CGSizeMake(20, 20))
    let chevronRightImage = FAKIonIcons.chevronRightIconWithSize(20).imageWithSize(CGSizeMake(20, 20))
    let playRightImage = FAKIonIcons.playIconWithSize(20).imageWithSize(CGSizeMake(20, 20))
    let pauseRightImage = FAKIonIcons.pauseIconWithSize(20).imageWithSize(CGSizeMake(20, 20))
    
    let topLineSeparator = UIView()
    let backgroundView = UIView()
    var leftButton:UIButton?
    var middleButton:UIButton?
    var albumTopLabel:UILabel?
    var albumBottomLabel:UILabel?
    var rightButton:UIButton?
    var progressBar:AlbumProgressView?
    
    // MARK: Init
    
    convenience init() {
        
        self.init(frame:CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        // top line separator
        topLineSeparator.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)
        addSubview(topLineSeparator)
        topLineSeparator.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        // white bg view
        backgroundView.backgroundColor = UIColor.whiteColor()
        addSubview(backgroundView)
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topLineSeparator.snp_bottom)
            make.left.bottom.right.equalTo(self)
        }
        
        // left button
        leftButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        if let leftButton = leftButton {
            leftButton.backgroundColor = UIColor.clearColor()
            showLogoInLeftButton()
            addSubview(leftButton)
            leftButton.snp_makeConstraints { (make) -> Void in
                make.width.height.equalTo(NavigationViewLeftButtonHeight)
                make.top.equalTo(backgroundView)
                make.left.equalTo(backgroundView)
            }
        }
        // middle button
        middleButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        if let middleButton = middleButton {
            middleButton.backgroundColor = UIColor.clearColor()
            addSubview(middleButton)
            middleButton.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(backgroundView).inset(UIEdgeInsetsMake(0,NavigationViewLeftButtonHeight,0,NavigationViewLeftButtonHeight))
            }
        }
        // right button
        rightButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        if let rightButton = rightButton {
            rightButton.backgroundColor = UIColor.clearColor()
            addSubview(rightButton)
            rightButton.snp_makeConstraints { (make) -> Void in
                make.width.height.equalTo(NavigationViewRightButtonHeight)
                make.top.right.equalTo(backgroundView)
            }
            rightButton.alpha = 0.0
        }
    }
    
    // MARK: Left Button
    
    func showLogoInLeftButton() {
        if let leftButton = leftButton {
            leftButton.setImage(logoImage, forState: UIControlState.Normal)
            leftButton.alpha = 1.0
        }
    }
    
    func showChevronInLeftButton() {
        if let leftButton = leftButton {
            leftButton.setImage(chevronLeftImage, forState: UIControlState.Normal)
            leftButton.alpha = 1.0
        }
    }
    
    func hideLeftButton() {
        if let leftButton = leftButton {
            leftButton.alpha = 0.0
        }
    }
    
    // MARK: Middle Button
    
    func showPlayAlbumInMiddleButton() {
        if let albumTopLabel = albumTopLabel,
            albumBottomLabel = albumBottomLabel {
                albumTopLabel.alpha = 0.0
                albumBottomLabel.alpha = 0.0
        }
        if let middleButton = middleButton {
            let icon = FAKIonIcons.playIconWithSize(17)
            let attributedTitle = NSMutableAttributedString(attributedString: icon.attributedString())
            attributedTitle.appendAttributedString(
                NSAttributedString(string: "  Play This Album",
                    attributes: [NSFontAttributeName: UIFont.buttonFontWithSize(20)]))
            middleButton.setAttributedTitle(attributedTitle, forState: .Normal)
            middleButton.alpha = 1.0
        }
    }
    
    func showMiddleButton() {
        if let middleButton = middleButton {
            middleButton.alpha = 1.0
        }
    }
    
    func hideMiddleButton() {
        if let middleButton = middleButton {
            middleButton.alpha = 0.0
        }
    }
    
    func hideMiddleButtonText() {
        if let middleButton = middleButton {
            middleButton.setAttributedTitle(nil, forState: UIControlState.Normal)
            middleButton.alpha = 1.0
        }
    }
    
    // MARK: Right Button
    
    func showChevronInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(chevronRightImage, forState: UIControlState.Normal)
            rightButton.alpha = 1.0
        }
    }
    
    func showPlayInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(playRightImage, forState: UIControlState.Normal)
            rightButton.alpha = 1.0
        }
    }
    
    func showPauseInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(pauseRightImage, forState: UIControlState.Normal)
            rightButton.alpha = 1.0
        }
    }
    
    func showRightButton() {
        if let rightButton = rightButton {
            rightButton.alpha = 1.0
        }
    }
    
    func hideRightButton() {
        if let rightButton = rightButton {
            rightButton.alpha = 0.0
        }
    }
    
    // MARK: Album Details
    
    func showAlbumDetails() {
        if let albumTopLabel = albumTopLabel {
            albumTopLabel.alpha = 1.0
        }
        if let albumBottomLabel = albumBottomLabel {
            albumBottomLabel.alpha = 1.0
        }
    }
    
    func hideAlbumDetails() {
        if let albumTopLabel = albumTopLabel {
            albumTopLabel.alpha = 0.0
        }
        if let albumBottomLabel = albumBottomLabel {
            albumBottomLabel.alpha = 0.0
        }
    }
    
    func populateAlbumDetails(topLabelText:String, bottomLabelText:String) {
        if let middleButton = middleButton {
            middleButton.setAttributedTitle(nil, forState: UIControlState.Normal)
        }
        if albumTopLabel == nil {
            albumTopLabel = UILabel()
            if let albumTopLabel = albumTopLabel,
                leftButton = leftButton,
                rightButton = rightButton {
                    albumTopLabel.font = UIFont.buttonFontWithSize(16)
                    addSubview(albumTopLabel)
                    albumTopLabel.snp_makeConstraints { (make) -> Void in
                        make.left.equalTo(leftButton.snp_right).offset(NavigationViewTopLabelSideSpacing)
                        make.right.equalTo(rightButton.snp_left).offset(-NavigationViewTopLabelSideSpacing)
                        make.top.equalTo(self).offset(NavigationViewTopLabelTopSpacing)
                        make.height.equalTo(NavigationViewTopLabelHeight)
                    }
            }
        }
        if albumBottomLabel == nil {
            albumBottomLabel = UILabel()
            if let albumBottomLabel = albumBottomLabel,
                albumTopLabel = albumTopLabel {
                    albumBottomLabel.font = UIFont.buttonFontWithSize(13)
                    addSubview(albumBottomLabel)
                    albumBottomLabel.snp_makeConstraints { (make) -> Void in
                        make.left.right.equalTo(albumTopLabel)
                        make.bottom.equalTo(self).offset(-NavigationViewBottomLabelBottomSpacing)
                        make.height.equalTo(NavigationViewBottomLabelHeight)
                    }
            }
        }
        if let albumTopLabel = albumTopLabel {
            albumTopLabel.text = topLabelText
        }
        if let albumBottomLabel = albumBottomLabel {
            albumBottomLabel.text = bottomLabelText
        }
    }
    
    // Progress View
    func updateProgressView(progress:Float) {
        
        if progressBar == nil {
            progressBar = AlbumProgressView()
            if let progressBar = progressBar {
                addSubview(progressBar)
                progressBar.snp_makeConstraints { (make) -> Void in
                    make.height.equalTo(2)
                    make.left.right.equalTo(self)
                    make.top.equalTo(self).offset(-1)
                }
            }
        }
        if let progressBar = progressBar {
            progressBar.setProgress(progress, animated: true)
        }
    }
}
