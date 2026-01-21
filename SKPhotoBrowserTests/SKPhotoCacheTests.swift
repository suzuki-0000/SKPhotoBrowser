//
//  SKPhotoCacheTests.swift
//  
//
//  Created by fattiger00 on 2022/9/5.
//

import XCTest
@testable import SKPhotoBrowser

class SKPhotoCacheTests: XCTestCase {
   
    let imageUrl = "https://placehold.jp/150x150.png"
    static let cacheKey = "test_cache_key"
    
    override func setUp() {
        super.setUp()
        
    }
    
    override class func tearDown() {
        super.tearDown()
        
        SKCache.sharedCache.removeImageForKey(SKPhotoCacheTests.cacheKey)
    }
    
    func testPhotoDownloadable() throws {
        // given
        let photos = SKPhoto(
            url: self.imageUrl,
            cacheKey: SKPhotoCacheTests.cacheKey
        )
        photos.shouldCachePhotoURLImage = true
        
        // when
        photos.loadUnderlyingImageAndNotify()
        
        // then
        let expectation = self.expectation(forNotification: NSNotification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: photos, handler: nil)
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testPhotoCacheGetable() throws {
        // given
        let photos = SKPhoto(
            url: self.imageUrl,
            cacheKey: SKPhotoCacheTests.cacheKey
        )
        photos.shouldCachePhotoURLImage = true
        
        //when
        photos.checkCache()
        
        //then
        XCTAssertNotNil(photos.underlyingImage)
    }
    
    func testPhotoCached() throws {
        let image = SKCache.sharedCache.imageForKey(SKPhotoCacheTests.cacheKey)
        XCTAssertNotNil(image)
    }
    
    func testExample() throws {
        try testPhotoDownloadable()
        try testPhotoCacheGetable()
        try testPhotoCached()
    }


}
