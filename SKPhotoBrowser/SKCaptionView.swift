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
    
    var photo:SKPhoto!
    var photoLabel:UILabel!
    var photoLabelPadding:CGFloat = 10
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(photo:SKPhoto) {
        let screenBound = UIScreen.mainScreen().bounds
        self.init(frame: CGRectMake(0, 0, screenBound.size.width, screenBound.size.height))
        self.photo = photo
        setup()
    }
    
    func setup() {
        opaque = false
        
        // setup background first
        let fadeView = UIView(frame: CGRectMake(0, -100, screenWidth, bounds.size.height))
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = fadeView.frame
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 0.0).CGColor, UIColor(white: 0.0, alpha: 0.8).CGColor]
        fadeView.layer.insertSublayer(gradientLayer, atIndex: 0)
        fadeView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(fadeView)
        
        photoLabel = UILabel(frame: CGRectMake(photoLabelPadding, 0, bounds.size.width - (photoLabelPadding * 2) , bounds.size.height))
        photoLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        photoLabel.opaque = false
        photoLabel.backgroundColor = .clearColor()
        photoLabel.textAlignment = .Center
        photoLabel.lineBreakMode = .ByWordWrapping
        photoLabel.numberOfLines = 3
        photoLabel.textColor = .whiteColor()
        photoLabel.shadowColor = UIColor(white: 0.0, alpha: 0.5)
        photoLabel.shadowOffset = CGSizeMake(0.0, 1.0)
        photoLabel.font = UIFont.systemFontOfSize(17.0)
        if let cap = photo.caption {
            photoLabel.text = cap
        }
        addSubview(photoLabel)
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        if photoLabel.text?.characters.count == 0 {
            return CGSizeZero
        }
        
        let text:String = photoLabel.text!
        let font:UIFont = photoLabel.font
        let width:CGFloat = size.width - (photoLabelPadding * 2)
        let height:CGFloat = photoLabel.font.lineHeight * CGFloat(photoLabel.numberOfLines)
        
        let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let textSize = attributedText.boundingRectWithSize(CGSizeMake(width, height),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).size
        
        return CGSizeMake(textSize.width, textSize.height + photoLabelPadding * 2)
    }
    
}

