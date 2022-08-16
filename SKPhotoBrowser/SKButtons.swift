//
//  SKButtons.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import UIKit

class SKButton: UIButton {
    internal var showFrame: CGRect!
    internal var hideFrame: CGRect!
    
    fileprivate var insets: UIEdgeInsets {
        if SKMesurement.isPhone {
            return UIEdgeInsets(top: 15.25, left: 15.25, bottom: 15.25, right: 15.25)
        } else {
            return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
    }
    fileprivate let size: CGSize = CGSize(width: 44, height: 44)
    fileprivate var marginX: CGFloat = 0
    fileprivate var marginY: CGFloat = 0
    fileprivate var extraMarginY: CGFloat = 20 //NOTE: dynamic to static 
    
    func setup(_ imageName: String) {
        backgroundColor = .clear
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        
        setImage(UIImage.bundledImage(named: imageName), for: .normal)
    }
  
    func setFrameSize(_ size: CGSize? = nil) {
        guard let size = size else { return }
        
        let newRect = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        frame = newRect
        showFrame = newRect
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
    
    func updateFrame(_ frameSize: CGSize) { }
}

class SKImageButton: SKButton {
    fileprivate var imageName: String { return "" }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
}

class SKCloseButton: SKImageButton {
    override var imageName: String { return "btn_common_close_wh" }
    override var marginX: CGFloat {
        get {
            return SKPhotoBrowserOptions.swapCloseAndDeleteButtons
                ? SKMesurement.screenWidth - SKButtonOptions.closeButtonPadding.x - self.size.width
                : SKButtonOptions.closeButtonPadding.x
        }
        set { super.marginX = newValue }
    }
    override var marginY: CGFloat {
        get { return SKButtonOptions.closeButtonPadding.y + extraMarginY }
        set { super.marginY = newValue }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
}

class SKDeleteButton: SKImageButton {
    override var imageName: String { return "btn_common_delete_wh" }
    override var marginX: CGFloat {
        get {
            return SKPhotoBrowserOptions.swapCloseAndDeleteButtons
                ? SKButtonOptions.deleteButtonPadding.x
                : SKMesurement.screenWidth - SKButtonOptions.deleteButtonPadding.x - self.size.width
        }
        set { super.marginX = newValue }
    }
    override var marginY: CGFloat {
        get { return SKButtonOptions.deleteButtonPadding.y + extraMarginY }
        set { super.marginY = newValue }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
}
