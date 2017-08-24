//
//  SKButtons.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

// helpers which often used
private let bundle = Bundle(for: SKPhotoBrowser.self)

class SKButton: UIButton {
    var showFrame: CGRect!
    var hideFrame: CGRect!
    var insets: UIEdgeInsets {
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return UIEdgeInsets(top: 15.25, left: 15.25, bottom: 15.25, right: 15.25)
        } else {
            return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
    }
    var size: CGSize = CGSize(width: 44, height: 44)
    var margin: CGFloat = SKPhotoBrowserOptions.closeAndDeleteButtonPadding
    
    var buttonTopOffset: CGFloat {
        return SKPhotoBrowserOptions.closeAndDeleteButtonPadding
    }
    
    func setup(_ imageName: String) {
        backgroundColor = .clear
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        
        let image = UIImage(named: "SKPhotoBrowser.bundle/images/\(imageName)",
                            in: bundle, compatibleWith: nil) ?? UIImage()
        setImage(image, for: UIControlState())
    }
  
    func setFrameSize(_ size: CGSize) {
        let newRect = CGRect(x: margin, y: buttonTopOffset, width: size.width, height: size.height)
        frame = newRect
        showFrame = newRect
        hideFrame = CGRect(x: margin, y: -20, width: size.width, height: size.height)
    }
    
    func updateFrame(_ frameSize: CGSize) { }
}

class SKImageButton: SKButton {
    
    fileprivate var leftSidePositionMargin: CGFloat {
        return super.margin
    }
    
    fileprivate var rightSidePositionMargin: CGFloat {
        return SKMesurement.screenWidth - super.margin - self.size.width
    }
    
    fileprivate var imageName: String {
        return ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: margin, y: buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: margin, y: -20, width: size.width, height: size.height)
    }
}

class SKCloseButton: SKImageButton {
    override var imageName: String { return "btn_common_close_wh" }
    
    override var margin: CGFloat {
        get {
            return SKPhotoBrowserOptions.swapCloseAndDeleteButtons
                ? rightSidePositionMargin
                : leftSidePositionMargin
        }
        set {
            super.margin = newValue
        }
    }
}

class SKDeleteButton: SKImageButton {
    override var imageName: String { return "btn_common_delete_wh" }
    
    
    override var margin: CGFloat {
        get { return SKPhotoBrowserOptions.swapCloseAndDeleteButtons
            ? leftSidePositionMargin
            : rightSidePositionMargin
        }
        set { super.margin = newValue }
    }
    
    override func updateFrame(_ newScreenSize: CGSize) {
        showFrame = CGRect(x: newScreenSize.width - size.width, y: buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: newScreenSize.width - size.width, y: -20, width: size.width, height: size.height)
    }
}
