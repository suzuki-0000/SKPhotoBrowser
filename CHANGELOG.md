# Change Log

## 4.0.x

#### Updated
- #173 Move the willDismiss delegate call closer to the dismissal
- #196 Improved SKCaptionView

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

