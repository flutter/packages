## 6.2.3

* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
* Clarified that `VideoEventType.initialized` cannot be sent more than once.

## 6.2.2

* Updates minimum required plugin_platform_interface version to 2.1.7.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 6.2.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 6.2.0

* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.
* Adds web options to customize control's list and displaying context menu.

## 6.1.0

* Aligns Dart and Flutter SDK constraints.
* Adds the `VideoEventType.isPlayingStateUpdate` event to track changes in play / pause state with
  the underlying video player.

## 6.0.2

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 6.0.1

* Fixes comment describing file URI construction.

## 6.0.0

* **BREAKING CHANGE**: Removes `MethodChannelVideoPlayer`. The default
  implementation is now only a placeholder with no functionality;
  implementations of `video_player` must include their own `VideoPlayerPlatform`
  Dart implementation.
* Updates minimum Flutter version to 2.10.
* Fixes violations of new analysis option use_named_constants.

## 5.1.4

* Fixes avoid_redundant_argument_values lint warnings and minor typos.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/106316).

## 5.1.3

* Updates references to the obsolete master branch.
* Removes unnecessary imports.

## 5.1.2

* Adopts `Object.hash`.
* Removes obsolete dependency on `pedantic`.

## 5.1.1

* Adds `rotationCorrection` (for Android playing videos recorded in landscapeRight [#60327](https://github.com/flutter/flutter/issues/60327)).

## 5.1.0

* Adds `allowBackgroundPlayback` to `VideoPlayerOptions`.

## 5.0.2

* Adds the Pigeon definitions used to create the method channel implementation.
* Internal code cleanup for stricter analysis options.

## 5.0.1

* Update to use the `verify` method introduced in platform_plugin_interface 2.1.0.

## 5.0.0

* **BREAKING CHANGES**:
  * Updates to extending `PlatformInterface`. Removes `isMock`, in favor of the
    now-standard `MockPlatformInterfaceMixin`.
  * Removes test.dart from the public interface. Tests in other packages should
    mock `VideoPlatformInterface` rather than the method channel.

## 4.2.0

* Add `contentUri` to `DataSourceType`.

## 4.1.0

* Add `httpHeaders` to `DataSource`

## 4.0.0

* **Breaking Changes**:
  * Migrate to null-safety
  * Update to latest Pigeon. This includes a breaking change to how the test logic is exposed.
* Add note about the `mixWithOthers` option being ignored on the web.
* Make DataSource's `uri` parameter nullable.
* `messages.dart` sets Dart `2.12`.

## 3.0.0

* Version 3 only was published as nullsafety "previews".

## 2.2.1

* Update Flutter SDK constraint.

## 2.2.0

* Added option to set the video playback speed on the video controller.

## 2.1.1

* Fix mixWithOthers test channel.

## 2.1.0

* Add VideoPlayerOptions with audio mix mode

## 2.0.2

* Migrated tests to use pigeon correctly.

## 2.0.1

* Updated minimum Dart version.
* Added class to help testing Pigeon communication.

## 2.0.0

* Migrated to [pigeon](https://pub.dev/packages/pigeon).

## 1.0.5

* Make the pedantic dev_dependency explicit.

## 1.0.4

* Remove the deprecated `author:` field from pubspec.yaml
* Require Flutter SDK 1.10.0 or greater.

## 1.0.3

* Document public API.

## 1.0.2

* Fix unawaited futures in the tests.

## 1.0.1

* Return correct platform event type when buffering

## 1.0.0

* Initial release.
