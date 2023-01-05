// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';
import 'matching.dart';
import 'misc/errors.dart';
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
    required void Function(
            StatefulShellBranchState, UnmodifiableRouteMatchList?)
        switchActiveBranch,
    required void Function() resetState,
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

  final void Function(StatefulShellBranchState, UnmodifiableRouteMatchList?)
      _switchActiveBranch;

  final void Function() _resetState;

  /// Gets the [Widget]s representing each of the shell branches.
  ///
  /// The Widget returned from this method contains the [Navigator]s of the
  /// branches. Note that the Widgets returned by this method should only be
  /// added to the widget tree if using a custom branch container Widget
  /// implementation, where the child parameter in the [ShellRouteBuilder] of
  /// the [StatefulShellRoute] is ignored (i.e. not added to the widget tree).
  /// See [StatefulShellBranchState.child].
  List<Widget> get children =>
      branchStates.map((StatefulShellBranchState e) => e.child).toList();

  /// Navigate to the current location of the shell navigator with the provided
  /// Navigator key, name or index.
  ///
  /// This method will switch the currently active [Navigator] for the
  /// [StatefulShellRoute] by replacing the current navigation stack with the
  /// one of the route branch identified by the provided Navigator key, name or
  /// index. If resetLocation is true, the branch will be reset to its default
  /// location (see [StatefulShellBranch.defaultLocation]).
  void goBranch({
    GlobalKey<NavigatorState>? navigatorKey,
    String? name,
    int? index,
    bool resetLocation = false,
  }) {
    assert(navigatorKey != null || name != null || index != null);
    assert(<dynamic>[navigatorKey, name, index].whereNotNull().length == 1);

    final StatefulShellBranchState? state;
    if (navigatorKey != null) {
      state = branchStates.firstWhereOrNull((StatefulShellBranchState e) =>
          e.branch.navigatorKey == navigatorKey);
      if (state == null) {
        throw GoError('Unable to find branch with key $navigatorKey');
      }
    } else if (name != null) {
      state = branchStates.firstWhereOrNull(
          (StatefulShellBranchState e) => e.branch.name == name);
      if (state == null) {
        throw GoError('Unable to find branch with name "$name"');
      }
    } else {
      state = branchStates[index!];
    }

    _switchActiveBranch(state, resetLocation ? null : state._matchList);
  }

  /// Refreshes this StatefulShellRouteState by rebuilding the state for the
  /// current location.
  void refresh() {
    _switchActiveBranch(currentBranchState, currentBranchState._matchList);
  }

  /// Resets this StatefulShellRouteState by clearing all navigation state of
  /// the branches, and returning the current branch to its default location.
  void reset() {
    _resetState();
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
    required this.child,
    this.isLoaded = false,
    UnmodifiableRouteMatchList? matchList,
  }) : _matchList = matchList;

  /// Constructs a copy of this [StatefulShellBranchState], with updated values for
  /// some of the fields.
  StatefulShellBranchState copy(
      {Widget? child, bool? isLoaded, UnmodifiableRouteMatchList? matchList}) {
    return StatefulShellBranchState(
      branch: branch,
      child: child ?? this.child,
      isLoaded: isLoaded ?? this.isLoaded,
      matchList: matchList ?? _matchList,
    );
  }

  /// The associated [StatefulShellBranch]
  final StatefulShellBranch branch;

  /// The [Widget] representing this route branch in a [StatefulShellRoute].
  ///
  /// The Widget returned from this method contains the [Navigator] of the
  /// branch. Note that the Widget returned by this method should only
  /// be added to the widget tree if using a custom branch container Widget
  /// implementation, where the child parameter in the [ShellRouteBuilder] of
  /// the [StatefulShellRoute] is ignored (i.e. not added to the widget tree).
  final Widget child;

  /// The current navigation stack for the branch.
  final UnmodifiableRouteMatchList? _matchList;

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
    return other.branch == branch &&
        other.child == child &&
        other._matchList == _matchList;
  }

  @override
  int get hashCode => Object.hash(branch, child, _matchList);

  /// Gets the state for the current branch of the nearest stateful shell route
  /// in the Widget tree.
  static StatefulShellBranchState of(BuildContext context) =>
      StatefulShellRouteState.of(context).currentBranchState;
}

/// Helper extension on [StatefulShellBranchState], for internal use.
extension StatefulShellBranchStateHelper on StatefulShellBranchState {
  /// The current navigation stack for the branch.
  UnmodifiableRouteMatchList? get matchList => _matchList;
}
