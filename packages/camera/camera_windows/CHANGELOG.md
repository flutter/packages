## 0.2.6+2

* Fixes compile errors under strict standards mode.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 0.2.6+1

* Fixes black bars on camera preview [#122966](https://github.com/flutter/flutter/issues/122966).

## 0.2.6

* Reverts streaming frame support, as the implementation was incorrect and never
  exposed.

## 0.2.5+1

* Updates C++ to Dart communication to use Pigeon.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 0.2.5

* Adds support for streaming frames.

## 0.2.4+1

* Updates to pigeon 21.

## 0.2.4

* Removes `maxVideoDuration`/`maxDuration`, as the feature was never exposed at
  the app-facing package level, and is deprecated at the platform interface
  level.

## 0.2.3

* Converts native platform calls to Pigeon.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.2.2

* Adds support to control video FPS and bitrate. See `CameraController.withSettings`.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 0.2.1+9

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 0.2.1+8

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.2.1+7

* Fixes unawaited_futures violations.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 0.2.1+6

* Sets a cmake_policy compatibility version to fix build warnings.
* Aligns Dart and Flutter SDK constraints.

## 0.2.1+5

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 0.2.1+4

* Updates code for stricter lint checks.

## 0.2.1+3

* Updates to latest camera platform interface but fails if user attempts to use streaming with recording (since streaming is currently unsupported on Windows).

## 0.2.1+2

* Updates code for `no_leading_underscores_for_local_identifiers` lint.
* Updates minimum Flutter version to 2.10.

## 0.2.1+1

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.2.1

* Adds a check for string size before Win32 MultiByte <-> WideChar conversions

## 0.2.0

**BREAKING CHANGES**:
  * `CameraException.code` now has value `"CameraAccessDenied"` if camera access permission was denied.
  * `CameraException.code` now has value `"camera_error"` if error occurs during capture.

## 0.1.0+5

* Fixes bugs in in error handling.

## 0.1.0+4

* Allows retrying camera initialization after error.

## 0.1.0+3

* Updates the README to better explain how to use the unendorsed package.

## 0.1.0+2

* Updates references to the obsolete master branch.

## 0.1.0+1

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.1.0

* Initial release
