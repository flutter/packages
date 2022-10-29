// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../configuration.dart';
import '../matching.dart';
import '../router.dart';
import '../typedefs.dart';

/// [InheritedWidget] for providing a reference to the closest
/// [StatefulNavigationShellState].
class InheritedStatefulNavigationShell extends InheritedWidget {
  /// Constructs an [InheritedStatefulNavigationShell].
  const InheritedStatefulNavigationShell({
    required super.child,
    required this.routeState,
    super.key,
  });

  /// The [StatefulShellRouteState] that is exposed by this InheritedWidget.
  final StatefulShellRouteState routeState;

  @override
  bool updateShouldNotify(
      covariant InheritedStatefulNavigationShell oldWidget) {
    return routeState != oldWidget.routeState;
  }
}

/// Builder function for a route branch navigator
typedef ShellRouteBranchNavigatorBuilder = Navigator? Function(
    BuildContext context, StatefulShellRouteState routeState, int branchIndex);

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
    required this.shellGoRouterState,
    required this.navigator,
    required this.matchList,
    required this.branchNavigatorBuilder,
    super.key,
  });

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute shellRoute;

  /// The [GoRouterState] for the navigation shell.
  final GoRouterState shellGoRouterState;

  /// The navigator for the currently active route branch
  final Navigator navigator;

  /// The RouteMatchList for the current location
  final RouteMatchList matchList;

  /// Builder for route branch navigators (used for preloading).
  final ShellRouteBranchNavigatorBuilder branchNavigatorBuilder;

  @override
  State<StatefulWidget> createState() => StatefulNavigationShellState();
}

/// State for StatefulNavigationShell.
class StatefulNavigationShellState extends State<StatefulNavigationShell> {
  late StatefulShellRouteState _routeState;

  int _findCurrentIndex() {
    final List<ShellRouteBranchState> branchState = _routeState.branchState;
    final int index = branchState.indexWhere((ShellRouteBranchState e) =>
        e.routeBranch.navigatorKey == widget.navigator.key);
    return index < 0 ? 0 : index;
  }

  void _switchActiveBranch(
      ShellRouteBranchState branchState, RouteMatchList? matchList) {
    if (matchList != null) {
      GoRouter.of(context).routerDelegate.replaceMatchList(matchList);
    } else {
      GoRouter.of(context).go(branchState.defaultLocation);
    }
  }

  String _fullPathForRoute(RouteBase route) =>
      widget.configuration.fullPathForRoute(route);

  @override
  void initState() {
    super.initState();
    final List<ShellRouteBranchState> branchState = widget.shellRoute.branches
        .map((ShellRouteBranch e) => ShellRouteBranchState(
              routeBranch: e,
              rootRoutePath: _fullPathForRoute(e.rootRoute),
            ))
        .toList();
    _routeState = StatefulShellRouteState(
      switchActiveBranch: _switchActiveBranch,
      route: widget.shellRoute,
      branchState: branchState,
      index: 0,
    );
  }

  @override
  void didUpdateWidget(covariant StatefulNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRouteState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRouteState();
  }

  void _updateRouteState() {
    final int currentIndex = _findCurrentIndex();

    final List<ShellRouteBranchState> branchState =
        _routeState.branchState.toList();
    branchState[currentIndex] = branchState[currentIndex].copy(
      navigator: widget.navigator,
      matchList: widget.matchList,
    );

    if (widget.shellRoute.preloadBranches) {
      for (int i = 0; i < branchState.length; i++) {
        if (i != currentIndex && branchState[i].navigator == null) {
          final Navigator? navigator =
              widget.branchNavigatorBuilder(context, _routeState, i);
          branchState[i] = branchState[i].copy(
            navigator: navigator,
          );
        }
      }
    }

    _routeState = StatefulShellRouteState(
      switchActiveBranch: _switchActiveBranch,
      route: widget.shellRoute,
      branchState: branchState,
      index: currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStatefulNavigationShell(
      routeState: _routeState,
      child: Builder(builder: (BuildContext context) {
        // This Builder Widget is mainly used to make it possible to access the
        // StatefulShellRouteState via the BuildContext in the ShellRouteBuilder
        final ShellRouteBuilder shellRouteBuilder = widget.shellRoute.builder!;
        return shellRouteBuilder(
          context,
          widget.shellGoRouterState,
          _IndexedStackedRouteBranchContainer(routeState: _routeState),
        );
      }),
    );
  }
}

/// Default implementation of a container widget for the [Navigator]s of the
/// route branches. This implementation uses an [IndexedStack] as a container.
class _IndexedStackedRouteBranchContainer extends StatelessWidget {
  const _IndexedStackedRouteBranchContainer({required this.routeState});

  final StatefulShellRouteState routeState;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = routeState.branchState
        .mapIndexed((int index, ShellRouteBranchState item) =>
            _buildRouteBranchContainer(context, index, item))
        .toList();

    return IndexedStack(index: routeState.index, children: children);
  }

  Widget _buildRouteBranchContainer(
      BuildContext context, int index, ShellRouteBranchState routeBranch) {
    final Navigator? navigator = routeBranch.navigator;
    if (navigator == null) {
      return const SizedBox.shrink();
    }
    final bool isActive = index == routeState.index;
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: navigator,
      ),
    );
  }
}
