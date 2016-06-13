//
//  SKCache.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

public class SKCache {

    static let sharedCache = SKCache()
    var imageCache: SKCacheable

    init() {
        self.imageCache = SKDefaultImageCache()
    }

    public func imageForKey(key: String) -> UIImage? {
        return self.imageCache.imageForKey(key)
    }

    public func setImage(image: UIImage, forKey key: String) {
        self.imageCache.setImage(image, forKey: key)
    }

    public func removeImageForKey(key: String) {
        self.imageCache.removeImageForKey(key)
    }
}

class SKDefaultImageCache: SKCacheable {
    var cache: NSCache

    init() {
        self.cache = NSCache()
    }

    func imageForKey(key: String) -> UIImage? {
        return self.cache.objectForKey(key) as? UIImage
    }

    func setImage(image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key)
    }

    func removeImageForKey(key: String) {
        self.cache.removeObjectForKey(key)
    }
}
