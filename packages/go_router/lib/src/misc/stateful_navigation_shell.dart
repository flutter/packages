// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../configuration.dart';
import '../typedefs.dart';

/// Transition builder callback used by [StatefulNavigationShell].
///
/// The builder is expected to return a transition powered by the provided
/// `animation` and wrapping the provided `child`.
///
/// The `animation` provided to the builder always runs forward from 0.0 to 1.0.
typedef StatefulNavigationTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// [InheritedWidget] for providing a reference to the closest
/// [StatefulNavigationShellState].
class InheritedStatefulNavigationShell extends InheritedWidget {
  /// Constructs an [InheritedStatefulNavigationShell].
  const InheritedStatefulNavigationShell({
    required super.child,
    required this.state,
    super.key,
  });

  /// The [StatefulNavigationShellState] that is exposed by this InheritedWidget.
  final StatefulNavigationShellState state;

  @override
  bool updateShouldNotify(
      covariant InheritedStatefulNavigationShell oldWidget) {
    return state != oldWidget.state;
  }
}

/// Widget that maintains a stateful stack of [Navigator]s, using an
/// [IndexedStack].
///
/// Each item in the stack is represented by a [StackedNavigationItem],
/// specified in the `stackItems` parameter. The stack items will be used to
/// build the widgets containing the [Navigator] for each index in the stack.
/// Once a stack item (along with its Navigator) has been initialized, it will
/// remain in a widget tree, wrapped in an [Offstage] widget.
///
/// The stacked navigation shell can be customized by specifying a
/// `scaffoldBuilder`, to build a widget that wraps the index stack.
class StatefulNavigationShell extends StatefulWidget {
  /// Constructs an [StatefulNavigationShell].
  const StatefulNavigationShell({
    required this.configuration,
    required this.shellRoute,
    required this.activeNavigator,
    required this.shellRouterState,
    required this.topRouterState,
    super.key,
  });

  /// The default transition duration
  static const Duration defaultTransitionDuration = Duration(milliseconds: 400);

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute shellRoute;

  /// The navigator for the currently active tab
  final Navigator activeNavigator;

  /// The [GoRouterState] for navigation shell.
  final GoRouterState shellRouterState;

  /// The [GoRouterState] for the top of the current navigation stack.
  final GoRouterState topRouterState;

  @override
  State<StatefulWidget> createState() => StatefulNavigationShellState();
}

/// State for StatefulNavigationShell.
class StatefulNavigationShellState extends State<StatefulNavigationShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController? _animationController;

  late final List<ShellRouteBranchState> _childRouteState;

  StatefulNavigationTransitionBuilder? get _transitionBuilder =>
      widget.shellRoute.transitionBuilder;

  Duration? get _transitionDuration => widget.shellRoute.transitionDuration;

  int _findCurrentIndex() {
    final int index = _childRouteState.indexWhere((ShellRouteBranchState i) =>
        i.navigationItem.navigatorKey == widget.activeNavigator.key);
    return index < 0 ? 0 : index;
  }

  /// The current [StatefulShellRouteState]
  StatefulShellRouteState get routeState => StatefulShellRouteState(
      route: widget.shellRoute,
      navigationBranchState: _childRouteState,
      currentBranchIndex: _currentIndex);

  @override
  void initState() {
    super.initState();
    _childRouteState = widget.shellRoute.branches
        .map((ShellRouteBranch e) => ShellRouteBranchState(
              navigationItem: e,
              rootRoutePath: widget.configuration.fullPathForRoute(e.rootRoute),
            ))
        .toList();

    if (_transitionBuilder != null) {
      _animationController = AnimationController(
          vsync: this,
          duration: _transitionDuration ??
              StatefulNavigationShell.defaultTransitionDuration);
      _animationController?.forward();
    } else {
      _animationController = null;
    }
  }

  @override
  void didUpdateWidget(covariant StatefulNavigationShell oldWidget) {
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

    final ShellRouteBranchState itemState = _childRouteState[_currentIndex];
    itemState.navigator = widget.activeNavigator;
    itemState.topRouteState = widget.topRouterState;

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
    return InheritedStatefulNavigationShell(
      state: this,
      child: Builder(builder: (BuildContext context) {
        final ShellRouteBuilder builder = widget.shellRoute.builder;
        return builder(
          context,
          widget.shellRouterState,
          _buildIndexStack(context),
        );
      }),
    );
  }

  Widget _buildIndexStack(BuildContext context) {
    final List<Widget> children = _childRouteState
        .mapIndexed((int index, ShellRouteBranchState item) =>
            _buildNavigator(context, index, item))
        .toList();

    final Widget indexedStack =
        IndexedStack(index: _currentIndex, children: children);

    final StatefulNavigationTransitionBuilder? transitionBuilder =
        _transitionBuilder;
    if (transitionBuilder != null) {
      return transitionBuilder(context, _animationController!, indexedStack);
    } else {
      return indexedStack;
    }
  }

  Widget _buildNavigator(
      BuildContext context, int index, ShellRouteBranchState navigationItem) {
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
