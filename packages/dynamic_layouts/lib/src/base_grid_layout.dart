// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
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

  /// Returns [BoxConstraints] that will be tight if the
  /// [DynamicSliverGridLayout] has provided fixed extents, forcing the child to
  /// have the required size.
  ///
  /// If the [mainAxisExtent] is [double.infinity] the child will be allowed to
  /// choose its own size in the main axis. Similarly, an infinite
  /// [crossAxisExtent] will result in the child sizing itself in the cross
  /// axis. Otherwise, the provided cross axis size or the
  /// [SliverConstraints.crossAxisExtent] will be used to create tight
  /// constraints in the cross axis.
  ///
  /// This differs from [SliverGridGeometry.getBoxConstraints] in that it allows
  /// loose constraints, allowing the child to be its preferred size, or within
  /// a range of minimum and maximum extents.
  @override
  BoxConstraints getBoxConstraints(SliverConstraints constraints) {
    final double mainMinExtent = mainAxisExtent.isFinite ? mainAxisExtent : 0;
    final double crossMinExtent =
        crossAxisExtent.isInfinite ? 0.0 : crossAxisExtent;

    switch (constraints.axis) {
      case Axis.vertical:
        return BoxConstraints(
          minHeight: mainMinExtent,
          maxHeight: mainAxisExtent,
          minWidth: crossMinExtent,
          maxWidth: crossAxisExtent,
        );
      case Axis.horizontal:
        return BoxConstraints(
          minHeight: crossMinExtent,
          maxHeight: crossAxisExtent,
          minWidth: mainMinExtent,
          maxWidth: mainAxisExtent,
        );
    }
  }
}

// TODO(all): A bit more docs here
/// Manages the size and position of all the tiles in a [RenderSliverGrid].
///
/// Rather than providing a grid with a [SliverGridLayout] directly, you instead
/// provide the grid with a [SliverGridDelegate], which can compute a
/// [SliverGridLayout] given the current [SliverConstraints].
abstract class DynamicSliverGridLayout extends SliverGridLayout {
  /// The  estimated size and position of the child with the given index.
  ///
  /// The [DynamicSliverGridGeometry] that is returned will
  /// provide looser constraints to the child, whose size after layout can be
  /// reported back to the layout object in [updateGeometryForChildIndex].
  @override
  DynamicSliverGridGeometry getGeometryForChildIndex(int index);

  /// Update the size and position of the child with the given index,
  /// considering the size of the child after layout.
  ///
  /// This is used to update the layout object after the child has laid out,
  /// allowing the layout pattern to adapt to the child's size.
  DynamicSliverGridGeometry updateGeometryForChildIndex(
    int index,
    Size childSize,
  );

  /// Called by [RenderDynamicSliverGrid] to validate the layout pattern has
  /// filled the screen.
  ///
  /// A given child may have reached the target scroll offset of the current
  /// layout pass, but there may still be more children to lay out based on the
  /// pattern.
  bool reachedTargetScrollOffset(double targetOffset);

  // These methods are not relevant to dynamic grid building, but extending the
  // base [SliverGridLayout] class allows us to re-use existing
  // [SliverGridDelegate]s like [SliverGridDelegateWithFixedCrossAxisCount] and
  // [SliverGridDelegateWithMaxCrossAxisExtent].
  @override
  @mustCallSuper
  double computeMaxScrollOffset(int childCount) => throw UnimplementedError();
  @override
  @mustCallSuper
  int getMaxChildIndexForScrollOffset(double scrollOffset) =>
      throw UnimplementedError();
  @override
  @mustCallSuper
  int getMinChildIndexForScrollOffset(double scrollOffset) =>
      throw UnimplementedError();
}
