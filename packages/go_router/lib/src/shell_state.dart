// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'route.dart';
import 'state.dart';

/// The snapshot of the current state of a [StatefulShellRoute].
///
/// Note that this an immutable class, that represents the snapshot of the state
/// of a StatefulShellRoute at a given point in time. Therefore, instances of
/// this object should not be stored, but instead fetched fresh when needed,
/// using the method [StatefulShellRouteState.of].
@immutable
abstract class StatefulShellRouteState {
  /// The associated [StatefulShellRoute]
  StatefulShellRoute get route;

  /// The state for all separate route branches associated with a
  /// [StatefulShellRoute].
  List<StatefulShellBranchState> get branchStates;

  /// The state associated with the current [StatefulShellBranch].
  StatefulShellBranchState get currentBranchState;

  /// The index of the currently active [StatefulShellBranch].
  ///
  /// Corresponds to the index of the branch in the List returned from
  /// branchBuilder of [StatefulShellRoute].
  int get currentIndex;

  /// The Navigator key of the current navigator.
  GlobalKey<NavigatorState> get currentNavigatorKey;

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
  });

  /// Gets the state for the nearest stateful shell route in the Widget tree.
  static StatefulShellRouteState of(BuildContext context) {
    return StatefulShellRouteStateContext.of(context);
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
abstract class StatefulShellBranchState {
  /// The associated [StatefulShellBranch]
  StatefulShellBranch get branch;

  /// The current GoRouterState associated with the branch.
  GoRouterState? get routeState;

  /// Returns true if this branch has been loaded (i.e. visited once or
  /// pre-loaded).
  bool get isLoaded;
}
