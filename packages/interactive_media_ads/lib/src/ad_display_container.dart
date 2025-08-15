// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

import 'companion_ad_slot.dart';
import 'platform_interface/platform_interface.dart';

/// A [Widget] for displaying loaded ads.
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
/// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
///   final IOSAdDisplayContainer iosContainer = container.platform as IOSAdDisplayContainer;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidAdDisplayContainer androidContainer =
///       container.platform as AndroidAdDisplayContainer;
/// }
/// ```
class AdDisplayContainer extends StatelessWidget {
  /// Constructs an [AdDisplayContainer].
  ///
  /// See [AdDisplayContainer.fromPlatformCreationParams] for setting parameters for a
  /// specific platform.
  AdDisplayContainer({
    Key? key,
    required void Function(AdDisplayContainer container) onContainerAdded,
    Iterable<CompanionAdSlot> companionSlots = const <CompanionAdSlot>[],
    TextDirection layoutDirection = TextDirection.ltr,
  }) : this.fromPlatformCreationParams(
          key: key,
          params: PlatformAdDisplayContainerCreationParams(
            onContainerAdded: (PlatformAdDisplayContainer container) {
              onContainerAdded(AdDisplayContainer.fromPlatform(
                platform: container,
              ));
            },
            companionSlots: companionSlots.map(
              (CompanionAdSlot slot) => slot.platform,
            ),
            layoutDirection: layoutDirection,
          ),
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
  /// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
  ///   params = IOSAdDisplayContainerCreationParams
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
  AdDisplayContainer.fromPlatformCreationParams({
    Key? key,
    required PlatformAdDisplayContainerCreationParams params,
  }) : this.fromPlatform(
          key: key,
          platform: PlatformAdDisplayContainer(params),
        );

  /// Constructs an [AdDisplayContainer] from a specific platform
  /// implementation.
  const AdDisplayContainer.fromPlatform({super.key, required this.platform});

  /// Implementation of [PlatformAdDisplayContainer] for the current platform.
  final PlatformAdDisplayContainer platform;

  /// Invoked when the native view that contains the ad has been added to the
  /// platform view hierarchy.
  void Function(PlatformAdDisplayContainer container) get onContainerAdded =>
      platform.params.onContainerAdded;

  /// List of companion ad slots.
  Iterable<CompanionAdSlot> get companionSlots =>
      platform.params.companionSlots.map(
        (PlatformCompanionAdSlot slot) => CompanionAdSlot.fromPlatform(slot),
      );

  /// The layout direction to use for the embedded AdDisplayContainer.
  TextDirection get layoutDirection => platform.params.layoutDirection;

  @override
  Widget build(BuildContext context) {
    return platform.build(context);
  }
}
