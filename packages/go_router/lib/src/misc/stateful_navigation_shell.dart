// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../configuration.dart';
import '../match.dart';
import '../matching.dart';
import '../parser.dart';
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
typedef ShellRouteBranchNavigatorBuilder = Navigator Function(
  BuildContext context,
  RouteMatchList navigatorMatchList,
  GlobalKey<NavigatorState> navigatorKey,
  String? restorationScopeId,
);

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
/// (see [StatefulShellRouteState.children]) instead.
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

  bool _branchesPreloaded = false;

  int _findCurrentIndex() {
    final List<ShellRouteBranchState> branchState = _routeState.branchState;
    final int index = branchState.indexWhere((ShellRouteBranchState e) =>
        e.routeBranch.navigatorKey == widget.navigator.key);
    return index < 0 ? 0 : index;
  }

  void _switchActiveBranch(
      ShellRouteBranchState branchState, RouteMatchList? matchList) {
    final GoRouter goRouter = GoRouter.of(context);
    if (matchList != null && matchList.isNotEmpty) {
      goRouter.routeInformationParser
          .processRedirection(matchList, context)
          .then(
            (RouteMatchList matchList) =>
                goRouter.routerDelegate.setNewRoutePath(matchList),
            onError: (_) => goRouter.go(_defaultBranchLocation(branchState)),
          );
    } else {
      goRouter.go(_defaultBranchLocation(branchState));
    }
  }

  String _defaultBranchLocation(ShellRouteBranchState branchState) {
    String? defaultLocation = branchState.routeBranch.defaultLocation;
    defaultLocation ??= widget.configuration
        .findShellRouteBranchDefaultLocation(branchState.routeBranch);
    return defaultLocation;
  }

  Future<ShellRouteBranchState> _preloadBranch(
      ShellRouteBranchState branchState) {
    // Parse a RouteMatchList from the default location of the route branch and
    // handle any redirects
    final GoRouteInformationParser parser =
        GoRouter.of(context).routeInformationParser;
    final Future<RouteMatchList> routeMatchList =
        parser.parseRouteInformationWithDependencies(
            RouteInformation(location: _defaultBranchLocation(branchState)),
            context);

    ShellRouteBranchState createBranchNavigator(RouteMatchList matchList) {
      // Find the index of the branch root route in the match list
      final ShellRouteBranch branch = branchState.routeBranch;
      final int shellRouteIndex = matchList.matches
          .indexWhere((RouteMatch e) => e.route == widget.shellRoute);
      // Keep only the routes from and below the root route in the match list and
      // use that to build the Navigator for the branch
      Navigator? navigator;
      if (shellRouteIndex >= 0 &&
          shellRouteIndex < (matchList.matches.length - 1)) {
        final RouteMatchList navigatorMatchList =
            RouteMatchList(matchList.matches.sublist(shellRouteIndex + 1));
        navigator = widget.branchNavigatorBuilder(context, navigatorMatchList,
            branch.navigatorKey, branch.restorationScopeId);
      }
      return branchState.copy(child: navigator, matchList: matchList);
    }

    return routeMatchList.then(createBranchNavigator);
  }

  void _updateRouteBranchState(int index, ShellRouteBranchState branchState,
      {int? currentIndex}) {
    final List<ShellRouteBranchState> branchStates =
        _routeState.branchState.toList();
    branchStates[index] = branchState;

    _routeState = _routeState.copy(
      branchState: branchStates,
      index: currentIndex,
    );
  }

  void _preloadBranches() {
    final List<ShellRouteBranchState> states = _routeState.branchState;
    for (int i = 0; i < states.length; i++) {
      if (states[i].child == null) {
        _preloadBranch(states[i]).then((ShellRouteBranchState branchState) {
          setState(() {
            _updateRouteBranchState(i, branchState);
          });
        });
      }
    }
  }

  void _updateRouteStateFromWidget() {
    final int index = _findCurrentIndex();

    _updateRouteBranchState(
      index,
      _routeState.branchState[index].copy(
        child: widget.navigator,
        matchList: widget.matchList,
      ),
      currentIndex: index,
    );

    if (widget.shellRoute.preloadBranches && !_branchesPreloaded) {
      _preloadBranches();
      _branchesPreloaded = true;
    }
  }

  void _resetState() {
    final ShellRouteBranchState currentBranchState =
        _routeState.branchState[_routeState.index];
    _setupInitialStatefulShellRouteState(index: _routeState.index);
    GoRouter.of(context).go(_defaultBranchLocation(currentBranchState));
  }

  void _setupInitialStatefulShellRouteState({int index = 0}) {
    final List<ShellRouteBranchState> branchState = widget.shellRoute.branches
        .map((ShellRouteBranch e) => ShellRouteBranchState(routeBranch: e))
        .toList();
    _routeState = StatefulShellRouteState(
      route: widget.shellRoute,
      branchState: branchState,
      index: index,
      switchActiveBranch: _switchActiveBranch,
      resetState: _resetState,
    );
  }

  @override
  void initState() {
    super.initState();
    _setupInitialStatefulShellRouteState();
  }

  @override
  void didUpdateWidget(covariant StatefulNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRouteStateFromWidget();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRouteStateFromWidget();
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
    final Widget? navigator = routeBranch.child;
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
