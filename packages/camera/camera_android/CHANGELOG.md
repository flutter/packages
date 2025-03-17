## 0.10.10+1

* Updates compileSdk 34 to flutter.compileSdkVersion.

## 0.10.10

* Adds API support query for image streaming.

## 0.10.9+17

* Updates annotations lib to 1.9.1.

## 0.10.9+16

* Updates annotations lib to 1.9.0.

## 0.10.9+15

* Converts Dart to native platform calls to Pigeon.

## 0.10.9+14

* Converts native to Dart platform calls to Pigeon.

## 0.10.9+13

* Converts `getAvailableCameras` to Pigeon.

## 0.10.9+12

* Updates Java compatibility version to 11.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 0.10.9+11

* Updates annotations lib to 1.8.2.

## 0.10.9+10

* Updates annotations lib to 1.8.1.

## 0.10.9+9

* Updates lint checks to ignore NewerVersionAvailable.

## 0.10.9+8

* Removes unused code related to `maxVideoDuration`.

## 0.10.9+7

* Updates Android Gradle plugin to 8.5.0.

## 0.10.9+6

* Reverts changes to support Impeller.

## 0.10.9+5

* Updates annotations lib to 1.8.0.

## 0.10.9+4

* [Supports Impeller](https://docs.flutter.dev/release/breaking-changes/android-surface-plugins).

## 0.10.9+3

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 0.10.9+2

* Updates `README.md` to reflect the fact that the `camera_android_camerax` camera plugin implementation
  is the endorsed Android implementation for `camera: ^0.11.0`.

## 0.10.9+1

* Changes the visibility of a number of fields to `@VisibleForTesting` in order simplify testing.

## 0.10.9

* Adds support to control video FPS and bitrate. See `CameraController.withSettings`.

## 0.10.8+18

* Updates annotations lib to 1.7.1.

## 0.10.8+17

* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Updates compileSdk version to 34.
* Updates `README.md` to encourage developers to opt into `camera_android_camerax`.

## 0.10.8+16

* Fixes new lint warnings.

## 0.10.8+15

* Updates example app to use non-deprecated video_player method.

## 0.10.8+14

* Fixes `pausePreview` null pointer error. `pausePreview` should not be called
  when camera is closed or not configured.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.10.8+13

* Updates annotations lib to 1.7.0.

## 0.10.8+12

* Fixes handling of autofocus state when taking a picture.

## 0.10.8+11

* Downgrades AGP version for compatibility with legacy projects.

## 0.10.8+10

* Sets android.defaults.buildfeatures.buildconfig to true for compatibility with AGP 8.0+.

## 0.10.8+9

* Removes usage of `_ambiguate` method in example.

## 0.10.8+8

* Adds pub topics to package metadata.

## 0.10.8+7

* Fixes video record crash on Android versions lower than 12.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.10.8+6

* Migrates `styleFrom` usage in examples off of deprecated `primary` and `onPrimary` parameters.

## 0.10.8+5

* Provides a default exposure point if null.

## 0.10.8+4

* Adjusts SDK checks for better testability.

## 0.10.8+3

* Fixes unawaited_futures violations.
* Removes duplicate line in `MediaRecorderBuilder.java`.
* Adds support for concurrently capturing images and image streaming/recording.

## 0.10.8+2

* Removes obsolete null checks on non-nullable values.

## 0.10.8+1

* Fixes lint errors.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 0.10.8

* Updates gradle, AGP and fixes some lint errors.

## 0.10.7

* Adds support for NV21 as a new streaming format in Android which includes correct handling of
  image padding when present.

## 0.10.6+2

* Fixes compatibility with AGP versions older than 4.2.

## 0.10.6+1

* Adds a namespace for compatibility with AGP 8.0.

## 0.10.6

* Fixes Java warnings.

## 0.10.5

* Allows camera to be switched while video recording.

## 0.10.4+3

* Clarifies explanation of endorsement in README.

## 0.10.4+2

* Aligns Dart and Flutter SDK constraints.
* Updates compileSdkVersion to 33.
* Fixes false positive for CamcorderProfile deprecation warning
  that was already fixed.
* Changes the severity of `javac` warnings so that they are treated as errors and fixes the violations.

## 0.10.4+1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.10.4

* Temporarily fixes issue with requested video profiles being null by falling back to deprecated behavior in that case.

## 0.10.3

* Adds back use of Optional type.
* Updates minimum Flutter version to 3.0.

## 0.10.2+3

* Updates code for stricter lint checks.

## 0.10.2+2

* Fixes zoom computation for virtual cameras hiding physical cameras in Android 11+.
* Removes the unused CameraZoom class from the codebase.

## 0.10.2+1

* Updates code for stricter lint checks.

## 0.10.2

* Remove usage of deprecated quiver Optional type.

## 0.10.1

* Implements an option to also stream when recording a video.

## 0.10.0+5

* Fixes `ArrayIndexOutOfBoundsException` when the permission request is interrupted.

## 0.10.0+4

* Upgrades `androidx.annotation` version to 1.5.0.

## 0.10.0+3

* Updates code for `no_leading_underscores_for_local_identifiers` lint.

## 0.10.0+2

* Removes call to `join` on the camera's background `HandlerThread`.
* Updates minimum Flutter version to 2.10.

## 0.10.0+1

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.10.0

* **Breaking Change** Updates Android camera access permission error codes to be consistent with other platforms. If your app still handles the legacy `cameraPermission` exception, please update it to handle the new permission exception codes that are noted in the README.
* Ignores missing return warnings in preparation for [upcoming analysis changes](https://github.com/flutter/flutter/issues/105750).

## 0.9.8+3

* Skips duplicate calls to stop background thread and removes unnecessary closings of camera capture sessions on Android.

## 0.9.8+2

* Fixes exception in registerWith caused by the switch to an in-package method channel.

## 0.9.8+1

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.9.8

* Switches to internal method channel implementation.

## 0.9.7+1

* Splits from `camera` as a federated implementation.
