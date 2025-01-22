// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'tree.dart';
import 'tree_span.dart';

/// Signature for a function that creates a [TreeRow] for a given
/// [TreeViewNode] in a [TreeView].
///
/// Used by the [TreeViewDelegateMixin.buildRow] to configure rows in the
/// [TreeView].
typedef TreeViewRowBuilder<T> = TreeRow Function(TreeViewNode<T> node);

/// Signature for a function that creates a [Widget] to represent the given
/// [TreeViewNode] in the [TreeView].
///
/// Used by [TreeView.treeRowBuilder] to build rows on demand for the
/// tree.
typedef TreeViewNodeBuilder<T> = Widget Function(
  BuildContext context,
  TreeViewNode<T> node,
  AnimationStyle toggleAnimationStyle,
);

/// The position of a [TreeRow] in a [TreeViewport] in relation
/// to other children of the viewport.
///
/// This subclass translates the abstract [ChildVicinity.xIndex] and
/// [ChildVicinity.yIndex] into terms of row index and depth for ease of use
/// within the context of a [TreeView].
@immutable
class TreeVicinity extends ChildVicinity {
  /// Creates a reference to a [TreeRow] in a [TreeView], with the [xIndex] and
  /// [yIndex] converted to terms of [depth] and [row], respectively.
  const TreeVicinity({
    required int depth,
    required int row,
  }) : super(xIndex: depth, yIndex: row);

  /// The row index of the [TreeRow] in the [TreeView].
  ///
  /// Equivalent to the [yIndex].
  int get row => yIndex;

  /// The depth of the [TreeRow] in the [TreeView].
  ///
  /// Root [TreeViewNode]s have a depth of 0.
  ///
  /// Equivalent to the [xIndex].
  int get depth => xIndex;

  @override
  String toString() => '(row: $row, depth: $depth)';
}

/// A mixin that defines the model for a [TwoDimensionalChildDelegate] to be
/// used with a [TreeView].
mixin TreeRowDelegateMixin on TwoDimensionalChildDelegate {
  /// The number of rows that the tree has active nodes for.
  ///
  /// The [buildRow] method will be called for [TreeViewNode]s that are
  /// currently active, meaning they are not contained within an unexpanded
  /// parent node.
  ///
  /// The [buildRow] method must provide a valid [TreeRow] for all active nodes.
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  int get rowCount;

  /// Builds the [TreeRow] that describe the row for the provided
  /// [TreeVicinity].
  ///
  /// The builder must return a valid [TreeRow] for all active nodes in the
  /// tree.
  TreeRow buildRow(TreeVicinity vicinity);
}

/// Returns a [TreeRow] for the given [TreeVicinity] in the [TreeView].
typedef TreeVicinityToRowBuilder = TreeRow Function(TreeVicinity);

/// A delegate that supplies nodes for a [TreeViewport] on demand using a
/// builder callback.
///
/// This is not typically used directly, instead being created and managed by
/// the [TreeView] so that the builder can be called for only those
/// [TreeViewNode]s that are currently active in the [TreeView].
///
/// The [rowCount] is determined by the number of active nodes in the
/// [TreeView].
class TreeRowBuilderDelegate extends TwoDimensionalChildBuilderDelegate
    with TreeRowDelegateMixin {
  /// Creates a lazy building delegate to use with a [TreeView].
  TreeRowBuilderDelegate({
    required int rowCount,
    super.addAutomaticKeepAlives,
    required TwoDimensionalIndexedWidgetBuilder nodeBuilder,
    required TreeVicinityToRowBuilder rowBuilder,
  })  : assert(rowCount >= 0),
        _rowBuilder = rowBuilder,
        super(
          builder: nodeBuilder,
          // No maxXIndex, since we do not know the max depth.
          maxYIndex: rowCount - 1,
          // repaintBoundaries handled by TreeView
          addRepaintBoundaries: false,
        );

  @override
  int get rowCount => maxYIndex! + 1;

  set rowCount(int value) {
    assert(value >= 0);
    maxYIndex = value - 1;
  }

  /// Builds the [TreeRow] that describes the row for the provided
  /// [TreeVicinity].
  final TreeVicinityToRowBuilder _rowBuilder;
  @override
  TreeRow buildRow(TreeVicinity vicinity) => _rowBuilder(vicinity);
}
