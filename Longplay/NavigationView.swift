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
    let chevronLeftImage = FAKIonIcons.chevronLeftIcon(withSize: 20).image(with: CGSize(width: 20, height: 20))
    let chevronRightImage = FAKIonIcons.chevronRightIcon(withSize: 20).image(with: CGSize(width: 20, height: 20))
    let playRightImage = FAKIonIcons.playIcon(withSize: 20).image(with: CGSize(width: 20, height: 20))
    let pauseRightImage = FAKIonIcons.pauseIcon(withSize: 20).image(with: CGSize(width: 20, height: 20))
    
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
        self.init(frame:CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        
        backgroundColor = UIColor.clear
        
        // top line separator
        topLineSeparator.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        addSubview(topLineSeparator)
        topLineSeparator.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        // white bg view
        backgroundView.backgroundColor = UIColor.white
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLineSeparator.snp.bottom)
            make.left.bottom.right.equalTo(self)
        }
        
        // left button
        leftButton = UIButton(type:UIButtonType.custom)
        if let leftButton = leftButton {
            leftButton.backgroundColor = UIColor.clear
            showLogoInLeftButton()
            addSubview(leftButton)
            leftButton.snp.makeConstraints { (make) -> Void in
                make.width.height.equalTo(NavigationViewLeftButtonHeight)
                make.top.equalTo(backgroundView)
                make.left.equalTo(backgroundView)
            }
        }
        // middle button
        middleButton = UIButton(type:UIButtonType.custom)
        if let middleButton = middleButton {
            middleButton.backgroundColor = UIColor.clear
            addSubview(middleButton)
            middleButton.snp.makeConstraints { (make) -> Void in
                make.edges.equalTo(backgroundView).inset(UIEdgeInsetsMake(0,NavigationViewLeftButtonHeight,0,NavigationViewLeftButtonHeight))
            }
        }
        // right button
        rightButton = UIButton(type:UIButtonType.custom)
        if let rightButton = rightButton {
            rightButton.backgroundColor = UIColor.clear
            addSubview(rightButton)
            rightButton.snp.makeConstraints { (make) -> Void in
                make.width.height.equalTo(NavigationViewRightButtonHeight)
                make.top.right.equalTo(backgroundView)
            }
            rightButton.alpha = 0.0
        }
    }
    
    // MARK: Show/hide anims
    
    func fadeInView(_ view:UIView) {
        
        view.alpha = 0.0
        UIView.animateWithDefaultDuration({ () -> Void in
            view.alpha = 1.0
        })
    }
    
    func fadeInWithScalingView(_ view:UIView) {
        
        fadeInView(view)
        view.layer.setAffineTransform(view.layer.affineTransform().scaledBy(x: NavigationViewFadeInScale, y: NavigationViewFadeInScale))
        UIView.animateWithDefaultDuration({ () -> Void in
            view.layer.setAffineTransform(view.layer.affineTransform().scaledBy(x: NavigationViewFadeInScaleRestore, y: NavigationViewFadeInScaleRestore))
        })
    }
    
    func fadeOutView(_ view:UIView) {
        
        UIView.animateWithDefaultDuration({ () -> Void in
            view.alpha = 0.0
        })
    }
    
    func fadeOutWithScalingView(_ view:UIView) {
        
        fadeOutView(view)
        UIView.animateWithDefaultDuration({ () -> Void in
            view.layer.setAffineTransform(view.layer.affineTransform().scaledBy(x: NavigationViewFadeOutScale, y: NavigationViewFadeOutScale))
            }, completion: { (finished:Bool) -> Void in
                view.layer.setAffineTransform(view.layer.affineTransform().scaledBy(x: NavigationViewFadeOutScaleRestore, y: NavigationViewFadeOutScaleRestore))
        })
    }
    
    func fadeOutToBottomView(_ view:UIView) {
        
        let translateY:CGFloat = view.bounds.size.height/7
        fadeOutVerticallyView(view, startY: -translateY, endY: translateY)
    }
    
    func fadeOutVerticallyView(_ view:UIView, startY:CGFloat, endY:CGFloat) {
        
        fadeInView(view)
        UIView.animateWithDefaultDuration({ () -> Void in
            view.layer.setAffineTransform(view.layer.affineTransform().translatedBy(x: 0, y: startY))
            }, completion: { (finished:Bool) -> Void in
                view.layer.setAffineTransform(view.layer.affineTransform().translatedBy(x: 0, y: endY))
        })
    }
    
    // MARK: Left Button

    func showLogoInLeftButton() {
        
        showLogoInLeftButtonAnimated(false)
    }

    func showLogoInLeftButtonAnimated(_ animated:Bool) {
        
        if let leftButton = leftButton {
            leftButton.setImage(logoImage, for: UIControlState())
            if animated {
                fadeInWithScalingView(leftButton)
            } else {
                leftButton.alpha = 1.0
            }
        }
    }
    
    func showChevronInLeftButton() {
        if let leftButton = leftButton {
            leftButton.setImage(chevronLeftImage, for: UIControlState())
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
            let albumBottomLabel = albumBottomLabel {
                albumTopLabel.alpha = 0.0
                albumBottomLabel.alpha = 0.0
        }
        if let middleButton = middleButton {
            let icon = FAKIonIcons.playIcon(withSize: 17)
            let attributedTitle = NSMutableAttributedString(attributedString: (icon?.attributedString())!)
            attributedTitle.append(
                NSAttributedString(string: "  Play This Album",
                    attributes: [NSFontAttributeName: UIFont.buttonFontWithSize(20)]))
            middleButton.setAttributedTitle(attributedTitle, for: UIControlState())
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
            middleButton.setAttributedTitle(nil, for: UIControlState())
            middleButton.alpha = 1.0
        }
    }
    
    // MARK: Right Button
    
    func showChevronInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(chevronRightImage, for: UIControlState())
            fadeInWithScalingView(rightButton)
        }
    }
    
    func showPlayInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(playRightImage, for: UIControlState())
            fadeInWithScalingView(rightButton)
        }
    }
    
    func showPauseInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(pauseRightImage, for: UIControlState())
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
            let albumBottomLabel = albumBottomLabel {
                if albumTopLabel.alpha == 0.0 || albumBottomLabel.alpha == 0.0 {
                    fadeInView(albumTopLabel)
                    fadeInView(albumBottomLabel)
                }
        }
    }
    
    func hideAlbumDetails() {
        if let albumTopLabel = albumTopLabel,
            let albumBottomLabel = albumBottomLabel {
                fadeOutToBottomView(albumTopLabel)
                fadeOutToBottomView(albumBottomLabel)
        }
    }
    
    func populateAlbumDetails(_ topLabelText:String, bottomLabelText:String) {
        if let middleButton = middleButton {
            middleButton.setAttributedTitle(nil, for: UIControlState())
        }
        if albumTopLabel == nil {
            albumTopLabel = UILabel()
            if let albumTopLabel = albumTopLabel,
                let leftButton = leftButton,
                let rightButton = rightButton {
                    albumTopLabel.font = UIFont.buttonFontWithSize(16)
                    addSubview(albumTopLabel)
                    albumTopLabel.snp.makeConstraints { (make) -> Void in
                        make.left.equalTo(leftButton.snp.right).offset(NavigationViewTopLabelSideSpacing)
                        make.right.equalTo(rightButton.snp.left).offset(-NavigationViewTopLabelSideSpacing)
                        make.top.equalTo(self).offset(NavigationViewTopLabelTopSpacing)
                        make.height.equalTo(NavigationViewTopLabelHeight)
                    }
            }
        }
        if albumBottomLabel == nil {
            albumBottomLabel = UILabel()
            if let albumBottomLabel = albumBottomLabel,
                let albumTopLabel = albumTopLabel {
                    albumBottomLabel.font = UIFont.buttonFontWithSize(13)
                    addSubview(albumBottomLabel)
                    albumBottomLabel.snp.makeConstraints { (make) -> Void in
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
    func updateProgressView(_ progress:Float) {
        
        if progressBar == nil {
            progressBar = AlbumProgressView()
            if let progressBar = progressBar {
                addSubview(progressBar)
                progressBar.snp.makeConstraints { (make) -> Void in
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
