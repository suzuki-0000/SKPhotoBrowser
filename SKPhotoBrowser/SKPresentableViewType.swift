//
//  SKPresentableViewType.swift
//  SKPhotoBrowser
//
//  Created by Елизаров Владимир Алексеевич on 05/06/2019.
//

import Foundation


typealias BasePresentableView = PresentableViewType

protocol PresentableViewType: UIView {
    
    var captionView: SKCaptionView! { get set }
    
    var photo: SKPhotoProtocol! { get set }
    
    var contentOffset: CGPoint { get }
    
    var imageFrame: CGRect { get }
    
    var presentableType: MediaType { get }
    
    func setMaxMinZoomScalesForCurrentBounds()
    
    func prepareForReuse()
    
    func displayImage(_ image: UIImage)
    
    func displayImageFailure()
    
    func displayImage(complete flag: Bool)
}

