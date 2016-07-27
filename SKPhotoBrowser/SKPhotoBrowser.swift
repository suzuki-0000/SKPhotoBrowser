//
//  SKPhotoBrowser.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

@objc public protocol SKPhotoBrowserDelegate {
    
    /**
     Tells the delegate that the browser started displaying a new photo
     
     - Parameter index: the index of the new photo
     */
    optional func didShowPhotoAtIndex(index: Int)
    
    /**
     Tells the delegate the browser will start to dismiss
     
     - Parameter index: the index of the current photo
     */
    optional func willDismissAtPageIndex(index: Int)
    
    /**
     Tells the delegate that the browser will start showing the `UIActionSheet`
     
     - Parameter photoIndex: the index of the current photo
     */
    optional func willShowActionSheet(photoIndex: Int)
    
    /**
     Tells the delegate that the browser has been dismissed
     
     - Parameter index: the index of the current photo
     */
    optional func didDismissAtPageIndex(index: Int)
    
    /**
     Tells the delegate that the browser did dismiss the UIActionSheet
     
     - Parameter buttonIndex: the index of the pressed button
     - Parameter photoIndex: the index of the current photo
     */
    optional func didDismissActionSheetWithButtonIndex(buttonIndex: Int, photoIndex: Int)

    /**
     Tells the delegate that the browser did scroll to index

     - Parameter index: the index of the photo where the user had scroll
     */
    optional func didScrollToIndex(index: Int)

    /**
     Tells the delegate the user removed a photo, when implementing this call, be sure to call reload to finish the deletion process
     
     - Parameter browser: reference to the calling SKPhotoBrowser
     - Parameter index: the index of the removed photo
     - Parameter reload: function that needs to be called after finishing syncing up
     */
    optional func removePhoto(browser: SKPhotoBrowser, index: Int, reload: (() -> Void))
    
    /**
     Asks the delegate for the view for a certain photo. Needed to detemine the animation when presenting/closing the browser.
     
     - Parameter browser: reference to the calling SKPhotoBrowser
     - Parameter index: the index of the removed photo
     
     - Returns: the view to animate to
     */
    optional func viewForPhoto(browser: SKPhotoBrowser, index: Int) -> UIView?
}

public let SKPHOTO_LOADING_DID_END_NOTIFICATION = "photoLoadingDidEndNotification"

// MARK: - SKPhotoBrowser
public class SKPhotoBrowser: UIViewController, UIScrollViewDelegate {
    
    final let pageIndexTagOffset: Int = 1000
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
    
    // device property
    final let screenBounds = UIScreen.mainScreen().bounds
    var screenWidth: CGFloat { return screenBounds.size.width }
    var screenHeight: CGFloat { return screenBounds.size.height }
    var screenRatio: CGFloat { return screenWidth / screenHeight }
    
    // custom abilities
    public var displayAction: Bool = true
    public var shareExtraCaption: String? = nil
    public var actionButtonTitles: [String]?
    public var displayToolbar: Bool = true
    public var displayCounterLabel: Bool = true
    public var displayBackAndForwardButton: Bool = true
    public var disableVerticalSwipe: Bool = false
    public var displayDeleteButton = false
    public var displayCloseButton = true // default is true
    /// If it is true displayCloseButton will be false
    public var displayCustomCloseButton = false
    /// If it is true displayDeleteButton will be false
    public var displayCustomDeleteButton = false
    public var bounceAnimation = false
    public var enableZoomBlackArea = true
    public var enableSingleTapDismiss = false
    /// Set nil to force the statusbar to be hidden
    public var statusBarStyle: UIStatusBarStyle?
    
    // actions
    private var activityViewController: UIActivityViewController!
    
    // tool for controls
    private var applicationWindow: UIWindow!
    private var backgroundView: UIView!
    private var toolBar: UIToolbar!
    private var toolCounterLabel: UILabel!
    private var toolCounterButton: UIBarButtonItem!
    private var toolPreviousButton: UIBarButtonItem!
    private var toolActionButton: UIBarButtonItem!
    private var toolNextButton: UIBarButtonItem!
    private var pagingScrollView: UIScrollView!
    private var panGesture: UIPanGestureRecognizer!
    // MARK: close button
    private var closeButton: UIButton!
    private var closeButtonShowFrame: CGRect!
    private var closeButtonHideFrame: CGRect!
    // MARK: delete button
    private var deleteButton: UIButton!
    private var deleteButtonShowFrame: CGRect!
    private var deleteButtonHideFrame: CGRect!
    
    // MARK: - custom buttons
    // MARK: CustomCloseButton
    private var customCloseButton: UIButton!
    public var customCloseButtonShowFrame: CGRect!
    public var customCloseButtonHideFrame: CGRect!
    public var customCloseButtonImage: UIImage!
    public var customCloseButtonEdgeInsets: UIEdgeInsets!
    
    // MARK: CustomDeleteButton
    private var customDeleteButton: UIButton!
    public var customDeleteButtonShowFrame: CGRect!
    public var customDeleteButtonHideFrame: CGRect!
    public var customDeleteButtonImage: UIImage!
    public var customDeleteButtonEdgeInsets: UIEdgeInsets!
    
    // photo's paging
    private var visiblePages = [SKZoomingScrollView]()//: Set<SKZoomingScrollView> = Set()
    private var recycledPages = [SKZoomingScrollView]()
    
    private var initialPageIndex: Int = 0
    private var currentPageIndex: Int = 0
    
    // senderView's property
    private var senderViewForAnimation: UIView?
    private var senderViewOriginalFrame: CGRect = CGRect.zero
    private var senderOriginImage: UIImage!
    
    private var resizableImageView: UIImageView = UIImageView()
    
    // for status check property
    private var isDraggingPhoto: Bool = false
    private var isEndAnimationByToolBar: Bool = true
    private var isViewActive: Bool = false
    private var isPerformingLayout: Bool = false
    private var isStatusBarOriginallyHidden = UIApplication.sharedApplication().statusBarHidden
    private var originalStatusBarStyle: UIStatusBarStyle {
        return self.presentingViewController?.preferredStatusBarStyle() ?? UIApplication.sharedApplication().statusBarStyle
    }
    private var buttonTopOffset: CGFloat {
        return statusBarStyle == nil ? 5 : 25
    }
    
    // scroll property
    private var firstX: CGFloat = 0.0
    private var firstY: CGFloat = 0.0
    
    // timer
    private var controlVisibilityTimer: NSTimer!
    
    // delegate
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
        let picutres = photos.flatMap {$0 }
        for photo in picutres {
            photo.checkCache()
            self.photos.append(photo)
        }
    }
    
    public convenience init(originImage: UIImage, photos: [SKPhotoProtocol], animatedFromView: UIView) {
        self.init(nibName: nil, bundle: nil)
        self.senderOriginImage = originImage
        self.senderViewForAnimation = animatedFromView
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
        
        view.backgroundColor = .blackColor()
        view.clipsToBounds = true
        view.opaque = false
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        backgroundView.backgroundColor = .blackColor()
        backgroundView.alpha = 0.0
        applicationWindow.addSubview(backgroundView)
        
        // setup paging
        let pagingScrollViewFrame = frameForPagingScrollView()
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        pagingScrollView.pagingEnabled = true
        pagingScrollView.delegate = self
        pagingScrollView.showsHorizontalScrollIndicator = true
        pagingScrollView.showsVerticalScrollIndicator = true
        pagingScrollView.backgroundColor = .clearColor()
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        view.addSubview(pagingScrollView)
        
        // toolbar
        toolBar = UIToolbar(frame: frameForToolbarAtOrientation())
        toolBar.backgroundColor = .clearColor()
        toolBar.clipsToBounds = true
        toolBar.translucent = true
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        view.addSubview(toolBar)
        
        if !displayToolbar {
            toolBar.hidden = true
        }
        
        // arrows:back
        let previousBtn = UIButton(type: .Custom)
        let previousImage = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_back_wh", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
        previousBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        previousBtn.imageEdgeInsets = UIEdgeInsetsMake(13.25, 17.25, 13.25, 17.25)
        previousBtn.setImage(previousImage, forState: .Normal)
        previousBtn.addTarget(self, action: #selector(self.gotoPreviousPage), forControlEvents: .TouchUpInside)
        previousBtn.contentMode = .Center
        toolPreviousButton = UIBarButtonItem(customView: previousBtn)
        
        // arrows:next
        let nextBtn = UIButton(type: .Custom)
        let nextImage = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_forward_wh", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
        nextBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        nextBtn.imageEdgeInsets = UIEdgeInsetsMake(13.25, 17.25, 13.25, 17.25)
        nextBtn.setImage(nextImage, forState: .Normal)
        nextBtn.addTarget(self, action: #selector(self.gotoNextPage), forControlEvents: .TouchUpInside)
        nextBtn.contentMode = .Center
        toolNextButton = UIBarButtonItem(customView: nextBtn)
        
        toolCounterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 95, height: 40))
        toolCounterLabel.textAlignment = .Center
        toolCounterLabel.backgroundColor = .clearColor()
        toolCounterLabel.font  = UIFont(name: "Helvetica", size: 16.0)
        toolCounterLabel.textColor = .whiteColor()
        toolCounterLabel.shadowColor = .darkTextColor()
        toolCounterLabel.shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        toolCounterButton = UIBarButtonItem(customView: toolCounterLabel)
        
        // starting setting
        setCustomSetting()
        setSettingCloseButton()
        setSettingDeleteButton()
        setSettingCustomCloseButton()
        setSettingCustomDeleteButton()
        
        // action button
        toolActionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(SKPhotoBrowser.actionButtonPressed))
        toolActionButton.tintColor = .whiteColor()
        
        // gesture
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SKPhotoBrowser.panGestureRecognized(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        
        // transition (this must be last call of view did load.)
        performPresentAnimation()
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
        pagingScrollView.frame = frameForPagingScrollView()
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        
        // resize frames of buttons after the device rotation
        frameForButton()
        
        // this algorithm resizes the current image after device rotation
        if visiblePages.count > 0 {
            for page in visiblePages {
                let pageIndex = page.tag - pageIndexTagOffset
                page.frame = frameForPageAtIndex(pageIndex)
                page.setMaxMinZoomScalesForCurrentBounds()
                if page.captionView != nil {
                    page.captionView.frame = frameForCaptionView(page.captionView, index: pageIndex)
                }
            }
        }

        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        // where did start
        didStartViewingPageAtIndex(currentPageIndex)
        
        toolBar.frame = frameForToolbarAtOrientation()
        isPerformingLayout = false
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        if statusBarStyle == nil {
            return true
        }
        
        if isDraggingPhoto && !areControlsHidden() {
            return isStatusBarOriginallyHidden
        }
        
        return areControlsHidden()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recycledPages.removeAll()
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle ?? super.preferredStatusBarStyle()
    }
    
    // MARK: - setting of buttons
    // This function should be at the beginning of the other functions
    private func setCustomSetting() {
        if displayCustomCloseButton == true {
            displayCloseButton = false
        }
        if displayCustomDeleteButton == true {
            displayDeleteButton = false
        }
    }
    
    // MARK: - Buttons' setting
    // MARK: Close button
    private func setSettingCloseButton() {
        if displayCloseButton == true {
            let doneImage = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_close_wh", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
            closeButton = UIButton(type: UIButtonType.Custom)
            closeButton.setImage(doneImage, forState: UIControlState.Normal)
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                closeButton.imageEdgeInsets = UIEdgeInsetsMake(15.25, 15.25, 15.25, 15.25)
            } else {
                closeButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
            }
            closeButton.backgroundColor = .clearColor()
            closeButton.addTarget(self, action: #selector(self.closeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            closeButtonHideFrame = CGRect(x: 5, y: -20, width: 44, height: 44)
            closeButtonShowFrame = CGRect(x: 5, y: buttonTopOffset, width: 44, height: 44)
            view.addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = true
            closeButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        }
    }
    
    // MARK: Delete button
    
    private func setSettingDeleteButton() {
        if displayDeleteButton == true {
            deleteButton = UIButton(type: .Custom)
            deleteButtonShowFrame = CGRect(x: view.frame.width - 44, y: buttonTopOffset, width: 44, height: 44)
            deleteButtonHideFrame = CGRect(x: view.frame.width - 44, y: -20, width: 44, height: 44)
            let image = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_delete_wh", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                deleteButton.imageEdgeInsets = UIEdgeInsets(top: 15.25, left: 15.25, bottom: 15.25, right: 15.25)
            } else {
                deleteButton.imageEdgeInsets = UIEdgeInsetsMake(12.3, 12.3, 12.3, 12.3)
            }
            deleteButton.setImage(image, forState: .Normal)
            deleteButton.addTarget(self, action: #selector(self.deleteButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            deleteButton.alpha = 0.0
            view.addSubview(deleteButton)
            deleteButton.translatesAutoresizingMaskIntoConstraints = true
            deleteButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        }
    }
    
    // MARK: - Custom buttons' setting
    // MARK: Custom Close Button
    
    private func setSettingCustomCloseButton() {
        if displayCustomCloseButton == true {
            let closeImage = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_close_wh", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
            customCloseButton = UIButton(type: .Custom)
            customCloseButton.addTarget(self, action: #selector(self.closeButtonPressed(_:)), forControlEvents: .TouchUpInside)
            customCloseButton.backgroundColor = .clearColor()
            // If another developer has not set their values
            if customCloseButtonImage != nil {
                customCloseButton.setImage(customCloseButtonImage, forState: .Normal)
            } else {
                customCloseButton.setImage(closeImage, forState: .Normal)
            }
            if customCloseButtonShowFrame == nil && customCloseButtonHideFrame == nil {
                customCloseButtonShowFrame = CGRect(x: 5, y: buttonTopOffset, width: 44, height: 44)
                customCloseButtonHideFrame = CGRect(x: 5, y: -20, width: 44, height: 44)
            }
            if customCloseButtonEdgeInsets != nil {
                customCloseButton.imageEdgeInsets = customCloseButtonEdgeInsets
            }
            
            customCloseButton.translatesAutoresizingMaskIntoConstraints = true
            view.addSubview(customCloseButton)
            customCloseButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        }
    }
    
    // MARK: Custom Delete Button
    private func setSettingCustomDeleteButton() {
        if displayCustomDeleteButton == true {
            customDeleteButton = UIButton(type: .Custom)
            customDeleteButton.backgroundColor = .clearColor()
            customDeleteButton.addTarget(self, action: #selector(self.deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
            // If another developer has not set their values
            if customDeleteButtonShowFrame == nil && customDeleteButtonHideFrame == nil {
                customDeleteButtonShowFrame = CGRect(x: view.frame.width - 44, y: buttonTopOffset, width: 44, height: 44)
                customDeleteButtonHideFrame = CGRect(x: view.frame.width - 44, y: -20, width: 44, height: 44)
            }
            if let _customDeleteButtonImage = customDeleteButtonImage {
                customDeleteButton.setImage(_customDeleteButtonImage, forState: .Normal)
            }
            if let _customDeleteButtonEdgeInsets = customDeleteButtonEdgeInsets {
                customDeleteButton.imageEdgeInsets = _customDeleteButtonEdgeInsets
            }
            view.addSubview(customDeleteButton)
            customDeleteButton.translatesAutoresizingMaskIntoConstraints = true
            customDeleteButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        }
    }
    
    // MARK: - notification
    public func handleSKPhotoLoadingDidEndNotification(notification: NSNotification) {
        guard let photo = notification.object as? SKPhotoProtocol else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            let page = self.pageDisplayingAtPhoto(photo)
            guard let photo = page.photo else {
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
        let page = pageDisplayingAtPhoto(photo)
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
        
        // for tool bar
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        if numberOfPhotos > 1 && displayBackAndForwardButton {
            items.append(toolPreviousButton)
        }
        if displayCounterLabel {
            items.append(flexSpace)
            items.append(toolCounterButton)
            items.append(flexSpace)
        } else {
            items.append(flexSpace)
        }
        if numberOfPhotos > 1 && displayBackAndForwardButton {
            items.append(toolNextButton)
        }
        items.append(flexSpace)
        if displayAction {
            items.append(toolActionButton)
        }
        toolBar.setItems(items, animated: false)
        updateToolbar()
        
        // reset local cache
        visiblePages.forEach({$0.removeFromSuperview()})
        visiblePages.removeAll()
        recycledPages.removeAll()
        
        // set content offset
        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        
        // tile page
        tilePages()
        didStartViewingPageAtIndex(currentPageIndex)
        
        isPerformingLayout = false
        
        // add pangesture if need
        if !disableVerticalSwipe {
            view.addGestureRecognizer(panGesture)
        }
    }
    
    public func prepareForClosePhotoBrowser() {
        cancelControlHiding()
        applicationWindow.removeGestureRecognizer(panGesture)
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    // MARK: - frame calculation
    public func frameForPagingScrollView() -> CGRect {
        var frame = view.bounds
        frame.origin.x -= 10
        frame.size.width += (2 * 10)
        return frame
    }
    
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
    
    public func frameForCaptionView(captionView: SKCaptionView, index: Int) -> CGRect {
        let pageFrame = frameForPageAtIndex(index)
        let captionSize = captionView.sizeThatFits(CGSize(width: pageFrame.size.width, height: 0))
        let navHeight = navigationController?.navigationBar.frame.size.height ?? 44
        return CGRect(x: pageFrame.origin.x, y: pageFrame.size.height - captionSize.height - navHeight,
            width: pageFrame.size.width, height: captionSize.height)
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
    
    public func contentSizeForPagingScrollView() -> CGSize {
        let bounds = pagingScrollView.bounds
        return CGSize(width: bounds.size.width * CGFloat(numberOfPhotos), height: bounds.size.height)
    }
    
    /// This function changes buttons's frame after the rotation of the device
    private func frameForButton() {
        if displayDeleteButton {
            deleteButtonShowFrame = CGRect(x: view.frame.width - 44, y: buttonTopOffset, width: 44, height: 44)
            deleteButtonHideFrame = CGRect(x: view.frame.width - 44, y: -20, width: 44, height: 44)
        }
        if displayCustomDeleteButton {
            customDeleteButtonShowFrame = CGRect(x: customDeleteButtonShowFrame.origin.y, y: customDeleteButtonShowFrame.origin.x, width: customDeleteButtonShowFrame.width, height: customDeleteButtonShowFrame.height)
            customDeleteButtonHideFrame = CGRect(x: customDeleteButtonHideFrame.origin.y, y: customDeleteButtonHideFrame.origin.x, width: customDeleteButtonHideFrame.width, height: customDeleteButtonHideFrame.height)
        }
        if displayCustomCloseButton {
            customCloseButtonHideFrame = CGRect(x: customCloseButtonHideFrame.origin.y, y: customCloseButtonHideFrame.origin.x, width: customCloseButtonHideFrame.width, height: customCloseButtonHideFrame.height)
            customCloseButtonShowFrame = CGRect(x: customCloseButtonShowFrame.origin.y, y: customCloseButtonShowFrame.origin.x, width: customCloseButtonShowFrame.width, height: customCloseButtonShowFrame.height)
        }
    }
    
    // MARK: - delete function
    @objc private func deleteButtonPressed(sender: UIButton) {
        delegate?.removePhoto?(self, index: currentPageIndex, reload: { () -> Void in
            self.deleteImage()
        })
    }
    
    private func deleteImage() {
        if photos.count > 1 {
            // index equals 0 because when we slide between photos delete button is hidden and user cannot to touch on delete button. And visible pages number equals 0
            visiblePages[0].captionView?.removeFromSuperview()
            photos.removeAtIndex(currentPageIndex)
            if currentPageIndex != 0 {
                gotoPreviousPage()
            }
            updateToolbar()
        } else if photos.count == 1 {
            dismissPhotoBrowser()
        }
        reloadData()
    }
    
    // MARK: - Toolbar
    public func updateToolbar() {
        if numberOfPhotos > 1 {
            toolCounterLabel.text = "\(currentPageIndex + 1) / \(numberOfPhotos)"
        } else {
            toolCounterLabel.text = nil
        }
        
        toolPreviousButton.enabled = (currentPageIndex > 0)
        toolNextButton.enabled = (currentPageIndex < numberOfPhotos - 1)
    }
    
    // MARK: - panGestureRecognized
    public func panGestureRecognized(sender: UIPanGestureRecognizer) {
        backgroundView.hidden = true
        let scrollView = pageDisplayedAtIndex(currentPageIndex)
        
        let viewHeight = scrollView.frame.size.height
        let viewHalfHeight = viewHeight/2
        
        var translatedPoint = sender.translationInView(self.view)
        
        // gesture began
        if sender.state == .Began {
            firstX = scrollView.center.x
            firstY = scrollView.center.y
            
            senderViewForAnimation?.hidden = (currentPageIndex == initialPageIndex)
            
            isDraggingPhoto = true
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        scrollView.center = translatedPoint
        
        let minOffset = viewHalfHeight / 4
        let offset = 1 - (scrollView.center.y > viewHalfHeight ? scrollView.center.y - viewHalfHeight : -(scrollView.center.y - viewHalfHeight)) / viewHalfHeight
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(max(0.7, offset))
        
        // gesture end
        if sender.state == .Ended {
            if scrollView.center.y > viewHalfHeight + minOffset || scrollView.center.y < viewHalfHeight - minOffset {
                backgroundView.backgroundColor = self.view.backgroundColor
                determineAndClose()
                return
            } else {
                // Continue Showing View
                isDraggingPhoto = false
                setNeedsStatusBarAppearanceUpdate()
                
                let velocityY: CGFloat = CGFloat(self.animationDuration) * sender.velocityInView(self.view).y
                let finalX: CGFloat = firstX
                let finalY: CGFloat = viewHalfHeight
                
                let animationDuration = Double(abs(velocityY) * 0.0002 + 0.2)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                view.backgroundColor = UIColor.blackColor()
                scrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()
            }
        }
    }
    
    // MARK: - perform animation
    public func performPresentAnimation() {
        view.hidden = true
        pagingScrollView.alpha = 0.0
        backgroundView.alpha = 0
        
        if let sender = delegate?.viewForPhoto?(self, index: initialPageIndex) ?? senderViewForAnimation {
            if let senderViewOriginalFrameTemp = sender.superview?.convertRect(sender.frame, toView:nil) {
                senderViewOriginalFrame = senderViewOriginalFrameTemp
            } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convertRect(sender.frame, toLayer: nil) {
                senderViewOriginalFrame = senderViewOriginalFrameTemp
            }
            sender.hidden = true
            
            let imageFromView = (senderOriginImage ?? getImageFromView(sender)).rotateImageByOrientation()
            let imageRatio = imageFromView.size.width / imageFromView.size.height
            let finalImageViewFrame: CGRect

            resizableImageView = UIImageView(image: imageFromView)
            resizableImageView.frame = senderViewOriginalFrame
            resizableImageView.clipsToBounds = true
            resizableImageView.contentMode = .ScaleAspectFill
            applicationWindow.addSubview(resizableImageView)
            
            if screenRatio < imageRatio {
                let width = applicationWindow.frame.width
                let height = width / imageRatio
                let yOffset = (applicationWindow.frame.height - height) / 2
                finalImageViewFrame = CGRect(x: 0, y: yOffset, width: width, height: height)
            } else {
                let height = applicationWindow.frame.height
                let width = height * imageRatio
                let xOffset = (applicationWindow.frame.width - width) / 2
                finalImageViewFrame = CGRect(x: xOffset, y: 0, width: width, height: height)
            }
            
            if sender.layer.cornerRadius != 0 {
                let duration = (animationDuration * Double(animationDamping))
                self.resizableImageView.layer.masksToBounds = true
                self.resizableImageView.addCornerRadiusAnimation(sender.layer.cornerRadius, to: 0, duration: duration)
            }
            
            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping:animationDamping, initialSpringVelocity:0, options:.CurveEaseInOut, animations: { () -> Void in
                
                    self.backgroundView.alpha = 1.0
                    self.resizableImageView.frame = finalImageViewFrame
                
                    if self.displayCloseButton {
                        self.closeButton.alpha = 1.0
                        self.closeButton.frame = self.closeButtonShowFrame
                    }
                    if self.displayDeleteButton {
                        self.deleteButton.alpha = 1.0
                        self.deleteButton.frame = self.deleteButtonShowFrame
                    }
                    if self.displayCustomCloseButton {
                        self.customCloseButton.alpha = 1.0
                        self.customCloseButton.frame = self.customCloseButtonShowFrame
                    }
                    if self.displayCustomDeleteButton {
                        self.customDeleteButton.alpha = 1.0
                        self.customDeleteButton.frame = self.customDeleteButtonShowFrame
                    }
                },
                completion: { (Bool) -> Void in
                    self.view.hidden = false
                    self.backgroundView.hidden = true
                    self.pagingScrollView.alpha = 1.0
                    self.resizableImageView.alpha = 0.0
            })
        } else {
            UIView.animateWithDuration(animationDuration, delay:0, usingSpringWithDamping:animationDamping, initialSpringVelocity:0, options:.CurveEaseInOut, animations: { () -> Void in
                    self.backgroundView.alpha = 1.0
                    if self.displayCloseButton {
                        self.closeButton.alpha = 1.0
                        self.closeButton.frame = self.closeButtonShowFrame
                    }
                    if self.displayDeleteButton {
                        self.deleteButton.alpha = 1.0
                        self.deleteButton.frame = self.deleteButtonShowFrame
                    }
                    if self.displayCustomCloseButton {
                        self.customCloseButton.alpha = 1.0
                        self.customCloseButton.frame = self.customCloseButtonShowFrame
                    }
                    if self.displayCustomDeleteButton {
                        self.customDeleteButton.alpha = 1.0
                        self.customDeleteButton.frame = self.customDeleteButtonShowFrame
                    }
                },
                completion: { (Bool) -> Void in
                    self.view.hidden = false
                    self.pagingScrollView.alpha = 1.0
                    self.backgroundView.hidden = true
            })
        }
    }
    
    public func performCloseAnimationWithScrollView(scrollView: SKZoomingScrollView) {
        view.hidden = true
        backgroundView.hidden = false
        backgroundView.alpha = 1
        
        statusBarStyle = isStatusBarOriginallyHidden ? nil : originalStatusBarStyle
        setNeedsStatusBarAppearanceUpdate()
        
        if let sender = senderViewForAnimation {
            if let senderViewOriginalFrameTemp = sender.superview?.convertRect(sender.frame, toView:nil) {
                senderViewOriginalFrame = senderViewOriginalFrameTemp
            } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convertRect(sender.frame, toLayer: nil) {
                senderViewOriginalFrame = senderViewOriginalFrameTemp
            }
        }
        
        let contentOffset = scrollView.contentOffset
        let scrollFrame = scrollView.photoImageView.frame
        let offsetY = scrollView.center.y - (scrollView.bounds.height/2)
        
        let frame = CGRect(
            x: scrollFrame.origin.x - contentOffset.x,
            y: scrollFrame.origin.y + contentOffset.y + offsetY,
            width: scrollFrame.width,
            height: scrollFrame.height)
        
        resizableImageView.image = scrollView.photo?.underlyingImage?.rotateImageByOrientation() ?? resizableImageView.image
        resizableImageView.frame = frame
        resizableImageView.alpha = 1.0
        resizableImageView.clipsToBounds = true
        resizableImageView.contentMode = .ScaleAspectFill
        applicationWindow.addSubview(resizableImageView)
        
        if let view = senderViewForAnimation where view.layer.cornerRadius != 0 {
            let duration = (animationDuration * Double(animationDamping))
            self.resizableImageView.layer.masksToBounds = true
            self.resizableImageView.addCornerRadiusAnimation(0, to: view.layer.cornerRadius, duration: duration)
        }
        
        UIView.animateWithDuration(animationDuration, delay:0, usingSpringWithDamping:animationDamping, initialSpringVelocity:0, options:.CurveEaseInOut, animations: { () -> () in
                self.backgroundView.alpha = 0.0
                self.resizableImageView.layer.frame = self.senderViewOriginalFrame
            },
            completion: { (Bool) -> () in
                self.resizableImageView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
                self.dismissPhotoBrowser()
        })
    }
    
    public func dismissPhotoBrowser() {
        modalTransitionStyle = .CrossDissolve
        senderViewForAnimation?.hidden = false
        prepareForClosePhotoBrowser()
        
        dismissViewControllerAnimated(true) {
            self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
        }
    }

    public func determineAndClose() {
        delegate?.willDismissAtPageIndex?(currentPageIndex)
        let scrollView = pageDisplayedAtIndex(currentPageIndex)
        
        if currentPageIndex == initialPageIndex {
            performCloseAnimationWithScrollView(scrollView)
            
        } else if let sender = delegate?.viewForPhoto?(self, index: currentPageIndex), image = photoAtIndex(currentPageIndex).underlyingImage {
            senderViewForAnimation = sender
            resizableImageView.image = image
            performCloseAnimationWithScrollView(scrollView)
            
        } else {
            dismissPhotoBrowser()
        }
    }
    
    //MARK: - image
    private func getImageFromView(sender: UIView) -> UIImage {
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
                tilePages()
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
            pagingScrollView.setContentOffset(CGPoint(x: pageFrame.origin.x - 10, y: 0), animated: true)
            updateToolbar()
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
    
    public func tilePages() {
        let visibleBounds = pagingScrollView.bounds
        
        var firstIndex = Int(floor((CGRectGetMinX(visibleBounds) + 10 * 2) / CGRectGetWidth(visibleBounds)))
        var lastIndex  = Int(floor((CGRectGetMaxX(visibleBounds) - 10 * 2 - 1) / CGRectGetWidth(visibleBounds)))
        if firstIndex < 0 {
            firstIndex = 0
        }
        if firstIndex > numberOfPhotos - 1 {
            firstIndex = numberOfPhotos - 1
        }
        if lastIndex < 0 {
            lastIndex = 0
        }
        if lastIndex > numberOfPhotos - 1 {
            lastIndex = numberOfPhotos - 1
        }
        
        for page in visiblePages {
            let newPageIndex = page.tag - pageIndexTagOffset
            if newPageIndex < firstIndex || newPageIndex > lastIndex {
                recycledPages.append(page)
                page.prepareForReuse()
                page.removeFromSuperview()
            }
        }
        
        let visibleSet = Set(visiblePages)
        visiblePages = Array(visibleSet.subtract(recycledPages))
        
        while recycledPages.count > 2 {
            recycledPages.removeFirst()
        }
        
        for index in firstIndex...lastIndex {
            if isDisplayingPageForIndex(index) {
                continue
            }
            
            let page = SKZoomingScrollView(frame: view.frame, browser: self)
            page.frame = frameForPageAtIndex(index)
            page.tag = index + pageIndexTagOffset
            page.photo = photoAtIndex(index)
            
            visiblePages.append(page)
            pagingScrollView.addSubview(page)
            // if exists caption, insert
            if let captionView = captionViewForPhotoAtIndex(index) {
                captionView.frame = frameForCaptionView(captionView, index: index)
                pagingScrollView.addSubview(captionView)
                // ref val for control
                page.captionView = captionView
            }
        }
    }
    
    private func didStartViewingPageAtIndex(index: Int) {
        delegate?.didShowPhotoAtIndex?(index)
    }
    
    private func captionViewForPhotoAtIndex(index: Int) -> SKCaptionView? {
        let photo = photoAtIndex(index)
        if let _ = photo.caption {
            let captionView = SKCaptionView(photo: photo)
            captionView.alpha = areControlsHidden() ? 0.0 : 1.0
            return captionView
        }
        return nil
    }
    
    public func isDisplayingPageForIndex(index: Int) -> Bool {
        for page in visiblePages {
            if page.tag - pageIndexTagOffset == index {
                return true
            }
        }
        return false
    }
    
    public func pageDisplayedAtIndex(index: Int) -> SKZoomingScrollView {
        var thePage = SKZoomingScrollView()
        for page in visiblePages {
            if page.tag - pageIndexTagOffset == index {
                thePage = page
                break
            }
        }
        return thePage
    }
    
    public func pageDisplayingAtPhoto(photo: SKPhotoProtocol) -> SKZoomingScrollView {
        var thePage = SKZoomingScrollView()
        for page in visiblePages {
            if page.photo === photo {
                thePage = page
                break
            }
        }
        return thePage
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
        var captionViews = Set<SKCaptionView>()
        for page in visiblePages {
            if page.captionView != nil {
                captionViews.insert(page.captionView)
            }
        }
        
        UIView.animateWithDuration(animationDuration,
            animations: { () -> Void in
                let alpha: CGFloat = hidden ? 0.0 : 1.0
                self.toolBar.alpha = alpha
                self.toolBar.frame = hidden ? self.frameForToolbarHideAtOrientation() : self.frameForToolbarAtOrientation()
                if self.displayCloseButton {
                    self.closeButton.alpha = alpha
                    self.closeButton.frame = hidden ? self.closeButtonHideFrame : self.closeButtonShowFrame
                }
                if self.displayDeleteButton {
                    self.deleteButton.alpha = alpha
                    self.deleteButton.frame = hidden ? self.deleteButtonHideFrame : self.deleteButtonShowFrame
                }
                if self.displayCustomCloseButton {
                    self.customCloseButton.alpha = alpha
                    self.customCloseButton.frame = hidden ? self.customCloseButtonHideFrame : self.customCloseButtonShowFrame
                }
                if self.displayCustomDeleteButton {
                    self.customDeleteButton.alpha = alpha
                    self.customDeleteButton.frame = hidden ? self.customDeleteButtonHideFrame : self.customDeleteButtonShowFrame
                }
                for captionView in captionViews {
                    captionView.alpha = alpha
                }
            },
            completion: { (Bool) -> Void in
        })
        
        if !permanent {
            hideControlsAfterDelay()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public func areControlsHidden() -> Bool {
        return toolBar.alpha == 0.0
    }
    
    // MARK: - Button
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
        
        if let titles = actionButtonTitles {
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
				    popoverController.barButtonItem = toolActionButton
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
                if let shareExtraCaption = shareExtraCaption {
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
                popover.barButtonItem = toolActionButton
                presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: -  UIScrollView Delegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        guard isViewActive else {
            return
        }
        guard !isPerformingLayout else {
            return
        }
        
        // tile page
        tilePages()
        
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
            didStartViewingPageAtIndex(currentPageIndex)
            updateToolbar()
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        setControlsHidden(true, animated: true, permanent: false)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        hideControlsAfterDelay()

        let currentIndex = self.pagingScrollView.contentOffset.x / self.pagingScrollView.frame.size.width
        self.delegate?.didScrollToIndex?(Int(currentIndex))
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        isEndAnimationByToolBar = true
    }

}
