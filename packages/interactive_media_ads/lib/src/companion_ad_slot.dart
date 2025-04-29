// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'platform_interface/platform_interface.dart';

/// A [Widget] for displaying loaded ads.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro interactive_media_ads.CompanionAdSlot.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final CompanionAdSlot slot = CompanionAdSlot();
///
/// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
///   final IOSCompanionAdSlot iosSlot = slot.platform as IOSCompanionAdSlot;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidCompanionAdSlot androidSlot =
///       slot.platform as AndroidCompanionAdSlot;
/// }
/// ```
class CompanionAdSlot extends StatelessWidget {
  /// Constructs an [CompanionAdSlot].
  ///
  /// See [CompanionAdSlot.fromPlatformCreationParams] for setting parameters
  /// for a specific platform.
  CompanionAdSlot.size({
    Key? key,
    required int width,
    required int height,
    TextDirection layoutDirection = TextDirection.ltr,
  }) : this.fromPlatformCreationParams(
          key: key,
          params: PlatformCompanionAdSlotCreationParams.size(
            width: width,
            height: height,
            layoutDirection: layoutDirection,
          ),
        );

  /// Constructs an [CompanionAdSlot].
  ///
  /// See [CompanionAdSlot.fromPlatformCreationParams] for setting parameters
  /// for a specific platform.
  CompanionAdSlot.fluid({
    Key? key,
    TextDirection layoutDirection = TextDirection.ltr,
  }) : this.fromPlatformCreationParams(
          key: key,
          params: PlatformCompanionAdSlotCreationParams.fluid(
            layoutDirection: layoutDirection,
          ),
        );

  /// Constructs an [CompanionAdSlot] from creation params for a specific platform.
  ///
  /// {@template interactive_media_ads.CompanionAdSlot.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// iOS and Android:
  ///
  /// ```dart
  /// PlatformCompanionAdSlotCreationParams params =
  ///     const PlatformCompanionAdSlotCreationParams();
  ///
  /// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
  ///   params = IOSCompanionAdSlotCreationParams
  ///       .fromPlatformCompanionAdSlotCreationParams(
  ///     params,
  ///   );
  /// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
  ///   params = AndroidCompanionAdSlotCreationParams
  ///       .fromPlatformCompanionAdSlotCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final CompanionAdSlot slot = CompanionAdSlot.fromPlatformCreationParams(
  ///   params,
  /// );
  /// ```
  /// {@endtemplate}
  CompanionAdSlot.fromPlatformCreationParams({
    Key? key,
    required PlatformCompanionAdSlotCreationParams params,
  }) : this.fromPlatform(
          key: key,
          platform: PlatformCompanionAdSlot(params),
        );

  /// Constructs an [CompanionAdSlot] from a specific platform implementation.
  const CompanionAdSlot.fromPlatform({super.key, required this.platform});

  /// Implementation of [PlatformCompanionAdSlot] for the current platform.
  final PlatformCompanionAdSlot platform;

  /// The layout direction to use for the embedded CompanionAdSlot.
  TextDirection get layoutDirection => platform.params.layoutDirection;

  @override
  Widget build(BuildContext context) {
    return platform.build(context);
  }
}
