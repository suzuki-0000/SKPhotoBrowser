//
//  SKAnimator.swift
//  SKPhotoBrowser
//
//  Created by keishi suzuki on 2016/08/09.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit


@objc public protocol SKPhotoBrowserAnimatorDelegate {
    func willPresent(browser: SKPhotoBrowser)
    func willDismiss(browser: SKPhotoBrowser)
}

class SKAnimator: NSObject, SKPhotoBrowserAnimatorDelegate {
    var resizableImageView: UIImageView?
    
    var senderOriginImage: UIImage!
    var senderViewOriginalFrame: CGRect = .zero
    var senderViewForAnimation: UIView?
    
    var finalImageViewFrame: CGRect = .zero
    
    var bounceAnimation: Bool = false
    var animationDuration: NSTimeInterval {
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
    
    func willPresent(browser: SKPhotoBrowser) {
        guard let appWindow = UIApplication.sharedApplication().delegate?.window else {
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
    
    func willDismiss(browser: SKPhotoBrowser) {
        guard let sender = browser.delegate?.viewForPhoto?(browser, index: browser.currentPageIndex),
            image = browser.photoAtIndex(browser.currentPageIndex).underlyingImage,
            scrollView = browser.pageDisplayedAtIndex(browser.currentPageIndex) else {
                
            senderViewForAnimation?.hidden = false
            browser.dismissPhotoBrowser(animated: false)
            return
        }
        
        senderViewForAnimation = sender
        browser.view.hidden = true
        browser.backgroundView.hidden = false
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
        if let view = senderViewForAnimation where view.layer.cornerRadius != 0 {
            let duration = (animationDuration * Double(animationDamping))
            resizableImageView!.layer.masksToBounds = true
            resizableImageView!.addCornerRadiusAnimation(0, to: view.layer.cornerRadius, duration: duration)
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
            animations: {
                browser.showButtons()
                browser.backgroundView.alpha = 1.0
                
                self.resizableImageView?.frame = self.finalImageViewFrame
            },
            completion: { (Bool) -> Void in
                UIApplication.sharedApplication().setStatusBarHidden(!SKPhotoBrowserOptions.displayStatusbar, withAnimation: .Fade)
                
                browser.view.hidden = false
                browser.view.alpha = 1.0
                browser.backgroundView.hidden = true
                
                self.resizableImageView?.alpha = 0.0
            })
    }
    
    func dismissAnimation(browser: SKPhotoBrowser, completion: (Void -> Void)? = nil) {
        UIView.animateWithDuration(
            animationDuration,
            delay:0,
            usingSpringWithDamping:animationDamping,
            initialSpringVelocity:0,
            options:.CurveEaseInOut,
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

