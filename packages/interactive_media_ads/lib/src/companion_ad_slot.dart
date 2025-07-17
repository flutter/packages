// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'platform_interface/platform_interface.dart';

/// Ad slot for companion ads.
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
/// final CompanionAdSlot slot = CompanionAdSlot.size(width: 100, height: 100);
///
/// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
///   final IOSCompanionAdSlot iosSlot = slot.platform as IOSCompanionAdSlot;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidCompanionAdSlot androidSlot =
///       slot.platform as AndroidCompanionAdSlot;
/// }
/// ```
class CompanionAdSlot {
  /// Constructs an instance of a [CompanionAdSlot].
  ///
  /// See [CompanionAdSlot.fromPlatformCreationParams] for setting parameters
  /// for a specific platform.
  CompanionAdSlot({
    required CompanionAdSlotSize size,
    void Function()? onClicked,
  }) : this.fromPlatformCreationParams(
          params: PlatformCompanionAdSlotCreationParams(
            size: size,
            onClicked: onClicked,
          ),
        );

  /// Constructs a [CompanionAdSlot] from creation params for a specific
  /// platform.
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
    required PlatformCompanionAdSlotCreationParams params,
  }) : this.fromPlatform(PlatformCompanionAdSlot(params));

  /// Constructs a [CompanionAdSlot] from a specific platform implementation.
  const CompanionAdSlot.fromPlatform(this.platform);

  /// Implementation of [PlatformCompanionAdSlot] for the current platform.
  final PlatformCompanionAdSlot platform;

  /// Called when the slot is clicked on by the user and will successfully
  /// navigate away.
  void Function()? get onClicked => platform.params.onClicked;

  /// Builds the Widget that contains the native View.
  Widget buildWidget(BuildContext context) {
    return platform.buildWidget(BuildWidgetCreationParams(context: context));
  }
}
