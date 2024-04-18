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
typedef TreeViewRowBuilder = TreeRow Function(TreeViewNode<dynamic> node);

/// Signature for a function that creates a [Widget] to represent the given
/// [TreeViewNode] in the [TreeView].
///
/// Used by [TreeView.treeRowBuilder] to build rows on demand for the
/// tree.
typedef TreeViewNodeBuilder = Widget Function(
  BuildContext context,
  TreeViewNode<dynamic> node, {
  AnimationStyle? animationStyle,
});

/// A mixin that defines the model for a [TwoDimensionalChildDelegate] to be
/// used with a [TreeView].
mixin TreeRowDelegateMixin on TwoDimensionalChildDelegate {
  /// The number of rows that the tree has active nodes for.
  ///
  /// The [buildRow] method will be called for nodes that are currently active,
  /// meaning they are not contained within an unexpanded parent node.
  ///
  /// The [buildRow] method must provide a valid [TreeRow] for all active nodes.=
  ///
  /// If the value returned by this getter changes throughout the lifetime of
  /// the delegate object, [notifyListeners] must be called.
  int get rowCount;

  /// Builds the [TreeRow] that describe the row for the provided
  /// [ChildVicinity].
  ///
  /// The builder must return a valid [TreeRow] for all active nodes in the
  /// tree.
  TreeRow buildRow(ChildVicinity vicinity);
}

/// Returns a [TreeRow] for the given [ChildVicinity] in the [TreeView].
///
/// [TreeRows] always have a [ChildVicinity.xIndex] of zero, with the
/// [ChildVicinity.yIndex] representing their index in the main axis of the
/// [TreeViewport].
typedef ChildVicinityToRowBuilder = TreeRow Function(ChildVicinity);

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
    required ChildVicinityToRowBuilder rowBuilder,
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
  /// [ChildVicinity].
  final ChildVicinityToRowBuilder _rowBuilder;
  @override
  TreeRow buildRow(ChildVicinity vicinity) => _rowBuilder(vicinity);
}
