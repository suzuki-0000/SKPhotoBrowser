//
//  SKPagingScrollView.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/18.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

class SKPagingScrollView: UIScrollView {
    let pageIndexTagOffset: Int = 1000
    // photo's paging
    private var visiblePages = [SKZoomingScrollView]()
    private var recycledPages = [SKZoomingScrollView]()
    
    private weak var browser: SKPhotoBrowser?
    var numberOfPhotos: Int {
        return browser?.photos.count ?? 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pagingEnabled = true
        showsHorizontalScrollIndicator = true
        showsVerticalScrollIndicator = true
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        
        self.browser = browser
        
        updateFrame(bounds)
        updateContentSize()
    }
    
    func reload() {
        visiblePages.forEach({$0.removeFromSuperview()})
        visiblePages.removeAll()
        recycledPages.removeAll()
    }
    
    func deleteImage() {
        // index equals 0 because when we slide between photos delete button is hidden and user cannot to touch on delete button. And visible pages number equals 0
        if numberOfPhotos > 0 {
            visiblePages[0].captionView?.removeFromSuperview()
        }
    }
    
    func updateFrame(bounds: CGRect) {
        var frame = bounds
        frame.origin.x -= 10
        frame.size.width += (2 * 10)
        
        self.frame = frame
        
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
    }
    
    func updateContentSize() {
        contentSize = CGSize(width: bounds.size.width * CGFloat(numberOfPhotos), height: bounds.size.height)
    }
    
    func updateContentOffset(frame: CGRect) {
        setContentOffset(CGPoint(x: frame.origin.x - 10, y: 0), animated: true)
    }
    
    func isDisplayingPageForIndex(index: Int) -> Bool {
        for page in visiblePages {
            if page.tag - pageIndexTagOffset == index {
                return true
            }
        }
        return false
    }
    
    func tilePages() {
        guard let browser = browser else { return }
        
        let numberOfPhotos = browser.photos.count
        let visibleBounds = bounds
        
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
            
            let page = SKZoomingScrollView(frame: frame, browser: browser)
            page.frame = frameForPageAtIndex(index)
            page.tag = index + pageIndexTagOffset
            page.photo = browser.photos[index]
            
            visiblePages.append(page)
            addSubview(page)
            // if exists caption, insert
            if let captionView = captionViewForPhotoAtIndex(index) {
                captionView.frame = frameForCaptionView(captionView, index: index)
                addSubview(captionView)
                // ref val for control
                page.captionView = captionView
            }
        }
    }
    
    func frameForCaptionView(captionView: SKCaptionView, index: Int) -> CGRect {
        let pageFrame = frameForPageAtIndex(index)
        let captionSize = captionView.sizeThatFits(CGSize(width: pageFrame.size.width, height: 0))
        let navHeight = browser?.navigationController?.navigationBar.frame.size.height ?? 44
        return CGRect(x: pageFrame.origin.x, y: pageFrame.size.height - captionSize.height - navHeight,
                      width: pageFrame.size.width, height: captionSize.height)
    }
    
    func pageDisplayedAtIndex(index: Int) -> SKZoomingScrollView? {
        for page in visiblePages {
            if page.tag - pageIndexTagOffset == index {
                return page
            }
        }
        return nil
    }
    
    func pageDisplayingAtPhoto(photo: SKPhotoProtocol) -> SKZoomingScrollView? {
        for page in visiblePages {
            if page.photo === photo {
                return page
            }
        }
        return nil
    }
    
    func getCaptionViews() -> Set<SKCaptionView> {
        var captionViews = Set<SKCaptionView>()
        for page in visiblePages {
            if page.captionView != nil {
                captionViews.insert(page.captionView)
            }
        }
        return captionViews
    }
}

private extension SKPagingScrollView {
    func frameForPageAtIndex(index: Int) -> CGRect {
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
    
    func captionViewForPhotoAtIndex(index: Int) -> SKCaptionView? {
        guard let browser = browser else { return nil }
        
        let photo = browser.photos[index]
        if let _ = photo.caption {
            let captionView = SKCaptionView(photo: photo)
            captionView.alpha = browser.areControlsHidden() ? 0 : 1
            return captionView
        }
        return nil
    }

}





