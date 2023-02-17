// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';
import 'misc/stateful_navigation_shell.dart';

/// The snapshot of the current state of a [StatefulShellRoute].
///
/// Note that this an immutable class, that represents the snapshot of the state
/// of a StatefulShellRoute at a given point in time. Therefore, instances of
/// this object should not be stored, but instead fetched fresh when needed,
/// using the method [StatefulShellRouteState.of].
@immutable
class StatefulShellRouteState {
  /// Constructs a [StatefulShellRouteState].
  const StatefulShellRouteState({
    required this.route,
    required this.branchStates,
    required this.currentIndex,
    required void Function(StatefulShellBranchState, bool) switchActiveBranch,
    required void Function(StatefulShellBranchState? branchState,
            bool navigateToDefaultLocation)
        resetState,
  })  : _switchActiveBranch = switchActiveBranch,
        _resetState = resetState;

  /// Constructs a copy of this [StatefulShellRouteState], with updated values
  /// for some of the fields.
  StatefulShellRouteState copy(
      {List<StatefulShellBranchState>? branchStates, int? currentIndex}) {
    return StatefulShellRouteState(
      route: route,
      branchStates: branchStates ?? this.branchStates,
      currentIndex: currentIndex ?? this.currentIndex,
      switchActiveBranch: _switchActiveBranch,
      resetState: _resetState,
    );
  }

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute route;

  /// The state for all separate route branches associated with a
  /// [StatefulShellRoute].
  final List<StatefulShellBranchState> branchStates;

  /// The state associated with the current [StatefulShellBranch].
  StatefulShellBranchState get currentBranchState => branchStates[currentIndex];

  /// The index of the currently active [StatefulShellBranch].
  ///
  /// Corresponds to the index of the branch in the List returned from
  /// branchBuilder of [StatefulShellRoute].
  final int currentIndex;

  /// The Navigator key of the current navigator.
  GlobalKey<NavigatorState> get currentNavigatorKey =>
      currentBranchState.branch.navigatorKey;

  final void Function(StatefulShellBranchState, bool) _switchActiveBranch;

  final void Function(
          StatefulShellBranchState? branchState, bool navigateToDefaultLocation)
      _resetState;

  /// Navigate to the current location of the shell navigator with the provided
  /// index.
  ///
  /// This method will switch the currently active [Navigator] for the
  /// [StatefulShellRoute] by replacing the current navigation stack with the
  /// one of the route branch identified by the provided index. If resetLocation
  /// is true, the branch will be reset to its initial location
  /// (see [StatefulShellBranch.initialLocation]).
  void goBranch({
    required int index,
    bool resetLocation = false,
  }) {
    _switchActiveBranch(branchStates[index], resetLocation);
  }

  /// Refreshes this StatefulShellRouteState by rebuilding the state for the
  /// current location.
  void refresh() {
    _switchActiveBranch(currentBranchState, true);
  }

  /// Resets this StatefulShellRouteState by clearing all navigation state of
  /// the branches
  ///
  /// After the state has been reset, the current branch will navigated to its
  /// initial location, if [navigateToDefaultLocation] is true.
  void reset({bool navigateToDefaultLocation = true}) {
    _resetState(null, navigateToDefaultLocation);
  }

  /// Resets the navigation state of the branch identified by the provided index.
  ///
  /// After the state has been reset, the branch will navigated to its
  /// initial location, if [navigateToDefaultLocation] is true.
  void resetBranch({
    required int index,
    bool navigateToDefaultLocation = true,
  }) {
    _resetState(branchStates[index], navigateToDefaultLocation);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! StatefulShellRouteState) {
      return false;
    }
    return other.route == route &&
        listEquals(other.branchStates, branchStates) &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode => Object.hash(route, currentIndex, currentIndex);

  /// Gets the state for the nearest stateful shell route in the Widget tree.
  static StatefulShellRouteState of(BuildContext context) {
    final InheritedStatefulNavigationShell? inherited = context
        .dependOnInheritedWidgetOfExactType<InheritedStatefulNavigationShell>();
    assert(inherited != null,
        'No InheritedStatefulNavigationShell found in context');
    return inherited!.routeState;
  }
}

/// The snapshot of the current state for a particular route branch
/// ([StatefulShellBranch]) in a [StatefulShellRoute].
///
/// Note that this an immutable class, that represents the snapshot of the state
/// of a StatefulShellBranchState at a given point in time. Therefore, instances of
/// this object should not be stored, but instead fetched fresh when needed,
/// via the [StatefulShellRouteState] returned by the method
/// [StatefulShellRouteState.of].
@immutable
class StatefulShellBranchState {
  /// Constructs a [StatefulShellBranchState].
  const StatefulShellBranchState({
    required this.branch,
    this.isLoaded = false,
    this.routeState,
  });

  /// Constructs a copy of this [StatefulShellBranchState], with updated values for
  /// some of the fields.
  StatefulShellBranchState copy({bool? isLoaded, GoRouterState? routeState}) {
    return StatefulShellBranchState(
      branch: branch,
      isLoaded: isLoaded ?? this.isLoaded,
      routeState: routeState ?? this.routeState,
    );
  }

  /// The associated [StatefulShellBranch]
  final StatefulShellBranch branch;

  /// The current GoRouterState associated with the branch.
  final GoRouterState? routeState;

  /// Returns true if this branch has been loaded (i.e. visited once or
  /// pre-loaded).
  final bool isLoaded;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! StatefulShellBranchState) {
      return false;
    }
    return other.branch == branch && other.routeState == routeState;
  }

  @override
  int get hashCode => Object.hash(branch, routeState);

  /// Gets the state for the current branch of the nearest stateful shell route
  /// in the Widget tree.
  static StatefulShellBranchState of(BuildContext context) =>
      StatefulShellRouteState.of(context).currentBranchState;
}
