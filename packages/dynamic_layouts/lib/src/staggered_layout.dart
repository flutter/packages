// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'base_grid_layout.dart';
import 'render_dynamic_grid.dart';

//TODO: add SliverGridWrappingTileLayout when it lands
/// A [DynamicSliverGridLayout] that creates tiles with varying main axis
/// sizes and fixed cross axis sizes, generating a staggered layout. The extent
/// in the main axis will be defined by the child's size and must be finite.
/// Similar to Android's StaggeredGridLayoutManager:
/// [https://developer.android.com/reference/androidx/recyclerview/widget/StaggeredGridLayoutManager].
///
/// The tiles are placed in the column (or row in case [scrollDirection] is set
/// to [Axis.horizontal]) with the minimum extent, which means children are not
/// neccesarily layed out in sequential order.
///
/// See also:
///
///  * [DynamicSliverGridDelegateWithMaxCrossAxisExtent], which creates
///    staggered layouts with a maximum extent in the cross axis.
///  * [DynamicSliverGridDelegateWithFixedCrossAxisCount], which creates
///    staggered layouts with a consistent amount of tiles in the cross axis.
///  * `SliverGridWrappingTileLayout`, a similar layout that allows tiles to be
///    freely sized in the main and cross axis.
///  * [DynamicSliverGridGeometry], which represents the size and position of a
///    single tile in a grid.
///  * [RenderDynamicSliverGrid], which uses this class during its
///    [RenderDynamicSliverGrid.performLayout] method.
class SliverGridStaggeredTileLayout extends DynamicSliverGridLayout {
  /// Creates a layout with dynamic main axis extents and fixed cross axis
  /// extents.
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
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childCrossAxisExtent != null && childCrossAxisExtent >= 0) {
    //TODO: Modify how this works
    for (int i = 0; i < crossAxisCount; i++) {
      _scrollOffsetForMainAxis[i] = 0.0;
      _mainAxisCount[i] = 0;
    }
  }

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
  final Map<int, double> _scrollOffsetForMainAxis = <int, double>{};

  /// The amount of tiles in every row or column across the main axis.
  final Map<int, int> _mainAxisCount = <int, int>{};

  /// Returns the row or column with the minimum extent for the next child to
  /// be layed out.
  int _getNextCrossAxisSlot() {
    int nextCrossAxisSlot = 0;
    double minScrollOffset = double.infinity;
    _scrollOffsetForMainAxis.forEach((int mainAxisSeries, double scrollOffset) {
      if (scrollOffset < minScrollOffset) {
        nextCrossAxisSlot = mainAxisSeries;
        minScrollOffset = scrollOffset;
      }
    });
    return nextCrossAxisSlot;
  }

  @override
  bool reachedTargetScrollOffset(double targetOffset) {
    for (final double scrollOffset in _scrollOffsetForMainAxis.values) {
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

  /// Returns an updated [DynamicSliverGridGeometry] with the actual size of
  /// the child.
  @override
  DynamicSliverGridGeometry updateGeometryForChildIndex(
    int index,
    Size childSize,
  ) {
    final int crossAxisSlot = _getNextCrossAxisSlot();
    final double currentScrollOffset = _scrollOffsetForMainAxis[crossAxisSlot]!;
    final double childMainAxisExtent =
        scrollDirection == Axis.vertical ? childSize.height : childSize.width;
    _scrollOffsetForMainAxis[crossAxisSlot] =
        childMainAxisExtent + _scrollOffsetForMainAxis[crossAxisSlot]!;

    final DynamicSliverGridGeometry sliverGridGeometry =
        DynamicSliverGridGeometry(
      scrollOffset: currentScrollOffset +
          _mainAxisCount[crossAxisSlot]! * mainAxisSpacing,
      crossAxisOffset:
          crossAxisSlot * (childCrossAxisExtent + crossAxisSpacing),
      mainAxisExtent:
          scrollDirection == Axis.vertical ? childSize.height : childSize.width,
      crossAxisExtent: childCrossAxisExtent,
    );
    _mainAxisCount[crossAxisSlot] = _mainAxisCount[crossAxisSlot]! + 1;
    return sliverGridGeometry;
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
/// This sample code shows how to use it independently with a DynamicGridView
/// constructor:
///
/// ```dart
///    DynamicGridView(
///      gridDelegate: const DynamicSliverGridDelegateWithFixedCrossAxisCount(
///        crossAxisCount: 4,
///      ),
///      children: List<Widget>.generate(
///        50,
///        (int index) => SizedBox(
///          height: index % 2 * 20 + 20,
///          child: Text('Index $index'),
///        ),
///      ),
///    ),
///          ```
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
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis and varying main axis size dependent on the child's
  /// corresponding finite extent.
  ///
  /// Only the [crossAxisCount] argument needs to be greater than zero. All of
  /// them must be not null.
  const DynamicSliverGridDelegateWithFixedCrossAxisCount({
    required super.crossAxisCount,
    super.mainAxisSpacing = 0.0,
    super.crossAxisSpacing = 0.0,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

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
/// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
/// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
/// columns that are 125.0 pixels wide.
/// ```dart
///    DynamicGridView(
///      gridDelegate: const DynamicSliverGridDelegateWithMaxCrossAxisExtent(
///        maxCrossAxisExtent: 100,
///      ),
///      children: List<Widget>.generate(
///        50,
///        (int index) => SizedBox(
///          height: index % 2 * 20 + 20,
///          child: Text('Index $index'),
///        ),
///      ),
///    ),
///          ```
///
/// See also:
///
///  * [DynamicSliverGridDelegateWithFixedCrossAxisCount], which creates a
///    layout with a fixed number of tiles in the cross axis.
///  * [DynamicGridView], which can use this delegate to control the layout of
///    its tiles.
///  * [DynamicSliverGridGeometry], which establishes the position of a child and
///    pass the child's desired proportions to [DynamicSliverGridLayout].
///  * [RenderDynamicSliverGrid], which is the sliver where the dynamic sized
///    tiles are positioned.
class DynamicSliverGridDelegateWithMaxCrossAxisExtent
    extends SliverGridDelegateWithMaxCrossAxisExtent {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent and varying main axis size.
  ///
  /// Only the [maxCrossAxisExtent] argument needs to be greater than zero. All of
  /// them must be not null.
  const DynamicSliverGridDelegateWithMaxCrossAxisExtent({
    required super.maxCrossAxisExtent,
    super.mainAxisSpacing = 0.0,
    super.crossAxisSpacing = 0.0,
  })  : assert(maxCrossAxisExtent != null && maxCrossAxisExtent > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

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
