//
//  SKPhotoBrowserOptions.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/18.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import UIKit

public struct SKPhotoBrowserOptions {
    public static var displayStatusbar: Bool = false
    
    public static var displayAction: Bool = true
    public static var shareExtraCaption: String?
    public static var actionButtonTitles: [String]?
    
    public static var displayToolbar: Bool = true
    public static var displayCounterLabel: Bool = true
    public static var displayBackAndForwardButton: Bool = true
    public static var disableVerticalSwipe: Bool = false
    
    public static var displayCloseButton: Bool = true
    public static var displayDeleteButton: Bool = false
    
    public static var displayHorizontalScrollIndicator: Bool = true
    public static var displayVerticalScrollIndicator: Bool = true
    
    public static var bounceAnimation: Bool = false
    public static var enableZoomBlackArea: Bool = true
    public static var enableSingleTapDismiss: Bool = false
    
    public static var backgroundColor: UIColor = .black
    
    public static var indicatorColor: UIColor = UIColor.white
    public static var indicatorStyle: UIActivityIndicatorViewStyle = .whiteLarge

    public static var toolbarTextShadowColor: UIColor = .darkText    
    
    /// By default close button is on left side and delete button is on right.
    ///
    /// Set this property to **true** for swap they.
    ///
    /// Default: false
    public static var swapCloseAndDeleteButtons = false
    
    
    /// Offset from top and from nearest screen edge of close button and delete button.
    ///
    /// - Default: 5
    public static var closeAndDeleteButtonPadding: CGFloat = 5
}

public struct SKCaptionOptions {
    public static var textColor: UIColor = .white
    public static var textAlignment: NSTextAlignment = .center
    public static var numberOfLine: Int = 3
    public static var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    public static var font: UIFont = .systemFont(ofSize: 17.0)
}

public struct SKToolbarOptions {
    public static var textColor: UIColor = .white
    public static var font: UIFont = .systemFont(ofSize: 17.0)
    public static var textShadowColor: UIColor = .black
}
