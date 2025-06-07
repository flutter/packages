// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'build_widget_creation_params.dart';
import 'companion_ad_slot_size.dart';
import 'interactive_media_ads_platform.dart';

/// Object specifying creation parameters for creating a
/// [PlatformCompanionAdSlot].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the
/// [PlatformCompanionAdSlotCreationParams] to provide additional platform
/// specific parameters.
///
/// When extending [PlatformCompanionAdSlotCreationParams], additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// final class AndroidPlatformCompanionAdSlotCreationParams
///     extends PlatformCompanionAdSlotCreationParams {
///   const AndroidPlatformCompanionAdSlotCreationParams.fluid({
///     super.key,
///     this.onFilled,
///   }) : super();
///
///   factory AndroidPlatformCompanionAdSlotCreationParams.fromPlatformCompanionAdSlotCreationParamsFluid(
///     PlatformCompanionAdSlotCreationParams params, {
///     void Function()? onFilled,
///   }) {
///     return AndroidPlatformCompanionAdSlotCreationParams.fluid(
///       key: params.key,
///       onFilled: onFilled,
///     );
///   }
///
///   final void Function()? onFilled;
/// }
/// ```
@immutable
base class PlatformCompanionAdSlotCreationParams {
  /// Used by the platform implementation to create a new
  /// [PlatformCompanionAdSlot].
  const PlatformCompanionAdSlotCreationParams({
    required this.size,
    this.onClicked,
  });

  /// The size of the slot.
  final CompanionAdSlotSize size;

  /// Called when the slot is clicked on by the user and will successfully
  /// navigate away.
  final void Function()? onClicked;
}

/// Ad slot for companion ads.
abstract base class PlatformCompanionAdSlot {
  /// Creates a new [PlatformCompanionAdSlot]
  factory PlatformCompanionAdSlot(
    PlatformCompanionAdSlotCreationParams params,
  ) {
    assert(
      InteractiveMediaAdsPlatform.instance != null,
      'A platform implementation for `interactive_media_ads` has not been set. '
      'Please ensure that an implementation of `InteractiveMediaAdsPlatform` '
      'has been set to `InteractiveMediaAdsPlatform.instance` before use. For '
      'unit testing, `InteractiveMediaAdsPlatform.instance` can be set with '
      'your own test implementation.',
    );
    final PlatformCompanionAdSlot implementation = InteractiveMediaAdsPlatform
        .instance!
        .createPlatformCompanionAdSlot(params);
    return implementation;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformCompanionAdSlot].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformCompanionAdSlot.implementation(this.params);

  /// The parameters used to initialize the [PlatformCompanionAdSlot].
  final PlatformCompanionAdSlotCreationParams params;

  /// Builds the Widget that contains the native View.
  Widget buildWidget(BuildWidgetCreationParams params);
}
