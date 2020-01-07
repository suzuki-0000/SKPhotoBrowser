//
//  SKCaptionView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi  on 2015/10/07.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

open class SKCaptionView: UIView {
    fileprivate var photo: SKPhotoProtocol?
    fileprivate var photoLabel: UILabel!
    fileprivate var photoLabelPadding: CGFloat = 10
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(photo: SKPhotoProtocol) {
        self.init(frame: CGRect(x: 0, y: 0, width: SKMesurement.screenWidth, height: SKMesurement.screenHeight))
        self.photo = photo
        setup()
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let text = photoLabel.text, text.count > 0 else {
            return CGSize.zero
        }
        
        let font: UIFont = photoLabel.font
        let width: CGFloat = size.width - photoLabelPadding * 2
        let height: CGFloat = photoLabel.font.lineHeight * CGFloat(photoLabel.numberOfLines)
        
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        let textSize = attributedText.boundingRect(with: CGSize(width: width, height: height), options: .usesLineFragmentOrigin, context: nil).size
        
        return CGSize(width: textSize.width, height: textSize.height + photoLabelPadding * 2)
    }
}

private extension SKCaptionView {
    func setup() {
        isOpaque = false
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin]
        
        // setup photoLabel
        setupPhotoLabel()
    }
    
    func setupPhotoLabel() {
        photoLabel = UILabel(frame: CGRect(x: photoLabelPadding, y: 0, width: bounds.size.width - (photoLabelPadding * 2), height: bounds.size.height))
        photoLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoLabel.isOpaque = false
        photoLabel.backgroundColor = SKCaptionOptions.backgroundColor
        photoLabel.textColor = SKCaptionOptions.textColor
        photoLabel.textAlignment = SKCaptionOptions.textAlignment
        photoLabel.lineBreakMode = SKCaptionOptions.lineBreakMode
        photoLabel.numberOfLines = SKCaptionOptions.numberOfLine
        photoLabel.font = SKCaptionOptions.font
        photoLabel.shadowColor = SKCaptionOptions.shadowColor
        photoLabel.shadowOffset = SKCaptionOptions.shadowOffset
        photoLabel.text = photo?.caption

        addSubview(photoLabel)
    }
}

