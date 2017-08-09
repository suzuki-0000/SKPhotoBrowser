//
//  UIImage+Rotation.swift
//  SKPhotoBrowser
//
//  Created by K Rummler on 15/03/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

extension UIImage {
    func rotateImageByOrientation() -> UIImage {
        // No-op if the orientation is already correct
        guard self.imageOrientation != .up else {
            return self
        }

        let transform = calculateAffineTransform()

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
            bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
            space: self.cgImage!.colorSpace!,
            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            
        default:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        if let cgImage = ctx!.makeImage() {
            return UIImage(cgImage: cgImage)
        } else {
            return self
        }
    }

    fileprivate func calculateAffineTransform() -> CGAffineTransform {
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi))

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi))

        default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        default:
            break
        }

        return transform
    }
}

