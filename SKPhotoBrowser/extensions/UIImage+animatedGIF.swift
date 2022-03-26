//
//  UIImage+animatedGIF.swift
//  SKPhotoBrowser
//
//  Created by Ege Sucu on 23.03.2022.
//  Copyright © 2022 suzuki_keishi. All rights reserved.
//

import ImageIO
import UIKit

/// UIImage (animatedGIF)
/// This category adds class methods to `UIImage` to create an animated `UIImage` from an animated GIF.

typealias toCF = CFTypeRef
typealias fromCF = Double

private func delayCentisecondsForImageAtIndex(_ source: CGImageSource, _ i: size_t) -> Int {
    var delayCentiseconds = 1
    let properties: CFDictionary? = CGImageSourceCopyPropertiesAtIndex(source, i, nil)
    
    if let properties = properties {
        if let pointer = CFDictionaryGetValue(properties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()){
            let gifProperties = Unmanaged<CFDictionary>.fromOpaque(pointer).takeUnretainedValue()
            if let numberPointer = CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            let clampedNumberPointer = CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()){
                var number = Unmanaged<NSNumber>.fromOpaque(numberPointer).takeUnretainedValue()
                if number.doubleValue == 0{
                    number = Unmanaged<NSNumber>.fromOpaque(clampedNumberPointer).takeUnretainedValue()
                }
                
                if number.doubleValue > 0{
                    delayCentiseconds = lrint(number.doubleValue * 100)
                }
            }
        }
    }
    return delayCentiseconds
}

private func createImagesAndDelays(_ source: CGImageSource, _ count: size_t, _ imagesOut: inout [CGImage?], _ delayCentisecondsOut: inout [Int]) {
    for i in 0..<count {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, nil)
        delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i)
    }
}

private func sum(_ count: size_t, _ values: [Int]) -> Int {
    var theSum = 0
    for i in 0..<count {
        theSum += Int(values[i])
    }
    return theSum
}

private func pairGCD(_ a: Int, _ b: Int) -> Int {
    var a = a
    var b = b
    if a < b {
        return pairGCD(b, a)
    }
    while true {
        let r = a % b
        if r == 0 {
            return b
        }
        a = b
        b = r
    }
}

private func vectorGCD(_ count: size_t, _ values: [Int]) -> Int {
    var gcd = Int(values[0])
    for i in 1..<count {
        // Note that after I process the first few elements of the vector, `gcd` will probably be smaller than any remaining element.  By passing the smaller value as the second argument to `pairGCD`, I avoid making it swap the arguments.
        gcd = pairGCD(Int(values[i]), gcd)
    }
    return gcd
}

private func frameArray(_ count: size_t, _ images: inout [CGImage?], _ delayCentiseconds: [Int], _ totalDurationCentiseconds: Int) -> [AnyHashable]? {
    let gcd = vectorGCD(count, delayCentiseconds)
    let frameCount = totalDurationCentiseconds / gcd
    var frames: [UIImage]? = nil
    var i = 0, f = 0
    while i < count {
        var frame: UIImage? = nil
        if let image = images[i] {
            frame = UIImage(cgImage: image)
        }
        var j = delayCentiseconds[i] / gcd
        while j > 0 {
            frames?[f] = frame ?? UIImage()
            f += 1
            j -= 1
        }
        i += 1
    }
    if let frames = frames {
        return Array(frames[..<frameCount])
    }
    return nil
}

private func animatedImageWithAnimatedGIFImageSource(_ source: CGImageSource?) -> UIImage? {
    var count: size_t? = nil
    if let source = source {
        count = CGImageSourceGetCount(source)
    }
    var images = Array<CGImage?>(repeating: nil, count: count ?? 0)
    var delayCentiseconds = [Int](repeating: 0, count: count ?? 0) // in centiseconds
    if let source = source {
        createImagesAndDelays(source, count ?? 0, &images, &delayCentiseconds)
    }
    let totalDurationCentiseconds = sum(count ?? 0, delayCentiseconds)
    let frames = frameArray(count ?? 0, &images, delayCentiseconds, totalDurationCentiseconds)
    var animation: UIImage? = nil
    if let frames = frames as? [UIImage] {
        animation = UIImage.animatedImage(with: frames, duration: TimeInterval(totalDurationCentiseconds) / 100.0)
    }
    return animation
}

private func animatedImageWithAnimatedGIFReleasingImageSource(_ source: CGImageSource?) -> UIImage? {
    if let source = source {
        let image = animatedImageWithAnimatedGIFImageSource(source)
        return image
    } else {
        return nil
    }
}

extension UIImage {
    /*
            UIImage *animation = [UIImage animatedImageWithAnimatedGIFData:theData];

        I interpret `theData` as a GIF.  I create an animated `UIImage` using the source images in the GIF.

        The GIF stores a separate duration for each frame, in units of centiseconds (hundredths of a second).  However, a `UIImage` only has a single, total `duration` property, which is a floating-point number.

        To handle this mismatch, I add each source image (from the GIF) to `animation` a varying number of times to match the ratios between the frame durations in the GIF.

        For example, suppose the GIF contains three frames.  Frame 0 has duration 3.  Frame 1 has duration 9.  Frame 2 has duration 15.  I divide each duration by the greatest common denominator of all the durations, which is 3, and add each frame the resulting number of times.  Thus `animation` will contain frame 0 3/3 = 1 time, then frame 1 9/3 = 3 times, then frame 2 15/3 = 5 times.  I set `animation.duration` to (3+9+15)/100 = 0.27 seconds.
    */
    class func animatedImage(withAnimatedGIFData data: Data?) -> UIImage? {
        if let data = data{
            let source = CGImageSourceCreateWithData(data as CFData, nil)
            return animatedImageWithAnimatedGIFReleasingImageSource(source)
        }
        return nil
    }

    /*
            UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:theURL];

        I interpret the contents of `theURL` as a GIF.  I create an animated `UIImage` using the source images in the GIF.

        I operate exactly like `+[UIImage animatedImageWithAnimatedGIFData:]`, except that I read the data from `theURL`.  If `theURL` is not a `file:` URL, you probably want to call me on a background thread or GCD queue to avoid blocking the main thread.
    */
    class func animatedImage(withAnimatedGIFURL url: URL?) -> UIImage? {
        if let url = url {
            let source = CGImageSourceCreateWithURL(url as CFURL, nil)
            return animatedImageWithAnimatedGIFImageSource(source)
        }
        return nil
    }
}



