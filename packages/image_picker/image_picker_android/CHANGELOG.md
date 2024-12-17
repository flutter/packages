## 0.8.12+18

* Fixes a security issue related to improperly trusting filenames provided by a `ContentProvider`.

## 0.8.12+17

* Bumps androidx.annotation:annotation from 1.8.2 to 1.9.0.

## 0.8.12+16

* Updates Pigeon for non-nullable collection type support.

## 0.8.12+15

* Updates Java compatibility version to 11.

## 0.8.12+14

* Bumps androidx.activity:activity from 1.9.1 to 1.9.2.

## 0.8.12+13

* Removes dependency on org.jetbrains.kotlin:kotlin-bom.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 0.8.12+12

* Bumps androidx.annotation:annotation from 1.8.1 to 1.8.2.

## 0.8.12+11

* Bumps androidx.annotation:annotation from 1.8.0 to 1.8.1.

## 0.8.12+10

* Bumps androidx.activity:activity from 1.9.0 to 1.9.1.

## 0.8.12+9

* Bumps androidx.annotation:annotation from 1.7.1 to 1.8.0.

## 0.8.12+8

* Updates lint checks to ignore NewerVersionAvailable.

## 0.8.12+7

* Bumps androidx.activity:activity from 1.8.2 to 1.9.0.

## 0.8.12+6

* Bumps androidx.activity:activity from 1.7.2 to 1.8.2.

## 0.8.12+5

* Updates Android Gradle Plugin to 8.5.1.

## 0.8.12+4

* Bumps androidx.core:core from 1.10.1 to 1.13.1.

## 0.8.12+3

* Update documentation to note that limit is not always supported.

## 0.8.12+2

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 0.8.12+1

* Fixes another app crash case on Android 12+, and refactors getting of paths from intents.

## 0.8.12

* Fixes app crashes on Android 12+ caused by selecting images with size 0.

## 0.8.11

* Updates documentation to note that Android Photo Picker use is not optional on Android 13+.

## 0.8.10

* Adds limit parameter to `MediaOptions` and `MultiImagePickerOptions` that sets a limit to how many media or image items can be selected.

## 0.8.9+6

* Updates minSdkVersion to 19.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.8.9+5

* Bumps androidx.exifinterface:exifinterface from 1.3.6 to 1.3.7.

## 0.8.9+4

* Minimizes scope of deprecation warning suppression to only the versions where it is required.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Updates compileSdk version to 34.

## 0.8.9+3

* Bumps androidx.annotation:annotation from 1.7.0 to 1.7.1.

## 0.8.9+2

* Fixes new lint warnings.

## 0.8.9+1

* Updates plugin and example Gradle versions to 7.6.3.

## 0.8.9

* Fixes resizing bug and updates rounding to be more accurate.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.8.8+2

* Updates annotations lib to 1.7.0.

## 0.8.8+1

* Fixes NullPointerException on pre-Android 13 devices when using Android Photo Picker to pick image or video.

## 0.8.8

* Adds additional category II and III exif tags to be copied during photo resize.

## 0.8.7+5

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.8.7+4

* Updates the example to use the latest versions of the platform interface APIs.

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
