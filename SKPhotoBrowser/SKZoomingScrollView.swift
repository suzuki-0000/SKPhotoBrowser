//
//  SKZoomingScrollView.swift
//  SKViewExample
//
//  Created by suzuki_keihsi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

public class SKZoomingScrollView:UIScrollView, UIScrollViewDelegate, SKDetectingViewDelegate, SKDetectingImageViewDelegate{
    
    weak var photoBrowser:SKPhotoBrowser!
    var photo:SKPhoto!{
        didSet{
            photoImageView.image = nil
            displayImage()
        }
    }
    
    var captionView:SKCaptionView!
    var tapView:SKDetectingView!
    var photoImageView:SKDetectingImageView!
    var indicatorView: SKIndicatorView!
    
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
        photoImageView.backgroundColor = UIColor.clearColor()
        addSubview(photoImageView)
        
        // indicator
        indicatorView = SKIndicatorView(frame: frame)
        addSubview(indicatorView)
        
        // self
        backgroundColor = UIColor.clearColor()
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    }
    
    // MARK: - override
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        tapView.frame = bounds
        
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
        if !CGRectEqualToRect(photoImageView.frame, frameToCenter){
            photoImageView.frame = frameToCenter
        }
    }
    
    public func setMaxMinZoomScalesForCurrentBounds(){
        
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        if photoImageView == nil {
            return
        }
        
        let boundsSize = bounds.size
        let imageSize = photoImageView.frame.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        var maxScale:CGFloat = 4.0
        let minScale:CGFloat = min(xScale, yScale)
        
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
        photoImageView.frame = CGRectMake(0, 0, photoImageView.frame.size.width, photoImageView.frame.size.height)
        setNeedsLayout()
    }
    
    public func prepareForReuse(){
        photo = nil
    }
    
    // MARK: - image
    public func displayImage(){
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSizeZero
        
        let image = photoBrowser.imageForPhoto(photo)
        if let image = image {
            
            // indicator
            indicatorView.stopAnimating()
            
            // image
            photoImageView.image = image

            var photoImageViewFrame = CGRectZero
            photoImageViewFrame.origin = CGPointZero
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
    
    public func displayImageFailure(){
        indicatorView.stopAnimating()
    }
    

    // MARK: - handle tap
    public func handleDoubleTap(touchPoint: CGPoint){
        NSObject.cancelPreviousPerformRequestsWithTarget(photoBrowser)
        
        if zoomScale > minimumZoomScale{
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // zoom in
            var newZoom:CGFloat = zoomScale * 2.0
            if newZoom >= maximumZoomScale {
                newZoom = maximumZoomScale
            }
            
            zoomToRect(zoomRectForScrollView(newZoom, touchPoint:touchPoint), animated:true)
        }
        
        // delay control
        photoBrowser.hideControlsAfterDelay()
    }
   
    public func zoomRectForScrollView(withScale:CGFloat, touchPoint:CGPoint) -> CGRect{
        return CGRectMake(touchPoint.x - (frame.size.width / 2.0),
                          touchPoint.y - (frame.size.height / 2.0),
                          frame.size.width, frame.size.height)
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
        // nothing to do
    }
    
    // MARK: - SKDetectingImageViewDelegate
    func handleImageViewSingleTap(view: UIImageView, touch: UITouch) {
        photoBrowser.toggleControls()
    }
    
    func handleImageViewDoubleTap(view: UIImageView, touch: UITouch) {
        handleDoubleTap(touch.locationInView(view))
    }
}