//
//  SKZoomingScrollView.swift
//  SKViewExample
//
//  Created by suzuki_keihsi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

public class SKZoomingScrollView: UIScrollView, UIScrollViewDelegate, SKDetectingViewDelegate, SKDetectingImageViewDelegate {
    
    var captionView: SKCaptionView!
    var photo: SKPhotoProtocol! {
        didSet {
            photoImageView.image = nil
            if photo != nil {
                displayImage(complete: false)
            }
        }
    }
    
    private(set) var photoImageView: SKDetectingImageView!
    private weak var photoBrowser: SKPhotoBrowser?
    private var tapView: SKDetectingView!
    private var indicatorView: SKIndicatorView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        photoBrowser = browser
        setup()
    }
    
    deinit {
        photoBrowser = nil
    }
    
    func setup() {
        // tap
        tapView = SKDetectingView(frame: bounds)
        tapView.delegate = self
        tapView.backgroundColor = UIColor.clearColor()
        tapView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addSubview(tapView)
        
        // image
        photoImageView = SKDetectingImageView(frame: frame)
        photoImageView.delegate = self
        photoImageView.contentMode = .ScaleAspectFill
        photoImageView.backgroundColor = .clearColor()
        addSubview(photoImageView)
        
        // indicator
        indicatorView = SKIndicatorView(frame: frame)
        addSubview(indicatorView)
        
        // self
        backgroundColor = .clearColor()
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleRightMargin, .FlexibleLeftMargin]
    }
    
    // MARK: - override
    public override func layoutSubviews() {
        tapView.frame = bounds
        
        super.layoutSubviews()
        
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame
        
        // horizon
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2)
        } else {
            frameToCenter.origin.x = 0
        }
        // vertical
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if !CGRectEqualToRect(photoImageView.frame, frameToCenter) {
            photoImageView.frame = frameToCenter
        }
    }
    
    public func setMaxMinZoomScalesForCurrentBounds() {
        
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        guard let photoImageView = photoImageView else {
            return
        }
        
        let boundsSize = bounds.size
        let imageSize = photoImageView.frame.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale: CGFloat = min(xScale, yScale)
        var maxScale: CGFloat!
        
        let deviceScreenWidth = UIScreen.mainScreen().bounds.width
        
        if photoImageView.frame.width < deviceScreenWidth {
            if deviceScreenWidth / 2 > photoImageView.frame.width {
                maxScale = 3.0
            } else {
                maxScale = 2.0
            }
        } else {
            maxScale = 1.0
        }
        
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        zoomScale = minScale
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5
        maxScale = maxScale / UIScreen.mainScreen().scale
        if maxScale < minScale {
            maxScale = minScale * 2
        }
        
        // reset position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.height)
        setNeedsLayout()
    }
    
    public func prepareForReuse() {
        photo = nil
        if captionView != nil {
            captionView.removeFromSuperview()
            captionView = nil 
        }
    }
    
    // MARK: - image 显示图片
    public func displayImage(complete flag: Bool) {
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSize.zero
        
        if !flag {
            indicatorView.startAnimating()
            photo.loadUnderlyingImageAndNotify()
        }else {
            indicatorView.stopAnimating()
        }
        
        if let image = photo.underlyingImage {

            // image
            photoImageView.image = image
            
            var photoImageViewFrame = CGRect.zero
            photoImageViewFrame.origin = CGPoint.zero
            photoImageViewFrame.size = image.size
            
            photoImageView.frame = photoImageViewFrame
            
            contentSize = photoImageViewFrame.size
            
            setMaxMinZoomScalesForCurrentBounds()
        }
        
        setNeedsLayout()
    }
    
    public func displayImageFailure() {
        indicatorView.stopAnimating()
    }
    
    // MARK: - handle tap
    public func handleDoubleTap(touchPoint: CGPoint) {
        if let photoBrowser = photoBrowser {
            NSObject.cancelPreviousPerformRequestsWithTarget(photoBrowser)
        }
        
        if zoomScale > minimumZoomScale {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // zoom in
            var newZoom: CGFloat = zoomScale * 3.13
            if newZoom >= maximumZoomScale {
                newZoom = maximumZoomScale
            }
            
            zoomToRect(zoomRectForScrollViewWith(newZoom, touchPoint:touchPoint), animated:true)
        }
        
        // delay control
        photoBrowser?.hideControlsAfterDelay()
    }
    
    public func zoomRectForScrollViewWith(scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = frame.size.width / scale
        let h = frame.size.height / scale
        let x = touchPoint.x - (w / 2.0)
        let y = touchPoint.y - (h / 2.0)
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    // MARK: - UIScrollViewDelegate
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        photoBrowser?.cancelControlHiding()
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    
    // MARK: - SKDetectingViewDelegate
    func handleSingleTap(view: UIView, touch: UITouch) {
        if photoBrowser?.enableZoomBlackArea == true {
            photoBrowser?.toggleControls()
        }
    }
    
    func handleDoubleTap(view: UIView, touch: UITouch) {
        if photoBrowser?.enableZoomBlackArea == true {
            let needPoint = getViewFramePercent(view, touch: touch)
            handleDoubleTap(needPoint)
        }
    }
    
    private func getViewFramePercent(view: UIView, touch: UITouch) -> CGPoint {
        let oneWidthViewPercent = view.bounds.width / 100
        let viewTouchPoint = touch.locationInView(view)
        let viewWidthTouch = viewTouchPoint.x
        let viewPercentTouch = viewWidthTouch / oneWidthViewPercent
        
        let photoWidth = photoImageView.bounds.width
        let onePhotoPercent = photoWidth / 100
        let needPoint = viewPercentTouch * onePhotoPercent
        
        var Y: CGFloat!
        
        if viewTouchPoint.y < view.bounds.height / 2 {
            Y = 0
        } else {
            Y = photoImageView.bounds.height
        }
        let allPoint = CGPoint(x: needPoint, y: Y)
        return allPoint
    }
    
    // MARK: - SKDetectingImageViewDelegate
    func handleImageViewSingleTap(view: UIImageView, touch: UITouch) {
        photoBrowser?.toggleControls()
    }
    
    func handleImageViewDoubleTap(view: UIImageView, touch: UITouch) {
        handleDoubleTap(touch.locationInView(view))
    }
}