//
//  SKCacheTests.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import XCTest
@testable import SKPhotoBrowser


class SKCacheTests: XCTestCase {

    var cache: SKCache!
    let image = UIImage()
    let key = "test_image"

    override func setUp() {
        super.setUp()

        self.cache = SKCache()
    }

    override func tearDown() {
        self.cache = nil

        super.tearDown()
    }
    
    func testInit() {
        XCTAssertNotNil(self.cache.imageCache)
        XCTAssert(self.cache.imageCache is SKDefaultImageCache, "Default image cache should be loaded on init")
    }

    func testDefaultCacheImageForKey() {
        // given
        let cache = (self.cache.imageCache as? SKDefaultImageCache)!.cache
        cache.setObject(self.image, forKey: self.key as AnyObject)

        // when
        let cachedImage = self.cache.imageForKey(self.key)

        // then
        XCTAssertNotNil(cachedImage)
    }

    func testDefaultCacheSetImageForKey() {
        // when
        self.cache.setImage(self.image, forKey: self.key)

        // then
        let cache = (self.cache.imageCache as? SKDefaultImageCache)!.cache
        let cachedImage = cache.object(forKey: self.key as AnyObject) as? UIImage
        XCTAssertNotNil(cachedImage)
    }

    func testDefaultCacheRemoveImageForKey() {
        // given
        let cache = (self.cache.imageCache as? SKDefaultImageCache)!.cache
        cache.setObject(self.image, forKey: self.key as AnyObject)

        // when
        self.cache.removeImageForKey(self.key)

        // then
        let cachedImage = self.cache.imageForKey(self.key)
        XCTAssertNil(cachedImage)
    }
}
