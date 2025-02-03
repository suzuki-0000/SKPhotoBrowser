//
//  SKCache.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit
import ImageIO

open class SKCache {
    public static let sharedCache = SKCache()
    open var imageCache: SKCacheable
    
    private let defaultOrientation = UIImage.Orientation.up

    init() {
        self.imageCache = SKDefaultImageCache()
    }

    open func imageForKey(_ key: String) -> UIImage? {
        guard let cache = imageCache as? SKImageCacheable else {
            return nil
        }
        
        return cache.imageForKey(key)
    }

    open func setImage(_ image: UIImage, forKey key: String) {
        guard let cache = imageCache as? SKImageCacheable else {
            return
        }
        
        cache.setImage(image, forKey: key)
    }

    open func removeImageForKey(_ key: String) {
        guard let cache = imageCache as? SKImageCacheable else {
            return
        }
        
        cache.removeImageForKey(key)
    }
    
    open func removeAllImages() {
        guard let cache = imageCache as? SKImageCacheable else {
            return
        }
        
        cache.removeAllImages()
    }

    open func imageForRequest(_ request: URLRequest) -> UIImage? {
        guard let cache = imageCache as? SKRequestResponseCacheable else {
            return nil
        }
        
        if let response = cache.cachedResponseForRequest(request) {
            let data = response.data
            guard let image = UIImage(data: data) else { return nil }
            
            let orientation = getOrientation(from: data)
            return UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: orientation)
        }
        
        return nil
    }

    open func setImageData(_ data: Data, response: URLResponse, request: URLRequest?) {
        guard let cache = imageCache as? SKRequestResponseCacheable, let request = request else {
            return
        }
        let cachedResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, forRequest: request)
    }

    open func getExifData(from imageData: Data) -> [String: Any]? {
        if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
                if let exifDict = imageProperties["{Exif}"] as? [String: Any] {
                    // Access EXIF properties here
                    return exifDict
                }
            }
        }
        
        return nil
    }
    
    private func getOrientation(from imageData: Data) -> UIImage.Orientation {
        let exifData = getExifData(from: imageData)
        guard let exifData, let orientation = exifData[String(kCGImagePropertyOrientation)] as? Int else { return .up }
        return convertExifOrientationToIosOrientation(orientation)
    }
    
    private func convertExifOrientationToIosOrientation(_ orientation: Int) -> UIImage.Orientation {
        switch orientation {
        case 1:
            return .up
        case 2:
            return .down
        case 3:
            return .left
        case 4:
            return .right
        case 5:
            return .upMirrored
        case 6:
            return .downMirrored
        case 7:
            return .leftMirrored
        case 8:
            return .rightMirrored
        default:
            return .up
        }
    }
}

class SKDefaultImageCache: SKImageCacheable {
    var cache: NSCache<AnyObject, AnyObject>

    init() {
        cache = NSCache()
    }

    func imageForKey(_ key: String) -> UIImage? {
        return cache.object(forKey: key as AnyObject) as? UIImage
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as AnyObject)
    }

    func removeImageForKey(_ key: String) {
        cache.removeObject(forKey: key as AnyObject)
    }
    
    func removeAllImages() {
        cache.removeAllObjects()
    }
}
