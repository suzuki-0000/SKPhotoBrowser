//
//  SKAnimator.swift
//  SKPhotoBrowser
//
//  Created by keishi suzuki on 2016/08/09.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit


@objc public protocol SKPhotoBrowserAnimatorDelegate {
    func willPresent(_ browser: SKPhotoBrowser)
    func willDismiss(_ browser: SKPhotoBrowser)
}

class SKAnimator: NSObject, SKPhotoBrowserAnimatorDelegate {
    var resizableImageView: UIImageView?
    
    var senderOriginImage: UIImage!
    var senderViewOriginalFrame: CGRect = .zero
    var senderViewForAnimation: UIView?
    
    var finalImageViewFrame: CGRect = .zero
    
    var bounceAnimation: Bool = false
    var animationDuration: TimeInterval {
        if SKPhotoBrowserOptions.bounceAnimation {
            return 0.5
        }
        return 0.35
    }
    var animationDamping: CGFloat {
        if SKPhotoBrowserOptions.bounceAnimation {
            return 0.8
        }
        return 1
    }
    
    func willPresent(_ browser: SKPhotoBrowser) {
        guard let appWindow = UIApplication.shared.delegate?.window else {
            return
        }
        guard let window = appWindow else {
            return
        }
        guard let sender = browser.delegate?.viewForPhoto?(browser, index: browser.initialPageIndex) ?? senderViewForAnimation else {
            presentAnimation(browser)
            return
        }
        
        let photo = browser.photoAtIndex(browser.currentPageIndex)
        let imageFromView = (senderOriginImage ?? browser.getImageFromView(sender)).rotateImageByOrientation()
        let imageRatio = imageFromView.size.width / imageFromView.size.height
        
        senderViewOriginalFrame = calcOriginFrame(sender)
        finalImageViewFrame = calcFinalFrame(imageRatio)
        
        resizableImageView = UIImageView(image: imageFromView)
        resizableImageView!.frame = senderViewOriginalFrame
        resizableImageView!.clipsToBounds = true
        resizableImageView!.contentMode = photo.contentMode
        if sender.layer.cornerRadius != 0 {
            let duration = (animationDuration * Double(animationDamping))
            resizableImageView!.layer.masksToBounds = true
            resizableImageView!.addCornerRadiusAnimation(sender.layer.cornerRadius, to: 0, duration: duration)
        }
        window.addSubview(resizableImageView!)
        
        presentAnimation(browser)
    }
    
    func willDismiss(_ browser: SKPhotoBrowser) {
        guard let sender = browser.delegate?.viewForPhoto?(browser, index: browser.currentPageIndex),
            let image = browser.photoAtIndex(browser.currentPageIndex).underlyingImage,
            let scrollView = browser.pageDisplayedAtIndex(browser.currentPageIndex) else {
                
            senderViewForAnimation?.isHidden = false
            browser.dismissPhotoBrowser(animated: false)
            return
        }
        
        senderViewForAnimation = sender
        browser.view.isHidden = true
        browser.backgroundView.isHidden = false
        browser.backgroundView.alpha = 1
        
        senderViewOriginalFrame = calcOriginFrame(sender)
        
        let photo = browser.photoAtIndex(browser.currentPageIndex)
        let contentOffset = scrollView.contentOffset
        let scrollFrame = scrollView.photoImageView.frame
        let offsetY = scrollView.center.y - (scrollView.bounds.height/2)
        let frame = CGRect(
            x: scrollFrame.origin.x - contentOffset.x,
            y: scrollFrame.origin.y + contentOffset.y + offsetY,
            width: scrollFrame.width,
            height: scrollFrame.height)
        
//        resizableImageView.image = scrollView.photo?.underlyingImage?.rotateImageByOrientation()
        resizableImageView!.image = image.rotateImageByOrientation()
        resizableImageView!.frame = frame
        resizableImageView!.alpha = 1.0
        resizableImageView!.clipsToBounds = true
        resizableImageView!.contentMode = photo.contentMode
        if let view = senderViewForAnimation , view.layer.cornerRadius != 0 {
            let duration = (animationDuration * Double(animationDamping))
            resizableImageView!.layer.masksToBounds = true
            resizableImageView!.addCornerRadiusAnimation(0, to: view.layer.cornerRadius, duration: duration)
        }
        
        dismissAnimation(browser)
    }
}

private extension SKAnimator {
    func calcOriginFrame(_ sender: UIView) -> CGRect {
        if let senderViewOriginalFrameTemp = sender.superview?.convert(sender.frame, to:nil) {
            return senderViewOriginalFrameTemp
        } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convert(sender.frame, to: nil) {
            return senderViewOriginalFrameTemp
        } else {
            return .zero
        }
    }
    
    func calcFinalFrame(_ imageRatio: CGFloat) -> CGRect {
        if SKMesurement.screenRatio < imageRatio {
            let width = SKMesurement.screenWidth
            let height = width / imageRatio
            let yOffset = (SKMesurement.screenHeight - height) / 2
            return CGRect(x: 0, y: yOffset, width: width, height: height)
        } else {
            let height = SKMesurement.screenHeight
            let width = height * imageRatio
            let xOffset = (SKMesurement.screenWidth - width) / 2
            return CGRect(x: xOffset, y: 0, width: width, height: height)
        }
    }
}

private extension SKAnimator {
    func presentAnimation(_ browser: SKPhotoBrowser, completion: ((Void) -> Void)? = nil) {
        browser.view.isHidden = true
        browser.view.alpha = 0.0
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping:animationDamping,
            initialSpringVelocity:0,
            options:UIViewAnimationOptions(),
            animations: {
                browser.showButtons()
                browser.backgroundView.alpha = 1.0
                
                self.resizableImageView?.frame = self.finalImageViewFrame
            },
            completion: { (Bool) -> Void in
                browser.view.isHidden = false
                browser.view.alpha = 1.0
                browser.backgroundView.isHidden = true
                
                self.resizableImageView?.alpha = 0.0
            })
    }
    
    func dismissAnimation(_ browser: SKPhotoBrowser, completion: ((Void) -> Void)? = nil) {
        UIView.animate(
            withDuration: animationDuration,
            delay:0,
            usingSpringWithDamping:animationDamping,
            initialSpringVelocity:0,
            options:UIViewAnimationOptions(),
            animations: {
                browser.backgroundView.alpha = 0.0
                
                self.resizableImageView?.layer.frame = self.senderViewOriginalFrame
            },
            completion: { (Bool) -> () in
                browser.dismissPhotoBrowser(animated: true) {
                    self.resizableImageView?.removeFromSuperview()
                }
            })
    }
}

