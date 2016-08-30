//
//  SKPhotoBrowserDelegate.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

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

