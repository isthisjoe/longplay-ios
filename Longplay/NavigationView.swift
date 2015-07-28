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

let NavigationViewHeight:CGFloat = 50
let NavigationViewLeftButtonHeight:CGFloat = 50
let NavigationViewRightButtonHeight:CGFloat = 50
let NavigationViewTopLabelTopSpacing:CGFloat = 8
let NavigationViewTopLabelHeight:CGFloat = 20
let NavigationViewBottomLabelHeight:CGFloat = 15
let NavigationViewBottomLabelBottomSpacing:CGFloat = 8

class NavigationView: UIView {
    
    let logoImage = UIImage(named: "AppLogo")
    let chevronLeftImage = FAKIonIcons.chevronLeftIconWithSize(20).imageWithSize(CGSizeMake(20, 20))
    let chevronRightImage = FAKIonIcons.chevronRightIconWithSize(20).imageWithSize(CGSizeMake(20, 20))
    
    var leftButton:UIButton?
    var middleButton:UIButton?
    var albumTopLabel:UILabel?
    var albumBottomLabel:UILabel?
    var rightButton:UIButton?
    
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
        backgroundColor = UIColor.whiteColor()
        // left button
        leftButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        if let leftButton = leftButton {
            leftButton.backgroundColor = UIColor.clearColor()
            showLogoInLeftButton()
            addSubview(leftButton)
            leftButton.snp_makeConstraints({ (make) -> Void in
                make.width.height.equalTo(NavigationViewLeftButtonHeight)
                make.top.left.equalTo(self)
            })
        }
        // middle button
        middleButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        if let middleButton = middleButton {
            middleButton.backgroundColor = UIColor.lightGrayColor()
            addSubview(middleButton)
            middleButton.snp_makeConstraints({ (make) -> Void in
                make.edges.equalTo(self).insets(UIEdgeInsetsMake(0,NavigationViewLeftButtonHeight,0,NavigationViewLeftButtonHeight))
            })
        }
        // right button
        rightButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        if let rightButton = rightButton {
            rightButton.backgroundColor = UIColor.clearColor()
            addSubview(rightButton)
            rightButton.snp_makeConstraints({ (make) -> Void in
                make.width.height.equalTo(NavigationViewRightButtonHeight)
                make.top.right.equalTo(self)
            })
            rightButton.alpha = 0.0
        }
    }
    
    // MARK: Buttons
    
    func showChevronInLeftButton() {
        if let leftButton = leftButton {
            leftButton.setImage(chevronLeftImage, forState: UIControlState.Normal)
            leftButton.alpha = 1.0
        }
    }
    
    func showLogoInLeftButton() {
        if let leftButton = leftButton {
            leftButton.setImage(logoImage, forState: UIControlState.Normal)
            leftButton.alpha = 1.0
        }
    }
    
    func hideLeftButton() {
        if let leftButton = leftButton {
            leftButton.alpha = 0.0
        }
    }
    
    func showChevronInRightButton() {
        if let rightButton = rightButton {
            rightButton.setImage(chevronRightImage, forState: UIControlState.Normal)
            rightButton.alpha = 1.0
        }
    }
    
    func hideRightButton() {
        if let rightButton = rightButton {
            rightButton.alpha = 0.0
        }
    }
    
    // MARK: Album Details
    
    func showAlbumDetails(topLabelText:String, bottomLabelText:String) {
        if albumTopLabel == nil {
            albumTopLabel = UILabel()
            if let albumTopLabel = albumTopLabel {
                addSubview(albumTopLabel)
                albumTopLabel.snp_makeConstraints { (make) -> Void in
                    make.left.right.equalTo(self).offset(NavigationViewLeftButtonHeight)
                    make.top.equalTo(self).offset(NavigationViewTopLabelTopSpacing)
                    make.height.equalTo(NavigationViewTopLabelHeight)
                }
            }
        }
        if albumBottomLabel == nil {
            albumBottomLabel = UILabel()
            if let albumBottomLabel = albumBottomLabel {
                addSubview(albumBottomLabel)
                albumBottomLabel.snp_makeConstraints { (make) -> Void in
                    make.left.right.equalTo(self).offset(NavigationViewLeftButtonHeight)
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
}
