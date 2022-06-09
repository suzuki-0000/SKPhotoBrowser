//
//  UIImage+BundledImage.swift
//  
//
//  Created by Aleksandr Solovev on 09.06.2022.
//

import UIKit

extension UIImage {
    static func bundledImage(named imageName: String) -> UIImage {
        let imagePath = "SKPhotoBrowser.bundle/images/\(imageName)"
#if SWIFT_PACKAGE
        return UIImage(named: imagePath, in: .module, compatibleWith: nil) ?? UIImage()
#else
        let bundle = Bundle(for: SKPhotoBrowser.self)
        return UIImage(named: imagePath, in: bundle, compatibleWith: nil) ?? UIImage()
#endif
    }
}
