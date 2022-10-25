// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'router.dart';

/// The route state during routing.
///
/// The state contains parsed artifacts of the current URI.
class GoRouterState {
  /// Default constructor for creating route state during routing.
  GoRouterState(
    this._configuration, {
    required this.location,
    required this.subloc,
    required this.name,
    this.path,
    this.fullpath,
    this.params = const <String, String>{},
    this.queryParams = const <String, String>{},
    this.queryParametersAll = const <String, List<String>>{},
    this.extra,
    this.error,
    ValueKey<String>? pageKey,
  }) : pageKey = pageKey ??
            ValueKey<String>(error != null
                ? 'error'
                : fullpath != null && fullpath.isNotEmpty
                    ? fullpath
                    : subloc);

  // TODO(johnpryan): remove once namedLocation is removed from go_router.
  // See https://github.com/flutter/flutter/issues/107729
  final RouteConfiguration _configuration;

  /// The full location of the route, e.g. /family/f2/person/p1
  final String location;

  /// The location of this sub-route, e.g. /family/f2
  final String subloc;

  /// The optional name of the route.
  final String? name;

  /// The path to this sub-route, e.g. family/:fid
  final String? path;

  /// The full path to this sub-route, e.g. /family/:fid
  final String? fullpath;

  /// The parameters for this sub-route, e.g. {'fid': 'f2'}
  final Map<String, String> params;

  /// The query parameters for the location, e.g. {'from': '/family/f2'}
  final Map<String, String> queryParams;

  /// The query parameters for the location,
  /// e.g. `{'q1': ['v1'], 'q2': ['v2', 'v3']}`
  final Map<String, List<String>> queryParametersAll;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// The error associated with this sub-route.
  final Exception? error;

  /// A unique string key for this sub-route, e.g. ValueKey('/family/:fid')
  final ValueKey<String> pageKey;

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  // TODO(johnpryan): deprecate namedLocation API
  // See https://github.com/flutter/flutter/issues/10772
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
  }) {
    return _configuration.namedLocation(name,
        params: params, queryParams: queryParams);
  }
}

/// The current state for a [StatefulShellRoute].
@immutable
class StatefulShellRouteState {
  /// Constructs a [StatefulShellRouteState].
  const StatefulShellRouteState({
    required Function(String, Object?) go,
    required this.route,
    required this.branchState,
    required this.index,
  }) : _go = go;

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute route;

  /// The state for all separate route branches associated with a
  /// [StatefulShellRoute].
  final List<ShellRouteBranchState> branchState;

  /// The index of the currently active route branch.
  final int index;

  final Function(String, Object?) _go;

  /// Gets the [Navigator]s for each of the route branches.
  ///
  /// Note that the Navigator for a particular branch may be null if the branch
  /// hasn't been visited yet.
  List<Widget?> get navigators =>
      branchState.map((ShellRouteBranchState e) => e.navigator).toList();

  /// Navigate to the current location of the branch with the provided index.
  ///
  /// This method will switch the currently active [Navigator] for the
  /// [StatefulShellRoute] by navigating to the current location of the
  /// specified branch, using the method [GoRouter.go].
  void goBranch(int index, {Object? extra}) {
    _go(branchState[index]._location, extra);
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
        listEquals(other.branchState, branchState) &&
        other.index == index;
  }

  @override
  int get hashCode => Object.hash(route, branchState, index);
}

/// The current state for a particular route branch
/// ([ShellRouteBranch]) of a [StatefulShellRoute].
@immutable
class ShellRouteBranchState {
  /// Constructs a [ShellRouteBranchState].
  const ShellRouteBranchState({
    required this.routeBranch,
    required String rootRoutePath,
    this.navigator,
    String? lastLocation,
  })  : _lastLocation = lastLocation,
        _rootRoutePath = rootRoutePath;

  /// Constructs a copy of this [ShellRouteBranchState], with updated values for
  /// some of the fields.
  ShellRouteBranchState copy({Navigator? navigator, String? lastLocation}) {
    return ShellRouteBranchState(
      routeBranch: routeBranch,
      rootRoutePath: _rootRoutePath,
      navigator: navigator ?? this.navigator,
      lastLocation: lastLocation ?? _lastLocation,
    );
  }

  /// The associated [ShellRouteBranch]
  final ShellRouteBranch routeBranch;

  /// The [Navigator] for this route branch in a [StatefulShellRoute]. This
  /// field will typically not be set until this route tree has been navigated
  /// to at least once.
  final Navigator? navigator;

  /// Gets the defaultLocation specified in [routeBranch] or falls back to
  /// the root path of the associated [rootRoute].
  String get _defaultLocation => routeBranch.defaultLocation ?? _rootRoutePath;

  final String? _lastLocation;

  /// The full path at which root route for the route branch is reachable.
  final String _rootRoutePath;

  /// Gets the current location for this branch or falls back to the default
  /// location () if this branch hasn't been visited yet.
  String get _location => _lastLocation ?? _defaultLocation;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! ShellRouteBranchState) {
      return false;
    }
    return other.routeBranch == routeBranch &&
        other._rootRoutePath == _rootRoutePath &&
        other.navigator == navigator &&
        other._lastLocation == _lastLocation;
  }

  @override
  int get hashCode =>
      Object.hash(routeBranch, _rootRoutePath, navigator, _lastLocation);
}
