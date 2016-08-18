# Change Log

## 2.0.x
Released on 2016-8

#### Added
- Migrate UIImage cache category to new SKCache

#### Fixed
- Make cached response data return optional
- Fixed issue when animatedFromView not has a superview but has superlayer
- Fixed when image downloaded then not show activityindicator

--- 

## 1.9.x
Released on 2016-6

#### Added
- Delegate to notify when the user scroll to an index
- Single tap to dismiss

#### Fixed
- Fixed a bug where the activity indicator was only visible
- Fixed unit test and problems running when being bridged

---

## 1.8.x
Released on 2016-4

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
Released on 2016-3

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
Released on 2016-2

#### Added
- Delegate add for actionbutton.
- DidShowPhotoAtIndex delegate goes to optional. 

#### Fixed
- Zooming bug fixed.

---

## 1.3.x
Released on 2016-1

#### Added
- Added action functionality similar to IDMPhotoBrowser.
- Add extra caption for share

#### Fixed
- Bug fixed for mail crash


--- 

## 1.2.x
Released on 2015-10

#### Added
- SKPhotoProtocol is implemented.

#### Fixed
- Double tap bug fixed

---

## 1.1.x
Released on 2015-10-09.

#### Fixed
- some property make private.
- layout bug fixed when zoom.

## 1.0.0
Released on 2015-10-09.

#### Added
- Tests for upload and download with progress.
  - Added by [Mattt Thompson](https://github.com/mattt).
- Test for question marks in url encoded query.
  - Added by [Mattt Thompson](https://github.com/mattt).
- The `NSURLSessionConfiguration` headers to `cURL` representation.
  - Added by [Matthias Ryne Cheow](https://github.com/rynecheow) in Pull Request
  [#140](https://github.com/Alamofire/Alamofire/pull/140).
- Parameter encoding tests for key/value pairs containing spaces.
  - Added by [Mattt Thompson](https://github.com/mattt).
- Percent character encoding for the `+` character.
  - Added by [Niels van Hoorn](https://github.com/nvh) in Pull Request
  [#167](https://github.com/Alamofire/Alamofire/pull/167).
- Escaping for quotes to support JSON in `cURL` commands.
  - Added by [John Gibb](https://github.com/johngibb) in Pull Request
  [#178](https://github.com/Alamofire/Alamofire/pull/178).
- The `request` method to the `Manager` bringing it more inline with the top-level methods.
  - Added by Brian Smith.
