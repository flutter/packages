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

/// Builder function for Navigator of the current branch.
typedef BranchNavigatorBuilder = Navigator Function();

/// Builder function for preloading a route branch navigator.
typedef BranchNavigatorPreloadBuilder = Navigator Function(
  BuildContext context,
  RouteMatchList navigatorMatchList,
  int startIndex,
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
    required this.currentBranch,
    required this.currentNavigatorBuilder,
    required this.currentMatchList,
    required this.branchNavigatorBuilder,
    super.key,
  });

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute shellRoute;

  /// The [GoRouterState] for the navigation shell.
  final GoRouterState shellGoRouterState;

  /// The currently active set of [StatefulShellBranch]s.
  final List<StatefulShellBranch> branches;

  /// The [StatefulShellBranch] for the current location
  final StatefulShellBranch currentBranch;

  /// The builder for the navigator of the currently active route branch
  final BranchNavigatorBuilder currentNavigatorBuilder;

  /// The RouteMatchList for the current location
  final UnmodifiableRouteMatchList currentMatchList;

  /// Builder for route branch navigators (used for preloading).
  final BranchNavigatorPreloadBuilder branchNavigatorBuilder;

  @override
  State<StatefulWidget> createState() => StatefulNavigationShellState();
}

/// State for StatefulNavigationShell.
class StatefulNavigationShellState extends State<StatefulNavigationShell> {
  final Map<Key, Navigator> _navigatorCache = <Key, Navigator>{};

  late StatefulShellRouteState _routeState;

  Navigator? _navigatorForBranch(StatefulShellBranch branch) {
    return _navigatorCache[branch.navigatorKey];
  }

  void _setNavigatorForBranch(StatefulShellBranch branch, Navigator navigator) {
    _navigatorCache[branch.navigatorKey] = navigator;
  }

  int _findCurrentIndex() {
    final int index = widget.branches.indexWhere((StatefulShellBranch e) =>
        e.navigatorKey == widget.currentBranch.navigatorKey);
    assert(index >= 0);
    return index;
  }

  void _switchActiveBranch(StatefulShellBranchState navigatorState,
      UnmodifiableRouteMatchList? unmodifiableRouteMatchList) {
    final GoRouter goRouter = GoRouter.of(context);
    final RouteMatchList? matchList =
        unmodifiableRouteMatchList?.routeMatchList;
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
      StatefulShellBranchState branchState) {
    // Parse a RouteMatchList from the default location of the route branch and
    // handle any redirects
    final GoRouteInformationParser parser =
        GoRouter.of(context).routeInformationParser;
    final Future<RouteMatchList> routeMatchList =
        parser.parseRouteInformationWithDependencies(
            RouteInformation(location: branchState.branch.defaultLocation),
            context);

    StatefulShellBranchState createBranchNavigator(RouteMatchList matchList) {
      // Find the index of the branch root route in the match list
      final StatefulShellBranch branch = branchState.branch;
      final int shellRouteIndex = matchList.matches
          .indexWhere((RouteMatch e) => e.route == widget.shellRoute);
      // Keep only the routes from and below the root route in the match list and
      // use that to build the Navigator for the branch
      BranchNavigatorBuilder? navigatorBuilder;
      if (shellRouteIndex >= 0 &&
          shellRouteIndex < (matchList.matches.length - 1)) {
        navigatorBuilder = () => widget.branchNavigatorBuilder(
              context,
              matchList,
              shellRouteIndex + 1,
              branch.navigatorKey,
              branch.restorationScopeId,
            );
      }
      return _copyStatefulShellBranchState(branchState,
          navigatorBuilder: navigatorBuilder,
          matchList: matchList.unmodifiableRouteMatchList());
    }

    return routeMatchList.then(createBranchNavigator);
  }

  void _updateRouteBranchState(StatefulShellBranchState branchState,
      {int? currentIndex}) {
    final List<StatefulShellBranch> branches = widget.branches;
    final List<StatefulShellBranchState> existingStates =
        _routeState.branchStates;
    final List<StatefulShellBranchState> newStates =
        <StatefulShellBranchState>[];

    // Build a new list of the current StatefulShellBranchStates, with an
    // updated state for the current branch etc.
    for (final StatefulShellBranch branch in branches) {
      if (branch.navigatorKey == branchState.navigatorKey) {
        newStates.add(branchState);
      } else {
        newStates.add(existingStates.firstWhereOrNull(
                (StatefulShellBranchState e) => e.branch == branch) ??
            _createStatefulShellBranchState(branch));
      }
    }

    // Remove any obsolete cached Navigators
    final Set<Key> validKeys =
        branches.map((StatefulShellBranch e) => e.navigatorKey).toSet();
    _navigatorCache.removeWhere((Key key, _) => !validKeys.contains(key));

    _routeState = _routeState.copy(
      branchStates: newStates,
      currentIndex: currentIndex,
    );
  }

  void _preloadBranches() {
    final List<StatefulShellBranchState> states = _routeState.branchStates;
    for (StatefulShellBranchState state in states) {
      if (state.branch.preload && !state.preloading) {
        state = _copyStatefulShellBranchState(state, loaded: true);
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
    final StatefulShellBranch branch = widget.currentBranch;

    // Update or create a new StatefulShellBranchState for the current branch
    // (i.e. the arguments currently provided to the Widget).
    StatefulShellBranchState? existingState = _routeState.branchStates
        .firstWhereOrNull((StatefulShellBranchState e) => e.branch == branch);
    if (existingState != null) {
      existingState = _copyStatefulShellBranchState(existingState,
          navigatorBuilder: widget.currentNavigatorBuilder,
          matchList: widget.currentMatchList);
    } else {
      existingState = _createStatefulShellBranchState(branch,
          navigatorBuilder: widget.currentNavigatorBuilder,
          matchList: widget.currentMatchList);
    }

    _updateRouteBranchState(
      existingState,
      currentIndex: index,
    );

    _preloadBranches();
  }

  void _resetState() {
    final StatefulShellBranchState navigatorState =
        _routeState.currentBranchState;
    _navigatorCache.clear();
    _setupInitialStatefulShellRouteState();
    GoRouter.of(context).go(navigatorState.branch.defaultLocation);
  }

  StatefulShellBranchState _copyStatefulShellBranchState(
      StatefulShellBranchState branchState,
      {BranchNavigatorBuilder? navigatorBuilder,
      UnmodifiableRouteMatchList? matchList,
      bool? loaded}) {
    if (navigatorBuilder != null) {
      final Navigator? existingNav = _navigatorForBranch(branchState.branch);
      if (existingNav == null || branchState.matchList != matchList) {
        _setNavigatorForBranch(branchState.branch, navigatorBuilder());
      }
    }
    final _BranchNavigatorProxy branchWidget =
        branchState.child as _BranchNavigatorProxy;
    final bool isLoaded =
        loaded ?? _navigatorForBranch(branchState.branch) != null;
    return branchState.copy(
      child: branchWidget.copy(loaded: isLoaded),
      matchList: matchList,
    );
  }

  StatefulShellBranchState _createStatefulShellBranchState(
      StatefulShellBranch branch,
      {BranchNavigatorBuilder? navigatorBuilder,
      UnmodifiableRouteMatchList? matchList}) {
    if (navigatorBuilder != null) {
      _setNavigatorForBranch(branch, navigatorBuilder());
    }
    return StatefulShellBranchState(
      branch: branch,
      child: _BranchNavigatorProxy(
        branch: branch,
        navigatorForBranch: _navigatorForBranch,
      ),
      matchList: matchList,
    );
  }

  void _setupInitialStatefulShellRouteState() {
    final List<StatefulShellBranchState> states = widget.branches
        .map((StatefulShellBranch e) => _createStatefulShellBranchState(e))
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

typedef _NavigatorForBranch = Navigator? Function(StatefulShellBranch);

/// Widget that serves as the proxy for a branch Navigator Widget, which
/// possibly hasn't been created yet.
class _BranchNavigatorProxy extends StatelessWidget {
  const _BranchNavigatorProxy(
      {required this.branch,
      required this.navigatorForBranch,
      this.loaded = false,
      super.key});

  _BranchNavigatorProxy copy({bool? loaded}) {
    return _BranchNavigatorProxy(
      branch: branch,
      loaded: loaded ?? this.loaded,
      navigatorForBranch: navigatorForBranch,
      key: key,
    );
  }

  final StatefulShellBranch branch;
  final _NavigatorForBranch navigatorForBranch;
  final bool loaded;

  @override
  Widget build(BuildContext context) {
    return navigatorForBranch(branch) ?? const SizedBox.shrink();
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
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: navigatorState.child,
      ),
    );
  }
}

extension _StatefulShellBranchStateHelper on StatefulShellBranchState {
  GlobalKey<NavigatorState> get navigatorKey => branch.navigatorKey;
  bool get preloading => (child as _BranchNavigatorProxy).loaded;
}
