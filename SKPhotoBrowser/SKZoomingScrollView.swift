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
            displayImage()
        }
    }
    
    private weak var photoBrowser: SKPhotoBrowser!
    private var tapView: SKDetectingView!
    private var photoImageView: SKDetectingImageView!
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
        var maxScale: CGFloat = 4.0
        
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
    }
    
    // MARK: - image
    public func displayImage() {
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSize.zero
        
        let image = photoBrowser.imageForPhoto(photo)
        if let image = image {
            
            // indicator
            indicatorView.stopAnimating()
            
            // image
            photoImageView.image = image

            var photoImageViewFrame = CGRect.zero
            photoImageViewFrame.origin = CGPoint.zero
            photoImageViewFrame.size = image.size
            
            photoImageView.frame = photoImageViewFrame
            
            contentSize = photoImageViewFrame.size
            
            setMaxMinZoomScalesForCurrentBounds()
        } else {
            // indicator 
            indicatorView.startAnimating()
        }
        
        setNeedsLayout()
    }
    
    public func displayImageFailure() {
        indicatorView.stopAnimating()
    }
    

    // MARK: - handle tap
    public func handleDoubleTap(touchPoint: CGPoint) {
        NSObject.cancelPreviousPerformRequestsWithTarget(photoBrowser)
        
        if zoomScale > minimumZoomScale {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // zoom in
            var newZoom: CGFloat = zoomScale * 2.0
            if newZoom >= maximumZoomScale {
                newZoom = maximumZoomScale
            }
            
            zoomToRect(zoomRectForScrollViewWith(newZoom, touchPoint:touchPoint), animated:true)
        }
        
        // delay control
        photoBrowser.hideControlsAfterDelay()
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
        photoBrowser.cancelControlHiding()
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    
    // MARK: - SKDetectingViewDelegate
    func handleSingleTap(view: UIView, touch: UITouch) {
        photoBrowser.toggleControls()
    }
    
    func handleDoubleTap(view: UIView, touch: UITouch) {
        let needPoint = getViewFramePercent(view, touch: touch)
        handleDoubleTap(needPoint)
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
        photoBrowser.toggleControls()
    }
    
    func handleImageViewDoubleTap(view: UIImageView, touch: UITouch) {
        handleDoubleTap(touch.locationInView(view))
    }
}