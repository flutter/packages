// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';

/// Describes the placement of a child in a [RenderDynamicSliverGrid].
class DynamicSliverGridGeometry extends SliverGridGeometry {
  /// Creates an object that describes the placement of a child in a
  /// [RenderDynamicSliverGrid].
  const DynamicSliverGridGeometry({
    required super.scrollOffset,
    required super.crossAxisOffset,
    required super.mainAxisExtent,
    required super.crossAxisExtent,
  });

  /// Returns [BoxConstraints] that will be tight if the [SliverGridLayout] has
  /// provided fixed extents, forcing the child to have the
  /// required size.
  ///
  /// If the [mainAxisExtent] is [double.infinity] the child will be allowed to
  /// chose its own size in the main axis. Similarly, an infinite
  /// [crossAxisExtent] will result in the child sizing itself in the cross
  /// axis. Otherwise, the provided cross axis size or the
  /// [SliverConstraints.crossAxisExtent] will be used to create tight
  /// constraints in the cross axis.
  @override
  BoxConstraints getBoxConstraints(SliverConstraints constraints) {
    final double mainMinExtent = mainAxisExtent.isFinite ? mainAxisExtent : 0;
    final double crossMinExtent = crossAxisExtent.isInfinite ? 0.0 : crossAxisExtent;

    switch(constraints.axis) {
      
      case Axis.horizontal:
        return BoxConstraints(
          minHeight: mainMinExtent,
          maxHeight: mainAxisExtent,
          minWidth: crossMinExtent,
          maxWidth: crossAxisExtent,
        );
      case Axis.vertical:
        return BoxConstraints(
          minHeight: crossMinExtent,
          maxHeight: crossAxisExtent,
          minWidth: mainMinExtent,
          maxWidth: mainAxisExtent,
        );
    }
  }
}
