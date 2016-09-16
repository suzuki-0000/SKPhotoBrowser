//
//  UIView+Radius.swift
//  SKPhotoBrowser
//
//  Created by K Rummler on 15/03/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

extension UIView {
    func addCornerRadiusAnimation(_ from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        self.layer.add(animation, forKey: "cornerRadius")
        self.layer.cornerRadius = to
    }
}
