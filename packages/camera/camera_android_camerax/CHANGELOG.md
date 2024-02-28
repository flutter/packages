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
