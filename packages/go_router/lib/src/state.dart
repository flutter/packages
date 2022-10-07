// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';

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
class StatefulShellRouteState {
  /// Constructs a [StatefulShellRouteState].
  StatefulShellRouteState(
      {required this.route,
      required this.navigationBranchState,
      required this.currentBranchIndex});

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute route;

  /// The state for all separate navigation branches associated with a
  /// [StatefulShellRoute].
  final List<ShellNavigationBranchState> navigationBranchState;

  /// The index of the currently active navigation branch.
  final int currentBranchIndex;

  /// Gets the current location from the [topRouteState] or falls back to
  /// the root path of the associated [route].
  String get currentLocation =>
      navigationBranchState[currentBranchIndex].currentLocation;
}

/// The current state for a particular navigation branch
/// ([ShellNavigationBranchItem]) of a [StatefulShellRoute].
class ShellNavigationBranchState {
  /// Constructs a [ShellNavigationBranchState].
  ShellNavigationBranchState({
    required this.navigationItem,
    required this.rootRoutePath,
  });

  /// The associated [ShellNavigationBranchItem]
  final ShellNavigationBranchItem navigationItem;

  /// The full path at which root route for the navigation branch is reachable.
  final String rootRoutePath;

  /// The [Navigator] for this navigation branch in a [StatefulShellRoute]. This
  /// field will typically not be set until this route tree has been navigated
  /// to at least once.
  Navigator? navigator;

  /// The [GoRouterState] for the top of the current navigation stack.
  GoRouterState? topRouteState;

  /// Gets the current location from the [topRouteState] or falls back to
  /// the root path of the associated [route].
  String get currentLocation => topRouteState?.location ?? rootRoutePath;

  /// The root route for the navigation branch.
  RouteBase get route => navigationItem.rootRoute;
}
