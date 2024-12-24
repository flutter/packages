## 0.6.10+3

* Bumps com.google.guava:guava from 33.3.1-android to 33.4.0-android.

## 0.6.10+2

* Bumps camerax_version from 1.3.4 to 1.4.1.

## 0.6.10+1

* Removes nonnull annotation from MeteringPointHostApiImpl#getDefaultPointSize.

## 0.6.10

* Removes logic that explicitly removes `READ_EXTERNAL_STORAGE` permission that may be implied
  from `WRITE_EXTERNAL_STORAGE` and updates the README to tell users how to manually
  remove it from their app's merged manifest if they wish.

## 0.6.9+2

* Updates Java compatibility version to 11.

## 0.6.9+1

* Bumps `com.google.guava:guava` from `33.3.0` to `33.3.1`.

## 0.6.9

* Corrects assumption about automatic preview correction happening on API >= 29 to API > 29,
  based on the fact that the `ImageReader` Impeller backend is not used for the most part on
  devices running API 29+.

## 0.6.8+3

* Removes dependency on org.jetbrains.kotlin:kotlin-bom.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 0.6.8+2

* Marks uses of `Camera2Interop` with `@OptIn` annotation.

## 0.6.8+1

* Re-lands support for Impeller.

## 0.6.8

* Updates Guava version to 33.3.0.

## 0.6.7+2

* Updates lint checks to ignore NewerVersionAvailable.

## 0.6.7+1

* Updates README to remove references to `maxVideoDuration`, as it was never
  visible to app-facing clients, nor was it implemented in `camera_android`.

## 0.6.7

* Updates AGP version to 8.5.0.

## 0.6.6

* Adds logic to support building a camera preview with Android `Surface`s not backed by a `SurfaceTexture`
  to which CameraX cannot not automatically apply the transformation required to achieve the correct rotation.
* Adds fix for incorrect camera preview rotation on naturally landscape-oriented devices.
* Updates example app's minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 0.6.5+6

* Updates Guava version to 33.2.1.
* Updates CameraX version to 1.3.4.

## 0.6.5+5

* Reverts changes to support Impeller.

## 0.6.5+4

* [Supports Impeller](https://docs.flutter.dev/release/breaking-changes/android-surface-plugins).

## 0.6.5+3

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Adds notes to `README.md` about allowing image streaming in the background and the required
  `WRITE_EXTERNAL_STORAGE` permission specified in the plugin to allow writing photos and videos to
  files.

## 0.6.5+2

* Update to latest stable camerax `1.3.3`.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.6.5+1

* Updates `README.md` to reflect the fact that the `camera_android_camerax` camera plugin implementation
  is the endorsed Android implementation for `camera: ^0.11.0`.

## 0.6.5

* Modifies `stopVideoRecording` to ensure that the method only returns when CameraX reports that the
  recorded video finishes saving to a file.
* Modifies `startVideoCapturing` to ensure that the method only returns when CameraX reports that
  video recording has started.
* Adds empty implementation for `setDescriptionWhileRecording` and leaves a todo to add this feature.

## 0.6.4+1

* Adds empty implementation for `prepareForVideoRecording` since this optimization is not used on Android.

## 0.6.4

* Prevents usage of unsupported concurrent `UseCase`s based on the capabiliites of the camera device.

## 0.6.3

* Shortens default interval that internal Java `InstanceManager` uses to release garbage collected weak references to
  native objects.
* Dynamically shortens interval that internal Java `InstanceManager` uses to release garbage collected weak references to
  native objects when an `ImageAnalysis.Analyzer` is set/removed to account for increased memory usage of analyzing
  images that may cause a crash.

## 0.6.2

* Adds support to control video FPS and bitrate. See `CameraController.withSettings`.

## 0.6.1+1

* Moves integration_test dependency to dev_dependencies.

## 0.6.1

* Modifies resolution selection logic to use an `AspectRatioStrategy` for all aspect ratios supported by CameraX.
* Adds `ResolutionFilter` to resolution selection logic to prioritize resolutions that match
  the defined `ResolutionPreset`s.

## 0.6.0+1

* Updates `README.md` to encourage developers to opt into this implementation of the camera plugin.

## 0.6.0

* Implements `setFocusMode`, which makes this plugin reach feature parity with camera_android.
* Fixes `setExposureCompensationIndex` return value to use index returned by CameraX.

## 0.5.0+36

* Implements `setExposureMode`.

## 0.5.0+35

* Modifies `CameraInitializedEvent` that is sent when the camera is initialized to indicate that the initial focus
  and exposure modes are auto and that developers may set focus and exposure points.

## 0.5.0+34

* Implements `setFocusPoint`, `setExposurePoint`, and `setExposureOffset`.

## 0.5.0+33

* Fixes typo in `README.md`.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 0.5.0+32

* Removes all remaining `unawaited` calls to fix potential race conditions and updates the
  camera state when video capture starts.

## 0.5.0+31

* Wraps CameraX classes needed to set capture request options, which is needed to implement setting the exposure mode.

## 0.5.0+30

* Adds documentation to clarify how the plugin uses resolution presets as target resolutions for CameraX.

## 0.5.0+29

* Modifies `buildPreview` to return `Texture` that maps to camera preview, building in the assumption
  that `createCamera` should have been called before building the preview. Fixes
  https://github.com/flutter/flutter/issues/140567.

## 0.5.0+28

* Wraps CameraX classes needed to implement setting focus and exposure points and exposure offset.
* Updates compileSdk version to 34.

## 0.5.0+27

* Removes or updates any references to an `ActivityPluginBinding` when the plugin is detached
  or attached/re-attached, respectively, to an `Activity.`

## 0.5.0+26

* Fixes new lint warnings.

## 0.5.0+25

* Implements `lockCaptureOrientation` and `unlockCaptureOrientation`.

## 0.5.0+24

* Updates example app to use non-deprecated video_player method.

## 0.5.0+23

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Adds `CameraXProxy` class to test `JavaObject` creation and their method calls in the plugin.

## 0.5.0+22

* Fixes `_getResolutionSelectorFromPreset` null pointer error.

## 0.5.0+21

* Changes fallback resolution strategies for camera use cases to look for a higher resolution if neither the desired
  resolution nor any lower resolutions are available.

## 0.5.0+20

* Implements `setZoomLevel`.

## 0.5.0+19

* Implements torch flash mode.

## 0.5.0+18

* Implements `startVideoCapturing`.

## 0.5.0+17

* Implements resolution configuration for all camera use cases.

## 0.5.0+16

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.5.0+15

* Explicitly removes `READ_EXTERNAL_STORAGE` permission that may otherwise be implied from `WRITE_EXTERNAL_STORAGE`.

## 0.5.0+14

* Wraps classes needed to implement resolution configuration for video recording.

## 0.5.0+13

* Migrates `styleFrom` usage in examples off of deprecated `primary` and `onPrimary` parameters.

## 0.5.0+12

* Wraps classes needed to implement resolution configuration for image capture, image analysis, and preview.
* Removes usages of deprecated APIs for resolution configuration.
* Bumps CameraX version to 1.3.0-beta01.

## 0.5.0+11

* Fixes issue with image data not being emitted after relistening to stream returned by `onStreamedFrameAvailable`.

## 0.5.0+10

* Implements off, auto, and always flash mode configurations for image capture.

## 0.5.0+9

* Marks all Dart-wrapped Android native classes as `@immutable`.
* Updates `CONTRIBUTING.md` to note requirements of Dart-wrapped Android native classes.

## 0.5.0+8

* Fixes unawaited_futures violations.

## 0.5.0+7

* Updates Guava version to 32.0.1.

## 0.5.0+6

* Updates Guava version to 32.0.0.

## 0.5.0+5

* Updates `README.md` to fully cover unimplemented functionality.

## 0.5.0+4

* Removes obsolete null checks on non-nullable values.

## 0.5.0+3

* Fixes Java lints.

## 0.5.0+2

* Adds a dependency on kotlin-bom to align versions of Kotlin transitive dependencies.
* Removes note in `README.md` regarding duplicate Kotlin classes issue.

## 0.5.0+1

* Update `README.md` to include known duplicate Kotlin classes issue.

## 0.5.0

* Initial release of this `camera` implementation that supports:
    * Image capture
    * Video recording
    * Displaying a live camera preview
    * Image streaming

  See [`README.md`](README.md) for more details on the limitations of this implementation.
