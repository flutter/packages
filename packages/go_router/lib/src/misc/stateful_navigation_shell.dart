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
/// branch is represented by [StatefulShellBranchState] and can be accessed via the
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
    required this.branches,
    required this.currentBranchState,
    required this.branchNavigatorBuilder,
    super.key,
  });

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute shellRoute;

  /// The [GoRouterState] for the navigation shell.
  final GoRouterState shellGoRouterState;

  /// The currently active set of [StatefulShellBranchState]s.
  final List<StatefulShellBranch> branches;

  /// The [StatefulShellBranchState] for the current location.
  final StatefulShellBranchState currentBranchState;

  /// Builder for route branch navigators (used for preloading).
  final ShellRouteBranchNavigatorBuilder branchNavigatorBuilder;

  @override
  State<StatefulWidget> createState() => StatefulNavigationShellState();
}

/// State for StatefulNavigationShell.
class StatefulNavigationShellState extends State<StatefulNavigationShell> {
  late StatefulShellRouteState _routeState;

  int _findCurrentIndex() {
    final int index = widget.branches.indexWhere(
        (StatefulShellBranch e) => e == widget.currentBranchState.branch);
    assert(index >= 0);
    return index;
  }

  void _switchActiveBranch(
      StatefulShellBranchState navigatorState, RouteMatchList? matchList) {
    final GoRouter goRouter = GoRouter.of(context);
    if (matchList != null && matchList.isNotEmpty) {
      goRouter.routeInformationParser
          .processRedirection(matchList, context)
          .then(
            (RouteMatchList matchList) =>
                goRouter.routerDelegate.setNewRoutePath(matchList),
            onError: (_) => goRouter.go(navigatorState.branch.defaultLocation),
          );
    } else {
      goRouter.go(navigatorState.branch.defaultLocation);
    }
  }

  Future<StatefulShellBranchState> _preloadBranch(
      StatefulShellBranchState navigatorState) {
    // Parse a RouteMatchList from the default location of the route branch and
    // handle any redirects
    final GoRouteInformationParser parser =
        GoRouter.of(context).routeInformationParser;
    final Future<RouteMatchList> routeMatchList =
        parser.parseRouteInformationWithDependencies(
            RouteInformation(location: navigatorState.branch.defaultLocation),
            context);

    StatefulShellBranchState createBranchNavigator(RouteMatchList matchList) {
      // Find the index of the branch root route in the match list
      final StatefulShellBranch branch = navigatorState.branch;
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
      return navigatorState.copy(child: navigator, matchList: matchList);
    }

    return routeMatchList.then(createBranchNavigator);
  }

  void _updateRouteBranchState(StatefulShellBranchState navigatorState,
      {int? currentIndex}) {
    final List<StatefulShellBranch> branches = widget.branches;
    final List<StatefulShellBranchState> existingStates =
        _routeState.branchStates;
    final List<StatefulShellBranchState> newStates =
        <StatefulShellBranchState>[];

    for (final StatefulShellBranch branch in branches) {
      if (branch.navigatorKey == navigatorState.navigatorKey) {
        newStates.add(navigatorState);
      } else {
        newStates.add(existingStates.firstWhereOrNull(
                (StatefulShellBranchState e) => e.branch == branch) ??
            StatefulShellBranchState(branch: branch));
      }
    }

    _routeState = _routeState.copy(
      branchStates: newStates,
      currentIndex: currentIndex,
    );
  }

  void _preloadBranches() {
    final List<StatefulShellBranchState> states = _routeState.branchStates;
    for (StatefulShellBranchState state in states) {
      if (state.branch.preload && state.child == null) {
        // Set a placeholder widget as child to prevent repeated preloading
        state = state.copy(child: const SizedBox.shrink());
        _preloadBranch(state).then((StatefulShellBranchState navigatorState) {
          setState(() {
            _updateRouteBranchState(navigatorState);
          });
        });
      }
    }
  }

  void _updateRouteStateFromWidget() {
    final int index = _findCurrentIndex();
    _updateRouteBranchState(
      widget.currentBranchState,
      currentIndex: index,
    );

    _preloadBranches();
  }

  void _resetState() {
    final StatefulShellBranchState navigatorState =
        _routeState.currentBranchState;
    _setupInitialStatefulShellRouteState();
    GoRouter.of(context).go(navigatorState.branch.defaultLocation);
  }

  void _setupInitialStatefulShellRouteState() {
    final List<StatefulShellBranchState> states = widget.branches
        .map((StatefulShellBranch e) => StatefulShellBranchState(branch: e))
        .toList();

    _routeState = StatefulShellRouteState(
      route: widget.shellRoute,
      branchStates: states,
      currentIndex: 0,
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
    final StatefulShellBranchState currentState = routeState.currentBranchState;
    final List<StatefulShellBranchState> states = routeState.branchStates;
    final List<Widget> children = states
        .map((StatefulShellBranchState e) =>
            _buildRouteBranchContainer(context, e == currentState, e))
        .toList();

    final int currentIndex =
        states.indexWhere((StatefulShellBranchState e) => e == currentState);
    return IndexedStack(index: currentIndex, children: children);
  }

  Widget _buildRouteBranchContainer(BuildContext context, bool isActive,
      StatefulShellBranchState navigatorState) {
    final Widget? navigator = navigatorState.child;
    if (navigator == null) {
      return const SizedBox.shrink();
    }
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: navigator,
      ),
    );
  }
}

/// StatefulShellRoute extension that provides support for resolving the
/// current StatefulShellBranch.
extension StatefulShellBranchResolver on StatefulShellRoute {
  static final Expando<StatefulShellBranch> _shellBranchCache =
      Expando<StatefulShellBranch>();

  /// The current StatefulShellBranch, previously resolved using [resolveBranch].
  StatefulShellBranch? get currentBranch => _shellBranchCache[this];

  /// Resolves the current StatefulShellBranch, given the provided GoRouterState.
  StatefulShellBranch? resolveBranch(
      List<StatefulShellBranch> branches, GoRouterState state) {
    final StatefulShellBranch? branch = branches
        .firstWhereOrNull((StatefulShellBranch e) => e.isBranchFor(state));
    _shellBranchCache[this] = branch;
    return branch;
  }
}

extension _StatefulShellBranchStateHelper on StatefulShellBranchState {
  GlobalKey<NavigatorState> get navigatorKey => branch.navigatorKey;
}
