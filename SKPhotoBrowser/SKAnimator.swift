//
//  SKAnimator.swift
//  SKPhotoBrowser
//
//  Created by keishi suzuki on 2016/08/09.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

class SKAnimator: NSObject, SKPhotoBrowserAnimatorDelegate {
    var senderViewOriginalFrame: CGRect = .zero
    var finalImageViewFrame: CGRect = .zero
    var bounceAnimation: Bool = false
    // animation property
    var animationDuration: NSTimeInterval {
        if bounceAnimation {
            return 0.5
        }
        return 0.35
    }
    var animationDamping: CGFloat {
        if bounceAnimation {
            return 0.8
        }
        return 1
    }
    
    func willPresent(browser: SKPhotoBrowser) {
        bounceAnimation = browser.bounceAnimation
        
        guard let appWindow = UIApplication.sharedApplication().delegate?.window else {
            return
        }
        guard let window = appWindow else {
            return
        }
        guard let sender = browser.delegate?.viewForPhoto?(browser, index: browser.initialPageIndex) ?? browser.senderViewForAnimation else {
            presentAnimation(browser)
            return
        }
        
        
        let imageFromView = (browser.senderOriginImage ?? browser.getImageFromView(sender)).rotateImageByOrientation()
        let imageRatio = imageFromView.size.width / imageFromView.size.height
        
        senderViewOriginalFrame = calcOriginFrame(sender)
        
        browser.resizableImageView = UIImageView(image: imageFromView)
        browser.resizableImageView.frame = senderViewOriginalFrame
        browser.resizableImageView.clipsToBounds = true
        browser.resizableImageView.contentMode = .ScaleAspectFill
        window.addSubview(browser.resizableImageView)
        
        finalImageViewFrame = calcFinalFrame(imageRatio)
        
        if sender.layer.cornerRadius != 0 {
            let duration = (animationDuration * Double(animationDamping))
            browser.resizableImageView.layer.masksToBounds = true
            browser.resizableImageView.addCornerRadiusAnimation(sender.layer.cornerRadius, to: 0, duration: duration)
        }
        
        presentAnimation(browser)
    }
    
    func willDismiss(browser: SKPhotoBrowser) {
        guard let appWindow = UIApplication.sharedApplication().delegate?.window else {
            return
        }
        guard let window = appWindow else {
            return
        }
        
        browser.view.hidden = true
        browser.backgroundView.hidden = false
        browser.backgroundView.alpha = 1
        
        browser.statusBarStyle = browser.isStatusBarOriginallyHidden ? nil : browser.originalStatusBarStyle
        browser.setNeedsStatusBarAppearanceUpdate()
        
        if let sender = browser.senderViewForAnimation {
            if let senderViewOriginalFrameTemp = sender.superview?.convertRect(sender.frame, toView:nil) {
                senderViewOriginalFrame = senderViewOriginalFrameTemp
            } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convertRect(sender.frame, toLayer: nil) {
                senderViewOriginalFrame = senderViewOriginalFrameTemp
            }
        }
        
        let scrollView = browser.pageDisplayedAtIndex(browser.currentPageIndex)
        let contentOffset = scrollView.contentOffset
        let scrollFrame = scrollView.photoImageView.frame
        let offsetY = scrollView.center.y - (scrollView.bounds.height/2)
        
        let frame = CGRect(
            x: scrollFrame.origin.x - contentOffset.x,
            y: scrollFrame.origin.y + contentOffset.y + offsetY,
            width: scrollFrame.width,
            height: scrollFrame.height)
        
        browser.resizableImageView.image = scrollView.photo?.underlyingImage?.rotateImageByOrientation() ?? browser.resizableImageView.image
        browser.resizableImageView.frame = frame
        browser.resizableImageView.alpha = 1.0
        browser.resizableImageView.clipsToBounds = true
        browser.resizableImageView.contentMode = .ScaleAspectFill
        window.addSubview(browser.resizableImageView)
        
        if let view = browser.senderViewForAnimation where view.layer.cornerRadius != 0 {
            let duration = (animationDuration * Double(animationDamping))
            browser.resizableImageView.layer.masksToBounds = true
            browser.resizableImageView.addCornerRadiusAnimation(0, to: view.layer.cornerRadius, duration: duration)
        }
        
        dismissAnimation(browser)
    }
}

private extension SKAnimator {
    func calcOriginFrame(sender: UIView) -> CGRect {
        if let senderViewOriginalFrameTemp = sender.superview?.convertRect(sender.frame, toView:nil) {
            return senderViewOriginalFrameTemp
        } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convertRect(sender.frame, toLayer: nil) {
            return senderViewOriginalFrameTemp
        } else {
            return .zero
        }
    }
    
    func calcFinalFrame(imageRatio: CGFloat) -> CGRect {
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
    func presentAnimation(browser: SKPhotoBrowser, completion: (Void -> Void)? = nil) {
        browser.view.hidden = true
        browser.view.alpha = 0.0
        
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            usingSpringWithDamping:animationDamping,
            initialSpringVelocity:0,
            options:.CurveEaseInOut,
            animations: { () -> Void in
                browser.showButtons()
                browser.backgroundView.alpha = 1.0
                browser.resizableImageView.frame = self.finalImageViewFrame
            },
            completion: { (Bool) -> Void in
                browser.view.hidden = false
                browser.pagingScrollView.alpha = 1.0
                browser.backgroundView.hidden = true
                browser.resizableImageView.alpha = 0.0
            })
    }
    
    func dismissAnimation(browser: SKPhotoBrowser, completion: (Void -> Void)? = nil) {
        UIView.animateWithDuration(
            animationDuration,
            delay:0,
            usingSpringWithDamping:animationDamping,
            initialSpringVelocity:0,
            options:.CurveEaseInOut,
            animations: { () -> () in
                browser.backgroundView.alpha = 0.0
                browser.resizableImageView.layer.frame = self.senderViewOriginalFrame
                },
            completion: { (Bool) -> () in
                browser.resizableImageView.removeFromSuperview()
                browser.backgroundView.removeFromSuperview()
                browser.dismissPhotoBrowser()
            })
    }
}




