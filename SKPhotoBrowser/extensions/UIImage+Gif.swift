//
//  UIImage+Gif.swift
//  SKPhotoBrowser
//
//  Created by rosua le on 2022/3/27.
//  Copyright © 2022 suzuki_keishi. All rights reserved.
//

import UIKit

extension UIImage {
    public enum GIFBehavior {
        case unclamped, clamped(TimeInterval), webkit
        
        fileprivate func duration(_ properties: Any?) -> TimeInterval? {
            
            // Look for specified image duration; always prefer unclamped delay time
            guard let properties: [String: Any] = (properties as? [String: Any])?["{GIF}"] as? [String: Any],
                let duration: TimeInterval = properties["UnclampedDelayTime"] as? TimeInterval ?? properties["DelayTime"] as? TimeInterval else {
                return nil
            }
            
            // Apply appropriate clamping behavior
            switch self {
            case .unclamped:
                return max(duration, 0.0) // Respect natural delay time
            case .clamped(let clamp):
                return max(duration, max(clamp, 0.0)) // Clamp to custom delay time
            case .webkit:
                return max(duration, 0.1) // Mimic WebKit behavior
            }
        }
    }
    
    public static func animatedImage(data: Data, behavior: GIFBehavior = .webkit) -> UIImage? {
        guard let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(source) > 1 else {
            return Self(data: data) // Delegate ineligible image data to the designated data constructor
        }
        
        // Collect key frames and durations
        let frames: [(image: CGImage, duration: TimeInterval)] = (0 ..< CGImageSourceGetCount(source)).compactMap { index in
            guard let image: CGImage = CGImageSourceCreateImageAtIndex(source, index, nil),
                let duration: TimeInterval = behavior.duration(CGImageSourceCopyPropertiesAtIndex(source, index, nil)) else {
                return nil // Drop bad frames
            }
            return (image, duration)
        }
        
        // Convert key frames to animated image
        var images: [UIImage] = []
        var duration: TimeInterval = 0.0
        for frame in frames {
            let image = UIImage(cgImage: frame.image)
            for _ in 0 ..< Int(frame.duration * 100.0) {
                images.append(image) // Add fill frames
            }
            duration += frame.duration
        }
        return animatedImage(with: images, duration: round(duration * 10.0) / 10.0)
    }
}
