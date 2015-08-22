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

let NavigationViewFadeInScale:CGFloat = 9/10
let NavigationViewFadeInScaleRestore:CGFloat = 10/9
let NavigationViewFadeOutScale:CGFloat = 8/10
let NavigationViewFadeOutScaleRestore:CGFloat = 10/8

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
    
    // MARK: Show/hide anims
    
    func fadeInView(view:UIView) {
        
        view.alpha = 0.0
        UIView.animateWithDefaultDuration({ () -> Void in
            view.alpha = 1.0
        })
    }
    
    func fadeInWithScalingView(view:UIView) {
        
        fadeInView(view)
        view.layer.setAffineTransform(CGAffineTransformScale(view.layer.affineTransform(),
            NavigationViewFadeInScale, NavigationViewFadeInScale))
        UIView.animateWithDefaultDuration({ () -> Void in
            view.layer.setAffineTransform(CGAffineTransformScale(view.layer.affineTransform(),
                NavigationViewFadeInScaleRestore, NavigationViewFadeInScaleRestore))
        })
    }
    
    func fadeOutView(view:UIView) {
        
        UIView.animateWithDefaultDuration({ () -> Void in
            view.alpha = 0.0
        })
    }
    
    func fadeOutWithScalingView(view:UIView) {
        
        fadeOutView(view)
        UIView.animateWithDefaultDuration({ () -> Void in
            view.layer.setAffineTransform(CGAffineTransformScale(view.layer.affineTransform(),
                NavigationViewFadeOutScale, NavigationViewFadeOutScale))
            }, completion: { (finished:Bool) -> Void in
                view.layer.setAffineTransform(CGAffineTransformScale(view.layer.affineTransform(),
                    NavigationViewFadeOutScaleRestore, NavigationViewFadeOutScaleRestore))
        })
    }
    
    func fadeOutToBottomView(view:UIView) {
        
        let translateY:CGFloat = view.bounds.size.height/7
        fadeOutVerticallyView(view, startY: -translateY, endY: translateY)
    }
    
    func fadeOutVerticallyView(view:UIView, startY:CGFloat, endY:CGFloat) {
        
        fadeInView(view)
        UIView.animateWithDefaultDuration({ () -> Void in
            view.layer.setAffineTransform(CGAffineTransformTranslate(view.layer.affineTransform(),
                0, startY))
            }, completion: { (finished:Bool) -> Void in
                view.layer.setAffineTransform(CGAffineTransformTranslate(view.layer.affineTransform(),
                    0, endY))
        })
    }
    
    // MARK: Left Button
    
    func showLogoInLeftButton() {
        if let leftButton = leftButton {
            leftButton.setImage(logoImage, forState: UIControlState.Normal)
            fadeInWithScalingView(leftButton)
        }
    }
    
    func showChevronInLeftButton() {
        if let leftButton = leftButton {
            leftButton.setImage(chevronLeftImage, forState: UIControlState.Normal)
            fadeInWithScalingView(leftButton)
        }
    }
    
    func hideLeftButton() {
        if let leftButton = leftButton {
            fadeOutView(leftButton)
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
            fadeInView(middleButton)
        }
    }
    
    func showMiddleButton() {
        if let middleButton = middleButton {
            fadeInView(middleButton)
        }
    }
    
    func hideMiddleButton() {
        if let middleButton = middleButton {
            fadeOutToBottomView(middleButton)
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
            fadeInWithScalingView(rightButton)
        }
    }
    
    func showPlayInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(playRightImage, forState: UIControlState.Normal)
            fadeInWithScalingView(rightButton)
        }
    }
    
    func showPauseInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(pauseRightImage, forState: UIControlState.Normal)
            fadeInWithScalingView(rightButton)
        }
    }
    
    func showRightButton() {
        if let rightButton = rightButton {
            if rightButton.alpha == 0.0 {
                fadeInWithScalingView(rightButton)
            }
        }
    }
    
    func hideRightButton() {
        if let rightButton = rightButton {
            fadeOutWithScalingView(rightButton)
        }
    }
    
    // MARK: Album Details
    
    func showAlbumDetails() {
        if let albumTopLabel = albumTopLabel,
            albumBottomLabel = albumBottomLabel {
                if albumTopLabel.alpha == 0.0 || albumBottomLabel.alpha == 0.0 {
                    fadeInView(albumTopLabel)
                    fadeInView(albumBottomLabel)
                }
        }
    }
    
    func hideAlbumDetails() {
        if let albumTopLabel = albumTopLabel,
            albumBottomLabel = albumBottomLabel {
                fadeOutToBottomView(albumTopLabel)
                fadeOutToBottomView(albumBottomLabel)
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
