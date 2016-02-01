//
//  SKCaptionView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi  on 2015/10/07.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import Foundation

public class SKCaptionView: UIView {
    
    final let screenBound = UIScreen.mainScreen().bounds
    var screenWidth :CGFloat { return screenBound.size.width }
    var screenHeight:CGFloat { return screenBound.size.height }
    
    private var photo:SKPhotoProtocol!
    private var photoLabel:UILabel!
    private var photoLabelPadding:CGFloat = 10
    private var fadeView:UIView = UIView()
    private var gradientLayer = CAGradientLayer()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(photo:SKPhotoProtocol) {
        let screenBound = UIScreen.mainScreen().bounds
        self.init(frame: CGRectMake(0, 0, screenBound.size.width, screenBound.size.height))
        self.photo = photo
        setup()
    }
    
    func setup() {
        opaque = false
        autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin, .FlexibleRightMargin, .FlexibleLeftMargin]
        
        // setup background first
        fadeView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(fadeView)
        
        // add layer at fadeView
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 0.0).CGColor, UIColor(white: 0.0, alpha: 0.8).CGColor]
        fadeView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        photoLabel = UILabel(frame: CGRectMake(photoLabelPadding, 0, bounds.size.width - (photoLabelPadding * 2) , bounds.size.height))
        photoLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        photoLabel.opaque = false
        photoLabel.backgroundColor = .clearColor()
        photoLabel.textColor = .whiteColor()
        photoLabel.textAlignment = .Center
        photoLabel.lineBreakMode = .ByTruncatingTail
        photoLabel.numberOfLines = 3
        photoLabel.shadowColor = UIColor(white: 0.0, alpha: 0.5)
        photoLabel.shadowOffset = CGSizeMake(0.0, 1.0)
        photoLabel.font = UIFont.systemFontOfSize(17.0)
        if let cap = photo.caption {
            photoLabel.text = cap
        }
        addSubview(photoLabel)
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        guard let text = photoLabel.text else {
            return CGSizeZero
        }
        guard photoLabel.text?.characters.count > 0 else {
            return CGSizeZero
        }
        
        let font:UIFont = photoLabel.font
        let width:CGFloat = size.width - (photoLabelPadding * 2)
        let height:CGFloat = photoLabel.font.lineHeight * CGFloat(photoLabel.numberOfLines)
        
        let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let textSize = attributedText.boundingRectWithSize(CGSizeMake(width, height),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).size
        
        return CGSizeMake(textSize.width, textSize.height + photoLabelPadding * 2)
    }
    
    public override func layoutSubviews() {
        fadeView.frame = frame
        gradientLayer.frame = frame
    }
    
}

