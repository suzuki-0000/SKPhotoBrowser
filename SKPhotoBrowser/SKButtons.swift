//
//  SKButtons.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

// helpers which often used
private let bundle = NSBundle(forClass: SKPhotoBrowser.self)

class SKButtons {
    
    var customCloseButtonImage: UIImage!
    var customCloseButtonEdgeInsets: UIEdgeInsets!
    var customDeleteButtonImage: UIImage!
    var customDeleteButtonEdgeInsets: UIEdgeInsets!
   
    var closeButton: SKCloseButton!
    var deleteButton: SKDeleteButton!
    
    private weak var browser: SKPhotoBrowser?
    
    
    init(browser: SKPhotoBrowser) {
        self.browser = browser
        
        setSettingCloseButton()
        setSettingDeleteButton()
    }
    
    func setup() {}
    
    private func setSettingCloseButton() {
        guard let browser = browser else { return }
        
        closeButton = SKCloseButton(frame: browser.view.frame)
        closeButton.addTarget(browser, action: #selector(browser.closeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        closeButton.hidden = !SKPhotoBrowserOptions.displayCloseButton
        browser.view.addSubview(closeButton)
        
        // If another developer has not set their values
        if customCloseButtonImage != nil {
            closeButton.setImage(customCloseButtonImage, forState: .Normal)
        }
        if customCloseButtonEdgeInsets != nil {
            closeButton.imageEdgeInsets = customCloseButtonEdgeInsets
        }
    }
    
    private func setSettingDeleteButton() {
        guard let browser = browser else { return }
        
        deleteButton = SKDeleteButton(frame: browser.view.frame)
        deleteButton.addTarget(browser, action: #selector(browser.deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        deleteButton.hidden = !SKPhotoBrowserOptions.displayDeleteButton
        browser.view.addSubview(deleteButton)
        
        // If another developer has not set their values
        if customDeleteButtonImage != nil {
            deleteButton.setImage(customCloseButtonImage, forState: .Normal)
        }
        if customDeleteButtonEdgeInsets != nil {
            deleteButton.imageEdgeInsets = customCloseButtonEdgeInsets
        }
    }
}

class SKButton: UIButton {
    var showFrame: CGRect!
    var hideFrame: CGRect!
    var insets: UIEdgeInsets {
        return UI_USER_INTERFACE_IDIOM() == .Phone
            ?  UIEdgeInsetsMake(15.25, 15.25, 15.25, 15.25) : UIEdgeInsetsMake(12, 12, 12, 12)
    }
    var size: CGSize = CGSize(width: 44, height: 44)
    var margin: CGFloat = 5
    
    var buttonTopOffset: CGFloat { return 5 }
    
    func setup(imageName: String) {
        backgroundColor = .clearColor()
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        
        let image = UIImage(named: "SKPhotoBrowser.bundle/images/\(imageName)",
                            inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
        setImage(image, forState: .Normal)
    }
    
    func updateFrame() {}
}

class SKCloseButton: SKButton {
    let imageName = "btn_common_close_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: margin, y: buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: margin, y: -20, width: size.width, height: size.height)
    }
    
    override func updateFrame() {
    }
}

class SKDeleteButton: SKButton {
    let imageName = "btn_common_delete_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: buttonTopOffset,
                                       width: size.width, height: size.height)
        hideFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: -20,
                                       width: size.width, height: size.height)
    }
    
    override func updateFrame() {
        showFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: buttonTopOffset,
                                       width: size.width, height: size.height)
        hideFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: -20,
                                       width: size.width, height: size.height)
    }
}
