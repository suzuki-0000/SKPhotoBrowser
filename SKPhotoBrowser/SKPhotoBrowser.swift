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
    
    private var closeButton: SKCloseButton!
    private var deleteButton: SKDeleteButton!
    private var toolbar: SKToolbar!
    
    // actions
    private var activityViewController: UIActivityViewController!
    private var panGesture: UIPanGestureRecognizer!
    
    // tool for controls
    private var applicationWindow: UIWindow!
    private lazy var pagingScrollView: SKPagingScrollView = SKPagingScrollView(frame: self.view.frame, browser: self)
    var backgroundView: UIView!
    
    var initialPageIndex: Int = 0
    var currentPageIndex: Int = 0
    
    // for status check property
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
    
    // photos
    var photos: [SKPhotoProtocol] = [SKPhotoProtocol]()
    var numberOfPhotos: Int {
        return photos.count
    }
    
    // statusbar initial state
    private var statusbarHidden: Bool = UIApplication.sharedApplication().statusBarHidden
    
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
        
        configureAppearance()
        configureCloseButton()
        configureDeleteButton()
        configureToolbar()
        
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
        pagingScrollView.updateFrame(view.bounds, currentPageIndex: currentPageIndex)
        
        toolbar.frame = frameForToolbarAtOrientation()
        
        // where did start
        delegate?.didShowPhotoAtIndex?(currentPageIndex)
        
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
            guard let page = self.pagingScrollView.pageDisplayingAtPhoto(photo), photo = page.photo else {
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
        pagingScrollView.loadAdjacentPhotosIfNecessary(photo, currentPageIndex: currentPageIndex)
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
        pagingScrollView.updateContentOffset(currentPageIndex)
        pagingScrollView.tilePages()
        
        delegate?.didShowPhotoAtIndex?(currentPageIndex)
        
        isPerformingLayout = false
    }
    
    public func prepareForClosePhotoBrowser() {
        UIApplication.sharedApplication().setStatusBarHidden(statusbarHidden, withAnimation: .None)
        cancelControlHiding()
        applicationWindow.removeGestureRecognizer(panGesture)
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    public func dismissPhotoBrowser(animated animated: Bool, completion: (Void -> Void)? = nil) {
        prepareForClosePhotoBrowser()

        if !animated {
            modalTransitionStyle = .CrossDissolve
        }
        
        dismissViewControllerAnimated(!animated) {
            completion?()
            self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
        }
    }

    public func determineAndClose() {
        delegate?.willDismissAtPageIndex?(currentPageIndex)
        animator.willDismiss(self)
    }
}

// MARK: - Public Function For Customizing Buttons

public extension SKPhotoBrowser {
  func updateCloseButton(image: UIImage, size: CGSize? = nil) {
        if closeButton == nil {
            configureCloseButton()
        }
        closeButton.setImage(image, forState: .Normal)
    
        if let size = size {
            closeButton.setFrameSize(size)
        }
    }
  
  func updateDeleteButton(image: UIImage, size: CGSize? = nil) {
        if deleteButton == nil {
            configureDeleteButton()
        }
        deleteButton.setImage(image, forState: .Normal)
    
        if let size = size {
            deleteButton.setFrameSize(size)
        }
    }
}

// MARK: - Public Function For Browser Control

public extension SKPhotoBrowser {
    func initializePageIndex(index: Int) {
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
    
    func jumpToPageAtIndex(index: Int) {
        if index < numberOfPhotos {
            if !isEndAnimationByToolBar {
                return
            }
            isEndAnimationByToolBar = false
            toolbar.updateToolbar(currentPageIndex)
            
            let pageFrame = frameForPageAtIndex(index)
            pagingScrollView.animate(pageFrame)
        }
        hideControlsAfterDelay()
    }
    
    func photoAtIndex(index: Int) -> SKPhotoProtocol {
        return photos[index]
    }
    
    func gotoPreviousPage() {
        jumpToPageAtIndex(currentPageIndex - 1)
    }
    
    func gotoNextPage() {
        jumpToPageAtIndex(currentPageIndex + 1)
    }
    
    func cancelControlHiding() {
        if controlVisibilityTimer != nil {
            controlVisibilityTimer.invalidate()
            controlVisibilityTimer = nil
        }
    }
    
    func hideControlsAfterDelay() {
        // reset
        cancelControlHiding()
        // start
        controlVisibilityTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(SKPhotoBrowser.hideControls(_:)), userInfo: nil, repeats: false)
    }
    
    func hideControls() {
        setControlsHidden(true, animated: true, permanent: false)
    }
    
    func hideControls(timer: NSTimer) {
        hideControls()
    }
    
    func toggleControls() {
        setControlsHidden(!areControlsHidden(), animated: true, permanent: false)
    }
    
    func areControlsHidden() -> Bool {
        return toolbar.alpha == 0.0
    }
    
    func popupShare(includeCaption includeCaption: Bool = true) {
        let photo = photos[currentPageIndex]
        guard let underlyingImage = photo.underlyingImage else {
            return
        }
        
        var activityItems: [AnyObject] = [underlyingImage]
        if photo.caption != nil && includeCaption {
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


// MARK: - Internal Function

internal extension SKPhotoBrowser {
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
    
    func pageDisplayedAtIndex(index: Int) -> SKZoomingScrollView? {
        return pagingScrollView.pageDisplayedAtIndex(index)
    }
    
    func getImageFromView(sender: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

// MARK: - Internal Function For Frame Calc

internal extension SKPhotoBrowser {
    func frameForToolbarAtOrientation() -> CGRect {
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        var height: CGFloat = navigationController?.navigationBar.frame.size.height ?? 44
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            height = 32
        }
        return CGRect(x: 0, y: view.bounds.size.height - height, width: view.bounds.size.width, height: height)
    }
    
    func frameForToolbarHideAtOrientation() -> CGRect {
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        var height: CGFloat = navigationController?.navigationBar.frame.size.height ?? 44
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            height = 32
        }
        return CGRect(x: 0, y: view.bounds.size.height + height, width: view.bounds.size.width, height: height)
    }
    
    func frameForPageAtIndex(index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
}

// MARK: - Internal Function For Button Pressed, UIGesture Control

internal extension SKPhotoBrowser {
    func panGestureRecognized(sender: UIPanGestureRecognizer) {
        guard let zoomingScrollView: SKZoomingScrollView = pagingScrollView.pageDisplayedAtIndex(currentPageIndex) else {
            return
        }
        
        backgroundView.hidden = true
        
        let viewHeight: CGFloat = zoomingScrollView.frame.size.height
        let viewHalfHeight: CGFloat = viewHeight/2
        var translatedPoint: CGPoint = sender.translationInView(self.view)
        
        // gesture began
        if sender.state == .Began {
            firstX = zoomingScrollView.center.x
            firstY = zoomingScrollView.center.y
            
            hideControls()
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        zoomingScrollView.center = translatedPoint
        
        let minOffset: CGFloat = viewHalfHeight / 4
        let offset: CGFloat = 1 - (zoomingScrollView.center.y > viewHalfHeight
            ? zoomingScrollView.center.y - viewHalfHeight
            : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight
        
        view.backgroundColor = SKPhotoBrowserOptions.backgroundColor.colorWithAlphaComponent(max(0.7, offset))
        
        // gesture end
        if sender.state == .Ended {
            
            if zoomingScrollView.center.y > viewHalfHeight + minOffset
                || zoomingScrollView.center.y < viewHalfHeight - minOffset {
                
                backgroundView.backgroundColor = view.backgroundColor
                determineAndClose()
                
            } else {
                // Continue Showing View
                setNeedsStatusBarAppearanceUpdate()
                
                let velocityY: CGFloat = CGFloat(0.35) * sender.velocityInView(self.view).y
                let finalX: CGFloat = firstX
                let finalY: CGFloat = viewHalfHeight
                
                let animationDuration: Double = Double(abs(velocityY) * 0.0002 + 0.2)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                view.backgroundColor = SKPhotoBrowserOptions.backgroundColor
                zoomingScrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()
            }
        }
    }
    
    func deleteButtonPressed(sender: UIButton) {
        delegate?.removePhoto?(self, index: currentPageIndex) { [weak self] in
            self?.deleteImage()
        }
    }
    
    func closeButtonPressed(sender: UIButton) {
        determineAndClose()
    }
    
    func actionButtonPressed(ignoreAndShare ignoreAndShare: Bool) {
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
            popupShare()
        }
    }
}

// MARK: - Private Function 
private extension SKPhotoBrowser {
    func configureAppearance() {
        view.backgroundColor = SKPhotoBrowserOptions.backgroundColor
        view.clipsToBounds = true
        view.opaque = false
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: SKMesurement.screenWidth, height: SKMesurement.screenHeight))
        backgroundView.backgroundColor = SKPhotoBrowserOptions.backgroundColor
        backgroundView.alpha = 0.0
        applicationWindow.addSubview(backgroundView)
        
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SKPhotoBrowser.panGestureRecognized(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        if !SKPhotoBrowserOptions.disableVerticalSwipe {
            view.addGestureRecognizer(panGesture)
        }
    }
    
    func configureCloseButton() {
        closeButton = SKCloseButton(frame: .zero)
        closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        closeButton.hidden = !SKPhotoBrowserOptions.displayCloseButton
        view.addSubview(closeButton)
    }
    
    func configureDeleteButton() {
        deleteButton = SKDeleteButton(frame: .zero)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        deleteButton.hidden = !SKPhotoBrowserOptions.displayDeleteButton
        view.addSubview(deleteButton)
    }
    
    func configureToolbar() {
        toolbar = SKToolbar(frame: frameForToolbarAtOrientation(), browser: self)
        view.addSubview(toolbar)
    }
    
    func setControlsHidden(hidden: Bool, animated: Bool, permanent: Bool) {
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
        let previousCurrentPage = currentPageIndex
        let visibleBounds = pagingScrollView.bounds
        currentPageIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), numberOfPhotos - 1)
        
        if currentPageIndex != previousCurrentPage {
            delegate?.didShowPhotoAtIndex?(currentPageIndex)
            toolbar.updateToolbar(currentPageIndex)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        hideControlsAfterDelay()
        
        let currentIndex = pagingScrollView.contentOffset.x / pagingScrollView.frame.size.width
        delegate?.didScrollToIndex?(Int(currentIndex))
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        isEndAnimationByToolBar = true
    }
}
