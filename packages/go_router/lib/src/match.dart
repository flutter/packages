// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'path_utils.dart';

/// An matched result by matching a [RouteBase] against a location.
///
/// This is typically created by calling [RouteMatch.match].
@immutable
class RouteMatch {
  /// Constructor for [RouteMatch].
  const RouteMatch({
    required this.route,
    required this.matchedLocation,
    required this.extra,
    required this.error,
    required this.pageKey,
  });

  /// Generate a [RouteMatch] object by matching the `route` with
  /// `remainingLocation`.
  ///
  /// The extracted path parameters, as the result of the matching, are stored
  /// into `pathParameters`.
  static RouteMatch? match({
    required RouteBase route,
    required String remainingLocation, // e.g. person/p1
    required String matchedLocation, // e.g. /family/f2
    required Map<String, String> pathParameters,
    required Object? extra,
  }) {
    if (route is ShellRouteBase) {
      return RouteMatch(
        route: route,
        matchedLocation: remainingLocation,
        extra: extra,
        error: null,
        pageKey: ValueKey<String>(route.hashCode.toString()),
      );
    } else if (route is GoRoute) {
      assert(!route.path.contains('//'));

      final RegExpMatch? match = route.matchPatternAsPrefix(remainingLocation);
      if (match == null) {
        return null;
      }

      final Map<String, String> encodedParams = route.extractPathParams(match);
      for (final MapEntry<String, String> param in encodedParams.entries) {
        pathParameters[param.key] = Uri.decodeComponent(param.value);
      }
      final String pathLoc = patternToPath(route.path, encodedParams);
      final String newMatchedLocation =
          concatenatePaths(matchedLocation, pathLoc);
      return RouteMatch(
        route: route,
        matchedLocation: newMatchedLocation,
        extra: extra,
        error: null,
        pageKey: ValueKey<String>(route.hashCode.toString()),
      );
    }
    assert(false, 'Unexpected route type: $route');
    return null;
  }

  /// The matched route.
  final RouteBase route;

  /// The location string that matches the [route].
  ///
  /// for example:
  ///
  /// uri = '/family/f2/person/p2'
  /// route = GoRoute('/family/:id)
  ///
  /// matchedLocation = '/family/f2'
  final String matchedLocation;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// An exception if there was an error during matching.
  final Exception? error;

  /// Value key of type string, to hold a unique reference to a page.
  final ValueKey<String> pageKey;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RouteMatch &&
        route == other.route &&
        matchedLocation == other.matchedLocation &&
        extra == other.extra &&
        pageKey == other.pageKey;
  }

  @override
  int get hashCode => Object.hash(route, matchedLocation, extra, pageKey);
}

/// The route match that represent route pushed through [GoRouter.push].
class ImperativeRouteMatch extends RouteMatch {
  /// Constructor for [ImperativeRouteMatch].
  ImperativeRouteMatch(
      {required super.pageKey, required this.matches, required this.completer})
      : super(
          route: matches.last.route,
          matchedLocation: matches.last.matchedLocation,
          extra: matches.last.extra,
          error: matches.last.error,
        );

  /// The matches that produces this route match.
  final RouteMatchList matches;

  /// The completer for the future returned by [GoRouter.push].
  final Completer<Object?> completer;

  /// Called when the corresponding [Route] associated with this route match is
  /// completed.
  void complete([dynamic value]) {
    completer.complete(value);
  }

  // An ImperativeRouteMatch has its own life cycle due the the _completer.
  // comparing _completer between instances would be the same thing as
  // comparing object reference.
  @override
  bool operator ==(Object other) {
    return identical(this, other);
  }

  @override
  int get hashCode => identityHashCode(this);
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
  RouteMatchList push(ImperativeRouteMatch match) {
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
    while (newMatches.isNotEmpty && newMatches.last.route is ShellRouteBase) {
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
  bool get isError => error != null;

  /// Returns the error that this match intends to display.
  Exception? get error => matches.firstOrNull?.error;

  /// The routes for each of the matches.
  List<RouteBase> get routes => matches.map((RouteMatch e) => e.route).toList();

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

/// Handles encoding and decoding of [RouteMatchList] objects to a format
/// suitable for using with [StandardMessageCodec].
///
/// The primary use of this class is for state restoration.
class RouteMatchListCodec {
  /// Creates a new [RouteMatchListCodec] object.
  RouteMatchListCodec(this._configuration);

  static const String _locationKey = 'location';
  static const String _extraKey = 'state';
  static const String _imperativeMatchesKey = 'imperativeMatches';
  static const String _pageKey = 'pageKey';

  final RouteConfiguration _configuration;

  /// Encodes the provided [RouteMatchList].
  Object? encode(RouteMatchList matchlist) {
    if (matchlist.isEmpty) {
      return null;
    }
    final List<Map<Object?, Object?>> imperativeMatches = matchlist.matches
        .whereType<ImperativeRouteMatch>()
        .map((ImperativeRouteMatch e) => _toPrimitives(
            e.matches.uri.toString(), e.extra,
            pageKey: e.pageKey.value))
        .toList();

    return _toPrimitives(
        matchlist.uri.toString(), matchlist.matches.first.extra,
        imperativeMatches: imperativeMatches);
  }

  static Map<Object?, Object?> _toPrimitives(String location, Object? extra,
      {List<dynamic>? imperativeMatches, String? pageKey}) {
    String? encodedExtra;
    try {
      encodedExtra = json.encoder.convert(extra);
    } on JsonUnsupportedObjectError {/* give up if not serializable */}
    return <Object?, Object?>{
      _locationKey: location,
      if (encodedExtra != null) _extraKey: encodedExtra,
      if (imperativeMatches != null) _imperativeMatchesKey: imperativeMatches,
      if (pageKey != null) _pageKey: pageKey,
    };
  }

  /// Attempts to decode the provided object into a [RouteMatchList].
  RouteMatchList decode(Object object) {
    final Map<Object?, Object?> data = object as Map<Object?, Object?>;
    final String rootLocation = data[_locationKey]! as String;
    final String? encodedExtra = data[_extraKey] as String?;
    final Object? extra;
    if (encodedExtra != null) {
      extra = json.decoder.convert(encodedExtra);
    } else {
      extra = null;
    }
    RouteMatchList matchList =
        _configuration.findMatch(rootLocation, extra: extra);

    final List<Object?>? imperativeMatches =
        data[_imperativeMatchesKey] as List<Object?>?;
    if (imperativeMatches != null) {
      for (final Map<Object?, Object?> encodedImperativeMatch
          in imperativeMatches.whereType<Map<Object?, Object?>>()) {
        final RouteMatchList imperativeMatchList =
            decode(encodedImperativeMatch);
        final ValueKey<String> pageKey =
            ValueKey<String>(encodedImperativeMatch[_pageKey]! as String);
        final ImperativeRouteMatch imperativeMatch = ImperativeRouteMatch(
          pageKey: pageKey,
          // TODO(chunhtai): Figure out a way to preserve future.
          // https://github.com/flutter/flutter/issues/128122.
          completer: Completer<Object?>(),
          matches: imperativeMatchList,
        );
        matchList = matchList.push(imperativeMatch);
      }
    }

    return matchList;
  }
}
