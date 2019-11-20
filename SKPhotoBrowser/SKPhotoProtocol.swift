//
//  SKPhotoProtocol.swift
//  Alamofire
//
//  Created by Елизаров Владимир Алексеевич on 04/06/2019.
//

import Foundation

@objc public enum MediaType: Int {
    case image, video
}


@objc public protocol SKPhotoProtocol: NSObjectProtocol {
    
    var index: Int { get set }
    var underlyingImage: UIImage! { get }
    var caption: String? { get }
    var contentMode: UIView.ContentMode { get set }
    var type: MediaType { get }
    
    var isLiked: Bool { get set }
    
    var videoStreamURL: URL? { get set }
    
    func loadUnderlyingImageAndNotify()
    func checkCache()
}
