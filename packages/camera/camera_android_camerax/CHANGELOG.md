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
