// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'configuration.dart';
import 'match.dart';
import 'path_utils.dart';

/// Converts a location into a list of [GoRouteMatch] objects.
class RouteMatcher {
  /// [RouteMatcher] constructor.
  RouteMatcher(this.configuration);

  /// The route configuration.
  final RouteConfiguration configuration;

  /// Finds the routes that matched the given URL.
  RouteMatchList findMatch(String location, {Object? extra}) {
    final String canonicalLocation = canonicalUri(location);
    final List<GoRouteMatch> matches =
        _getLocRouteMatches(canonicalLocation, extra);
    return RouteMatchList(matches);
  }

  List<GoRouteMatch> _getLocRouteMatches(String location, Object? extra) {
    final Uri uri = Uri.parse(location);
    final List<GoRouteMatch> result = _getLocRouteRecursively(
      loc: uri.path,
      restLoc: uri.path,
      routes: configuration.routes,
      parentFullpath: '',
      parentSubloc: '',
      queryParams: uri.queryParameters,
      queryParametersAll: uri.queryParametersAll,
      extra: extra,
    );

    if (result.isEmpty) {
      throw MatcherError('no routes for location', location);
    }

    return result;
  }
}

/// The list of [GoRouteMatch] objects.
class RouteMatchList {
  /// RouteMatchList constructor.
  RouteMatchList(this._matches);

  /// Constructs an empty matches object.
  factory RouteMatchList.empty() => RouteMatchList(<GoRouteMatch>[]);

  final List<GoRouteMatch> _matches;

  /// Returns true if there are no matches.
  bool get isEmpty => _matches.isEmpty;

  /// Returns true if there are matches.
  bool get isNotEmpty => _matches.isNotEmpty;

  /// The original URL that was matched.
  Uri get location =>
      _matches.isEmpty ? Uri() : Uri.parse(_matches.last.fullUriString);

  /// Pushes a match onto the list of matches.
  void push(GoRouteMatch match) {
    _matches.add(match);
  }

  /// Removes the last match.
  void pop() {
    _matches.removeLast();

    _assertNotEmpty();

    // Also pop ShellRoutes when there are no subsequent route matches
    if (_matches.last.route is ShellRoute) {
      _matches.removeLast();
    }

    _assertNotEmpty();
  }

  /// Returns true if [pop] can safely be called.
  bool canPop() {
    // TODO(johnpryan): Call Navigator.canPop(). Deal with ShellRoute.
    return _matches.length > 1;
  }

  /// An optional object provided by the app during navigation.
  Object? get extra => _matches.last.extra;

  /// The last matching route.
  GoRouteMatch get last => _matches.last;

  /// The route matches.
  List<GoRouteMatch> get matches => _matches;

  /// Returns true if the current match intends to display an error screen.
  bool get isError => matches.length == 1 && matches.first.error != null;

  /// Returns the error that this match intends to display.
  Exception? get error => matches.first.error;

  void _assertNotEmpty() {
    assert(
        _matches.isNotEmpty,
        'You have popped the last page off of the stack,'
        ' there are no pages left to show');
  }
}

/// An error that occurred during matching.
class MatcherError extends Error {
  /// Constructs a [MatcherError].
  MatcherError(String message, this.location) : message = '$message: $location';

  /// The error message.
  final String message;

  /// The location that failed to match.
  final String location;

  @override
  String toString() {
    return message;
  }
}

List<GoRouteMatch> _getLocRouteRecursively({
  required String loc,
  required String restLoc,
  required String parentSubloc,
  required List<RouteBase> routes,
  required String parentFullpath,
  required Map<String, String> queryParams,
  required Map<String, List<String>> queryParametersAll,
  required Object? extra,
}) {
  bool debugGatherAllMatches = false;
  assert(() {
    debugGatherAllMatches = true;
    return true;
  }());
  final List<List<GoRouteMatch>> result = <List<GoRouteMatch>>[];
  // find the set of matches at this level of the tree
  for (final RouteBase route in routes) {
    late final String fullpath;
    if (route is GoRoute) {
      fullpath = concatenatePaths(parentFullpath, route.path);
    } else if (route is ShellRoute) {
      fullpath = parentFullpath;
    }

    final GoRouteMatch? match = GoRouteMatch.match(
      route: route,
      restLoc: restLoc,
      parentSubloc: parentSubloc,
      fullpath: fullpath,
      queryParams: queryParams,
      queryParametersAll: queryParametersAll,
      extra: extra,
    );

    if (match == null) {
      continue;
    }

    if (match.route is GoRoute &&
        match.location.toLowerCase() == loc.toLowerCase()) {
      // If it is a complete match, then return the matched route
      // NOTE: need a lower case match because subloc is canonicalized to match
      // the path case whereas the location can be of any case and still match
      result.add(<GoRouteMatch>[match]);
    } else if (route.routes.isEmpty) {
      // If it is partial match but no sub-routes, bail.
      continue;
    } else {
      // Otherwise, recurse
      final String childRestLoc;
      final String newParentSubLoc;
      if (match.route is ShellRoute) {
        childRestLoc = restLoc;
        newParentSubLoc = parentSubloc;
      } else {
        assert(loc.startsWith(match.location));
        assert(restLoc.isNotEmpty);

        childRestLoc = loc
            .substring(match.location.length + (match.location == '/' ? 0 : 1));
        newParentSubLoc = match.location;
      }

      final List<GoRouteMatch> subRouteMatch = _getLocRouteRecursively(
        loc: loc,
        restLoc: childRestLoc,
        parentSubloc: newParentSubLoc,
        routes: route.routes,
        parentFullpath: fullpath,
        queryParams: queryParams,
        queryParametersAll: queryParametersAll,
        extra: extra,
      ).toList();

      // If there's no sub-route matches, there is no match for this location
      if (subRouteMatch.isEmpty) {
        continue;
      }
      result.add(<GoRouteMatch>[match, ...subRouteMatch]);
    }
    // Should only reach here if there is a match.
    if (debugGatherAllMatches) {
      continue;
    } else {
      break;
    }
  }

  if (result.isEmpty) {
    return <GoRouteMatch>[];
  }

  // If there are multiple routes that match the location, returning the first one.
  // To make predefined routes to take precedence over dynamic routes eg. '/:id'
  // consider adding the dynamic route at the end of the routes
  return result.first;
}
