## NEXT

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.8.0

* Deprecates `maxVideoDuration`/`maxDuration`, as it was never implemented on
  most platforms, and there is no plan to implement it in the future.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 2.7.4

* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Documents `getExposureOffsetStepSize` to return -1 if the device does not support
  exposure compensation.

## 2.7.3

* Adds documentation to clarify that platform implementations of the plugin use
  resolution presets as target resolutions.

## 2.7.2

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 2.7.1

* Fixes new lint warnings.

## 2.7.0

* Adds support for setting the image file format. See `CameraPlatform.setImageFileFormat`.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 2.6.0

* Adds support to control video fps and bitrate. See `CameraPlatform.createCameraWithSettings`.

## 2.5.2

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.5.1

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.5.0

* Adds NV21 as an image stream format (suitable for Android).
* Aligns Dart and Flutter SDK constraints.

## 2.4.1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 2.4.0

* Allows camera to be switched while video recording.
* Updates minimum Flutter version to 3.0.

## 2.3.4

* Updates code for stricter lint checks.

## 2.3.3

* Updates code for stricter lint checks.

## 2.3.2

* Updates MethodChannelCamera to have startVideoRecording call the newer startVideoCapturing.

## 2.3.1

* Exports VideoCaptureOptions to allow dependencies to implement concurrent stream and record.

## 2.3.0

* Adds new capture method for a camera to allow concurrent streaming and recording.

## 2.2.2

* Updates code for `no_leading_underscores_for_local_identifiers` lint.

## 2.2.1

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/104231).
* Ignores missing return warnings in preparation for [upcoming analysis changes](https://github.com/flutter/flutter/issues/105750).

## 2.2.0

* Adds image streaming to the platform interface.
* Removes unnecessary imports.

## 2.1.6

* Adopts `Object.hash`.
* Removes obsolete dependency on `pedantic`.

## 2.1.5

* Fixes asynchronous exceptions handling of the `initializeCamera` method.

## 2.1.4

* Removes dependency on `meta`.

## 2.1.3

*  Update to use the `verify` method introduced in platform_plugin_interface 2.1.0.

## 2.1.2

* Adopts new analysis options and fixes all violations.

## 2.1.1

* Add web-relevant docs to platform interface code.

## 2.1.0

* Introduces interface methods for pausing and resuming the camera preview.

## 2.0.1

* Update platform_plugin_interface version requirement.

## 2.0.0

- Stable null safety release.

## 1.6.0

- Added VideoRecordedEvent to support ending a video recording in the native implementation.

## 1.5.0

- Introduces interface methods for locking and unlocking the capture orientation.
- Introduces interface method for listening to the device orientation.

## 1.4.0

- Added interface methods to support auto focus.

## 1.3.0

- Introduces an option to set the image format when initializing.

## 1.2.0

- Added interface to support automatic exposure.

## 1.1.0

- Added an optional `maxVideoDuration` parameter to the `startVideoRecording` method, which allows implementations to limit the duration of a video recording.

## 1.0.4

- Added the torch option to the FlashMode enum, which when implemented indicates the flash light should be turned on continuously.

## 1.0.3

- Update Flutter SDK constraint.

## 1.0.2

- Added interface methods to support zoom features.

## 1.0.1

- Added interface methods for setting flash mode.

## 1.0.0

- Initial open-source release
