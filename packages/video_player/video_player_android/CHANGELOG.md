## NEXT

* Suppresses deprecation and removal warnings for
  `TextureRegistry.SurfaceProducer.onSurfaceDestroyed`.

## 2.7.17

* Replaces deprecated Android embedder APIs (`onSurfaceCreated` -> `onSurfaceAvailable`).
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.7.16

* Updates internal Pigeon API to use newer features.

## 2.7.15

* Changes the rotation correction calculation for Android API 29+ to use
  the one that is reported by the video's format instead of the unapplied
  rotation degrees that Exoplayer does not report on Android API 21+.
* Changes the rotation correction calculation for Android APIs 21-28 to 0
  because the Impeller backend used on those API versions correctly rotates
  the video being played automatically.

## 2.7.14

* Removes SSL workaround for API 19, which is no longer supported.

## 2.7.13

* When `AndroidVideoPlayer` attempts to operate on a `textureId` that is not
  active (i.e. it was previously disposed or never created), the resulting
  platform exception is more informative than a "NullPointerException".

## 2.7.12

* Fixes a [bug](https://github.com/flutter/flutter/issues/156451) where
  additional harmless but annoying warnings in the form of native stack traces
  would be printed when the app was backgrounded. There may be additional
  warnings that are not yet fixed, but this should address the
  most common case.

## 2.7.11

* Fixes a [bug](https://github.com/flutter/flutter/issues/156158) where a
  harmless but annoying warning in the form of a native stack trace would be
  printed when a previously disposed video player received a trim memory event
  (i.e. by backgrounding).

## 2.7.10

* Fixes a [bug](https://github.com/flutter/flutter/issues/156158) where
  disposing a video player (including implicitly by switching tabs or views
  in a running app) would cause native stack traces.

## 2.7.9

* Updates Java compatibility version to 11.

## 2.7.8

* Updates Pigeon for non-nullable collection type support.

## 2.7.7

* Removes the flag to treat warnings as errors in client builds.

## 2.7.6

* Fixes a [bug](https://github.com/flutter/flutter/issues/154602) where
  resuming a video player would cause a `Bad state: Future already completed`.

## 2.7.5

* Add a deprecation suppression in advance of a new `SurfaceProducer` API.

## 2.7.4

* Fixes a [bug](https://github.com/flutter/flutter/issues/154559) where
  resuming (or using a plugin like `share_plus` that implicitly resumes the
  activity where) a video player would cause a `DecoderInitializationException`.

## 2.7.3

* Updates Media3-ExoPlayer to 1.4.1.

## 2.7.2

* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

* Re-adds Impeller support.

## 2.7.1

* Revert Impeller support.

## 2.7.0

* Re-adds [support for Impeller](https://docs.flutter.dev/release/breaking-changes/android-surface-plugins).

## 2.6.0

* Adds RTSP support.

## 2.5.4

* Updates Media3-ExoPlayer to 1.4.0.

## 2.5.3

* Updates lint checks to ignore NewerVersionAvailable.

## 2.5.2

* Updates Android Gradle plugin to 8.5.0.

## 2.5.1

* Removes additional references to the v1 Android embedding.

## 2.5.0

* Migrates ExoPlayer to Media3-ExoPlayer 1.3.1.

## 2.4.17

* Revert Impeller support.

## 2.4.16

* [Supports Impeller](https://docs.flutter.dev/release/breaking-changes/android-surface-plugins).

## 2.4.15

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 2.4.14

* Calls `onDestroy` instead of `initialize` in onDetachedFromEngine.

## 2.4.13

* Updates minSdkVersion to 19.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 2.4.12

* Updates compileSdk version to 34.
* Adds error handling for `BehindLiveWindowException`, which may occur upon live-video playback failure.

## 2.4.11

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 2.4.10

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.4.9

* Bumps ExoPlayer version to 2.18.7.

## 2.4.8

* Bumps ExoPlayer version to 2.18.6.

## 2.4.7

* Fixes Java warnings.

## 2.4.6

* Fixes compatibility with AGP versions older than 4.2.

## 2.4.5

* Adds a namespace for compatibility with AGP 8.0.

## 2.4.4

* Synchronizes `VideoPlayerValue.isPlaying` with `ExoPlayer`.
* Updates minimum Flutter version to 3.3.

## 2.4.3

* Bumps ExoPlayer version to 2.18.5.

## 2.4.2

* Bumps ExoPlayer version to 2.18.4.

## 2.4.1

* Changes the severity of `javac` warnings so that they are treated as errors and fixes the violations.

## 2.4.0

* Allows setting the ExoPlayer user agent by passing a User-Agent HTTP header.

## 2.3.12

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.
* Updates compileSdkVersion to 33.

## 2.3.11

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.3.10

* Adds compatibilty with version 6.0 of the platform interface.
* Fixes file URI construction in example.
* Updates code for new analysis options.
* Updates code for `no_leading_underscores_for_local_identifiers` lint.
* Updates minimum Flutter version to 2.10.
* Fixes violations of new analysis option use_named_constants.
* Removes an unnecessary override in example code.

## 2.3.9

* Updates ExoPlayer to 2.18.1.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.3.8

* Updates ExoPlayer to 2.18.0.

## 2.3.7

* Bumps gradle version to 7.2.1.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/106316).

## 2.3.6

* Updates references to the obsolete master branch.

## 2.3.5

* Sets rotationCorrection for videos recorded in landscapeRight (https://github.com/flutter/flutter/issues/60327).

## 2.3.4

* Updates ExoPlayer to 2.17.1.

## 2.3.3

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.3.2

* Updates ExoPlayer to 2.17.0.

## 2.3.1

* Renames internal method channels to avoid potential confusion with the
  default implementation's method channel.
* Updates Pigeon to 2.0.1.

## 2.3.0

* Updates Pigeon to ^1.0.16.

## 2.2.17

* Splits from `video_player` as a federated implementation.
