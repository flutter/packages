// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';

import 'base_grid_layout.dart';

// The model that tracks the current max size of the Sliver in the mainAxis and
// tracks if there is still space on the crossAxis.
class _RunMetrics {
  _RunMetrics({
    required this.maxSliver,
    required this.currentSizeUsed,
    required this.scrollOffset,
  });

  /// The biggest sliver size for the current run.
  double maxSliver;

  /// The current size that has been used in the current run.
  double currentSizeUsed;

  /// The scroll offset in the current run.
  double scrollOffset;
}

/// A [DynamicSliverGridLayout] that uses dynamically sized tiles.
///
/// Rather that providing a grid with a [DynamicSliverGridLayout] directly, instead
/// provide the grid a [SliverGridDelegate], which can compute a
/// [DynamicSliverGridLayout] given the current [SliverConstraints].
///
/// This layout is used by [SliverGridDelegateWithWrapping].
///
/// See also:
///
///  * [SliverGridDelegateWithWrapping], which uses this layout.
///  * [DynamicSliverGridLayout], which represents an arbitrary dynamic tile layout.
///  * [DynamicSliverGridGeometry], which represents the size and position of a
///     single tile in a grid.
///  * [SliverGridDelegate.getLayout], which returns this object to describe the
///    delegate's layout.
///  * [RenderDynamicSliverGrid], which uses this class during its
///    [RenderDynamicSliverGrid.performLayout] method.
class SliverGridWrappingTileLayout extends DynamicSliverGridLayout {
  /// Creates a layout that uses dynamic sized and spaced tiles.
  ///
  /// All of the arguments must not be null and must not be negative.
  SliverGridWrappingTileLayout({
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childMainAxisExtent,
    required this.childCrossAxisExtent,
    required this.crossAxisExtent,
    required this.scrollDirection,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(childMainAxisExtent >= 0),
        assert(childCrossAxisExtent >= 0),
        assert(crossAxisExtent >= 0),
        assert(scrollDirection == Axis.horizontal ||
            scrollDirection == Axis.vertical);

  /// The direction in which the layout should be built.
  final Axis scrollDirection;

  /// The extent of the child in the non-scrolling axis.
  final double crossAxisExtent;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the main axis.
  final double childMainAxisExtent;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  /// The model that is used internally to keep track of how much space is left
  /// and how much has been used.
  final List<_RunMetrics> _model = <_RunMetrics>[
    _RunMetrics(maxSliver: 0.0, currentSizeUsed: 0.0, scrollOffset: 0.0)
  ];

  // This method provides the initial constraints for the child to layout,
  // and then it is updated with the final size later in
  // updateGeometryForChildIndex.
  @override
  DynamicSliverGridGeometry getGeometryForChildIndex(int index) {
    return DynamicSliverGridGeometry(
      scrollOffset: 0,
      crossAxisOffset: 0,
      mainAxisExtent: childMainAxisExtent,
      crossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  DynamicSliverGridGeometry updateGeometryForChildIndex(
    int index,
    Size childSize,
  ) {
    final double scrollOffset = _model.last.scrollOffset;
    final double currentSizeUsed = _model.last.currentSizeUsed;
    late final double addedSize;

    switch (scrollDirection) {
      case Axis.vertical:
        addedSize = currentSizeUsed + childSize.width + crossAxisSpacing;
        break;
      case Axis.horizontal:
        addedSize = currentSizeUsed + childSize.height + mainAxisSpacing;
        break;
    }

    if (addedSize > crossAxisExtent && _model.last.currentSizeUsed > 0.0) {
      switch (scrollDirection) {
        case Axis.vertical:
          _model.add(
            _RunMetrics(
              maxSliver: childSize.height + mainAxisSpacing,
              currentSizeUsed: childSize.width + crossAxisSpacing,
              scrollOffset:
                  scrollOffset + _model.last.maxSliver + mainAxisSpacing,
            ),
          );
          break;
        case Axis.horizontal:
          _model.add(
            _RunMetrics(
              maxSliver: childSize.width + crossAxisSpacing,
              currentSizeUsed: childSize.height + mainAxisSpacing,
              scrollOffset:
                  scrollOffset + _model.last.maxSliver + crossAxisSpacing,
            ),
          );
          break;
      }

      return DynamicSliverGridGeometry(
        scrollOffset: _model.last.scrollOffset,
        crossAxisOffset: 0.0,
        mainAxisExtent: childSize.height + mainAxisSpacing,
        crossAxisExtent: childSize.width + crossAxisSpacing,
      );
    } else {
      _model.last.currentSizeUsed = addedSize;
    }

    switch (scrollDirection) {
      case Axis.vertical:
        if (childSize.height + mainAxisSpacing > _model.last.maxSliver) {
          _model.last.maxSliver = childSize.height + mainAxisSpacing;
        }
        break;
      case Axis.horizontal:
        if (childSize.width + crossAxisSpacing > _model.last.maxSliver) {
          _model.last.maxSliver = childSize.width + crossAxisSpacing;
        }
        break;
    }

    return DynamicSliverGridGeometry(
      scrollOffset: scrollOffset,
      crossAxisOffset: currentSizeUsed,
      mainAxisExtent: childSize.height,
      crossAxisExtent: childSize.width,
    );
  }

  @override
  bool reachedTargetScrollOffset(double targetOffset) {
    return _model.last.scrollOffset > targetOffset;
  }
}

/// A [SliverGridDelegate] for creating grids that wrap variably sized tiles.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// where the children are laid out until they fill the horizontal axis and then
/// they continue in the next row. If the grid is horizontal, this delegate will
/// do the same but it will fill the vertical axis and will pass to another
/// column until it finishes.
///
/// This delegate creates grids with different sized tiles. Tiles
/// can have fixed dimensions if [childCrossAxisExtent] or
/// [childMainAxisExtent] are provided.
///
/// See also:
///  * [DynamicGridView.wrap], a constructor to use with this [SliverGridDelegate],
///    like `GridView.extent`.
///  * [DynamicGridView], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderDynamicSliverGrid], which can use this delegate to control the
///    layout of its tiles.
class SliverGridDelegateWithWrapping extends SliverGridDelegate {
  /// Create a delegate that wraps variably sized tiles.
  ///
  /// The children widgets are provided with loose constraints, and if any of the
  /// extent parameters are set, the children are given tight constraints.
  /// The way that children are made to have loose constraints is by assigning
  /// the value of [double.infinity] to [childMainAxisExtent] and
  /// [childCrossAxisExtent].
  /// To have same sized tiles with the wrapping, specify the [childCrossAxisExtent]
  /// and the [childMainAxisExtent] to be the same size. Or only one of them to
  /// be of a certain size in one of the axis.
  const SliverGridDelegateWithWrapping({
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childCrossAxisExtent = double.infinity,
    this.childMainAxisExtent = double.infinity,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0);

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the main axis.
  ///
  /// Defaults to [double.infinity] to provide the child with loose constraints.
  final double childMainAxisExtent;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  ///
  /// Defaults to [double.infinity] to provide the child with loose constraints.
  final double childCrossAxisExtent;

  /// The number of logical pixels between each child along the main axis.
  ///
  /// Defaults to 0.0
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  ///
  /// Defaults to 0.0
  final double crossAxisSpacing;

  bool _debugAssertIsValid() {
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    return SliverGridWrappingTileLayout(
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      scrollDirection: axisDirectionToAxis(constraints.axisDirection),
      crossAxisExtent: constraints.crossAxisExtent,
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithWrapping oldDelegate) {
    return oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}
