SKPhotoBrowser
========================

![Language](https://img.shields.io/badge/language-Swift%202.3-orange.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/SKPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/SKPhotoBrowser)

Simple PhotoBrowser/Viewer inspired by facebook, twitter photo browsers written by swift, based on [IDMPhotoBrowser](https://github.com/ideaismobile/IDMPhotoBrowser), [MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser).

## Note
- released v3.0.x and this version goes some breaking changes. please check [CHANGELOG](https://github.com/suzuki-0000/SKPhotoBrowser/blob/master/CHANGELOG.md).

## features
- Display one or more images by providing either `UIImage` objects, or string of URL array.
- Photos can be zoomed and panned, and optional captions can be displayed
- Minimalistic Facebook-like interface, swipe up/down to dismiss
- Ability to custom control. (hide/ show toolbar for controls, / swipe control)
- Handling and caching photos from web 
- Landscape handling
- Delete photo support(by offbye). By set displayDelete=true show a delete icon in statusbar, deleted indexes can be obtain from delegate func didDeleted 

![sample](Screenshots/example02.gif)

## Requirements
- iOS 8.0+
- Swift 2.0+
- ARC

##Installation

####CocoaPods
available on CocoaPods. Just add the following to your project Podfile:
```
pod 'SKPhotoBrowser'
use_frameworks!
```

####Carthage
To integrate into your Xcode project using Carthage, specify it in your Cartfile:

```ogdl
github "suzuki-0000/SKPhotoBrowser"
```

####Manually
Add the code directly into your project.

##Usage
See the code snippet below for an example of how to implement, or see the example project.
	
from UIImages:
```swift
// 1. create SKPhoto Array from UIImage
var images = [SKPhoto]()
let photo = SKPhoto.photoWithImage(UIImage())// add some UIImage
images.append(photo) 

// 2. create PhotoBrowser Instance, and present from your viewController. 
let browser = SKPhotoBrowser(photos: images)
browser.initializePageIndex(0)
presentViewController(browser, animated: true, completion: {})
```

from URLs:
```swift
// 1. create URL Array 
var images = [SKPhoto]()
let photo = SKPhoto.photoWithImageURL("https://placehold.jp/150x150.png")
photo.shouldCachePhotoURLImage = false // you can use image cache by true(NSCache)
images.append(photo)

// 2. create PhotoBrowser Instance, and present. 
let browser = SKPhotoBrowser(photos: images)
browser.initializePageIndex(0)
presentViewController(browser, animated: true, completion: {})
```

from local files:
```swift
// 1. create images from local files
var images = [SKLocalPhoto]()
let photo = SKLocalPhoto.photoWithImageURL("..some_local_path/150x150.png")
images.append(photo)

// 2. create PhotoBrowser Instance, and present. 
let browser = SKPhotoBrowser(photos: images)
browser.initializePageIndex(0)
presentViewController(browser, animated: true, completion: {})
```

If you want to use zooming effect from an existing view, use another initializer:
```swift
// e.g.: some tableView or collectionView.
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
   let cell = collectionView.cellForItemAtIndexPath(indexPath) 
   let originImage = cell.exampleImageView.image // some image for baseImage 

   let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell) 
   browser.initializePageIndex(indexPath.row)
   presentViewController(browser, animated: true, completion: {})
}
```

### Custom

#### Toolbar
You can customize Toolbar via SKPhotoBrowserOptions.

```swift
SKPhotoBrowserOptions.displayToolbar = false                // all tool bar will be hidden
SKPhotoBrowserOptions.displayCounterLabel = false           // counter label will be hidden
SKPhotoBrowserOptions.displayBackAndForwardButton = false   // back / forward button will be hidden
SKPhotoBrowserOptions.displayAction = false                 // action button will be hidden
SKPhotoBrowserOptions.displayDeleteButton = true            // delete button will be shown
let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell)
```

#### Custom Cache From Web URL
You can use SKCacheable protocol if others are adaptable. (SKImageCacheable or SKRequestResponseCacheable)

```swift
e.g. SDWebImage

// 1. create custon cache. implement function for protocol
class CustomImageCache: SKImageCacheable { var cache: SDImageCache }

// 2. replace SKCache instance with custom cache
SKCache.sharedCache.imageCache = CustomImageCache()
```

#### CustomButton Image
Close, Delete buttons are able to change image and frame.
``` swift
browser.updateCloseButton(UIImage())
browser.updateUpdateButton(UIImage())
```

#### Delete Photo
You can delete your photo for your own handling. detect button tap from `removePhoto` delegate function.


#### Photo Captions
Photo captions can be displayed simply bottom of PhotoBrowser. by setting the `caption` property on specific photos:
``` swift
let photo = SKPhoto.photoWithImage(UIImage())
photo.caption = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
images.append(photo)
```

#### SwipeGesture 
vertical swipe can enable/disable:
``` swift
SKPhotoBrowserOptions.disableVerticalSwipe = true 
``` 

#### Delegate
There's some trigger point you can handle using delegate. those are optional.
- didShowPhotoAtIndex(index:Int) 
- willDismissAtPageIndex(index:Int)
- willShowActionSheet(photoIndex: Int)
- didDismissAtPageIndex(index:Int)
- didDismissActionSheetWithButtonIndex(buttonIndex: Int, photoIndex: Int)
- didScrollToIndex(index: Int)
- removePhoto(browser: SKPhotoBrowser, index: Int, reload: (() -> Void))
- viewForPhoto(browser: SKPhotoBrowser, index: Int) -> UIView?

```swift
let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell)
browser.delegate = self

// MARK: - SKPhotoBrowserDelegate
func didShowPhotoAtIndex(index: Int) {
// when photo will be shown
}

func willDismissAtPageIndex(index: Int) {
// when PhotoBrowser will be dismissed
}

func didDismissAtPageIndex(index: Int) {
// when PhotoBrowser did dismissed
}

```

#### Minor Option
- blackArea handling which is appearing outside of photo
- single tap handling, dismiss/noaction
- bounce animation when appearing/dismissing
``` swift
SKPhotoBrowserOptions.enableZoomBlackArea    = true  // default true
SKPhotoBrowserOptions.enableSingleTapDismiss = true  // default false
SKPhotoBrowserOptions.bounceAnimation        = true  // default false
``` 

## Photos from
- [Unsplash](https://unsplash.com)

## License
available under the MIT license. See the LICENSE file for more info.

