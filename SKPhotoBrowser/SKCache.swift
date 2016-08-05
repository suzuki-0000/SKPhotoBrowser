//
//  SKCache.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

public class SKCache {
    public static let sharedCache = SKCache()
    public var imageCache: SKCacheable

    init() {
        self.imageCache = SKDefaultImageCache()
    }

    public func imageForKey(key: String) -> UIImage? {
        guard let cache = imageCache as? SKImageCacheable else {
            return nil
        }
        
        return cache.imageForKey(key)
    }

    public func setImage(image: UIImage, forKey key: String) {
        guard let cache = imageCache as? SKImageCacheable else {
            return
        }
        
        cache.setImage(image, forKey: key)
    }

    public func removeImageForKey(key: String) {
        guard let cache = imageCache as? SKImageCacheable else {
            return
        }
        
        cache.removeImageForKey(key)
    }

    public func imageForRequest(request: NSURLRequest) -> UIImage? {
        guard let cache = imageCache as? SKRequestResponseCacheable else {
            return nil
        }
        
        if let response = cache.cachedResponseForRequest(request) {
            return UIImage(data: response.data)
        }
        return nil
    }

    public func setImageData(data: NSData, response: NSURLResponse, request: NSURLRequest) {
        guard let cache = imageCache as? SKRequestResponseCacheable else {
            return
        }
        let cachedResponse = NSCachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, forRequest: request)
    }
}

class SKDefaultImageCache: SKImageCacheable {
    var cache: NSCache

    init() {
        cache = NSCache()
    }

    func imageForKey(key: String) -> UIImage? {
        return cache.objectForKey(key) as? UIImage
    }

    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key)
    }

    func removeImageForKey(key: String) {
        cache.removeObjectForKey(key)
    }
}
