//
//  SKCaptionView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi  on 2015/10/07.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

public class SKCaptionView: UIView {
    private var photo: SKPhotoProtocol?
    private var photoLabel: UILabel!
    private var photoLabelPadding: CGFloat = 10
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(photo: SKPhotoProtocol) {
        let screenBound = UIScreen.mainScreen().bounds
        self.init(frame: CGRect(x: 0, y: 0, width: screenBound.size.width, height: screenBound.size.height))
        self.photo = photo
        setup()
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        guard let text = photoLabel.text else {
            return CGSize.zero
        }
        guard photoLabel.text?.characters.count > 0 else {
            return CGSize.zero
        }
        
        let font: UIFont = photoLabel.font
        let width: CGFloat = size.width - photoLabelPadding * 2
        let height: CGFloat = photoLabel.font.lineHeight * CGFloat(photoLabel.numberOfLines)
        
        let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let textSize = attributedText.boundingRectWithSize(CGSize(width: width, height: height), options: .UsesLineFragmentOrigin, context: nil).size
        
        return CGSize(width: textSize.width, height: textSize.height + photoLabelPadding * 2)
    }
}

private extension SKCaptionView {
    func setup() {
        opaque = false
        autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin, .FlexibleRightMargin, .FlexibleLeftMargin]
        
        // setup photoLabel
        setupPhotoLabel()
    }
    
    func setupPhotoLabel() {
        photoLabel = UILabel(frame: CGRect(x: photoLabelPadding, y: 0, width: bounds.size.width - (photoLabelPadding * 2), height: bounds.size.height))
        photoLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        photoLabel.opaque = false
        photoLabel.backgroundColor = .clearColor()
        photoLabel.textColor = SKPhotoBrowserOptions.textAndIconColor
        photoLabel.textAlignment = .Center
        photoLabel.lineBreakMode = .ByTruncatingTail
        photoLabel.numberOfLines = 3
        photoLabel.shadowColor = UIColor(white: 0.0, alpha: 0.5)
        photoLabel.shadowOffset = CGSize(width: 0.0, height: 1.0)
        photoLabel.font = SKPhotoBrowserOptions.captionFont
        photoLabel.text = photo?.caption
        addSubview(photoLabel)
    }
}

