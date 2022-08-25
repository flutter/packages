// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/rendering.dart';

// The model that tracks the current max size of the Sliver in the mainAxis and
// tracks if there is still space on the crossAxis.
class _RunMetrics {
  _RunMetrics({
    required this.maxSliver,
    required this.currentSizeUsed,
    required this.scrollOffset,
  });

  double maxSliver;
  double currentSizeUsed;
  double scrollOffset;
}

/// Controls the layout of tiles in a grid.
/// A [SliverGridLayout] that uses dynamically sized tiles.
///
/// Rather that providing a grid with a [SliverGridLayout] directly, you instead
/// provide the grid a [SliverGridDelegate], which can compute a
/// [SliverGridLayout] given the current [SliverConstraints].
///
/// This layout is used by [SliverGridDelegateWithWrapping].
///
/// See also:
///
///  * [SliverGridDelegateWithWrapping], which uses this layout.
///  * [SliverGridLayout], which represents an arbitrary tile layout.
///  * [DynamicSliverGridGeometry], which represents the size and position of a
///     single tile in a grid.
///  * [SliverGridDelegate.getLayout], which returns this object to describe the
///    delegate's layout.
///  * RenderDynamicSliverGrid], which uses this class during its
///    RenderDynamicSliverGrid.performLayout] method.
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
  })  : assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childMainAxisExtent != null && childMainAxisExtent >= 0),
        assert(childCrossAxisExtent != null && childCrossAxisExtent >= 0),
        assert(crossAxisExtent != null && crossAxisExtent >= 0),
        assert(scrollDirection != null &&
            (scrollDirection == Axis.horizontal ||
                scrollDirection == Axis.vertical));

  /// The direction in wich the layout should be built.
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
  final List<_RunMetrics> model = <_RunMetrics>[
    _RunMetrics(maxSliver: 0.0, currentSizeUsed: 0.0, scrollOffset: 0.0)
  ];

  // In this case the function getGeometryForChildIndex only works to get
  // the geometry for the child, where the layout actually happens is in
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
      int index, Size childSize) {
    final double scrollOffset = model.last.scrollOffset;
    final double currentSizeUsed = model.last.currentSizeUsed;
    late final double addedSize;

    switch (scrollDirection) {
      case Axis.vertical:
        addedSize = currentSizeUsed + childSize.width + crossAxisSpacing;
        break;
      case Axis.horizontal:
        addedSize = currentSizeUsed + childSize.height + mainAxisSpacing;
        break;
    }

    if (addedSize > crossAxisExtent && model.last.currentSizeUsed > 0.0) {
      switch (scrollDirection) {
        case Axis.vertical:
          model.add(
            _RunMetrics(
              maxSliver: childSize.height + mainAxisSpacing,
              currentSizeUsed: childSize.width + crossAxisSpacing,
              scrollOffset:
                  scrollOffset + model.last.maxSliver + mainAxisSpacing,
            ),
          );
          break;
        case Axis.horizontal:
          model.add(
            _RunMetrics(
              maxSliver: childSize.width + crossAxisSpacing,
              currentSizeUsed: childSize.height + mainAxisSpacing,
              scrollOffset:
                  scrollOffset + model.last.maxSliver + crossAxisSpacing,
            ),
          );
          break;
      }

      return DynamicSliverGridGeometry(
        scrollOffset: model.last.scrollOffset,
        crossAxisOffset: 0.0,
        mainAxisExtent: childSize.height + mainAxisSpacing,
        crossAxisExtent: childSize.width + crossAxisSpacing,
      );
    } else {
      model.last.currentSizeUsed = addedSize;
    }

    switch (scrollDirection) {
      case Axis.vertical:
        if (childSize.height + mainAxisSpacing > model.last.maxSliver) {
          model.last.maxSliver = childSize.height + mainAxisSpacing;
        }
        break;
      case Axis.horizontal:
        if (childSize.width + crossAxisSpacing > model.last.maxSliver) {
          model.last.maxSliver = childSize.width + crossAxisSpacing;
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
    if (model.last.scrollOffset > targetOffset) {
      return true;
    }
    return false;
  }
}

// TODO(snat-s): YourWrapDelegate extends SliverGridDelegate

/// A [SliverGridDelegate] that makes it possible to create grids that wrap and
/// have variably sized tiles.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// where the children are layed out until they fill the horizontal axis and then
/// they pass to the second row. If the grid is horizontal, this delegate will
/// do the same but it will fill the vertical axis and will pass to another
/// column until it finishes.
///
/// This delegate creates grids with different sized tiles. But you
/// can have equally sized tiles if you modify the `childCrossAxisExtent` and
/// the `childMainAxisExtent` to be the same size.
///
/// See also:
///  * [DynamicGridView.wrap], wich is a constructor to use this [SliverGridDelegate],
///    like `GridView.extent`.
///  * [DynamicGridView], which can use this delegate to control the layout of its
///    tiles.
///  * RenderDynamicSliverGrid], which can use this delegate to control the
///    layout of its tiles.
class SliverGridDelegateWithWrapping extends SliverGridDelegate {
  /// Creates a delegate that makes dynamic grid layouts, the children Widgets
  /// are the ones that decide their own size. Because the children decide their
  /// own size the default values of `childMainAxisExtent` and
  /// `childCrossAxisExtent` are set to [double.infinity].
  /// If you only want to have the wrap, you can specify the `childCrossAxisExtent`
  /// and the `childMainAxisExtent` to be the same size. Or only one of them to
  /// be of a certain size in one of the axis.
  const SliverGridDelegateWithWrapping({
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childCrossAxisExtent = double.infinity,
    this.childMainAxisExtent = double.infinity,
    this.scrollDirection = Axis.vertical,
  })  : assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the main axis.
  ///
  /// Defaults to [double.infinity].
  final double childMainAxisExtent;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  ///
  /// Defaults to [double.infinity].
  final double childCrossAxisExtent;

  /// The number of logical pixels between each child along the main axis.
  ///
  /// Defaults to 0.0
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  ///
  /// Defaults to 0.0
  final double crossAxisSpacing;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

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
      scrollDirection: scrollDirection,
      crossAxisExtent: constraints.crossAxisExtent,
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithWrapping oldDelegate) {
    return oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}
