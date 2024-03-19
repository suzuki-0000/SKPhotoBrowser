//
//  UIView+ScreenshotProtection.swift
//  SKPhotoBrowser
//
//  Created by  JuyeonYu on 2023/08/18.
//  Copyright © 2023 suzuki_keishi. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func protectScreenshot() {
        DispatchQueue.main.async {
            let textField = UITextField()
            textField.isSecureTextEntry = true
            self.addSubview(textField)
            textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            textField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            textField.layer.removeFromSuperlayer()
            self.layer.superlayer?.insertSublayer(textField.layer, at: 0)
            textField.layer.sublayers?.last?.addSublayer(self.layer)
        }
    }
}
