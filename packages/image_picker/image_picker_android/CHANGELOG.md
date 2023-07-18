## 0.8.7+3

* Bumps androidx.activity:activity from 1.7.1 to 1.7.2.

## 0.8.7+2

* Fixes a crash case when picking an image with a display name that does not contain a period.

## 0.8.7+1

* Bumps org.jetbrains.kotlin:kotlin-bom from 1.8.21 to 1.8.22.

## 0.8.7

* Adds `getMedia` method.

## 0.8.6+20

* Bumps androidx.activity:activity from 1.7.0 to 1.7.1.

## 0.8.6+19

* Bumps androidx.core:core from 1.9.0 to 1.10.1.

## 0.8.6+18

* Bumps org.jetbrains.kotlin:kotlin-bom from 1.8.10 to 1.8.21.

## 0.8.6+17

* Moves disk accesses to background thread.

## 0.8.6+16

* Fixes crashes caused by `SecurityException` when calling `getPathFromUri()`.

## 0.8.6+15

* Bumps androidx.activity:activity from 1.6.1 to 1.7.0.

## 0.8.6+14

* Fixes Java warnings.

## 0.8.6+13

* Fixes `BuildContext` handling in example.

## 0.8.6+12

* Improves image resizing performance by decoding Bitmap only when needed.

## 0.8.6+11

* Updates gradle to 7.6.1.
* Updates gradle, AGP and fixes some lint errors.

## 0.8.6+10

* Offloads picker result handling to separate thread.

## 0.8.6+9

* Fixes compatibility with AGP versions older than 4.2.

## 0.8.6+8

* Adds a namespace for compatibility with AGP 8.0.

## 0.8.6+7

* Fixes handling of non-bitmap image types.
* Updates minimum Flutter version to 3.3.

## 0.8.6+6

* Bumps androidx.core:core from 1.8.0 to 1.9.0.

## 0.8.6+5

* Fixes case when file extension returned from the OS does not match its real mime type.

## 0.8.6+4

* Bumps androidx.exifinterface:exifinterface from 1.3.3 to 1.3.6.

## 0.8.6+3

* Switches to Pigeon for internal implementation.

## 0.8.6+2

* Fixes null pointer exception in `saveResult`.

## 0.8.6+1

* Refactors code in preparation for adopting Pigeon.

## 0.8.6

* Adds `usePhotoPickerAndroid` options.

## 0.8.5+10

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 0.8.5+9

* Fixes compilation warnings.
* Updates compileSdkVersion to 33.

## 0.8.5+8

* Adds Android 13 photo picker functionality if SDK version is at least 33.
* Bumps compileSdkVersion from 31 to 33

## 0.8.5+7

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.8.5+6

* Updates minimum Flutter version to 3.0.
* Fixes names of picked files to match original filenames where possible.

## 0.8.5+5

* Updates code for stricter lint checks.

## 0.8.5+4

* Fixes null cast exception when restoring a cancelled selection.

## 0.8.5+3

* Updates minimum Flutter version to 2.10.
* Bumps gradle from 7.1.2 to 7.2.1.

## 0.8.5+2

* Updates `image_picker_platform_interface` constraint to the correct minimum
  version.

## 0.8.5+1

* Switches to an internal method channel implementation.

## 0.8.5

* Updates gradle to 7.1.2.

## 0.8.4+13

* Minor fixes for new analysis options.

## 0.8.4+12

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.8.4+11

* Splits from `image_picker` as a federated implementation.
