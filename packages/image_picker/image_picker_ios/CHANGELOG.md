## 0.8.12+2

* Removes the need for user permissions to pick an image on iOS 14+.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 0.8.12+1

* Updates Pigeon for non-nullable collection type support.
* Updates UI test photo element query for iOS 18.

## 0.8.12

* Re-adds Swift Package Manager compatibility.

## 0.8.11+2

* Temporarily remove Swift Package Manager compatibility to resolve issues with Cocoapods builds.

## 0.8.11+1

* Makes all headers public with Swift Package Manager integration to keep inline with CocoaPods.

## 0.8.11

* Adds Swift Package Manager compatibility.

## 0.8.10+1

* Fixes a possible crash when calling a picker method UIGraphicsImageRenderer if imageToScale is nil.

## 0.8.10

* Adds limit parameter to `MediaOptions` and `MultiImagePickerOptions` that sets a limit to how many media or image items can be selected.

## 0.8.9+2

* Updates minimum iOS version to 12.0 and minimum Flutter version to 3.16.6.
* Replaces deprecated UIGraphicsBeginImageContextWithOptions with UIGraphicsImageRenderer.

## 0.8.9+1

* Adds privacy manifest.

## 0.8.9

* Fixes resizing bug and updates rounding to be more accurate.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.8.8+4

* Updates to Pigeon 13.

## 0.8.8+3

* Fixes a possible crash when calling a picker method while another is waiting on permissions.

## 0.8.8+2

* Adds pub topics to package metadata.

## 0.8.8+1

* Fixes exception when canceling pickMultipleMedia.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.8.8

* Adds `getMedia` and `getMultipleMedia` methods.

## 0.8.7+4

* Fixes `BuildContext` handling in example.
* Updates metadata unit test to work on iOS 16.2.

## 0.8.7+3

* Updates pigeon to fix warnings with clang 15.
* Updates minimum Flutter version to 3.3.

## 0.8.7+2

* Updates to `pigeon` version 9.

## 0.8.7+1

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 0.8.7

* Updates minimum Flutter version to 3.3 and iOS 11.

## 0.8.6+9

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.8.6+8

* Fixes issue with images sometimes changing to incorrect orientation.

## 0.8.6+7

* Fixes issue where GIF file would not animate without `Photo Library Usage` permissions. Fixes issue where PNG and GIF files were converted to JPG, but only when they are do not have `Photo Library Usage` permissions.
* Updates minimum Flutter version to 3.0.

## 0.8.6+6

* Updates code for stricter lint checks.

## 0.8.6+5

* Fixes crash when `imageQuality` is set.

## 0.8.6+4

* Fixes authorization status check for iOS14+ so it includes `PHAuthorizationStatusLimited`.

## 0.8.6+3

* Returns error on image load failure.

## 0.8.6+2

* Fixes issue where selectable images of certain types (such as ProRAW images) could not be loaded.

## 0.8.6+1

* Fixes issue with crashing the app when picking images with PHPicker without providing `Photo Library Usage` permission.

## 0.8.6

* Adds `requestFullMetadata` option to `pickImage`, so images on iOS can be picked without `Photo Library Usage` permission.
* Updates minimum Flutter version to 2.10.

## 0.8.5+6

* Updates description.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/106316).

## 0.8.5+5

* Adds non-deprecated codepaths for iOS 13+.

## 0.8.5+4

* Suppresses warnings for pre-iOS-11 codepaths.

## 0.8.5+3

* Fixes 'messages.g.h' file not found.

## 0.8.5+2

* Minor fixes for new analysis options.

## 0.8.5+1

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.8.5

* Switches to an in-package method channel based on Pigeon.
* Fixes invalid casts when selecting multiple images on versions of iOS before
  14.0.

## 0.8.4+11

* Splits from `image_picker` as a federated implementation.
