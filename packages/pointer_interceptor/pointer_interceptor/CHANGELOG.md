## NEXT

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 0.10.1+2

* Adds performance warning about using multiple pointer interceptors on iOS.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.10.1+1

* Updates support matrix in README to indicate that iOS 11 is no longer supported.
* Clients on versions of Flutter that still support iOS 11 can continue to use this
  package with iOS 11, but will not receive any further updates to the iOS implementation.
* Removes invalid `implements` tag in pubspec.

## 0.10.1

* Fixes new lint warnings.

## 0.10.0

* Transitions to federated architecture.
* Adds iOS implementation to federated package.

## 0.9.3+7

* Updates metadata to point to new source folder.

## 0.9.3+6

* Migrates to `dart:ui_web` APIs.
* Updates minimum supported SDK version to Flutter 3.13.0/Dart 3.1.0.

## 0.9.3+5

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Aligns Dart and Flutter SDK constraints.

##  0.9.3+4

* Removes const keyword from PointerInterceptor's constructor.
* Updates minimum Flutter version to 3.0.

## 0.9.3+3

* Fixes lint warnings.

## 0.9.3+2

* (Temporarily) helps tests introduced in prior version to pass in `stable`.
  (This will be removed when `master` rolls to `stable`)
* Updates README to reference the correct github URL.

## 0.9.3+1

* Updates example code and integration tests to accomodate hit-testing changes in the Flutter web engine.

## 0.9.3

* Require minimal version of flutter SDK to be `2.10`

## 0.9.2

* Marked `PointerInterceptor` as invisible, so it can be optimized by the engine.
* (Version Retracted. This attempted to use an API from Flutter `2.10` in earlier versions of Flutter. Fixed in v0.9.3)

## 0.9.1

* Removed `android` and `ios` directories from `example`, as the example doesn't
  build for those platforms.
* Added `intercepting` field to allow for conditional pointer interception

## 0.9.0+1

* Change sizing of HtmlElementView so it works well when slotted.

## 0.9.0

* Migrates to null safety.

## 0.8.0+2

* Use `ElevatedButton` instead of the deprecated `RaisedButton` in example and docs.

## 0.8.0+1

* Update README.md so images render in pub.dev

## 0.8.0

* Initial release of the `PointerInterceptor` widget.
