// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../go_router.dart';

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
    required this.shellRoute,
    required this.navigatorBuilder,
    required this.shellGoRouterState,
    required this.shellBodyWidgetBuilder,
    super.key,
  });

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute shellRoute;

  /// The shell navigator builder.
  final ShellNavigatorBuilder navigatorBuilder;

  /// The [GoRouterState] for the navigation shell.
  final GoRouterState shellGoRouterState;

  /// The shell body widget builder.
  final ShellBodyWidgetBuilder shellBodyWidgetBuilder;

  @override
  State<StatefulWidget> createState() => StatefulNavigationShellState();
}

/// State for StatefulNavigationShell.
class StatefulNavigationShellState extends State<StatefulNavigationShell> {
  final Map<Key, Widget> _navigatorCache = <Key, Widget>{};

  late StatefulShellRouteState _routeState;

  List<StatefulShellBranch> get _branches => widget.shellRoute.branches;

  GlobalKey<NavigatorState> get _currentNavigatorKey =>
      widget.navigatorBuilder.navigatorKeyForCurrentRoute;

  Widget? _navigatorForBranch(StatefulShellBranch branch) {
    return _navigatorCache[branch.navigatorKey];
  }

  void _setNavigatorForBranch(StatefulShellBranch branch, Widget? navigator) {
    navigator != null
        ? _navigatorCache[branch.navigatorKey] = navigator
        : _navigatorCache.remove(branch.navigatorKey);
  }

  int _findCurrentIndex() {
    final int index = _branches.indexWhere(
        (StatefulShellBranch e) => e.navigatorKey == _currentNavigatorKey);
    assert(index >= 0);
    return index;
  }

  void _switchActiveBranch(
      StatefulShellBranchState branchState, bool resetLocation) {
    final GoRouter goRouter = GoRouter.of(context);
    final GoRouterState? routeState = branchState.routeState;
    if (routeState != null && !resetLocation) {
      goRouter.goState(routeState, context).onError(
          (_, __) => goRouter.go(_defaultBranchLocation(branchState.branch)));
    } else {
      goRouter.go(_defaultBranchLocation(branchState.branch));
    }
  }

  String _defaultBranchLocation(StatefulShellBranch branch) {
    return branch.defaultLocation ??
        GoRouter.of(context)
            .routeConfiguration
            .findStatefulShellBranchDefaultLocation(branch);
  }

  void _preloadBranches() {
    final List<StatefulShellBranchState> states = _routeState.branchStates;
    for (StatefulShellBranchState state in states) {
      if (state.branch.preload && !state.isLoaded) {
        state = _updateStatefulShellBranchState(state, loaded: true);
        _preloadBranch(state).then((StatefulShellBranchState navigatorState) {
          setState(() {
            _updateRouteBranchState(navigatorState);
          });
        });
      }
    }
  }

  Future<StatefulShellBranchState> _preloadBranch(
      StatefulShellBranchState branchState) {
    final Future<Widget> navigatorBuilder =
        widget.navigatorBuilder.buildPreloadedShellNavigator(
      context: context,
      location: _defaultBranchLocation(branchState.branch),
      parentShellRoute: widget.shellRoute,
      navigatorKey: branchState.navigatorKey,
      // TODO, observers,
      restorationScopeId: branchState.branch.restorationScopeId,
    );

    return navigatorBuilder.then((Widget navigator) {
      return _updateStatefulShellBranchState(
        branchState,
        navigator: navigator,
      );
    });
  }

  void _updateRouteBranchState(StatefulShellBranchState branchState,
      {int? currentIndex}) {
    final List<StatefulShellBranchState> existingStates =
        _routeState.branchStates;
    final List<StatefulShellBranchState> newStates =
        <StatefulShellBranchState>[];

    // Build a new list of the current StatefulShellBranchStates, with an
    // updated state for the current branch etc.
    for (final StatefulShellBranch branch in _branches) {
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
        _branches.map((StatefulShellBranch e) => e.navigatorKey).toSet();
    _navigatorCache.removeWhere((Key key, _) => !validKeys.contains(key));

    _routeState = _routeState.copy(
      branchStates: newStates,
      currentIndex: currentIndex,
    );
  }

  void _updateRouteStateFromWidget() {
    final int index = _findCurrentIndex();
    final StatefulShellBranch branch = _branches[index];

    // TODO: Observers
    final Widget currentNavigator = widget.navigatorBuilder
        .buildNavigatorForCurrentRoute(
            restorationScopeId: branch.restorationScopeId);

    // Update or create a new StatefulShellBranchState for the current branch
    // (i.e. the arguments currently provided to the Widget).
    StatefulShellBranchState? currentBranchState = _routeState.branchStates
        .firstWhereOrNull((StatefulShellBranchState e) => e.branch == branch);
    if (currentBranchState != null) {
      currentBranchState = _updateStatefulShellBranchState(
        currentBranchState,
        navigator: currentNavigator,
        routeState: widget.shellGoRouterState,
      );
    } else {
      currentBranchState = _createStatefulShellBranchState(
        branch,
        navigator: currentNavigator,
        routeState: widget.shellGoRouterState,
      );
    }

    _updateRouteBranchState(
      currentBranchState,
      currentIndex: index,
    );

    _preloadBranches();
  }

  void _resetState(
      StatefulShellBranchState? branchState, bool navigateToDefaultLocation) {
    final StatefulShellBranch branch;
    if (branchState != null) {
      branch = branchState.branch;
      _setNavigatorForBranch(branch, null);
      _updateRouteBranchState(
        _createStatefulShellBranchState(branch),
      );
    } else {
      branch = _routeState.currentBranchState.branch;
      // Reset the state for all branches (the whole stateful shell)
      _navigatorCache.clear();
      _setupInitialStatefulShellRouteState();
    }
    if (navigateToDefaultLocation) {
      GoRouter.of(context).go(_defaultBranchLocation(branch));
    }
  }

  StatefulShellBranchState _updateStatefulShellBranchState(
    StatefulShellBranchState branchState, {
    Widget? navigator,
    GoRouterState? routeState,
    bool? loaded,
  }) {
    bool dirty = false;
    if (routeState != null) {
      dirty = branchState.routeState != routeState;
    }

    if (navigator != null) {
      // Only update Navigator for branch if matchList is different (i.e.
      // dirty == true) or if Navigator didn't already exist
      final bool hasExistingNav =
          _navigatorForBranch(branchState.branch) != null;
      if (!hasExistingNav || dirty) {
        dirty = true;
        _setNavigatorForBranch(branchState.branch, navigator);
      }
    }

    final bool isLoaded =
        loaded ?? _navigatorForBranch(branchState.branch) != null;
    dirty = dirty || isLoaded != branchState.isLoaded;

    if (dirty) {
      return branchState.copy(
        child: _BranchNavigatorProxy(
            branch: branchState.branch,
            navigatorForBranch: _navigatorForBranch),
        isLoaded: isLoaded,
        routeState: routeState,
      );
    } else {
      return branchState;
    }
  }

  StatefulShellBranchState _createStatefulShellBranchState(
    StatefulShellBranch branch, {
    Widget? navigator,
    GoRouterState? routeState,
  }) {
    if (navigator != null) {
      _setNavigatorForBranch(branch, navigator);
    }
    return StatefulShellBranchState(
      branch: branch,
      child: _BranchNavigatorProxy(
          branch: branch, navigatorForBranch: _navigatorForBranch),
      routeState: routeState,
    );
  }

  void _setupInitialStatefulShellRouteState() {
    final List<StatefulShellBranchState> states = _branches
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
        final ShellBodyWidgetBuilder shellWidgetBuilder =
            widget.shellBodyWidgetBuilder;
        return shellWidgetBuilder(
          context,
          widget.shellGoRouterState,
          _IndexedStackedRouteBranchContainer(routeState: _routeState),
        );
      }),
    );
  }
}

typedef _NavigatorForBranch = Widget? Function(StatefulShellBranch);

/// Widget that serves as the proxy for a branch Navigator Widget, which
/// possibly hasn't been created yet.
class _BranchNavigatorProxy extends StatelessWidget {
  const _BranchNavigatorProxy({
    required this.branch,
    required this.navigatorForBranch,
  });

  final StatefulShellBranch branch;
  final _NavigatorForBranch navigatorForBranch;

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
    final int currentIndex = routeState.currentIndex;
    final List<Widget> children = routeState.branchStates
        .mapIndexed((int index, StatefulShellBranchState item) =>
            _buildRouteBranchContainer(context, currentIndex == index, item))
        .toList();

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
}
