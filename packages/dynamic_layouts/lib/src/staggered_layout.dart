// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'base_grid_layout.dart';
import 'render_dynamic_grid.dart';
import 'wrap_layout.dart';

/// A [DynamicSliverGridLayout] that creates tiles with varying main axis
/// sizes and fixed cross axis sizes, generating a staggered layout. The extent
/// in the main axis will be defined by the child's size and must be finite.
/// Similar to Android's StaggeredGridLayoutManager:
/// [https://developer.android.com/reference/androidx/recyclerview/widget/StaggeredGridLayoutManager].
///
/// The tiles are placed in the column (or row in case [scrollDirection] is set
/// to [Axis.horizontal]) with the minimum extent, which means children are not
/// necessarily laid out in sequential order.
///
/// See also:
///
///  * [SliverGridWrappingTileLayout], a similar layout that allows tiles to be
///    freely sized in the main and cross axis.
///  * [DynamicSliverGridDelegateWithMaxCrossAxisExtent], which creates
///    staggered layouts with a maximum extent in the cross axis.
///  * [DynamicSliverGridDelegateWithFixedCrossAxisCount], which creates
///    staggered layouts with a consistent amount of tiles in the cross axis.
///  * [DynamicGridView.staggered], which uses these delegates to create
///    staggered layouts.
///  * [DynamicSliverGridGeometry], which establishes the position of a child
///    and pass the child's desired proportions to a [DynamicSliverGridLayout].
///  * [RenderDynamicSliverGrid], which is the sliver where the dynamic sized
///    tiles are positioned.
class SliverGridStaggeredTileLayout extends DynamicSliverGridLayout {
  /// Creates a layout with dynamic main axis extents determined by the child's
  /// size and fixed cross axis extents.
  ///
  /// All arguments must be not null. The [crossAxisCount] argument must be
  /// greater than zero. The [mainAxisSpacing], [crossAxisSpacing] and
  /// [childCrossAxisExtent] arguments must not be negative.
  SliverGridStaggeredTileLayout({
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childCrossAxisExtent,
    required this.scrollDirection,
  })  : assert(crossAxisCount > 0),
        assert(crossAxisSpacing >= 0),
        assert(childCrossAxisExtent >= 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  /// The axis along which the scroll view scrolls.
  final Axis scrollDirection;

  /// The collection of scroll offsets for every row or column across the main
  /// axis. It includes the tiles' sizes and the spacing between them.
  final List<double> _scrollOffsetForMainAxis = <double>[];

  /// The amount of tiles in every row or column across the main axis.
  final List<int> _mainAxisCount = <int>[];

  /// Returns the row or column with the minimum extent for the next child to
  /// be laid out.
  int _getNextCrossAxisSlot() {
    int nextCrossAxisSlot = 0;
    double minScrollOffset = double.infinity;

    if (_scrollOffsetForMainAxis.length < crossAxisCount) {
      nextCrossAxisSlot = _scrollOffsetForMainAxis.length;
      _scrollOffsetForMainAxis.add(0.0);
      return nextCrossAxisSlot;
    }

    for (int i = 0; i < crossAxisCount; i++) {
      if (_scrollOffsetForMainAxis[i] < minScrollOffset) {
        nextCrossAxisSlot = i;
        minScrollOffset = _scrollOffsetForMainAxis[i];
      }
    }
    return nextCrossAxisSlot;
  }

  @override
  bool reachedTargetScrollOffset(double targetOffset) {
    for (final double scrollOffset in _scrollOffsetForMainAxis) {
      if (scrollOffset < targetOffset) {
        return false;
      }
    }
    return true;
  }

  @override
  DynamicSliverGridGeometry getGeometryForChildIndex(int index) {
    return DynamicSliverGridGeometry(
      scrollOffset: 0.0,
      crossAxisOffset: 0.0,
      mainAxisExtent: double.infinity,
      crossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  DynamicSliverGridGeometry updateGeometryForChildIndex(
    int index,
    Size childSize,
  ) {
    final int crossAxisSlot = _getNextCrossAxisSlot();
    final double currentScrollOffset = _scrollOffsetForMainAxis[crossAxisSlot];
    final double childMainAxisExtent =
        scrollDirection == Axis.vertical ? childSize.height : childSize.width;
    final double scrollOffset = currentScrollOffset +
        (_mainAxisCount.length >= crossAxisCount
                ? _mainAxisCount[crossAxisSlot]
                : 0) *
            mainAxisSpacing;
    final double crossAxisOffset =
        crossAxisSlot * (childCrossAxisExtent + crossAxisSpacing);
    final double mainAxisExtent =
        scrollDirection == Axis.vertical ? childSize.height : childSize.width;
    _scrollOffsetForMainAxis[crossAxisSlot] =
        childMainAxisExtent + _scrollOffsetForMainAxis[crossAxisSlot];
    _mainAxisCount.length >= crossAxisCount
        ? _mainAxisCount[crossAxisSlot] += 1
        : _mainAxisCount.add(1);

    return DynamicSliverGridGeometry(
      scrollOffset: scrollOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: childCrossAxisExtent,
    );
  }
}

/// Creates dynamic grid layouts with a fixed number of tiles in the cross axis
/// and varying main axis size dependent on the child's corresponding finite
/// extent. It uses the same logic as
/// [SliverGridDelegateWithFixedCrossAxisCount] where the total extent in the
/// cross axis is distributed equally between the specified amount of tiles,
/// but with a [SliverGridStaggeredTileLayout].
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
///
/// This sample code shows how to use it independently with a [DynamicGridView]
/// constructor:
///
/// ```dart
/// DynamicGridView(
///   gridDelegate: const DynamicSliverGridDelegateWithFixedCrossAxisCount(
///     crossAxisCount: 4,
///   ),
///   children: List<Widget>.generate(
///     50,
///     (int index) => SizedBox(
///       height: index % 2 * 20 + 20,
///       child: Text('Index $index'),
///     ),
///   ),
/// );
/// ```
///
/// See also:
///
///  * [DynamicSliverGridDelegateWithMaxCrossAxisExtent], which creates a
///    dynamic layout with tiles that have a maximum cross-axis extent
///    and varying main axis size.
///  * [DynamicGridView], which can use this delegate to control the layout of
///    its tiles.
///  * [DynamicSliverGridGeometry], which establishes the position of a child
///    and pass the child's desired proportions to [DynamicSliverGridLayout].
///  * [RenderDynamicSliverGrid], which is the sliver where the dynamic sized
///    tiles are positioned.
class DynamicSliverGridDelegateWithFixedCrossAxisCount
    extends SliverGridDelegateWithFixedCrossAxisCount {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles
  /// in the cross axis and varying main axis size dependent on the child's
  /// corresponding finite extent.
  ///
  /// Only the [crossAxisCount] argument needs to be greater than zero. All of
  /// them must be not null.
  const DynamicSliverGridDelegateWithFixedCrossAxisCount({
    required super.crossAxisCount,
    super.mainAxisSpacing = 0.0,
    super.crossAxisSpacing = 0.0,
  })  : assert(crossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0);

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  DynamicSliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent = math.max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    return SliverGridStaggeredTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childCrossAxisExtent: childCrossAxisExtent,
      scrollDirection: axisDirectionToAxis(constraints.axisDirection),
    );
  }
}

/// Creates dynamic grid layouts with tiles that each have a maximum cross-axis
/// extent and varying main axis size dependent on the child's corresponding
/// finite extent. It uses the same logic as
/// [SliverGridDelegateWithMaxCrossAxisExtent] where every tile has the same
/// cross axis size and does not exceed the provided max extent, but with a
/// [SliverGridStaggeredTileLayout].
///
/// This delegate will select a cross-axis extent for the tiles that is as
/// large as possible subject to the following conditions:
///
///  * The extent evenly divides the cross-axis extent of the grid.
///  * The extent is at most [maxCrossAxisExtent].
///
/// This sample code shows how to use it independently with a [DynamicGridView]
/// constructor:
///
/// ```dart
/// DynamicGridView(
///   gridDelegate: const DynamicSliverGridDelegateWithMaxCrossAxisExtent(
///     maxCrossAxisExtent: 100,
///   ),
///   children: List<Widget>.generate(
///     50,
///     (int index) => SizedBox(
///       height: index % 2 * 20 + 20,
///       child: Text('Index $index'),
///     ),
///   ),
/// );
/// ```
///
/// See also:
///
///  * [DynamicSliverGridDelegateWithFixedCrossAxisCount], which creates a
///    layout with a fixed number of tiles in the cross axis.
///  * [DynamicGridView], which can use this delegate to control the layout of
///    its tiles.
///  * [DynamicSliverGridGeometry], which establishes the position of a child
///    and pass the child's desired proportions to [DynamicSliverGridLayout].
///  * [RenderDynamicSliverGrid], which is the sliver where the dynamic sized
///    tiles are positioned.
class DynamicSliverGridDelegateWithMaxCrossAxisExtent
    extends SliverGridDelegateWithMaxCrossAxisExtent {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent and varying main axis size dependent on the child's
  /// corresponding finite extent.
  ///
  /// Only the [maxCrossAxisExtent] argument needs to be greater than zero.
  /// All of them must be not null.
  const DynamicSliverGridDelegateWithMaxCrossAxisExtent({
    required super.maxCrossAxisExtent,
    super.mainAxisSpacing = 0.0,
    super.crossAxisSpacing = 0.0,
  })  : assert(maxCrossAxisExtent > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0);

  bool _debugAssertIsValid(double crossAxisExtent) {
    assert(crossAxisExtent > 0.0);
    assert(maxCrossAxisExtent > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  DynamicSliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid(constraints.crossAxisExtent));
    final int crossAxisCount =
        (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
            .ceil();
    final double usableCrossAxisExtent = math.max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    return SliverGridStaggeredTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childCrossAxisExtent: childCrossAxisExtent,
      scrollDirection: axisDirectionToAxis(constraints.axisDirection),
    );
  }
}
