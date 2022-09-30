// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../state.dart';

/// Transition builder callback used by [IndexStackShell].
///
/// The builder is expected to return a transition powered by the provided
/// `animation` and wrapping the provided `child`.
///
/// The `animation` provided to the builder always runs forward from 0.0 to 1.0.
typedef StackedNavigationTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// Builder for the scaffold of a [StackedNavigationScaffold]
typedef StackedNavigationScaffoldBuilder = Widget Function(
    BuildContext context,
    int currentIndex,
    List<StackedNavigationItemState> itemsState,
    Widget scaffoldBody);

/// Representation of a item in the stack of a [StackedNavigationScaffold]
class StackedNavigationItem {
  /// Constructs an [StackedNavigationItem].
  StackedNavigationItem(
      {required this.initialLocation, required this.navigatorKey});

  /// The initial location/path
  final String initialLocation;

  /// Optional navigatorKey
  final GlobalKey<NavigatorState> navigatorKey;
}

/// Represents the current state of a [StackedNavigationItem] in a
/// [StackedNavigationScaffold]
class StackedNavigationItemState {
  /// Constructs an [StackedNavigationItemState].
  StackedNavigationItemState(this.item);

  /// The [StackedNavigationItem] this state is representing.
  final StackedNavigationItem item;

  /// The current [GoRouterState] for the navigator of this item.
  GoRouterState? currentRouterState;

  /// The [Navigator] for this item.
  Navigator? navigator;

  /// Gets the current location from the [currentRouterState] or falls back to
  /// the initial location of the associated [item].
  String get currentLocation => currentRouterState != null
      ? currentRouterState!.location
      : item.initialLocation;
}

/// Widget that maintains a stateful stack of [Navigator]s, using an
/// [IndexStack].
class StackedNavigationScaffold extends StatefulWidget {
  /// Constructs an [IndexStackShell].
  const StackedNavigationScaffold({
    required this.currentNavigator,
    required this.currentRouterState,
    required this.stackItems,
    this.scaffoldBuilder,
    this.transitionBuilder,
    this.transitionDuration = defaultTransitionDuration,
    super.key,
  });

  /// The default transition duration
  static const Duration defaultTransitionDuration = Duration(milliseconds: 400);

  /// The navigator for the currently active tab
  final Navigator currentNavigator;

  /// The current router state
  final GoRouterState currentRouterState;

  /// The tabs
  final List<StackedNavigationItem> stackItems;

  /// The scaffold builder
  final StackedNavigationScaffoldBuilder? scaffoldBuilder;

  /// An optional transition builder for stack transitions
  final StackedNavigationTransitionBuilder? transitionBuilder;

  /// The duration for stack transitions
  final Duration transitionDuration;

  @override
  State<StatefulWidget> createState() => _StackedNavigationScaffoldState();
}

class _StackedNavigationScaffoldState extends State<StackedNavigationScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController? _animationController;
  late final List<StackedNavigationItemState> _items;

  int _findCurrentIndex() {
    final int index = _items.indexWhere((StackedNavigationItemState i) =>
        i.item.navigatorKey == widget.currentNavigator.key);
    return index < 0 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    _items = widget.stackItems
        .map((StackedNavigationItem i) => StackedNavigationItemState(i))
        .toList();

    if (widget.transitionBuilder != null) {
      _animationController =
          AnimationController(vsync: this, duration: widget.transitionDuration);
      _animationController?.forward();
    } else {
      _animationController = null;
    }
  }

  @override
  void didUpdateWidget(covariant StackedNavigationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateForCurrentTab();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateForCurrentTab();
  }

  void _updateForCurrentTab() {
    final int previousIndex = _currentIndex;
    _currentIndex = _findCurrentIndex();

    final StackedNavigationItemState itemState = _items[_currentIndex];
    itemState.navigator = widget.currentNavigator;
    itemState.currentRouterState = widget.currentRouterState;

    if (previousIndex != _currentIndex) {
      _animationController?.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StackedNavigationScaffoldBuilder? scaffoldBuilder =
        widget.scaffoldBuilder;
    if (scaffoldBuilder != null) {
      return scaffoldBuilder(
          context, _currentIndex, _items, _buildIndexStack(context));
    } else {
      return _buildIndexStack(context);
    }
  }

  Widget _buildIndexStack(BuildContext context) {
    final List<Widget> children = _items
        .mapIndexed((int index, StackedNavigationItemState item) =>
            _buildNavigator(context, index, item))
        .toList();

    final Widget indexedStack =
        IndexedStack(index: _currentIndex, children: children);

    final StackedNavigationTransitionBuilder? transitionBuilder =
        widget.transitionBuilder;
    if (transitionBuilder != null) {
      return transitionBuilder(context, _animationController!, indexedStack);
    } else {
      return indexedStack;
    }
  }

  Widget _buildNavigator(BuildContext context, int index,
      StackedNavigationItemState navigationItem) {
    final Navigator? navigator = navigationItem.navigator;
    if (navigator == null) {
      return const SizedBox.shrink();
    }
    final bool isActive = index == _currentIndex;
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: navigator,
      ),
    );
  }
}
