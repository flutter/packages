// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'platform_interface/platform_interface.dart';

/// Allow the SDK to track progress of the content video.
///
/// Provides updates required to enable triggering ads at configured cue points.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro interactive_media_ads.ContentProgressProvider.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final ContentProgressProvider provider = ContentProgressProvider();
///
/// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
///   final IOSContentProgressProvider iosProvider =
///       provider.platform as IOSContentProgressProvider;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidContentProgressProvider androidProvider =
///       provider.platform as AndroidContentProgressProvider;
/// }
/// ```
class ContentProgressProvider {
  /// Constructs an [ContentProgressProvider].
  ///
  /// See [ContentProgressProvider.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  ContentProgressProvider()
      : this.fromPlatformCreationParams(
          const PlatformContentProgressProviderCreationParams(),
        );

  /// Constructs an [ContentProgressProvider] from creation params for a
  /// specific platform.
  ///
  /// {@template interactive_media_ads.ContentProgressProvider.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// iOS and Android:
  ///
  /// ```dart
  /// PlatformContentProgressProviderCreationParams params =
  ///     const PlatformContentProgressProviderCreationParams();
  ///
  /// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
  ///   params = IOSContentProgressProviderCreationParams
  ///       .fromPlatformContentProgressProviderCreationParams(
  ///     params,
  ///   );
  /// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
  ///   params = AndroidContentProgressProviderCreationParams
  ///       .fromPlatformContentProgressProviderCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final ContentProgressProvider provider = ContentProgressProvider.fromPlatformCreationParams(
  ///   params,
  /// );
  /// ```
  /// {@endtemplate}
  ContentProgressProvider.fromPlatformCreationParams(
    PlatformContentProgressProviderCreationParams params,
  ) : this.fromPlatform(PlatformContentProgressProvider(params));

  /// Constructs a [ContentProgressProvider] from a specific platform
  /// implementation.
  ContentProgressProvider.fromPlatform(this.platform);

  /// Implementation of [PlatformContentProgressProvider] for the current
  /// platform.
  final PlatformContentProgressProvider platform;

  /// Sends an update on the progress of the content video.
  ///
  /// When using a `Timer` to periodically send updates through this method, an
  /// interval of 200ms is recommended.
  Future<void> setProgress({
    required Duration progress,
    required Duration duration,
  }) {
    return platform.setProgress(progress: progress, duration: duration);
  }
}
