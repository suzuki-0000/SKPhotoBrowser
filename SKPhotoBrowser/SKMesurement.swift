//
//  SKMesurement.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation
import UIKit

struct SKMesurement {
    static let isPhone: Bool = UIDevice.currentDevice().userInterfaceIdiom == .Phone
    static let isPad: Bool = UIDevice.currentDevice().userInterfaceIdiom == .Pad
    static var statusBarH: CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.height
    }
    static var screenHeight: CGFloat {
        return UIScreen.mainScreen().bounds.height
    }
    static var screenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
    static var screenScale: CGFloat {
        return UIScreen.mainScreen().scale
    }
    static var screenRatio: CGFloat {
        return screenWidth / screenHeight
    }
}
