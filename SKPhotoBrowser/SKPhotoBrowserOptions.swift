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
    public static var shareExtraCaption: String? = nil
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
    public static var textAndIconColor: UIColor = .white
    public static var toolbarTextShadowColor: UIColor = .darkText
    
    public static var toolbarFont = UIFont(name: "Helvetica", size: 16.0)
    public static var captionFont = UIFont.systemFont(ofSize: 17.0)
    
    // FIXED: Scrolling performance slowed #145
    // public static var imagePaddingX: CGFloat = 0
    // public static var imagePaddingY: CGFloat = 0
}
