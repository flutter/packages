// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'match.dart';
import 'path_utils.dart';

/// Converts a location into a list of [RouteMatch] objects.
class RouteMatcher {
  /// [RouteMatcher] constructor.
  RouteMatcher(this.configuration);

  /// The route configuration.
  final RouteConfiguration configuration;

  /// Finds the routes that matched the given URL.
  RouteMatchList findMatch(String location, {Object? extra}) {
    final Uri uri = Uri.parse(canonicalUri(location));

    final Map<String, String> pathParameters = <String, String>{};
    final List<RouteMatch> matches =
        _getLocRouteMatches(uri, extra, pathParameters);
    return RouteMatchList(matches, uri, pathParameters);
  }

  List<RouteMatch> _getLocRouteMatches(
      Uri uri, Object? extra, Map<String, String> pathParameters) {
    final List<RouteMatch>? result = _getLocRouteRecursively(
      loc: uri.path,
      restLoc: uri.path,
      routes: configuration.routes,
      parentSubloc: '',
      pathParameters: pathParameters,
      extra: extra,
    );

    if (result == null) {
      throw MatcherError('no routes for location', uri.toString());
    }

    return result;
  }
}

/// The list of [RouteMatch] objects.
class RouteMatchList {
  /// RouteMatchList constructor.
  RouteMatchList(List<RouteMatch> matches, this._uri, this.pathParameters)
      : _matches = matches,
        fullpath = _generateFullPath(matches);

  /// Creates an immutable clone of this RouteMatchList.
  UnmodifiableRouteMatchList unmodifiableRouteMatchList() {
    return UnmodifiableRouteMatchList.from(this);
  }

  /// Constructs an empty matches object.
  static RouteMatchList empty = RouteMatchList(
      const <RouteMatch>[], Uri.parse(''), const <String, String>{});

  static String _generateFullPath(List<RouteMatch> matches) {
    final StringBuffer buffer = StringBuffer();
    bool addsSlash = false;
    for (final RouteMatch match in matches) {
      final RouteBase route = match.route;
      if (route is GoRoute) {
        if (addsSlash) {
          buffer.write('/');
        }
        buffer.write(route.path);
        addsSlash = addsSlash || route.path != '/';
      }
    }
    return buffer.toString();
  }

  final List<RouteMatch> _matches;

  /// the full path pattern that matches the uri.
  /// /family/:fid/person/:pid
  final String fullpath;

  /// Parameters for the matched route, URI-encoded.
  final Map<String, String> pathParameters;

  /// The uri of the current match.
  Uri get uri => _uri;
  Uri _uri;

  /// Returns true if there are no matches.
  bool get isEmpty => _matches.isEmpty;

  /// Returns true if there are matches.
  bool get isNotEmpty => _matches.isNotEmpty;

  /// Pushes a match onto the list of matches.
  void push(RouteMatch match) {
    _matches.add(match);
  }

  /// Removes the last match.
  void pop() {
    if (_matches.last.route is GoRoute) {
      final GoRoute route = _matches.last.route as GoRoute;
      _uri = _uri.replace(path: removePatternFromPath(route.path, _uri.path));
    }
    _matches.removeLast();
    // Also pop ShellRoutes when there are no subsequent route matches
    while (_matches.isNotEmpty && _matches.last.route is ShellRouteBase) {
      _matches.removeLast();
    }
  }

  /// An optional object provided by the app during navigation.
  Object? get extra => _matches.isEmpty ? null : _matches.last.extra;

  /// The last matching route.
  RouteMatch get last => _matches.last;

  /// The route matches.
  List<RouteMatch> get matches => _matches;

  /// Returns true if the current match intends to display an error screen.
  bool get isError => matches.length == 1 && matches.first.error != null;

  /// Returns the error that this match intends to display.
  Exception? get error => matches.first.error;
}

/// Unmodifiable version of [RouteMatchList].
@immutable
class UnmodifiableRouteMatchList {
  /// UnmodifiableRouteMatchList constructor.
  UnmodifiableRouteMatchList.from(RouteMatchList routeMatchList)
      : _matches = List<RouteMatch>.unmodifiable(routeMatchList.matches),
        _uri = routeMatchList.uri,
        _pathParameters =
            Map<String, String>.unmodifiable(routeMatchList.pathParameters);

  /// Creates a new [RouteMatchList] from this UnmodifiableRouteMatchList.
  RouteMatchList get routeMatchList => RouteMatchList(
      List<RouteMatch>.from(_matches),
      _uri,
      Map<String, String>.from(_pathParameters));

  /// The route matches.
  final List<RouteMatch> _matches;

  /// The uri of the current match.
  final Uri _uri;

  /// Parameters for the matched route, URI-encoded.
  final Map<String, String> _pathParameters;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! UnmodifiableRouteMatchList) {
      return false;
    }
    return listEquals(other._matches, _matches) &&
        other._uri == _uri &&
        mapEquals(other._pathParameters, _pathParameters);
  }

  @override
  int get hashCode => Object.hash(_matches, _uri, _pathParameters);
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

List<RouteMatch>? _getLocRouteRecursively({
  required String loc,
  required String restLoc,
  required String parentSubloc,
  required List<RouteBase> routes,
  required Map<String, String> pathParameters,
  required Object? extra,
}) {
  List<RouteMatch>? result;
  late Map<String, String> subPathParameters;
  // find the set of matches at this level of the tree
  for (final RouteBase route in routes) {
    subPathParameters = <String, String>{};

    final RouteMatch? match = RouteMatch.match(
      route: route,
      restLoc: restLoc,
      parentSubloc: parentSubloc,
      pathParameters: subPathParameters,
      extra: extra,
    );

    if (match == null) {
      continue;
    }

    if (match.route is GoRoute &&
        match.subloc.toLowerCase() == loc.toLowerCase()) {
      // If it is a complete match, then return the matched route
      // NOTE: need a lower case match because subloc is canonicalized to match
      // the path case whereas the location can be of any case and still match
      result = <RouteMatch>[match];
    } else if (route.routes.isEmpty) {
      // If it is partial match but no sub-routes, bail.
      continue;
    } else {
      // Otherwise, recurse
      final String childRestLoc;
      final String newParentSubLoc;
      if (match.route is ShellRouteBase) {
        childRestLoc = restLoc;
        newParentSubLoc = parentSubloc;
      } else {
        assert(loc.startsWith(match.subloc));
        assert(restLoc.isNotEmpty);

        childRestLoc =
            loc.substring(match.subloc.length + (match.subloc == '/' ? 0 : 1));
        newParentSubLoc = match.subloc;
      }

      final List<RouteMatch>? subRouteMatch = _getLocRouteRecursively(
        loc: loc,
        restLoc: childRestLoc,
        parentSubloc: newParentSubLoc,
        routes: route.routes,
        pathParameters: subPathParameters,
        extra: extra,
      );

      // If there's no sub-route matches, there is no match for this location
      if (subRouteMatch == null) {
        continue;
      }
      result = <RouteMatch>[match, ...subRouteMatch];
    }
    // Should only reach here if there is a match.
    break;
  }
  if (result != null) {
    pathParameters.addAll(subPathParameters);
  }
  return result;
}

/// The match used when there is an error during parsing.
RouteMatchList errorScreen(Uri uri, String errorMessage) {
  final Exception error = Exception(errorMessage);
  return RouteMatchList(
      <RouteMatch>[
        RouteMatch(
          subloc: uri.path,
          extra: null,
          error: error,
          route: GoRoute(
            path: uri.toString(),
            pageBuilder: (BuildContext context, GoRouterState state) {
              throw UnimplementedError();
            },
          ),
          pageKey: const ValueKey<String>('error'),
        ),
      ],
      uri,
      const <String, String>{});
}
