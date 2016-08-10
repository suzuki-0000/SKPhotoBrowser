//
//  SKPhotoBrowserAnimatorDelegate.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

@objc public protocol SKPhotoBrowserAnimatorDelegate {
    func willPresent(browser: SKPhotoBrowser)
    func willDismiss(browser: SKPhotoBrowser)
}