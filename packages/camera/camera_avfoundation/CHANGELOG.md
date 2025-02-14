## 0.9.18+6

* Refactors implementations to remove remaining usage of OCMock in internal testing.

## 0.9.18+5

* Migrates unit tests to Swift.

## 0.9.18+4

* Refactors implementations to reduce usage of OCMock in internal testing.

## 0.9.18+3

* Refactors implementations to reduce usage of OCMock in internal testing.

## 0.9.18+2

* Refactors implementations to reduce usage of OCMock in internal testing.

## 0.9.18+1

* Refactors implementations to reduce usage of OCMock in internal testing.

## 0.9.18

* Adds API support query for image streaming.

## 0.9.17+7

* Fixes changing global audio session category to be collision free across plugins.

## 0.9.17+6

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes OCMock usage from permission tests

## 0.9.17+5

* Adds ability to use any supported FPS and fixes crash when using unsupported FPS.

## 0.9.17+4

* Updates Pigeon for non-nullable collection type support.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 0.9.17+3

* Fixes deallocation of camera on dispose.

## 0.9.17+2

* Fixes stopVideoRecording waiting indefinitely and lag at start of video.

## 0.9.17+1

* Fixes a crash due to appending sample buffers when readyForMoreMediaData is NO.

## 0.9.17

* Adds Swift Package Manager compatibility.

## 0.9.16+3

* Removes unused `maxVideoDuration` code.

## 0.9.16+2

* Fixes regression taking a picture in torch mode.

## 0.9.16+1

* Fixes sample times not being numeric after pause/resume.

## 0.9.16

* Converts Dart-to-host communcation to Pigeon.
* Fixes a race condition in camera disposal.

## 0.9.15+4

* Converts host-to-Dart communcation to Pigeon.

## 0.9.15+3

* Moves `pigeon` to `dev_dependencies`.

## 0.9.15+2

* Converts camera query to Pigeon.

## 0.9.15+1

* Simplifies internal handling of method channel responses.

## 0.9.15

* Adds support to control video FPS and bitrate. See `CameraController.withSettings`.

## 0.9.14+2

* Removes `_ambiguate` methods from example code.

## 0.9.14+1

* Fixes bug where max resolution preset does not produce highest available resolution on iOS.

## 0.9.14

* Adds support to HEIF format.

## 0.9.13+11

* Fixes a memory leak of sample buffer when pause and resume the video recording.
* Removes development team from example app.
* Updates minimum iOS version to 12.0 and minimum Flutter version to 3.16.6.

## 0.9.13+10

* Adds privacy manifest.

## 0.9.13+9

* Fixes new lint warnings.

## 0.9.13+8

* Updates example app to use non-deprecated video_player method.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.9.13+7

* Fixes inverted orientation strings.

## 0.9.13+6

* Fixes incorrect use of `NSError` that could cause crashes on launch.

## 0.9.13+5

* Ignores audio samples until the first video sample arrives.

## 0.9.13+4

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.9.13+3

* Migrates `styleFrom` usage in examples off of deprecated `primary` and `onPrimary` parameters.
* Fixes unawaited_futures violations.

## 0.9.13+2

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 0.9.13+1

* Clarifies explanation of endorsement in README.

## 0.9.13

* Allows camera to be switched while video recording.
* Aligns Dart and Flutter SDK constraints.

## 0.9.12

* Updates minimum Flutter version to 3.3 and iOS 11.

## 0.9.11+1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.9.11

* Adds back use of Optional type.
* Updates minimum Flutter version to 3.0.

## 0.9.10+2

* Updates code for stricter lint checks.

## 0.9.10+1

* Updates code for stricter lint checks.

## 0.9.10

* Remove usage of deprecated quiver Optional type.

## 0.9.9

* Implements option to also stream when recording a video.

## 0.9.8+6

* Updates code for `no_leading_underscores_for_local_identifiers` lint.
* Updates minimum Flutter version to 2.10.

## 0.9.8+5

* Fixes a regression introduced in 0.9.8+4 where the stream handler is not set.

## 0.9.8+4

* Fixes a crash due to sending orientation change events when the engine is torn down.

## 0.9.8+3

* Fixes avoid_redundant_argument_values lint warnings and minor typos.
* Ignores missing return warnings in preparation for [upcoming analysis changes](https://github.com/flutter/flutter/issues/105750).

## 0.9.8+2

* Fixes exception in registerWith caused by the switch to an in-package method channel.

## 0.9.8+1

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.9.8

* Switches to internal method channel implementation.

## 0.9.7+1

* Splits from `camera` as a federated implementation.
