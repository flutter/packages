// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'platform_interface/platform_interface.dart';

/// Handles playing ads after they've been received from the server.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro interactive_media_ads.AdDisplayContainer.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final AdDisplayContainer container = AdDisplayContainer();
///
/// if (InteractiveMediaAdsPlatform.instance is IosInteractiveMediaAdsPlatform) {
///   final IosAdDisplayContainer iosContainer = container.platform as IosAdDisplayContainer;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidAdDisplayContainer androidContainer =
///       container.platform as AndroidAdDisplayContainer;
/// }
/// ```
class AdDisplayContainer {
  /// Constructs an [AdDisplayContainer].
  ///
  /// See [AdDisplayContainer.fromPlatformCreationParams] for setting parameters for a
  /// specific platform.
  AdDisplayContainer()
      : this.fromPlatformCreationParams(
          const PlatformAdDisplayContainerCreationParams(),
        );

  /// Constructs an [AdDisplayContainer] from creation params for a specific platform.
  ///
  /// {@template interactive_media_ads.AdDisplayContainer.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// iOS and Android:
  ///
  /// ```dart
  /// PlatformAdDisplayContainerCreationParams params =
  ///     const PlatformAdDisplayContainerCreationParams();
  ///
  /// if (InteractiveMediaAdsPlatform.instance is IosInteractiveMediaAdsPlatform) {
  ///   params = IosAdDisplayContainerCreationParams
  ///       .fromPlatformAdDisplayContainerCreationParams(
  ///     params,
  ///   );
  /// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
  ///   params = AndroidAdDisplayContainerCreationParams
  ///       .fromPlatformAdDisplayContainerCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final AdDisplayContainer container = AdDisplayContainer.fromPlatformCreationParams(
  ///   params,
  /// );
  /// ```
  /// {@endtemplate}
  AdDisplayContainer.fromPlatformCreationParams(
    PlatformAdDisplayContainerCreationParams params,
  ) : this.fromPlatform(PlatformAdDisplayContainer(params));

  /// Constructs a [AdDisplayContainer] from a specific platform implementation.
  AdDisplayContainer.fromPlatform(this.platform);

  /// Implementation of [PlatformAdDisplayContainer] for the current platform.
  final PlatformAdDisplayContainer platform;
}
