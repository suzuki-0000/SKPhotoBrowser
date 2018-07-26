//
//  SKLocalPhoto.swift
//  SKPhotoBrowser
//
//  Created by Antoine Barrault on 13/04/2016.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

// MARK: - SKLocalPhoto
open class SKLocalPhoto: NSObject, SKPhotoProtocol {
    
    open var underlyingImage: UIImage!
    open var photoURL: String!
    open var contentMode: UIView.ContentMode = .scaleToFill
    open var shouldCachePhotoURLImage: Bool = false
    open var caption: String?
    open var index: Int = 0
    
    override init() {
        super.init()
    }
    
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    convenience init(url: String, holder: UIImage?) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    open func checkCache() {}
    
    open func loadUnderlyingImageAndNotify() {
        
        if underlyingImage != nil && photoURL == nil {
            loadUnderlyingImageComplete()
        }
        
        if photoURL != nil {
            // Fetch Image
            if FileManager.default.fileExists(atPath: photoURL) {
                if let data = FileManager.default.contents(atPath: photoURL) {
                    self.loadUnderlyingImageComplete()
                    if let image = UIImage(data: data) {
                        self.underlyingImage = image
                        self.loadUnderlyingImageComplete()
                    }
                }
            }
        }
    }
    
    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
    // MARK: - class func
    open class func photoWithImageURL(_ url: String) -> SKLocalPhoto {
        return SKLocalPhoto(url: url)
    }
    
    open class func photoWithImageURL(_ url: String, holder: UIImage?) -> SKLocalPhoto {
        return SKLocalPhoto(url: url, holder: holder)
    }
}
