// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The size of the slot for a companion ad.
@immutable
sealed class CompanionAdSlotSize {
  const CompanionAdSlotSize._();

  /// A slot for a companion ad with a fixed with and height.
  factory CompanionAdSlotSize.fixed({
    required int width,
    required int height,
  }) {
    return CompanionAdSlotSizeFixed._(width: width, height: height);
  }

  /// A slot for a companion ad with no fixed size, but rather adapts to fit the
  /// creative content they display.
  factory CompanionAdSlotSize.fluid() {
    return const CompanionAdSlotSizeFluid._();
  }
}

/// A slot for a companion ad with a fixed with and height.
@immutable
class CompanionAdSlotSizeFixed extends CompanionAdSlotSize {
  const CompanionAdSlotSizeFixed._({
    required this.width,
    required this.height,
  }) : super._();

  /// The width of the ad slot in pixels.
  final int width;

  /// The height of the ad slot in pixels.
  final int height;
}

/// A slot for a companion had with no fixed size, but rather adapts to fit the
/// creative content they display.
@immutable
class CompanionAdSlotSizeFluid extends CompanionAdSlotSize {
  const CompanionAdSlotSizeFluid._() : super._();
}
