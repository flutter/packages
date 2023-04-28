// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
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
    return RouteMatchList(
        matches: matches, uri: uri, pathParameters: pathParameters);
  }

  List<RouteMatch> _getLocRouteMatches(
      Uri uri, Object? extra, Map<String, String> pathParameters) {
    final List<RouteMatch>? result = _getLocRouteRecursively(
      location: uri.path,
      remainingLocation: uri.path,
      routes: configuration.routes,
      matchedLocation: '',
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
///
/// This corresponds to the GoRouter's history.
@immutable
class RouteMatchList {
  /// RouteMatchList constructor.
  RouteMatchList({
    required this.matches,
    required this.uri,
    required this.pathParameters,
  }) : fullPath = _generateFullPath(matches);

  /// Constructs an empty matches object.
  static RouteMatchList empty = RouteMatchList(
      matches: const <RouteMatch>[],
      uri: Uri(),
      pathParameters: const <String, String>{});

  /// The route matches.
  final List<RouteMatch> matches;

  /// Parameters for the matched route, URI-encoded.
  ///
  /// The parameters only reflects [RouteMatch]s that are not
  /// [ImperativeRouteMatch].
  final Map<String, String> pathParameters;

  /// The uri of the current match.
  ///
  /// This uri only reflects [RouteMatch]s that are not [ImperativeRouteMatch].
  final Uri uri;

  /// the full path pattern that matches the uri.
  ///
  /// For example:
  ///
  /// ```dart
  /// '/family/:fid/person/:pid'
  /// ```
  final String fullPath;

  /// Generates the full path (ex: `'/family/:fid/person/:pid'`) of a list of
  /// [RouteMatch].
  ///
  /// This method ignores [ImperativeRouteMatch]s in the `matches`, as they
  /// don't contribute to the path.
  ///
  /// This methods considers that [matches]'s elements verify the go route
  /// structure given to `GoRouter`. For example, if the routes structure is
  ///
  /// ```dart
  /// GoRoute(
  ///   path: '/a',
  ///   routes: [
  ///     GoRoute(
  ///       path: 'b',
  ///       routes: [
  ///         GoRoute(
  ///           path: 'c',
  ///         ),
  ///       ],
  ///     ),
  ///   ],
  /// ),
  /// ```
  ///
  /// The [matches] must be the in same order of how GoRoutes are matched.
  ///
  /// ```dart
  /// [RouteMatchA(), RouteMatchB(), RouteMatchC()]
  /// ```
  static String _generateFullPath(Iterable<RouteMatch> matches) {
    final StringBuffer buffer = StringBuffer();
    bool addsSlash = false;
    for (final RouteMatch match in matches
        .where((RouteMatch match) => match is! ImperativeRouteMatch)) {
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

  /// Returns true if there are no matches.
  bool get isEmpty => matches.isEmpty;

  /// Returns true if there are matches.
  bool get isNotEmpty => matches.isNotEmpty;

  /// Returns a new instance of RouteMatchList with the input `match` pushed
  /// onto the current instance.
  RouteMatchList push<T>(ImperativeRouteMatch<T> match) {
    // Imperative route match doesn't change the uri and path parameters.
    return _copyWith(matches: <RouteMatch>[...matches, match]);
  }

  /// Returns a new instance of RouteMatchList with the input `match` removed
  /// from the current instance.
  RouteMatchList remove(RouteMatch match) {
    final List<RouteMatch> newMatches = matches.toList();
    final int index = newMatches.indexOf(match);
    assert(index != -1);
    newMatches.removeRange(index, newMatches.length);

    // Also pop ShellRoutes when there are no subsequent route matches
    while (newMatches.isNotEmpty && newMatches.last.route is ShellRoute) {
      newMatches.removeLast();
    }
    // Removing ImperativeRouteMatch should not change uri and pathParameters.
    if (match is ImperativeRouteMatch) {
      return _copyWith(matches: newMatches);
    }

    final String fullPath = _generateFullPath(
        newMatches.where((RouteMatch match) => match is! ImperativeRouteMatch));
    // Need to remove path parameters that are no longer in the fullPath.
    final List<String> newParameters = <String>[];
    patternToRegExp(fullPath, newParameters);
    final Set<String> validParameters = newParameters.toSet();
    final Map<String, String> newPathParameters =
        Map<String, String>.fromEntries(
      pathParameters.entries.where((MapEntry<String, String> value) =>
          validParameters.contains(value.key)),
    );
    final Uri newUri =
        uri.replace(path: patternToPath(fullPath, newPathParameters));
    return _copyWith(
      matches: newMatches,
      uri: newUri,
      pathParameters: newPathParameters,
    );
  }

  /// An optional object provided by the app during navigation.
  Object? get extra => matches.isEmpty ? null : matches.last.extra;

  /// The last matching route.
  RouteMatch get last => matches.last;

  /// Returns true if the current match intends to display an error screen.
  bool get isError => matches.length == 1 && matches.first.error != null;

  /// Returns the error that this match intends to display.
  Exception? get error => matches.first.error;

  RouteMatchList _copyWith({
    List<RouteMatch>? matches,
    Uri? uri,
    Map<String, String>? pathParameters,
  }) {
    return RouteMatchList(
        matches: matches ?? this.matches,
        uri: uri ?? this.uri,
        pathParameters: pathParameters ?? this.pathParameters);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RouteMatchList &&
        const ListEquality<RouteMatch>().equals(matches, other.matches) &&
        uri == other.uri &&
        const MapEquality<String, String>()
            .equals(pathParameters, other.pathParameters);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(matches),
      uri,
      Object.hashAllUnordered(
        pathParameters.entries.map<int>((MapEntry<String, String> entry) =>
            Object.hash(entry.key, entry.value)),
      ),
    );
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'RouteMatchList')}($fullPath)';
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

/// Returns the list of `RouteMatch` corresponding to the given `loc`.
///
/// For example, for a given `loc` `/a/b/c/d`, this function will return the
/// list of [RouteBase] `[GoRouteA(), GoRouterB(), GoRouteC(), GoRouterD()]`.
///
/// - [location] is the complete URL to match (without the query parameters). For
///   example, for the URL `/a/b?c=0`, [location] will be `/a/b`.
/// - [remainingLocation] is the remaining part of the URL to match while [matchedLocation]
///   is the part of the URL that has already been matched. For examples, for
///   the URL `/a/b/c/d`, at some point, [remainingLocation] would be `/c/d` and
///   [matchedLocation] will be `/a/b`.
/// - [routes] are the possible [RouteBase] to match to [remainingLocation].
List<RouteMatch>? _getLocRouteRecursively({
  required String location,
  required String remainingLocation,
  required String matchedLocation,
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
      remainingLocation: remainingLocation,
      matchedLocation: matchedLocation,
      pathParameters: subPathParameters,
      extra: extra,
    );

    if (match == null) {
      continue;
    }

    if (match.route is GoRoute &&
        match.matchedLocation.toLowerCase() == location.toLowerCase()) {
      // If it is a complete match, then return the matched route
      // NOTE: need a lower case match because matchedLocation is canonicalized to match
      // the path case whereas the location can be of any case and still match
      result = <RouteMatch>[match];
    } else if (route.routes.isEmpty) {
      // If it is partial match but no sub-routes, bail.
      continue;
    } else {
      // Otherwise, recurse
      final String childRestLoc;
      final String newParentSubLoc;
      if (match.route is ShellRoute) {
        childRestLoc = remainingLocation;
        newParentSubLoc = matchedLocation;
      } else {
        assert(location.startsWith(match.matchedLocation));
        assert(remainingLocation.isNotEmpty);

        childRestLoc = location.substring(match.matchedLocation.length +
            (match.matchedLocation == '/' ? 0 : 1));
        newParentSubLoc = match.matchedLocation;
      }

      final List<RouteMatch>? subRouteMatch = _getLocRouteRecursively(
        location: location,
        remainingLocation: childRestLoc,
        matchedLocation: newParentSubLoc,
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
    matches: <RouteMatch>[
      RouteMatch(
        matchedLocation: uri.path,
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
    uri: uri,
    pathParameters: const <String, String>{},
  );
}
