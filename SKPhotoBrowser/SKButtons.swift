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


        return UI_USER_INTERFACE_IDIOM() == .phone
            ?  UIEdgeInsets(top: 15.25, left: 15.25, bottom: 15.25, right: 15.25) : UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    var size: CGSize = CGSize(width: 44, height: 44)
    var xPosition: CGFloat = 5
    
    var buttonTopOffset: CGFloat { return 5 }

    enum Position {
        case TopLeft
        case TopRight
    }
    var position: Position = .TopLeft {
        didSet {
            switch position {
            case .TopLeft:
                xPosition = 5
            case .TopRight:
                xPosition = SKMesurement.screenWidth - size.width - 5
            }
            setupFrames()
        }
    }
    
    func setup(_ imageName: String) {
        backgroundColor = UIColor.clear
        imageEdgeInsets = insets
//        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        
        let image = UIImage(named: "SKPhotoBrowser.bundle/images/\(imageName)",
                            in: bundle, compatibleWith: nil) ?? UIImage()
        setImage(image, for: UIControlState())
    }
  
    func updateFrame() { }
  
    func setFrameSize(_ size: CGSize) {
        setupFrames()
        self.frame = showFrame
    }

    func setupFrames() {
        showFrame = CGRect(x: xPosition, y: buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: xPosition, y: -20, width: size.width, height: size.height)
    }
}

class SKCloseButton: SKButton {
    let imageName = "btn_common_close_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        position = .TopLeft
        setupFrames()
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
        position = .TopRight
        setupFrames()
    }
    
    override func updateFrame() {
    }
}
