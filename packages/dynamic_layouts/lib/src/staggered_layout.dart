import 'dart:math' as math;
import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/rendering.dart';

class SliverGridStaggeredTileLayout extends DynamicSliverGridLayout {
  ///
  SliverGridStaggeredTileLayout({
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisStride,
    required this.childCrossAxisExtent,
    required this.reverseCrossAxis,
    required this.scrollDirection,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(crossAxisStride != null && crossAxisStride >= 0),
        assert(childCrossAxisExtent != null && childCrossAxisExtent >= 0),
        assert(reverseCrossAxis != null) {
    for (int i = 0; i < crossAxisCount; i++) {
      _scrollOffsetForMainAxis[i] = 0.0;
      _mainAxisCount[i] = 0;
    }
  }

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the cross axis.
  final double crossAxisStride;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  /// The axis along which the scroll view scrolls.
  final Axis scrollDirection;

  /// The collection of scroll offsets of the leading edge of the children relative
  /// to the leading edge of their parent.
  final Map<int, double> _scrollOffsetForMainAxis = <int, double>{};

  final Map<int, int> _mainAxisCount = <int, int>{};

  double _getOffsetFromStartInCrossAxis(double crossAxisStart) {
    if (reverseCrossAxis) {
      return crossAxisCount * crossAxisStride -
          crossAxisStart -
          childCrossAxisExtent -
          (crossAxisStride - childCrossAxisExtent);
    }
    return crossAxisStart;
  }

  int _getNextColumn(int index) {
    int nextColumn = 0;
    double minScrollOffset = double.infinity;
    _scrollOffsetForMainAxis.forEach((column, scrollOffset) {
      if (scrollOffset < minScrollOffset) {
        nextColumn = column;
        minScrollOffset = scrollOffset;
      }
    });
    return nextColumn;
  }

  ///
  @override
  bool reachedTargetScrollOffset(double targetOffset) {
    bool flag = false;
    for (int column in _scrollOffsetForMainAxis.keys) {
      if (_scrollOffsetForMainAxis[column]! < targetOffset) {
        flag = false;
      }
    }
    return flag;
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
      int index, Size childSize) {
    final int column = _getNextColumn(index); // 2
    final double currentScrollOffset = _scrollOffsetForMainAxis[column]!;
    final double childMainAxisExtent =
        scrollDirection == Axis.vertical ? childSize.height : childSize.width;
    _scrollOffsetForMainAxis[column] =
        childMainAxisExtent + _scrollOffsetForMainAxis[column]!;

    final DynamicSliverGridGeometry sliverGridGeometry =
        DynamicSliverGridGeometry(
      scrollOffset:
          currentScrollOffset + _mainAxisCount[column]! * mainAxisSpacing,
      crossAxisOffset: column * crossAxisStride,
      mainAxisExtent:
          scrollDirection == Axis.vertical ? childSize.height : childSize.width,
      crossAxisExtent: childCrossAxisExtent,
    );
    _mainAxisCount[column] = _mainAxisCount[column]! + 1;
    return sliverGridGeometry;
  }
}

class DynamicSliverGridDelegateWithFixedCrossAxisCount
    extends SliverGridDelegateWithFixedCrossAxisCount {
  DynamicSliverGridDelegateWithFixedCrossAxisCount({
    required super.crossAxisCount,
    super.mainAxisSpacing = 0.0,
    super.crossAxisSpacing = 0.0,
    super.childAspectRatio = 1.0,
    super.mainAxisExtent,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childAspectRatio != null && childAspectRatio > 0);

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
    final double childMainAxisExtent =
        mainAxisExtent ?? childCrossAxisExtent / childAspectRatio;
    return SliverGridStaggeredTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      scrollDirection: axisDirectionToAxis(constraints.axisDirection),
    );
  }
}

///
class DynamicSliverGridDelegateWithMaxCrossAxisExtent
    extends SliverGridDelegateWithMaxCrossAxisExtent {
  ///
  const DynamicSliverGridDelegateWithMaxCrossAxisExtent({
    required super.maxCrossAxisExtent,
    super.mainAxisSpacing = 0.0,
    super.crossAxisSpacing = 0.0,
    super.childAspectRatio = 1.0,
    super.mainAxisExtent,
  })  : assert(maxCrossAxisExtent != null && maxCrossAxisExtent > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childAspectRatio != null && childAspectRatio > 0);
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
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      scrollDirection: axisDirectionToAxis(constraints.axisDirection),
    );
  }
}
