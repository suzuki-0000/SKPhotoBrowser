//
//  SKIndicatorView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi on 2015/10/09.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

class SKIndicatorView: UIActivityIndicatorView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        activityIndicatorViewStyle = .whiteLarge
    }
}
