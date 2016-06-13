//
//  SKCachable.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit.UIImage

protocol SKCachable {
    func imageForKey(key: String) -> UIImage?
    func setImage(image: UIImage, forKey key: String)
    func removeImageForKey(key: String)
}