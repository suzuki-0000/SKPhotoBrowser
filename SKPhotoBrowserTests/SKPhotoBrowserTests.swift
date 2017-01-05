//
//  SKPhotoBrowserTests.swift
//  SKPhotoBrowserTests
//
//  Created by Alexsander  on 4/2/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import XCTest
@testable import SKPhotoBrowser


class FakeSKPhotoBrowser: SKPhotoBrowser {
    override func setup () {
    }
}

class SKPhotoBrowserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testSKPhotoArray() {
        var images = [SKPhoto]()
        let photo = SKPhoto.photoWithImage(UIImage())// add some UIImage
        images.append(photo)
        let _ = FakeSKPhotoBrowser(photos: images)
    }
    
    func testSKLocalPhotoArray() {
        var images = [SKLocalPhoto]()
        let photo = SKLocalPhoto.photoWithImageURL("")
        images.append(photo)
        let _ = FakeSKPhotoBrowser(photos: images)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
