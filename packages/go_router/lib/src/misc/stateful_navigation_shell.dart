// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../configuration.dart';
import '../typedefs.dart';

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

  /// The [StatefulShellRouteState] that is exposed by this InheritedWidget.
  StatefulShellRouteState get routeState => state.routeState;

  @override
  bool updateShouldNotify(
      covariant InheritedStatefulNavigationShell oldWidget) {
    return state != oldWidget.state;
  }
}

/// Widget that manages and maintains the state of a [StatefulShellRoute],
/// including the [Navigator]s of the configured route branches.
///
/// This widget acts as a wrapper around the builder function specified for the
/// associated StatefulShellRoute, and exposes the state (represented by
/// [StatefulShellRouteState]) to its child widgets with the help of the
/// InheritedWidget [InheritedStatefulNavigationShell]. The state for each route
/// branch is represented by [ShellRouteBranchState] and can be accessed via the
/// StatefulShellRouteState.
///
/// By default, this widget creates a container for the branch route Navigators,
/// provided as the child argument to the builder of the StatefulShellRoute.
/// However, implementors can choose to disregard this and use an alternate
/// container around the branch navigators
/// (see [StatefulShellRouteState.navigators]) instead.
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
class StatefulNavigationShellState extends State<StatefulNavigationShell> {
  int _currentIndex = 0;

  late final List<ShellRouteBranchState> _childRouteState;

  int _findCurrentIndex() {
    final int index = _childRouteState.indexWhere((ShellRouteBranchState i) =>
        i.navigationItem.navigatorKey == widget.activeNavigator.key);
    return index < 0 ? 0 : index;
  }

  /// The current [StatefulShellRouteState]
  StatefulShellRouteState get routeState => StatefulShellRouteState(
        route: widget.shellRoute,
        navigationBranchState: _childRouteState,
        index: _currentIndex,
      );

  @override
  void initState() {
    super.initState();
    _childRouteState = widget.shellRoute.branches
        .map((ShellRouteBranch e) => ShellRouteBranchState(
              navigationItem: e,
              rootRoutePath: widget.configuration.fullPathForRoute(e.rootRoute),
            ))
        .toList();
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
    _currentIndex = _findCurrentIndex();

    final ShellRouteBranchState currentBranchState =
        _childRouteState[_currentIndex];
    _childRouteState[_currentIndex] = ShellRouteBranchState(
      navigationItem: currentBranchState.navigationItem,
      rootRoutePath: currentBranchState.rootRoutePath,
      navigator: widget.activeNavigator,
      topRouteState: widget.topRouterState,
    );
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
          _IndexedStackedRouteBranchContainer(
              branchState: _childRouteState, currentIndex: _currentIndex),
        );
      }),
    );
  }
}

/// Default implementation of a container widget for the [Navigator]s of the
/// route branches. This implementation uses an [IndexedStack] as a container.
class _IndexedStackedRouteBranchContainer extends StatelessWidget {
  const _IndexedStackedRouteBranchContainer(
      {required this.currentIndex, required this.branchState});

  final int currentIndex;
  final List<ShellRouteBranchState> branchState;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = branchState
        .mapIndexed((int index, ShellRouteBranchState item) =>
            _buildRouteBranchContainer(context, index, item))
        .toList();

    return IndexedStack(index: currentIndex, children: children);
  }

  Widget _buildRouteBranchContainer(
      BuildContext context, int index, ShellRouteBranchState navigationItem) {
    final Navigator? navigator = navigationItem.navigator;
    if (navigator == null) {
      return const SizedBox.shrink();
    }
    final bool isActive = index == currentIndex;
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: navigator,
      ),
    );
  }
}
