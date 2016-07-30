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
        return (self.imageCache as? SKImageCacheable)!.imageForKey(key)
    }

    public func setImage(image: UIImage, forKey key: String) {
        (self.imageCache as? SKImageCacheable)!.setImage(image, forKey: key)
    }

    public func removeImageForKey(key: String) {
        (self.imageCache as? SKImageCacheable)!.removeImageForKey(key)
    }

    public func imageForRequest(request: NSURLRequest) -> UIImage? {
        if let response = (self.imageCache as? SKRequestResponseCacheable)!.cachedResponseForRequest(request) {
            let data = response.data

            return UIImage(data: data)
        }

        return nil
    }

    public func setImageData(data: NSData, response: NSURLResponse, request: NSURLRequest) {
        let cachedResponse = NSCachedURLResponse(response: response, data: data)
        (self.imageCache as? SKRequestResponseCacheable)!.storeCachedResponse(cachedResponse, forRequest: request)
    }
}

class SKDefaultImageCache: SKImageCacheable {
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
