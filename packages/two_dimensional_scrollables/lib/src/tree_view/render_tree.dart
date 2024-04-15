// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../common/implementation_span.dart';
import 'tree_delegate.dart';
import 'tree_span.dart';
import 'tree_temp.dart';

/// A render object for viewing [RenderBox]es in a tree format that extends in
/// both the horizontal and vertical dimensions.
///
/// [RenderTreeViewport] is the visual workhorse of the [TreeView]. It
/// displays a subset of its [TreeViewNode] rows according to its own dimensions
/// and the given [verticalOffset] and [horizontalOffset]. As the offset varies,
/// different nodes are visible through the viewport.
class RenderTreeViewport extends RenderTwoDimensionalViewport {
  /// Creates a viewport for [RenderBox] objects in a tree format of rows.
  RenderTreeViewport({
    required Map<UniqueKey, TreeViewNodesAnimation> activeAnimations,
    required TreeViewTraversalOrder traversalOrder,
    required double indentation,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TreeRowDelegateMixin super.delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior,
  })  : _activeAnimations = activeAnimations,
        _traversalOrder = traversalOrder,
        _indentation = indentation;

  @override
  TreeRowDelegateMixin get delegate => super.delegate as TreeRowDelegateMixin;
  @override
  set delegate(TreeRowDelegateMixin value) {
    super.delegate = value;
  }

  /// The currently active [TreeViewNode] animations.
  ///
  /// Since the index of animating nodes can change at any time, the unique key
  /// is used to track an animation of nodes across frames.
  Map<UniqueKey, TreeViewNodesAnimation> get activeAnimations {
    return _activeAnimations;
  }

  Map<UniqueKey, TreeViewNodesAnimation> _activeAnimations;
  set activeAnimations(Map<UniqueKey, TreeViewNodesAnimation> value) {
    if (_activeAnimations == value) {
      return;
    }
    _activeAnimations = value;
    markNeedsLayout();
  }

  /// The order in which child nodes of the tree will be traversed.
  ///
  /// The default traversal order is [TreeViewTraversalOrder.depthFirst].
  TreeViewTraversalOrder get traversalOrder => _traversalOrder;
  TreeViewTraversalOrder _traversalOrder;
  set traversalOrder(TreeViewTraversalOrder value) {
    if (_traversalOrder == value) {
      return;
    }
    _traversalOrder = value;
    // We don't need to layout again. This is used when we visit children.
  }

  /// The number of pixels by which child nodes will be offset in the cross axis
  /// based on their [TreeViewNodeParentData.depth].
  ///
  /// If zero, can alternatively offset children in [TreeView.treeRowBuilder]
  /// for more options to customize the indented space.
  double get indentation => _indentation;
  double _indentation;
  set indentation(double value) {
    if (_indentation == value) {
      return;
    }
    assert(indentation >= 0.0);
    _indentation = value;
    markNeedsLayout();
  }

  // Cached metrics
  Map<int, _Span> _rowMetrics = <int, _Span>{};
  int? _firstRow;
  int? _lastRow;
  // How far rows should be laid out in a given frame.
  double get _targetRowPixel {
    return cacheExtent + verticalOffset.pixels + viewportDimension.height;
  }

  // Maps the index of parents to the animation key of their children.
  final Map<int, UniqueKey> _animationLeadingIndices = <int, UniqueKey>{};
  // Maps the key of child node animations to the fixed distance they are
  // traversing during the animation. Determined at the start of the animation.
  final Map<UniqueKey, double> _animationOffsets = <UniqueKey, double>{};
  void _updateAnimationCache() {
    _animationLeadingIndices.clear();
    _activeAnimations.forEach(
      (UniqueKey key, TreeViewNodesAnimation animation) {
        _animationLeadingIndices[animation.fromIndex - 1] = key;
      },
    );
    // Remove any stored offsets or clip layers that are no longer actively
    // animating.
    _animationOffsets.removeWhere((UniqueKey key, _) {
      return !_activeAnimations.keys.contains(key);
    });
    _clipHandles.removeWhere(
      (UniqueKey key, LayerHandle<ClipRectLayer> handle) {
        if (!_activeAnimations.keys.contains(key)) {
          handle.layer = null;
          return true;
        }
        return false;
      },
    );
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TreeViewNodeParentData) {
      child.parentData = TreeViewNodeParentData();
    }
  }

  @override
  TreeViewNodeParentData parentDataOf(RenderBox child) {
    return super.parentDataOf(child) as TreeViewNodeParentData;
  }

  @override
  void dispose() {
    _clipHandles.removeWhere(
      (UniqueKey key, LayerHandle<ClipRectLayer> handle) {
        handle.layer = null;
        return true;
      },
    );
    for (final _Span span in _rowMetrics.values) {
      span.dispose();
    }
    super.dispose();
  }

  void _updateRowMetrics() {
    assert(needsDelegateRebuild || didResize);
    _firstRow = null;
    _lastRow = null;
    double startOfRow = 0;
    final Map<int, _Span> newRowMetrics = <int, _Span>{};
    for (int row = 0; row < delegate.rowCount; row++) {
      final double leadingOffset = startOfRow;
      _Span? span = _rowMetrics.remove(row);
      assert(needsDelegateRebuild || span != null);
      final TreeRow configuration = needsDelegateRebuild
          ? delegate.buildRow(ChildVicinity(yIndex: row, xIndex: 0))
          : span!.configuration;
      span ??= _Span();
      span.update(
        configuration: configuration,
        leadingOffset: leadingOffset,
        extent: configuration.extent.calculateExtent(
          TreeRowExtentDelegate(
            viewportExtent: viewportDimension.height,
            precedingExtent: leadingOffset,
          ),
        ),
      );
      newRowMetrics[row] = span;
      if (span.trailingOffset >= verticalOffset.pixels && _firstRow == null) {
        _firstRow = row;
      }
      if (span.trailingOffset >= _targetRowPixel && _lastRow == null) {
        _lastRow = row;
      }
      startOfRow = span.trailingOffset;
    }
    for (final _Span span in _rowMetrics.values) {
      span.dispose();
    }
    _rowMetrics = newRowMetrics;
  }

  void _updateFirstAndLastVisibleRow() {
    _firstRow = null;
    _lastRow = null;
    for (int row = 0; row < _rowMetrics.length; row++) {
      final double endOfRow = _rowMetrics[row]!.trailingOffset;
      if (endOfRow >= verticalOffset.pixels && _firstRow == null) {
        _firstRow = row;
      }
      if (endOfRow >= _targetRowPixel && _lastRow == null) {
        _lastRow = row;
        break;
      }
    }
    if (_firstRow != null) {
      _lastRow ??= _rowMetrics.length - 1;
    }
  }

  @override
  void layoutChildSequence() {
    assert(verticalAxisDirection == AxisDirection.down &&
        horizontalAxisDirection == AxisDirection.right);

    _updateAnimationCache();
    if (needsDelegateRebuild || didResize) {
      // Recomputes the table metrics, invalidates any cached information.
      _updateRowMetrics();
    } else {
      // Updates the visible cells based on cached table metrics.
      _updateFirstAndLastVisibleRow();
    }

    if (_firstRow == null) {
      assert(_lastRow == null);
      return;
    }
    assert(_firstRow != null && _lastRow != null);

    _Span rowSpan;
    double rowOffset = verticalOffset.pixels;
    for (int row = _firstRow!; row <= _lastRow!; row++) {
      rowSpan = _rowMetrics[row]!;
      final double rowHeight = rowSpan.extent;
      rowOffset += rowSpan.configuration.padding.leading;

      final ChildVicinity vicinity = ChildVicinity(xIndex: 0, yIndex: row);
      final RenderBox child = buildOrObtainChildFor(vicinity)!;
      final TreeViewNodeParentData parentData = parentDataOf(child);
      final BoxConstraints childConstraints = BoxConstraints(
        minHeight: rowHeight,
        maxHeight: rowHeight,
        // Width is allowed to be unbounded.
      );
      child.layout(childConstraints, parentUsesSize: true);
      parentData.layoutOffset = Offset(
        parentData.depth * indentation,
        rowOffset,
      );
      rowOffset += rowHeight + rowSpan.configuration.padding.trailing;
    }
    // _updateScrollBounds
    // TODO(Piinks): Keep track of longest width during layout for update to scroll bounds.
    // TODO(Piinks): Depth map
  }

  final Map<UniqueKey, LayerHandle<ClipRectLayer>> _clipHandles =
      <UniqueKey, LayerHandle<ClipRectLayer>>{};

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_firstRow == null) {
      assert(_lastRow == null);
      return;
    }
    assert(_firstRow != null && _lastRow != null);

    // Row decorations
    final LinkedHashMap<Rect, TreeRowDecoration> foregroundRows =
        LinkedHashMap<Rect, TreeRowDecoration>();
    final LinkedHashMap<Rect, TreeRowDecoration> backgroundRows =
        LinkedHashMap<Rect, TreeRowDecoration>();

    for (int row = _firstRow!; row <= _lastRow!; row++) {
      final _Span rowSpan = _rowMetrics[row]!;
      final TreeRow configuration = rowSpan.configuration;
      if (configuration.backgroundDecoration != null ||
          configuration.foregroundDecoration != null) {
        final RenderBox child = getChildFor(
          ChildVicinity(xIndex: 0, yIndex: row),
        )!;

        Rect getRowRect(bool consumePadding) {
          final TreeViewNodeParentData parentData = parentDataOf(child);
          return Rect.fromPoints(
            parentData.layoutOffset!,
            Offset(
              child.size.width + parentData.layoutOffset!.dx,
              rowSpan.trailingOffset,
            ),
          );
        }

        if (configuration.backgroundDecoration != null) {
          final Rect rect = getRowRect(
            configuration.backgroundDecoration!.consumeSpanPadding,
          );
          backgroundRows[rect] = configuration.backgroundDecoration!;
        }
        if (configuration.foregroundDecoration != null) {
          final Rect rect = getRowRect(
            configuration.foregroundDecoration!.consumeSpanPadding,
          );
          foregroundRows[rect] = configuration.foregroundDecoration!;
        }
      }
    }

    // Get to painting.
    // Background decorations first.
    backgroundRows.forEach((Rect rect, TreeRowDecoration decoration) {
      final TreeRowDecorationPaintDetails paintingDetails =
          TreeRowDecorationPaintDetails(
        canvas: context.canvas,
        rect: rect,
        axisDirection: horizontalAxisDirection,
      );
      decoration.paint(paintingDetails);
    });
    // Child nodes.
    for (int row = _firstRow!; row <= _lastRow!; row++) {
      final RenderBox cell = getChildFor(
        ChildVicinity(xIndex: 0, yIndex: row),
      )!;
      final TreeViewNodeParentData cellParentData = parentDataOf(cell);
      if (cellParentData.isVisible) {
        context.paintChild(cell, offset + cellParentData.paintOffset!);
      }
    }
    // Foreground decorations.
    foregroundRows.forEach((Rect rect, TreeRowDecoration decoration) {
      final TreeRowDecorationPaintDetails paintingDetails =
          TreeRowDecorationPaintDetails(
        canvas: context.canvas,
        rect: rect,
        axisDirection: horizontalAxisDirection,
      );
      decoration.paint(paintingDetails);
    });
  }
}

class _Span extends ImplementedSpan {}
