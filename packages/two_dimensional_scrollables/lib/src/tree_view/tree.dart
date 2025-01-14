// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'render_tree.dart';
import 'tree_core.dart';
import 'tree_delegate.dart';
import 'tree_span.dart';

// The classes in these files follow the same pattern as the one dimensional
// sliver tree in the framework.
//
// After rolling to stable, these classes may be deprecated, or more likely
// made to be typedefs/subclasses of the framework core tree components. They
// could also live on if at a later date the 2D TreeView deviates or adds
// special features not relevant to the 1D sliver components of the framework.

const double _kDefaultRowExtent = 40.0;

/// A data structure for configuring children of a [TreeView].
///
/// A [TreeViewNode.content] can be of any type [T], but must correspond with
/// the same type of the [TreeView].
///
/// Getters for [depth], [parent] and [isExpanded] are managed by the
/// [TreeView]'s state.
class TreeViewNode<T> {
  /// Creates a [TreeViewNode] instance for use in a [TreeView].
  TreeViewNode(
    T content, {
    List<TreeViewNode<T>>? children,
    bool expanded = false,
  })  : _expanded = children != null && children.isNotEmpty && expanded,
        _content = content,
        _children = children ?? <TreeViewNode<T>>[];

  /// The subject matter of the node.
  ///
  /// Must correspond with the type of [TreeView].
  T get content => _content;
  final T _content;

  /// Other [TreeViewNode]s that this node will be [parent] to.
  ///
  /// Modifying the children of nodes in a [TreeView] will cause the tree to be
  /// rebuilt so that newly added active nodes are reflected in the tree.
  List<TreeViewNode<T>> get children => _children;
  final List<TreeViewNode<T>> _children;

  /// Whether or not this node is expanded in the tree.
  ///
  /// Cannot be expanded if there are no children.
  bool get isExpanded => _expanded;
  bool _expanded;

  /// The number of parent nodes between this node and the root of the tree.
  int? get depth => _depth;
  int? _depth;

  /// The parent [TreeViewNode] of this node.
  TreeViewNode<T>? get parent => _parent;
  TreeViewNode<T>? _parent;

  @override
  String toString() {
    return 'TreeViewNode: $content, depth: ${depth == 0 ? 'root' : depth}, '
        '${children.isEmpty ? 'leaf' : 'parent, expanded: $isExpanded'}';
  }
}

/// Enables control over the [TreeViewNodes] of a [TreeView].
///
/// It can be useful to expand or collapse nodes of the tree
/// programmatically, for example to reconfigure an existing node
/// based on a system event. To do so, create a [TreeView]
/// with a [TreeViewController] that's owned by a stateful widget
/// or look up the tree's automatically created [TreeViewController]
/// with [TreeViewController.of]
///
/// The controller's methods to expand or collapse nodes cause the
/// the [TreeView] to rebuild, so they may not be called from
/// a build method.
class TreeViewController {
  /// Create a controller to be used with [TreeView.controller].
  TreeViewController();

  TreeViewStateMixin<Object?>? _state;

  /// Whether the given [TreeViewNode] built with this controller is in an
  /// expanded state.
  ///
  /// See also:
  ///
  ///  * [expandNode], which expands a given [TreeViewNode].
  ///  * [collapseNode], which collapses a given [TreeViewNode].
  ///  * [TreeView.controller] to create an TreeView with a controller.
  bool isExpanded(TreeViewNode<Object?> node) {
    assert(_state != null);
    return _state!.isExpanded(node);
  }

  /// Whether or not the given [TreeViewNode] is enclosed within its parent
  /// [TreeViewNode].
  ///
  /// If the [TreeViewNode.parent] [isExpanded], or this is a root node, the given
  /// node is active and this method will return true. This does not reflect
  /// whether or not the node is visible in the [Viewport].
  bool isActive(TreeViewNode<Object?> node) {
    assert(_state != null);
    return _state!.isActive(node);
  }

  /// Returns the [TreeViewNode] containing the associated content, if it exists.
  ///
  /// If no node exists, this will return null. This does not reflect whether
  /// or not a node [isActive], or if it is currently visible in the viewport.
  TreeViewNode<Object?>? getNodeFor(Object? content) {
    assert(_state != null);
    return _state!.getNodeFor(content);
  }

  /// Switches the given [TreeViewNode]s expanded state.
  ///
  /// May trigger an animation to reveal or hide the node's children based on
  /// the [TreeView.toggleAnimationStyle].
  ///
  /// If the node does not have any children, nothing will happen.
  void toggleNode(TreeViewNode<Object?> node) {
    assert(_state != null);
    return _state!.toggleNode(node);
  }

  /// Expands the [TreeViewNode] that was built with this controller.
  ///
  /// If the node is already in the expanded state (see [isExpanded]), calling
  /// this method has no effect.
  ///
  /// Calling this method may cause the [TreeView] to rebuild, so it may
  /// not be called from a build method.
  ///
  /// Calling this method will trigger the [TreeView.onNodeToggle] callback.
  ///
  /// See also:
  ///
  ///  * [collapseNode], which collapses the [TreeViewNode].
  ///  * [isExpanded] to check whether the tile is expanded.
  ///  * [TreeView.controller] to create an TreeView with a controller.
  void expandNode(TreeViewNode<Object?> node) {
    assert(_state != null);
    if (!node.isExpanded) {
      _state!.toggleNode(node);
    }
  }

  /// Expands all parent [TreeViewNode]s in the tree.
  void expandAll() {
    assert(_state != null);
    _state!.expandAll();
  }

  /// Closes all parent [TreeViewNode]s in the tree.
  void collapseAll() {
    assert(_state != null);
    _state!.collapseAll();
  }

  /// Returns the current row index of the given [TreeViewNode].
  ///
  /// If the node is not currently active in the tree, meaning its parent is
  /// collapsed, this will return null.
  int? getActiveIndexFor(TreeViewNode<Object?> node) {
    assert(_state != null);
    return _state!.getActiveIndexFor(node);
  }

  /// Collapses the [TreeViewNode] that was built with this controller.
  ///
  /// If the node is already in the collapsed state (see [isExpanded]), calling
  /// this method has no effect.
  ///
  /// Calling this method may cause the [TreeView] to rebuild, so it may
  /// not be called from a build method.
  ///
  /// Calling this method will trigger the [TreeView.onNodeToggle] callback.
  ///
  /// See also:
  ///
  ///  * [expandNode], which expands the tile.
  ///  * [isExpanded] to check whether the tile is expanded.
  ///  * [TreeView.controller] to create an TreeView with a controller.
  void collapseNode(TreeViewNode<Object?> node) {
    assert(_state != null);
    if (node.isExpanded) {
      _state!.toggleNode(node);
    }
  }

  /// Finds the [TreeViewController] for the closest [TreeView] instance
  /// that encloses the given context.
  ///
  /// If no [TreeView] encloses the given context, calling this
  /// method will cause an assert in debug mode, and throw an
  /// exception in release mode.
  ///
  /// To return null if there is no [TreeView] use [maybeOf] instead.
  ///
  /// Typical usage of the [TreeViewController.of] function is to call it
  /// from within the `build` method of a descendant of an [TreeView].
  ///
  /// When the [TreeView] is actually created in the same `build`
  /// function as the callback that refers to the controller, then the
  /// `context` argument to the `build` function can't be used to find
  /// the [TreeViewController] (since it's "above" the widget
  /// being returned in the widget tree). In cases like that you can
  /// add a [Builder] widget, which provides a new scope with a
  /// [BuildContext] that is "under" the [TreeView].
  static TreeViewController of(BuildContext context) {
    final _TreeViewState<Object?>? result =
        context.findAncestorStateOfType<_TreeViewState<Object?>>();
    if (result != null) {
      return result.controller;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'TreeViewController.of() called with a context that does not contain a '
        'TreeView.',
      ),
      ErrorDescription(
        'No TreeView ancestor could be found starting from the context that '
        'was passed to TreeViewController.of(). '
        'This usually happens when the context provided is from the same '
        'StatefulWidget as that whose build function actually creates the '
        'TreeView widget being sought.',
      ),
      ErrorHint(
        'There are several ways to avoid this problem. The simplest is to use '
        'a Builder to get a context that is "under" the TreeView.',
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into '
        'several widgets. This introduces a new context from which you can '
        'obtain the TreeView. In this solution, you would have an outer '
        'widget that creates the TreeView populated by instances of your new '
        'inner widgets, and then in these inner widgets you would use '
        'TreeViewController.of().',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// Finds the [TreeView] from the closest instance of this class that
  /// encloses the given context and returns its [TreeViewController].
  ///
  /// If no [TreeView] encloses the given context then return null.
  /// To throw an exception instead, use [of] instead of this function.
  ///
  /// See also:
  ///
  ///  * [of], a similar function to this one that throws if no [TreeView]
  ///    encloses the given context. Also includes some sample code in its
  ///    documentation.
  static TreeViewController? maybeOf(BuildContext context) {
    return context
        .findAncestorStateOfType<_TreeViewState<Object?>>()
        ?.controller;
  }
}

// END of shared surfaces from the framework.

/// A widget that displays [TreeViewNode]s that expand and collapse in a
/// vertically and horizontally scrolling [TreeViewport].
///
/// The type [T] correlates to the type of [TreeView] and [TreeViewNode],
/// representing the type of [TreeViewNode.content].
///
/// The rows of the tree are laid out on demand by the [TreeViewport]'s render
/// object, using [TreeView.treeNodeBuilder]. This will only be called for the
/// nodes that are visible, or within the [TreeViewport.cacheExtent].
///
/// The [TreeView.treeNodeBuilder] returns the [Widget] that represents the
/// given [TreeViewNode].
///
/// The [TreeView.treeRowBuilder] returns a [TreeRow],
/// which provides details about the row such as the [TreeRowExtent], as well as
/// any [TreeRow.recognizerFactories], [TreeRowDecoration]s, and more.
///
/// Providing a [TreeController] will enable querying and controlling the state
/// of nodes in the tree.
///
/// Each active node of the tree will have a [TreeVicinity], representing the
/// resolved row index of the node, based on what nodes are active, as well as
/// the depth.
///
/// A [TreeView] only supports a vertical axis direction of
/// [AxisDirection.down] and a horizontal axis direction of
/// [AxisDirection.right].
class TreeView<T> extends StatefulWidget {
  /// Creates an instance of a [TreeView] for displaying [TreeViewNode]s
  /// that animate expanding and collapsing of nodes.
  TreeView({
    super.key,
    required this.tree,
    this.treeNodeBuilder = TreeView.defaultTreeNodeBuilder,
    this.treeRowBuilder = TreeView.defaultTreeRowBuilder,
    this.controller,
    this.onNodeToggle,
    this.toggleAnimationStyle,
    this.indentation = TreeViewIndentationType.standard,
    this.primary,
    this.mainAxis = Axis.vertical,
    this.verticalDetails = const ScrollableDetails.vertical(),
    this.horizontalDetails = const ScrollableDetails.horizontal(),
    this.cacheExtent,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
  }) : assert(verticalDetails.direction == AxisDirection.down &&
            horizontalDetails.direction == AxisDirection.right);

  /// The list of [TreeViewNode]s that may be displayed in the [TreeView].
  ///
  /// Beyond root nodes, or those in this list, whether or not a given
  /// [TreeViewNode] is displayed depends on the [TreeViewNode.isExpanded] value
  /// of its parent. The [TreeView] will set the [TreeViewNode.parent] and
  /// [TreeViewNode.depth] as nodes are built on demand to ensure the integrity
  /// of the tree.
  final List<TreeViewNode<T>> tree;

  /// Called to build an entry of the [TreeView] for the given [TreeViewNode].
  ///
  /// By default, if this is unset, the [TreeView.defaultTreeNodeBuilder] is
  /// used.
  final TreeViewNodeBuilder<T> treeNodeBuilder;

  /// Builds the [TreeRow] that describes the row for the provided
  /// [TreeViewNode].
  ///
  /// By default, if this is unset, the [TreeView.defaultTreeRowBuilder]
  /// is used.
  final TreeViewRowBuilder<T> treeRowBuilder;

  /// If provided, the controller can be used to expand and collapse
  /// [TreeViewNode]s, or lookup information about the current state of the
  /// [TreeView].
  final TreeViewController? controller;

  /// Called when a [TreeViewNode] is toggled to expand or collapse.
  ///
  /// This will be called before the collapse or expand animation starts, but
  /// after the [TreeViewNode.isExpanded] value is updated. This means that
  /// [TreeViewNode.isExpanded] will reflect the value it is transitioning to as
  /// a result of being toggled.
  ///
  /// This will not be called if a [TreeViewNode] does not have any children.
  final TreeViewNodeCallback<T>? onNodeToggle;

  /// The default [AnimationStyle] for expanding and collapsing nodes in the
  /// [TreeView].
  ///
  /// The default [AnimationStyle.duration] uses
  /// [TreeView.defaultAnimationDuration], which is 150 milliseconds.
  ///
  /// The default [AnimationStyle.curve] uses [TreeView.defaultAnimationCurve],
  /// which is [Curves.linear].
  ///
  /// To disable the tree animation, use [AnimationStyle.noAnimation].
  final AnimationStyle? toggleAnimationStyle;

  /// The number of pixels children will be offset by in the cross axis based on
  /// their [TreeViewNode.depth].
  ///
  /// By default, the indentation is handled by [RenderTreeViewport]. Child
  /// nodes are offset by the indentation specified by
  /// [TreeViewIndentationType.value] in the cross axis of the viewport. This
  /// means the space allotted to the indentation will not be part of the space
  /// made available to the Widget returned by [TreeView.treeNodeBuilder].
  ///
  /// Alternatively, the indentation can be implemented in
  /// [TreeView.treeNodeBuilder]. By providing [TreeViewIndentationType.none],
  /// the depth of the given tree row can be accessed
  /// in [TreeView.treeNodeBuilder] through [TreeViewNode.depth]. This allows
  /// for more customization in building tree rows, such as filling the indented
  /// area with decorations or ink effects.
  final TreeViewIndentationType indentation;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// When this is true, the scroll view is scrollable even if it does not have
  /// sufficient content to actually scroll. Otherwise, by default the user can
  /// only scroll the view if it has sufficient content.
  ///
  /// See also:
  ///
  ///   * [TwoDimensionalScrollView.primary], whether or not the
  ///     [TreeView.mainAxis] will use the [PrimaryScrollController].
  final bool? primary;

  /// The main axis of the two.
  ///
  /// Used to determine how to apply [primary] when true. This will not affect
  /// paint order or traversal order of [TreeViewNode]s. Nodes will be painted
  /// in the order they are laid out in the vertical axis. For tree traversal,
  /// see [TreeViewTraversalOrder].
  ///
  /// Defaults to [Axis.vertical].
  final Axis mainAxis;

  /// The configuration of the vertical Scrollable.
  ///
  /// These [ScrollableDetails] can be used to set the [AxisDirection],
  /// [ScrollController], [ScrollPhysics] and more for the vertical axis.
  final ScrollableDetails verticalDetails;

  /// The configuration of the horizontal Scrollable.
  ///
  /// These [ScrollableDetails] can be used to set the [AxisDirection],
  /// [ScrollController], [ScrollPhysics] and more for the horizontal axis.
  final ScrollableDetails horizontalDetails;

  /// The [TreeViewport] has an area before and after the visible area to cache
  /// rows that are about to become visible when the user scrolls.
  ///
  /// [TreeRow]s that fall in this cache area are laid out even though they are
  /// not (yet) visible on screen. The [cacheExtent] describes how many pixels
  /// the cache area extends before the leading edge and after the trailing edge
  /// of the viewport.
  ///
  /// See also:
  ///
  ///   * [TwoDimensionalScrollView.cacheExtent], the area beyond the viewport
  ///     bounds where soon-to-be-visible children are rendered.
  final double? cacheExtent;

  /// Whether scrolling gestures should lock to one axes, allow free movement
  /// in both axes, or be evaluated on a weighted scale.
  ///
  /// Defaults to [DiagonalDragBehavior.none], locking axes to receive input one
  /// at a time.
  final DiagonalDragBehavior diagonalDragBehavior;

  /// Determines the way that drag start behavior is handled.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [TwoDimensionalScrollView.dragStartBehavior]
  final DragStartBehavior dragStartBehavior;

  /// [ScrollViewKeyboardDismissBehavior] the defines how this [ScrollView] will
  /// dismiss the keyboard automatically.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// The bounds of the [TreeViewport] will be clipped (or not) according to
  /// this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// Whether to wrap each row of the tree in an [AutomaticKeepAlive].
  ///
  /// Typically, lazily laid out children are wrapped in [AutomaticKeepAlive]
  /// widgets so that the children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAlive] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each row in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and instead always repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// The default [AnimationStyle] used for node expand and collapse animations,
  /// when one has not been provided in [toggleAnimationStyle].
  // ignore: prefer_const_constructors
  static AnimationStyle defaultToggleAnimationStyle = AnimationStyle(
    curve: defaultAnimationCurve,
    duration: defaultAnimationDuration,
  );

  /// A default of [Curves.linear], which is used in the tree's expanding and
  /// collapsing node animation.
  static const Curve defaultAnimationCurve = Curves.linear;

  /// A default [Duration] of 150 milliseconds, which is used in the tree's
  /// expanding and collapsing node animation.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 150);

  /// A wrapper method for triggering the expansion or collapse of a
  /// [TreeViewNode].
  ///
  /// Use as part of [TreeView.defaultTreeNodeBuilder] to wrap the leading icon
  /// of parent [TreeViewNode]s such that tapping on it triggers the animation.
  ///
  /// If defining your own [TreeView.treeNodeBuilder], this method can be used
  /// to wrap any part, or all, of the returned widget in order to trigger the
  /// change in state for the node when tapped.
  ///
  /// The gesture uses [HitTestBehavior.translucent], so as to not conflict
  /// with any [TreeRow.recognizerFactories] or other interactive content in the
  /// [TreeRow].
  static Widget wrapChildToToggleNode({
    required TreeViewNode<Object?> node,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          TreeViewController.of(context).toggleNode(node);
        },
        child: child,
      );
    });
  }

  /// Returns the fixed height, default [TreeRow] for rows in the tree,
  /// which is 40 pixels.
  ///
  /// Used by [TreeView.treeRowBuilder].
  static TreeRow defaultTreeRowBuilder(TreeViewNode<Object?> node) {
    return const TreeRow(
      extent: FixedTreeRowExtent(_kDefaultRowExtent),
    );
  }

  /// Default builder for the widget representing a given [TreeViewNode] in the
  /// tree.
  ///
  /// Used by [TreeView.treeNodeBuilder].
  ///
  /// This will return a [Row] containing the [toString] of
  /// [TreeViewNode.content]. If the [TreeViewNode] is a parent of additional
  /// nodes, an arrow icon will precede the content, and will trigger an expand
  /// and collapse animation when tapped based on the
  /// [TreeView.toggleAnimationStyle].
  static Widget defaultTreeNodeBuilder(
    BuildContext context,
    TreeViewNode<Object?> node,
    AnimationStyle toggleAnimationStyle,
  ) {
    final Duration animationDuration =
        toggleAnimationStyle.duration ?? TreeView.defaultAnimationDuration;
    final Curve animationCurve =
        toggleAnimationStyle.curve ?? TreeView.defaultAnimationCurve;
    final int index = TreeViewController.of(context).getActiveIndexFor(node)!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: <Widget>[
        // Icon for parent nodes
        TreeView.wrapChildToToggleNode(
          node: node,
          child: SizedBox.square(
            dimension: 30.0,
            child: node.children.isNotEmpty
                ? AnimatedRotation(
                    key: ValueKey<int>(index),
                    turns: node.isExpanded ? 0.25 : 0.0,
                    duration: animationDuration,
                    curve: animationCurve,
                    // Renders a unicode right-facing arrow. >
                    child: const Icon(IconData(0x25BA), size: 14),
                  )
                : null,
          ),
        ),
        // Spacer
        const SizedBox(width: 8.0),
        // Content
        Text(node.content.toString()),
      ]),
    );
  }

  @override
  State<TreeView<T>> createState() => _TreeViewState<T>();
}

// Used in TreeViewState for code simplicity.
typedef _AnimationRecord = ({
  AnimationController controller,
  CurvedAnimation animation,
  UniqueKey key,
});

class _TreeViewState<T> extends State<TreeView<T>>
    with TickerProviderStateMixin, TreeViewStateMixin<T> {
  TreeViewController get controller => _treeController!;
  TreeViewController? _treeController;

  // The flat representation of the tree, omitting nodes that are not active.
  final List<TreeViewNode<T>> _activeNodes = <TreeViewNode<T>>[];
  final Map<int, int> _rowDepths = <int, int>{};
  bool _shouldUnpackNode(TreeViewNode<T> node) {
    if (node.children.isEmpty) {
      // No children to unpack.
      return false;
    }
    if (_currentAnimationForParent[node] != null) {
      // Whether expanding or collapsing, the child nodes are still active, so
      // unpack.
      return true;
    }
    // If we are not animating, respect node.isExpanded;
    return node.isExpanded;
  }

  // Flattens the tree, omitting nodes that are not active.
  void _unpackActiveNodes({
    int depth = 0,
    List<TreeViewNode<T>>? nodes,
    TreeViewNode<T>? parent,
  }) {
    if (nodes == null) {
      _activeNodes.clear();
      _rowDepths.clear();
      nodes = widget.tree;
    }
    for (final TreeViewNode<T> node in nodes) {
      node._depth = depth;
      node._parent = parent;
      _activeNodes.add(node);
      _rowDepths[_activeNodes.length - 1] = depth;
      if (_shouldUnpackNode(node)) {
        _unpackActiveNodes(
          depth: depth + 1,
          nodes: node.children,
          parent: node,
        );
      }
    }
  }

  final Map<TreeViewNode<T>, _AnimationRecord> _currentAnimationForParent =
      <TreeViewNode<T>, _AnimationRecord>{};
  final Map<UniqueKey, TreeViewNodesAnimation> _activeAnimations =
      <UniqueKey, TreeViewNodesAnimation>{};

  @override
  void initState() {
    _unpackActiveNodes();
    assert(
      widget.controller?._state == null,
      'The provided TreeViewController is already associated with another '
      'TreeView. A TreeViewController can only be associated with one '
      'TreeView.',
    );
    _treeController = widget.controller ?? TreeViewController();
    _treeController!._state = this;
    super.initState();
  }

  @override
  void didUpdateWidget(TreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Internal or provided, there is always a tree controller.
    assert(_treeController != null);
    if (oldWidget.controller == null && widget.controller != null) {
      // A new tree controller has been provided, update and dispose of the
      // internally generated one.
      _treeController!._state = null;
      _treeController = widget.controller;
      _treeController!._state = this;
    } else if (oldWidget.controller != null && widget.controller == null) {
      // A tree controller had been provided, but was removed. We need to create
      // one internally.
      assert(oldWidget.controller == _treeController);
      oldWidget.controller!._state = null;
      _treeController = TreeViewController();
      _treeController!._state = this;
    } else if (oldWidget.controller != widget.controller) {
      assert(oldWidget.controller != null);
      assert(widget.controller != null);
      assert(oldWidget.controller == _treeController);
      // The tree is still being provided a controller, but it has changed. Just
      // update it.
      _treeController!._state = null;
      _treeController = widget.controller;
      _treeController!._state = this;
    }
    // Internal or provided, there is always a tree controller.
    assert(_treeController != null);
    assert(_treeController!._state != null);
    _unpackActiveNodes();
  }

  @override
  void dispose() {
    _treeController!._state = null;
    for (final _AnimationRecord record in _currentAnimationForParent.values) {
      record.animation.dispose();
      record.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _TreeView(
      primary: widget.primary,
      mainAxis: widget.mainAxis,
      horizontalDetails: widget.horizontalDetails,
      verticalDetails: widget.verticalDetails,
      cacheExtent: widget.cacheExtent,
      diagonalDragBehavior: widget.diagonalDragBehavior,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
      rowCount: _activeNodes.length,
      activeAnimations: _activeAnimations,
      rowDepths: _rowDepths,
      nodeBuilder: (BuildContext context, ChildVicinity vicinity) {
        vicinity = vicinity as TreeVicinity;
        final TreeViewNode<T> node = _activeNodes[vicinity.row];
        assert(vicinity.depth == node.depth);
        Widget child = widget.treeNodeBuilder(
          context,
          node,
          widget.toggleAnimationStyle ?? TreeView.defaultToggleAnimationStyle,
        );

        if (widget.addRepaintBoundaries) {
          child = RepaintBoundary(child: child);
        }

        return child;
      },
      rowBuilder: (TreeVicinity vicinity) {
        return widget.treeRowBuilder(_activeNodes[vicinity.row]);
      },
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      indentation: widget.indentation.value,
    );
  }

  // TreeViewStateMixin Implementation

  @override
  bool isExpanded(TreeViewNode<T> node) {
    return _getNode(node.content, widget.tree)?.isExpanded ?? false;
  }

  @override
  bool isActive(TreeViewNode<T> node) => _activeNodes.contains(node);

  @override
  TreeViewNode<T>? getNodeFor(T content) => _getNode(content, widget.tree);
  TreeViewNode<T>? _getNode(T content, List<TreeViewNode<T>> tree) {
    final List<TreeViewNode<T>> nextDepth = <TreeViewNode<T>>[];
    for (final TreeViewNode<T> node in tree) {
      if (node.content == content) {
        return node;
      }
      if (node.children.isNotEmpty) {
        nextDepth.addAll(node.children);
      }
    }
    if (nextDepth.isNotEmpty) {
      return _getNode(content, nextDepth);
    }
    return null;
  }

  @override
  int? getActiveIndexFor(TreeViewNode<T> node) {
    if (_activeNodes.contains(node)) {
      return _activeNodes.indexOf(node);
    }
    return null;
  }

  @override
  void expandAll() {
    final List<TreeViewNode<T>> activeNodesToExpand = <TreeViewNode<T>>[];
    _expandAll(widget.tree, activeNodesToExpand);
    activeNodesToExpand.reversed.forEach(toggleNode);
  }

  void _expandAll(
    List<TreeViewNode<T>> tree,
    List<TreeViewNode<T>> activeNodesToExpand,
  ) {
    for (final TreeViewNode<T> node in tree) {
      if (node.children.isNotEmpty) {
        // This is a parent node.
        // Expand all the children, and their children.
        _expandAll(node.children, activeNodesToExpand);
        if (!node.isExpanded) {
          // The node itself needs to be expanded.
          if (_activeNodes.contains(node)) {
            // This is an active node in the tree, add to
            // the list to toggle once all hidden nodes
            // have been handled.
            activeNodesToExpand.add(node);
          } else {
            // This is a hidden node. Update its expanded state.
            node._expanded = true;
          }
        }
      }
    }
  }

  @override
  void collapseAll() {
    final List<TreeViewNode<T>> activeNodesToCollapse = <TreeViewNode<T>>[];
    _collapseAll(widget.tree, activeNodesToCollapse);
    activeNodesToCollapse.reversed.forEach(toggleNode);
  }

  void _collapseAll(
    List<TreeViewNode<T>> tree,
    List<TreeViewNode<T>> activeNodesToCollapse,
  ) {
    for (final TreeViewNode<T> node in tree) {
      if (node.children.isNotEmpty) {
        // This is a parent node.
        // Collapse all the children, and their children.
        _collapseAll(node.children, activeNodesToCollapse);
        if (node.isExpanded) {
          // The node itself needs to be collapsed.
          if (_activeNodes.contains(node)) {
            // This is an active node in the tree, add to
            // the list to toggle once all hidden nodes
            // have been handled.
            activeNodesToCollapse.add(node);
          } else {
            // This is a hidden node. Update its expanded state.
            node._expanded = false;
          }
        }
      }
    }
  }

  void _updateActiveAnimations() {
    // The indexes of various child node animations can change constantly based
    // on more nodes being expanded or collapsed. Compile the indexes and their
    // animations keys each time we build with an updated active node list.
    _activeAnimations.clear();
    for (final TreeViewNode<T> node in _currentAnimationForParent.keys) {
      final _AnimationRecord animationRecord =
          _currentAnimationForParent[node]!;
      final int leadingChildIndex = _activeNodes.indexOf(node) + 1;
      final TreeViewNodesAnimation animatingChildren = (
        fromIndex: leadingChildIndex,
        toIndex: leadingChildIndex + node.children.length - 1,
        value: animationRecord.animation.value,
      );
      _activeAnimations[animationRecord.key] = animatingChildren;
    }
  }

  @override
  void toggleNode(TreeViewNode<T> node) {
    assert(_activeNodes.contains(node));
    if (node.children.isEmpty) {
      // No state to change.
      return;
    }
    setState(() {
      node._expanded = !node._expanded;
      if (widget.onNodeToggle != null) {
        widget.onNodeToggle!(node);
      }

      // If animation is disabled or duration is zero, skip the animation
      // and update the active nodes immediately. This ensures the tree
      // is updated correctly when the node's children are no longer active.
      if (widget.toggleAnimationStyle?.duration == Duration.zero) {
        _unpackActiveNodes();
        return;
      }

      final AnimationController controller =
          _currentAnimationForParent[node]?.controller ??
              AnimationController(
                value: node._expanded ? 0.0 : 1.0,
                vsync: this,
                duration: widget.toggleAnimationStyle?.duration ??
                    TreeView.defaultAnimationDuration,
              );
      controller
        ..addStatusListener((AnimationStatus status) {
          switch (status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.completed:
              _currentAnimationForParent[node]!.controller.dispose();
              _currentAnimationForParent.remove(node);
              _updateActiveAnimations();
              // If the node is collapsing, we need to unpack the active
              // nodes to remove the ones that were removed from the tree.
              // This is only necessary if the node is collapsing.
              if (!node._expanded) {
                _unpackActiveNodes();
              }
            case AnimationStatus.forward:
            case AnimationStatus.reverse:
          }
        })
        ..addListener(() {
          setState(() {
            _updateActiveAnimations();
          });
        });

      switch (controller.status) {
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          // We're interrupting an animation already in progress.
          controller.stop();
        case AnimationStatus.dismissed:
        case AnimationStatus.completed:
      }

      final CurvedAnimation newAnimation = CurvedAnimation(
        parent: controller,
        curve: widget.toggleAnimationStyle?.curve ??
            TreeView.defaultAnimationCurve,
      );
      _currentAnimationForParent[node] = (
        controller: controller,
        animation: newAnimation,
        // This key helps us keep track of the lifetime of this animation in the
        // render object, since the indexes can change at any time.
        key: UniqueKey(),
      );
      switch (node._expanded) {
        case true:
          // Expanding
          _unpackActiveNodes();
          controller.forward();
        case false:
          // Collapsing
          controller.reverse();
      }
    });
  }
}

class _TreeView extends TwoDimensionalScrollView {
  _TreeView({
    super.primary,
    super.mainAxis,
    super.horizontalDetails,
    super.verticalDetails,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.clipBehavior,
    required TwoDimensionalIndexedWidgetBuilder nodeBuilder,
    required TreeVicinityToRowBuilder rowBuilder,
    required this.activeAnimations,
    required this.rowDepths,
    required this.indentation,
    required int rowCount,
    bool addAutomaticKeepAlives = true,
  })  : assert(verticalDetails.direction == AxisDirection.down),
        assert(horizontalDetails.direction == AxisDirection.right),
        super(
            delegate: TreeRowBuilderDelegate(
          nodeBuilder: nodeBuilder,
          rowBuilder: rowBuilder,
          rowCount: rowCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
        ));

  final Map<UniqueKey, TreeViewNodesAnimation> activeAnimations;
  final Map<int, int> rowDepths;
  final double indentation;

  @override
  TreeViewport buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TreeViewport(
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      delegate: delegate as TreeRowDelegateMixin,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      activeAnimations: activeAnimations,
      rowDepths: rowDepths,
      indentation: indentation,
    );
  }
}

/// A widget through which a portion of a tree of [TreeViewNode] children are
/// viewed as rows, typically in combination with a [TreeView].
class TreeViewport extends TwoDimensionalViewport {
  /// Creates a viewport for [Widget]s that extend and scroll in both
  /// horizontal and vertical dimensions.
  const TreeViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TreeRowDelegateMixin super.delegate,
    super.cacheExtent,
    super.clipBehavior,
    required this.activeAnimations,
    required this.rowDepths,
    required this.indentation,
  })  : assert(verticalAxisDirection == AxisDirection.down &&
            horizontalAxisDirection == AxisDirection.right),
        // This is fixed as there is currently only one traversal pattern, https://github.com/flutter/flutter/issues/148357
        super(mainAxis: Axis.vertical);

  /// The currently active [TreeViewNode] animations.
  ///
  /// Since the indexing of animating nodes can change at any time from
  /// inserting and removing them from the tree, the unique key is used to track
  /// an animation of nodes independent of their indexing across frames.
  final Map<UniqueKey, TreeViewNodesAnimation> activeAnimations;

  /// The depth of each active [TreeNode].
  final Map<int, int> rowDepths;

  /// The number of pixels by which child nodes will be offset in the cross axis
  /// based on their [TreeViewNode.depth].
  ///
  /// If zero, can alternatively offset children in [TreeView.treeRowBuilder]
  /// for more options to customize the indented space.
  final double indentation;

  @override
  RenderTreeViewport createRenderObject(BuildContext context) {
    return RenderTreeViewport(
      activeAnimations: activeAnimations,
      rowDepths: rowDepths,
      indentation: indentation,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      delegate: delegate as TreeRowDelegateMixin,
      childManager: context as TwoDimensionalChildManager,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTreeViewport renderObject,
  ) {
    renderObject
      ..activeAnimations = activeAnimations
      ..rowDepths = rowDepths
      ..indentation = indentation
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior
      ..delegate = delegate as TreeRowDelegateMixin;
  }
}
