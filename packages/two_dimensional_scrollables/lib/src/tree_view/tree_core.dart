// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'tree.dart';

// The classes in these files follow the same pattern as the one dimensional
// sliver tree in the framework.
//
// After rolling to stable, these classes may be deprecated, or more likely
// made to be typedefs/subclasses of the framework core tree components. They
// could also live on if at a later date the 2D TreeView deviates or adds
// special features not relevant to the 1D sliver components of the framework.

/// Signature for a function that is called when a [TreeViewNode] is toggled,
/// changing its expanded state.
///
/// See also:
///
///   * [TreeViewNode.toggleNode], for controlling node expansion
///     programmatically.
typedef TreeViewNodeCallback<T> = void Function(TreeViewNode<T> node);

/// A mixin for classes implementing a tree structure as expected by a
/// [TreeViewController].
///
/// Used by [TreeView] to implement an interface for the [TreeViewController].
///
/// This allows the [TreeViewController] to be used in other widgets that
/// implement this interface.
///
/// The type [T] correlates to the type of [TreeView] and [TreeViewNode],
/// representing the type of [TreeViewNode.content].
mixin TreeViewStateMixin<T> {
  /// Returns whether or not the given [TreeViewNode] is expanded, regardless of
  /// whether or not it is active in the tree.
  bool isExpanded(TreeViewNode<T> node);

  /// Returns whether or not the given [TreeViewNode] is enclosed within its
  /// parent [TreeViewNode].
  ///
  /// If the [TreeViewNode.parent] [isExpanded] (and all its parents are
  /// expanded), or this is a root node, the given node is active and this
  /// method will return true. This does not reflect whether or not the node is
  /// visible in the [Viewport].
  bool isActive(TreeViewNode<T> node);

  /// Switches the given [TreeViewNode]s expanded state.
  ///
  /// May trigger an animation to reveal or hide the node's children based on
  /// the [TreeView.toggleAnimationStyle].
  ///
  /// If the node does not have any children, nothing will happen.
  void toggleNode(TreeViewNode<T> node);

  /// Closes all parent [TreeViewNode]s in the tree.
  void collapseAll();

  /// Expands all parent [TreeViewNode]s in the tree.
  void expandAll();

  /// Retrieves the [TreeViewNode] containing the associated content, if it
  /// exists.
  ///
  /// If no node exists, this will return null. This does not reflect whether
  /// or not a node [isActive], or if it is visible in the viewport.
  TreeViewNode<T>? getNodeFor(T content);

  /// Returns the current row index of the given [TreeViewNode].
  ///
  /// If the node is not currently active in the tree, meaning its parent is
  /// collapsed, this will return null.
  int? getActiveIndexFor(TreeViewNode<T> node);
}

/// Represents the animation of the children of a parent [TreeViewNode] that
/// are animating into or out of view.
///
/// The [fromIndex] and [toIndex] are identify the animating children following
/// the parent, with the [value] representing the status of the current
/// animation. The value of [toIndex] is inclusive, meaning the child at that
/// index is included in the animating segment.
///
/// Provided to [RenderTreeViewport] as part of
/// [RenderTreeViewport.activeAnimations] by [TreeView] to properly offset
/// animating children.
typedef TreeViewNodesAnimation = ({
  int fromIndex,
  int toIndex,
  double value,
});

/// The style of indentation for [TreeViewNode]s in a [TreeView], as handled
/// by [RenderTreeViewport].
///
/// By default, the indentation is handled by [RenderTreeViewport]. Child nodes
/// are offset by the indentation specified by
/// [TreeViewIndentationType.value] in the cross axis of the viewport. This
/// means the space allotted to the indentation will not be part of the space
/// made available to the Widget returned by [TreeView.treeNodeBuilder].
///
/// Alternatively, the indentation can be implemented in
/// [TreeView.treeNodeBuilder], with the depth of the given tree row accessed
/// by [TreeViewNode.depth]. This allows for more customization in building
/// tree rows, such as filling the indented area with decorations or ink
/// effects.
class TreeViewIndentationType {
  const TreeViewIndentationType._internal(double value) : _value = value;

  /// The number of pixels by which [TreeViewNode]s will be offset according
  /// to their [TreeViewNode.depth].
  double get value => _value;
  final double _value;

  /// The default indentation of child [TreeViewNode]s in a [TreeView].
  ///
  /// Child nodes will be offset by 10 pixels for each level in the tree.
  static const TreeViewIndentationType standard =
      TreeViewIndentationType._internal(10.0);

  /// Configures no offsetting of child nodes in a [TreeView].
  ///
  /// Useful if the indentation is implemented in the
  /// [TreeView.treeNodeBuilder] instead for more customization options.
  ///
  /// Child nodes will not be offset in the tree.
  static const TreeViewIndentationType none =
      TreeViewIndentationType._internal(0.0);

  /// Configures a custom offset for indenting child nodes in a [TreeView].
  ///
  /// Child nodes will be offset by the provided number of pixels in the tree.
  /// The [value] must be a non negative number.
  static TreeViewIndentationType custom(double value) {
    assert(value >= 0.0);
    return TreeViewIndentationType._internal(value);
  }
}
