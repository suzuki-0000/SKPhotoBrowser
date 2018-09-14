# Change Log

## 6.0.0

### Big Changed
- #330 Changes for swift 4.2, Xcode 10, and iOS 12 by jlcanale 

#### Updated
- #314 Add possibility to provide custom request parameters by Fiser33 
- #315 Fix: Unable to set delete and close button images without setting size. by kiztonwose
- #318 fix unreleased views in uiwindow for non-dismiss animation case by fans3210
- #321 Set the backround view's background color from settings by pantelisss 
- #331 Add ability to lower caption and give caption a background gradient by corban123
- #334 Prevent app crashed on zooming when xScale or yScale is NaN, Inf by GE-N
- #335 use the size of the window instead of UIScreen to support SplitScreen by PatrickDotStar

## 5.1.0

#### Updated
- #311 Delete and Close Button Overlapping bug by rajendersha

## 5.0.9

#### Updated
- #304 CaptionViewForPhotoAtIndex is not work 
- #305 Padding properties for close and delete button. 
- Bug  At iphoneX, close / delete / pagination can be tapped correctly.

## 5.0.8

#### Updated
- #224 override popupShare not working
- #248 always ignore image cache, asked by FicowShen
- #304 CaptionViewForPhotoAtIndex is not work 
- #301 SKPhotoBrowserOptions.displayDeleteButton not working
- #302 Add method to remove all images for SKCache by filograno

## 5.0.7

#### Updated
- #301 SKPhotoBrowserOptions.displayCounterLabel is not working 
- #297 I want to hide SKPagingScrollView's horizontal indicator by mothule

## 5.0.6

#### Updated
- #292 Fix crash when imageRatio isNan by arnaudWasappli 
- #291 When disableVerticalSwipe is true the browser crashes on close by aliillyas 

## 5.0.5

#### Updated
- #271 SmartInvert now works properly by timroesner 
- #288 Add the long photo width match screen option by dirtmelon 
- #289 Add SWIFT_VERSION to xcconfig by cheungpat

## 5.0.4

#### Updated
- #273 Fixed crash on resizableImageView force unwrapping by matuslittva 

## 5.0.3

#### Updated
- Refactoring for swift4.0

## 5.0.2

#### Updated
- #255 Fixed the crash where the PhotoBrowser could crash.
- #262 Fix calling willDismissAtPageIndex delegate method
- #263 Remove unused options
- #263 Use iOS 11 Safe Area Insets to layout toolbar
- #270 Added functionality to add new photos at the end or at the start of c…

## 5.0.1

#### Updated
- #246 Updated to Swift 4 and made Swift Lint recommended changes

## 5.0.0

#### Major changed
- #250 Swift4 merge 
- #242 swift4 merge

#### Updated
- #239 Updated padding for iPhone X 

## 4.1.1

#### Updated
- #208 improve: change deleteButtonPressed(), currentPageIndex access level
- #210 Fix Shorthand Operator Violation of Swiftlint 
- #215 swiftLint
- #216 update code to Swift 3.1 
- #223 Removed deprecated constants
- #225 Custom Cancel button title 
- #227 Attach toolbar and delete button to single browser instance 
- #236 improve SKPhotoBrowserDelegate 

## 4.1.0
Released on 30-8-2017

#### Updated
- #173 Move the willDismiss delegate call closer to the dismissal
- #196 Improved SKCaptionView
- #197 fix: deleteButton frame does not update if screen has rotated 
- #199 Add SKPhotoBrowserOptions to customize indicator color & style 
- #200 Swap and custom padding for delete and close buttons 
- #205 Replaced deprecated Pi constants
- #207 Update code style: to Swift3.1
- #231 Update SKZoomingScrollView.swift

## 4.0.1
Released on 18-1-2017

#### Fixed
- Update README.md
- #158 Button Position wrong with changed StatusBar handling
- #162 Fix SKPhotoBrowserOptions background color
- #181 Unclear how placeholder image is supposed to work

## 4.0.0
Released on 5-1-2017

#### Breaking Change
- default swift version change. swift2.2 -> swift3
  
#### Fixed
- #171 Add @escaping to delegate method's reload closure parameter.
- #172 Fix caption font bug
- #177 Fix a fatal error when app's window is customized.
- #178 SKPagingScrollView fixes / swift3 branch
- #179 SKPagingScrollView fixes
- #182 Always load from the URL even if a placeholder image exists
- #186 fix setStatusBarHidden is deprecated in iOS 9.0 and demo cannot run
- #188 Added options for custom photo's caption.
- #180 SKPhotoBrowserOptions not working Swift 3

## 3.1.4
Released on 11-14-2016
- add delegate that get notified when controls view visibility toggled

## 3.1.3
Released on 23-9-2016

#### Fixed
- The method dismissPhotoBrowser should only animate if the parameter animated is true.

## 3.1.2

Released on 16-9-2016

#### Fixed
- Scrolling performance slowed #145

## 3.1.1

Released on 15-9-2016

#### Fixed
- Example crash in xcode8 fixed
- Provides various UI configuration options via SKPhotoBrowserOptions. #144

## 3.1.0

Released on 9-2016

#### Fixed
- Issue with multiple actionButtonTitles #137
- fix swiftlint warnings #140
- Update for Xcode 8 GM (swift 2.3). #141

## 3.0.2

Released on 9-2016

#### Fixed
- Issue with multiple actionButtonTitles #137
- Impossible to zoom when resolution is 1024x768 #134
- Crash bug at zooming scrool view #133

## 3.0.1 

Released on 9-2016

#### Fixed
- Skip loading image if already loaded #135

Released on 8-2016

#### Some Interface is removed, changed this version.
- status bar handling is removed.
- custom button handling interface is chagned.
- custom option goes internal/private. use option via SKPhotoBrowserOptions.

#### Add
- Add changelog

#### Fixed
- prepare for swift3.0. 
- refactoring code for new implement.
- Parent View disappears when dismissed. #120
- Glitch when origin imageview is not correct size #108 
- Problems with the "long" photo #116 

#### Remove
- Statusbar handling. 
- Some public property to internal for improving

## 2.0.x
Released on 8-2016

#### Added
- Migrate UIImage cache category to new SKCache

#### Fixed
- Make cached response data return optional
- Fixed issue when animatedFromView not has a superview but has superlayer
- Fixed when image downloaded then not show activityindicator
- Update for Swift2.3

--- 

## 1.9.x
Released on 6-2016

#### Added
- Delegate to notify when the user scroll to an index
- Single tap to dismiss

#### Fixed
- Fixed a bug where the activity indicator was only visible
- Fixed unit test and problems running when being bridged

---

## 1.8.x
Released on 4-2016

#### Added
- Using SKPhotoProtocol to enable usage from SKLocalPhoto 
- SKLocalPhoto to support local photo from file

#### Fixed
- Bug when animation when tap.
- The indicator may not disappear when loading local image
- Event crash when closing before image has been loaded
- Fix crash on initialisation

---

## 1.7.x
Released on 3-2016

#### Added
- Enable ability to override statusBar style

#### Fixed
- Update for swift2.0
- Bug when zooming small image
- Prevent crash when closing before image has been loaded

---

## 1.6.x
Released on 2016-3

#### Fixed
- Change maxScale to 1.0 it works perfectly.
- Fixed the bug which was after the device rotation

---

## 1.5.x
Released on 2016-3

#### Added
- Delete Button

#### Fixed
- Change maxScale to 1.0 it works perfectly.
- Rew algorithm for maxScale.
- Changed UIActionSheet to UIAlertController with ActionSheet style

---

## 1.4.x
Released on 2-2016

#### Added
- Delegate add for actionbutton.
- DidShowPhotoAtIndex delegate goes to optional. 

#### Fixed
- Zooming bug fixed.

---

## 1.3.x
Released on 1-2016

#### Added
- Added action functionality similar to IDMPhotoBrowser.
- Add extra caption for share

#### Fixed
- Bug fixed for mail crash


--- 

## 1.2.x
Released on 10-2015

#### Added
- SKPhotoProtocol is implemented.

#### Fixed
- Double tap bug fixed

---

## 1.1.x
Released on 10-2015

#### Fixed
- some property make private.
- layout bug fixed when zoom.

## 1.0.0
Released on 10-2015

