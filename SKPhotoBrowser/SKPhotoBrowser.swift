//
//  SKPhotoBrowser.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

public let SKPHOTO_LOADING_DID_END_NOTIFICATION = "photoLoadingDidEndNotification"

// MARK: - SKPhotoBrowser
public class SKPhotoBrowser: UIViewController {
    
    let pageIndexTagOffset: Int = 1000
    
    lazy var buttons: SKButtons = SKButtons(browser: self)
    lazy var toolbar: SKToolbar = SKToolbar(frame: self.frameForToolbarAtOrientation(), browser: self)
    
    // actions
    private var activityViewController: UIActivityViewController!
    private var panGesture: UIPanGestureRecognizer!
    
    // tool for controls
    private var applicationWindow: UIWindow!
    private var pagingScrollView: SKPagingScrollView!
    var backgroundView: UIView!
    
    private var closeButton: SKCloseButton {
        return buttons.closeButton
    }
    private var deleteButton: SKDeleteButton {
        return buttons.deleteButton
    }
    
    var initialPageIndex: Int = 0
    var currentPageIndex: Int = 0
    
    // for status check property
    private var isDraggingPhoto: Bool = false
    private var isEndAnimationByToolBar: Bool = true
    private var isViewActive: Bool = false
    private var isPerformingLayout: Bool = false
    
    // pangesture property
    private var firstX: CGFloat = 0.0
    private var firstY: CGFloat = 0.0
    
    // timer
    private var controlVisibilityTimer: NSTimer!
    
    // delegate
    private let animator = SKAnimator()
    public weak var delegate: SKPhotoBrowserDelegate?
    
    // helpers which often used
    private let bundle = NSBundle(forClass: SKPhotoBrowser.self)
    
    // photos
    var photos: [SKPhotoProtocol] = [SKPhotoProtocol]()
    var numberOfPhotos: Int {
        return photos.count
    }
    // MARK - Initializer
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    public convenience init(photos: [SKPhotoProtocol]) {
        self.init(nibName: nil, bundle: nil)
        let picutres = photos.flatMap { $0 }
        for photo in picutres {
            photo.checkCache()
            self.photos.append(photo)
        }
    }
    
    public convenience init(originImage: UIImage, photos: [SKPhotoProtocol], animatedFromView: UIView) {
        self.init(nibName: nil, bundle: nil)
        
        animator.senderOriginImage = originImage
        animator.senderViewForAnimation = animatedFromView
        
        let picutres = photos.flatMap { $0 }
        for photo in picutres {
            photo.checkCache()
            self.photos.append(photo)
        }
    }
    
    deinit {
        pagingScrollView = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setup() {
        guard let window = UIApplication.sharedApplication().delegate?.window else {
            return
        }
        applicationWindow = window
        
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleSKPhotoLoadingDidEndNotification(_:)), name: SKPHOTO_LOADING_DID_END_NOTIFICATION, object: nil)
    }
    
    // MARK: - override
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        
        toolbar.setup()
        buttons.setup()
        
        animator.willPresent(self)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        reloadData()
        
        var i = 0
        for photo: SKPhotoProtocol in photos {
            photo.index = i
            i = i + 1
        }
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        isPerformingLayout = true
        
        closeButton.updateFrame()
        deleteButton.updateFrame()
        
        // this algorithm resizes the current image after device rotation
        pagingScrollView.updateFrame(view.bounds)
        pagingScrollView.updateContentSize()
        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        // where did start
        delegate?.didShowPhotoAtIndex?(currentPageIndex)
        
        toolbar.frame = frameForToolbarAtOrientation()
        isPerformingLayout = false
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
    }
    
    // MARK: - Notification
    public func handleSKPhotoLoadingDidEndNotification(notification: NSNotification) {
        guard let photo = notification.object as? SKPhotoProtocol else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            guard let page = self.pagingScrollView.pageDisplayingAtPhoto(photo), let photo = page.photo else {
                return
            }
            
            if photo.underlyingImage != nil {
                page.displayImage(complete: true)
                self.loadAdjacentPhotosIfNecessary(photo)
            } else {
                page.displayImageFailure()
            }
        })
    }
    
    public func loadAdjacentPhotosIfNecessary(photo: SKPhotoProtocol) {
        guard let page = self.pagingScrollView.pageDisplayingAtPhoto(photo) else {
            return
        }
        let pageIndex = (page.tag - pageIndexTagOffset)
        if currentPageIndex == pageIndex {
            if pageIndex > 0 {
                // Preload index - 1
                let previousPhoto = photoAtIndex(pageIndex - 1)
                if previousPhoto.underlyingImage == nil {
                    previousPhoto.loadUnderlyingImageAndNotify()
                }
            }
            if pageIndex < numberOfPhotos - 1 {
                // Preload index + 1
                let nextPhoto = photoAtIndex(pageIndex + 1)
                if nextPhoto.underlyingImage == nil {
                    nextPhoto.loadUnderlyingImageAndNotify()
                }
            }
        }
    }
    
    // MARK: - initialize / setup
    public func reloadData() {
        performLayout()
        view.setNeedsLayout()
    }
    
    public func performLayout() {
        isPerformingLayout = true
        
        toolbar.updateToolbar(currentPageIndex)
        
        // reset local cache
        pagingScrollView.reload()
        
        // reframe
        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        pagingScrollView.tilePages()
        
        delegate?.didShowPhotoAtIndex?(currentPageIndex)
        
        isPerformingLayout = false
    }
    
    func showButtons() {
        if SKPhotoBrowserOptions.displayCloseButton {
            closeButton.alpha = 1
            closeButton.frame = closeButton.showFrame
        }
        if SKPhotoBrowserOptions.displayDeleteButton {
            deleteButton.alpha = 1
            deleteButton.frame = deleteButton.showFrame
        }
    }
    
    public func prepareForClosePhotoBrowser() {
        cancelControlHiding()
        applicationWindow.removeGestureRecognizer(panGesture)
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    // MARK: - frame calculation
    public func frameForToolbarAtOrientation() -> CGRect {
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        var height: CGFloat = navigationController?.navigationBar.frame.size.height ?? 44
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            height = 32
        }
        return CGRect(x: 0, y: view.bounds.size.height - height, width: view.bounds.size.width, height: height)
    }
    
    public func frameForToolbarHideAtOrientation() -> CGRect {
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        var height: CGFloat = navigationController?.navigationBar.frame.size.height ?? 44
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            height = 32
        }
        return CGRect(x: 0, y: view.bounds.size.height + height, width: view.bounds.size.width, height: height)
    }
    
    public func frameForPageAtIndex(index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
    
    public func contentOffsetForPageAtIndex(index: Int) -> CGPoint {
        let pageWidth = pagingScrollView.bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        return CGPoint(x: newOffset, y: 0)
    }
    
    private func setupAppearance() {
        view.backgroundColor = .blackColor()
        view.clipsToBounds = true
        view.opaque = false
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: SKMesurement.screenWidth, height: SKMesurement.screenHeight))
        backgroundView.backgroundColor = .blackColor()
        backgroundView.alpha = 0.0
        applicationWindow.addSubview(backgroundView)
        
        pagingScrollView = SKPagingScrollView(frame: view.frame, browser: self)
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SKPhotoBrowser.panGestureRecognized(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        if !SKPhotoBrowserOptions.disableVerticalSwipe {
            view.addGestureRecognizer(panGesture)
        }
    }
    
    private func deleteImage() {
        defer {
            reloadData()
        }
        
        if photos.count > 1 {
            pagingScrollView.deleteImage()
            
            photos.removeAtIndex(currentPageIndex)
            if currentPageIndex != 0 {
                gotoPreviousPage()
            }
            toolbar.updateToolbar(currentPageIndex)
            
        } else if photos.count == 1 {
            dismissPhotoBrowser(animated: false)
        }
    }
    
    // MARK: - panGestureRecognized
    public func panGestureRecognized(sender: UIPanGestureRecognizer) {
        guard let zoomingScrollView = pagingScrollView.pageDisplayedAtIndex(currentPageIndex) else {
            return
        }
        
        backgroundView.hidden = true
        
        let viewHeight = zoomingScrollView.frame.size.height
        let viewHalfHeight = viewHeight/2
        
        var translatedPoint = sender.translationInView(self.view)
        
        // gesture began
        if sender.state == .Began {
            
            firstX = zoomingScrollView.center.x
            firstY = zoomingScrollView.center.y
            
            isDraggingPhoto = true
            setControlsHidden(true, animated: true, permanent: false)
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        zoomingScrollView.center = translatedPoint
        
        let minOffset = viewHalfHeight / 4
        let offset = 1 - (zoomingScrollView.center.y > viewHalfHeight
            ? zoomingScrollView.center.y - viewHalfHeight
            : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight
        
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(max(0.7, offset))
        
        // gesture end
        if sender.state == .Ended {
            
            if zoomingScrollView.center.y > viewHalfHeight + minOffset
                || zoomingScrollView.center.y < viewHalfHeight - minOffset {
                
                backgroundView.backgroundColor = view.backgroundColor
                determineAndClose()
                
            } else {
                // Continue Showing View
                isDraggingPhoto = false
                setNeedsStatusBarAppearanceUpdate()
                
                let velocityY: CGFloat = CGFloat(0.35) * sender.velocityInView(self.view).y
                let finalX: CGFloat = firstX
                let finalY: CGFloat = viewHalfHeight
                
                let animationDuration = Double(abs(velocityY) * 0.0002 + 0.2)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                view.backgroundColor = UIColor.blackColor()
                zoomingScrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()
            }
        }
    }
    
    public func dismissPhotoBrowser(animated animated: Bool, completion: (Void -> Void)? = nil) {
        prepareForClosePhotoBrowser()
        
        if animated {
            dismissViewControllerAnimated(false) {
                completion?()
                self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
            }
        } else {
            modalTransitionStyle = .CrossDissolve
            dismissViewControllerAnimated(true) {
                completion?()
                self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
            }
        }
        
    }

    public func determineAndClose() {
        delegate?.willDismissAtPageIndex?(currentPageIndex)
        animator.willDismiss(self)
        
    }
    
    func getImageFromView(sender: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    // MARK: - paging
    public func initializePageIndex(index: Int) {
        var i = index
        if index >= numberOfPhotos {
            i = numberOfPhotos - 1
        }
        
        initialPageIndex = i
        currentPageIndex = i
        
        if isViewLoaded() {
            jumpToPageAtIndex(index)
            if !isViewActive {
                pagingScrollView.tilePages()
            }
        }
    }
    
    public func jumpToPageAtIndex(index: Int) {
        if index < numberOfPhotos {
            if !isEndAnimationByToolBar {
                return
            }
            isEndAnimationByToolBar = false
            let pageFrame = frameForPageAtIndex(index)
            pagingScrollView.updateContentOffset(pageFrame)
            toolbar.updateToolbar(currentPageIndex)
        }
        hideControlsAfterDelay()
    }
    
    public func photoAtIndex(index: Int) -> SKPhotoProtocol {
        return photos[index]
    }
    
    public func gotoPreviousPage() {
        jumpToPageAtIndex(currentPageIndex - 1)
    }
    
    public func gotoNextPage() {
        jumpToPageAtIndex(currentPageIndex + 1)
    }
    
    public func pageDisplayedAtIndex(index: Int) -> SKZoomingScrollView? {
        return pagingScrollView.pageDisplayedAtIndex(index)
    }
    
    public func pageDisplayingAtPhoto(photo: SKPhotoProtocol) -> SKZoomingScrollView? {
        return pagingScrollView.pageDisplayingAtPhoto(photo)
    }
    
    // MARK: - Control Hiding / Showing
    public func cancelControlHiding() {
        if controlVisibilityTimer != nil {
            controlVisibilityTimer.invalidate()
            controlVisibilityTimer = nil
        }
    }
    
    public func hideControlsAfterDelay() {
        // reset
        cancelControlHiding()
        // start
        controlVisibilityTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(SKPhotoBrowser.hideControls(_:)), userInfo: nil, repeats: false)
    }
    
    public func hideControls(timer: NSTimer) {
        setControlsHidden(true, animated: true, permanent: false)
    }
    
    public func toggleControls() {
        setControlsHidden(!areControlsHidden(), animated: true, permanent: false)
    }
    
    public func setControlsHidden(hidden: Bool, animated: Bool, permanent: Bool) {
        cancelControlHiding()
        
        let captionViews = pagingScrollView.getCaptionViews()
        
        UIView.animateWithDuration(0.35,
            animations: { () -> Void in
                let alpha: CGFloat = hidden ? 0.0 : 1.0
                self.toolbar.alpha = alpha
                self.toolbar.frame = hidden ? self.frameForToolbarHideAtOrientation() : self.frameForToolbarAtOrientation()
                if SKPhotoBrowserOptions.displayCloseButton {
                    self.closeButton.alpha = alpha
                    self.closeButton.frame = hidden ? self.closeButton.hideFrame : self.closeButton.showFrame
                }
                if SKPhotoBrowserOptions.displayDeleteButton {
                    self.deleteButton.alpha = alpha
                    self.deleteButton.frame = hidden ? self.deleteButton.hideFrame : self.deleteButton.showFrame
                }
                captionViews.forEach { $0.alpha = alpha }
            },
            completion: nil)
        
        if !permanent {
            hideControlsAfterDelay()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public func areControlsHidden() -> Bool {
        return toolbar.alpha == 0.0
    }
    
    // MARK: - Button
    @objc func deleteButtonPressed(sender: UIButton) {
        delegate?.removePhoto?(self, index: currentPageIndex) { [weak self] in
            self?.deleteImage()
        }
    }
    
    public func closeButtonPressed(sender: UIButton) {
        determineAndClose()
    }
    
    // MARK: Action Button
    public func actionButtonPressed() {
        let photo = photoAtIndex(currentPageIndex)
        
        delegate?.willShowActionSheet?(currentPageIndex)
        
        guard numberOfPhotos > 0 else {
            return
        }
        
        if let titles = SKPhotoBrowserOptions.actionButtonTitles {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            }))
            for idx in titles.indices {
                actionSheetController.addAction(UIAlertAction(title: titles[idx], style: .Default, handler: { (action) -> Void in
                    self.delegate?.didDismissActionSheetWithButtonIndex?(idx, photoIndex: self.currentPageIndex)
                }))
            }
            
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                presentViewController(actionSheetController, animated: true, completion: nil)
            } else {
                actionSheetController.modalPresentationStyle = .Popover
                
                if let popoverController = actionSheetController.popoverPresentationController {
					popoverController.sourceView = self.view
				    popoverController.barButtonItem = toolbar.toolActionButton
				}
            
                presentViewController(actionSheetController, animated: true, completion: { () -> Void in
                })
            }
        } else {
            guard let underlyingImage = photo.underlyingImage else {
                return
            }
            
            var activityItems: [AnyObject] = [underlyingImage]
            if photo.caption != nil {
                if let shareExtraCaption = SKPhotoBrowserOptions.shareExtraCaption {
                    activityItems.append(photo.caption + shareExtraCaption)
                } else {
                    activityItems.append(photo.caption)
                }
            }
            activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {
                (activity, success, items, error) in
                self.hideControlsAfterDelay()
                self.activityViewController = nil
            }
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                presentViewController(activityViewController, animated: true, completion: nil)
            } else {
                activityViewController.modalPresentationStyle = .Popover
                let popover: UIPopoverPresentationController! = activityViewController.popoverPresentationController
                popover.barButtonItem = toolbar.toolActionButton
                presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
  
}

// MARK: -  UIScrollView Delegate

extension SKPhotoBrowser: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        guard isViewActive else {
            return
        }
        guard !isPerformingLayout else {
            return
        }
        
        // tile page
        pagingScrollView.tilePages()
        
        // Calculate current page
        let visibleBounds = pagingScrollView.bounds
        var index = Int(floor(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)))
        
        if index < 0 {
            index = 0
        }
        if index > numberOfPhotos - 1 {
            index = numberOfPhotos
        }
        let previousCurrentPage = currentPageIndex
        currentPageIndex = index
        if currentPageIndex != previousCurrentPage {
            delegate?.didShowPhotoAtIndex?(currentPageIndex)
            toolbar.updateToolbar(currentPageIndex)
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        setControlsHidden(true, animated: true, permanent: false)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        hideControlsAfterDelay()
        
        let currentIndex = pagingScrollView.contentOffset.x / pagingScrollView.frame.size.width
        self.delegate?.didScrollToIndex?(Int(currentIndex))
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        isEndAnimationByToolBar = true
    }
}