## 2.7.0

* Adds support for platform views as an optional way of displaying a video.

## 2.6.7

* Fixes playback speed resetting.

## 2.6.6

* Fixes changing global audio session category to be collision free across plugins.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.6.5

* Bugfix to allow the audio-only HLS (.m3u8) on iOS.

## 2.6.4

* Refactors native code structure.

## 2.6.3

* Fixes VideoPlayerController.initialize() future never resolving with invalid video file.
* Adds more details to the error message returned by VideoPlayerController.initialize().

## 2.6.2

* Updates Pigeon for non-nullable collection type support.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 2.6.1

* Adds files to make include directory permanent.

## 2.6.0

* Adds Swift Package Manager compatibility.

## 2.5.7

* Adds frame availability checks on iOS.
* Simplifies internal platform channel interfaces.
* Updates minimum iOS version to 12.0 and minimum Flutter version to 3.16.6.

## 2.5.6

* Adds privacy manifest.

## 2.5.5

* Fixes display of initial frame when paused.

## 2.5.4

* Fixes new lint warnings.

## 2.5.3

* Publishes an instance of the plugin to the registrar on macOS, as on iOS.

## 2.5.2

* Fixes flickering and seek-while-paused on macOS.

## 2.5.1

* Updates to  Pigeon 13.

## 2.5.0

* Adds support for macOS.

## 2.4.11

* Updates Pigeon.
* Changes Objective-C class prefixes to avoid future collisions.

## 2.4.10

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.4.9

* Fixes the iOS crash when using multiple players on the same screen.
  See: https://github.com/flutter/flutter/issues/124937

## 2.4.8

* Fixes missing `isPlaybackLikelyToKeepUp` check for iOS video player `bufferingEnd` event and `bufferingStart` event.

## 2.4.7

* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.
* Adds iOS exception on incorrect asset path

## 2.4.6

* Fixes hang when seeking to end of video.

## 2.4.5

* Updates functions without a prototype to avoid deprecation warning.

## 2.4.4

* Updates pigeon to fix warnings with clang 15.

## 2.4.3

* Synchronizes `VideoPlayerValue.isPlaying` with `AVPlayer`.

## 2.4.2

* Makes seekTo async and only complete when AVPlayer.seekTo completes.

## 2.4.1

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.4.0

* Updates minimum Flutter version to 3.3 and iOS 11.

## 2.3.9

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.3.8

* Adds compatibilty with version 6.0 of the platform interface.
* Fixes file URI construction in example.
* Updates code for new analysis options.
* Adds an integration test for a bug where the aspect ratios of some HLS videos are incorrectly inverted.
* Removes an unnecessary override in example code.

## 2.3.7

* Fixes a bug where the aspect ratio of some HLS videos are incorrectly inverted.
* Updates code for `no_leading_underscores_for_local_identifiers` lint.

## 2.3.6

* Fixes a bug in iOS 16 where videos from protected live streams are not shown.
* Updates minimum Flutter version to 2.10.
* Fixes violations of new analysis option use_named_constants.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/106316).

## 2.3.5

* Updates references to the obsolete master branch.

## 2.3.4

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.3.3

* Fix XCUITest based on the new voice over announcement for tooltips.
  See: https://github.com/flutter/flutter/pull/87684

## 2.3.2

* Applies the standardized transform for videos with different orientations.

## 2.3.1

* Renames internal method channels to avoid potential confusion with the
  default implementation's method channel.
* Updates Pigeon to 2.0.1.

## 2.3.0

* Updates Pigeon to ^1.0.16.

## 2.2.18

* Wait to initialize m3u8 videos until size is set, fixing aspect ratio.
* Adjusts test timeouts for network-dependent native tests to avoid flake.

## 2.2.17

* Splits from `video_player` as a federated implementation.
