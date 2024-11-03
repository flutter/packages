// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'configuration.dart';
import 'logging.dart';
import 'misc/errors.dart';
import 'path_utils.dart';
import 'route.dart';
import 'state.dart';

/// The function signature for [RouteMatchList.visitRouteMatches]
///
/// Return false to stop the walk.
typedef RouteMatchVisitor = bool Function(RouteMatchBase);

/// The base class for various route matches.
abstract class RouteMatchBase with Diagnosticable {
  /// An abstract route match base
  const RouteMatchBase();

  /// The matched route.
  RouteBase get route;

  /// The page key.
  ValueKey<String> get pageKey;

  /// The location string that matches the [route].
  ///
  /// for example:
  ///
  /// uri = '/family/f2/person/p2'
  /// route = GoRoute('/family/:id')
  ///
  /// matchedLocation = '/family/f2'
  String get matchedLocation;

  /// Gets the state that represent this route match.
  GoRouterState buildState(
      RouteConfiguration configuration, RouteMatchList matches);

  /// Generates a list of [RouteMatchBase] objects by matching the `route` and
  /// its sub-routes with `uri`.
  ///
  /// This method returns empty list if it can't find a complete match in the
  /// `route`.
  ///
  /// The `rootNavigatorKey` is required to match routes with
  /// parentNavigatorKey.
  ///
  /// The extracted path parameters, as the result of the matching, are stored
  /// into `pathParameters`.
  static List<RouteMatchBase> match({
    required RouteBase route,
    required Map<String, String> pathParameters,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required Uri uri,
  }) {
    return _matchByNavigatorKey(
          route: route,
          matchedPath: '',
          remainingLocation: uri.path,
          matchedLocation: '',
          pathParameters: pathParameters,
          scopedNavigatorKey: rootNavigatorKey,
          uri: uri,
        )[null] ??
        const <RouteMatchBase>[];
  }

  static const Map<GlobalKey<NavigatorState>?, List<RouteMatchBase>> _empty =
      <GlobalKey<NavigatorState>?, List<RouteMatchBase>>{};

  /// Returns a navigator key to route matches maps.
  ///
  /// The null key corresponds to the route matches of `scopedNavigatorKey`.
  /// The scopedNavigatorKey must not be part of the returned map; otherwise,
  /// it is impossible to order the matches.
  static Map<GlobalKey<NavigatorState>?, List<RouteMatchBase>>
      _matchByNavigatorKey({
    required RouteBase route,
    required String matchedPath, // e.g. /family/:fid
    required String remainingLocation, // e.g. person/p1
    required String matchedLocation, // e.g. /family/f2
    required Map<String, String> pathParameters,
    required GlobalKey<NavigatorState> scopedNavigatorKey,
    required Uri uri,
  }) {
    final Map<GlobalKey<NavigatorState>?, List<RouteMatchBase>> result;
    if (route is ShellRouteBase) {
      result = _matchByNavigatorKeyForShellRoute(
        route: route,
        matchedPath: matchedPath,
        remainingLocation: remainingLocation,
        matchedLocation: matchedLocation,
        pathParameters: pathParameters,
        scopedNavigatorKey: scopedNavigatorKey,
        uri: uri,
      );
    } else if (route is GoRoute) {
      result = _matchByNavigatorKeyForGoRoute(
        route: route,
        matchedPath: matchedPath,
        remainingLocation: remainingLocation,
        matchedLocation: matchedLocation,
        pathParameters: pathParameters,
        scopedNavigatorKey: scopedNavigatorKey,
        uri: uri,
      );
    } else {
      assert(false, 'Unexpected route type: $route');
      return _empty;
    }
    // Grab the route matches for the scope navigator key and put it into the
    // matches for `null`.
    if (result.containsKey(scopedNavigatorKey)) {
      final List<RouteMatchBase> matchesForScopedNavigator =
          result.remove(scopedNavigatorKey)!;
      assert(matchesForScopedNavigator.isNotEmpty);
      result
          .putIfAbsent(null, () => <RouteMatchBase>[])
          .addAll(matchesForScopedNavigator);
    }
    return result;
  }

  static Map<GlobalKey<NavigatorState>?, List<RouteMatchBase>>
      _matchByNavigatorKeyForShellRoute({
    required ShellRouteBase route,
    required String matchedPath, // e.g. /family/:fid
    required String remainingLocation, // e.g. person/p1
    required String matchedLocation, // e.g. /family/f2
    required Map<String, String> pathParameters,
    required GlobalKey<NavigatorState> scopedNavigatorKey,
    required Uri uri,
  }) {
    final GlobalKey<NavigatorState>? parentKey =
        route.parentNavigatorKey == scopedNavigatorKey
            ? null
            : route.parentNavigatorKey;
    Map<GlobalKey<NavigatorState>?, List<RouteMatchBase>>? subRouteMatches;
    late GlobalKey<NavigatorState> navigatorKeyUsed;
    for (final RouteBase subRoute in route.routes) {
      navigatorKeyUsed = route.navigatorKeyForSubRoute(subRoute);
      subRouteMatches = _matchByNavigatorKey(
        route: subRoute,
        matchedPath: matchedPath,
        remainingLocation: remainingLocation,
        matchedLocation: matchedLocation,
        pathParameters: pathParameters,
        uri: uri,
        scopedNavigatorKey: navigatorKeyUsed,
      );
      assert(!subRouteMatches
          .containsKey(route.navigatorKeyForSubRoute(subRoute)));
      if (subRouteMatches.isNotEmpty) {
        break;
      }
    }
    if (subRouteMatches?.isEmpty ?? true) {
      return _empty;
    }
    final RouteMatchBase result = ShellRouteMatch(
      route: route,
      // The RouteConfiguration should have asserted the subRouteMatches must
      // have at least one match for this ShellRouteBase.
      matches: subRouteMatches!.remove(null)!,
      matchedLocation: remainingLocation,
      pageKey: ValueKey<String>(route.hashCode.toString()),
      navigatorKey: navigatorKeyUsed,
    );
    subRouteMatches.putIfAbsent(parentKey, () => <RouteMatchBase>[]).insert(
          0,
          result,
        );

    return subRouteMatches;
  }

  static Map<GlobalKey<NavigatorState>?, List<RouteMatchBase>>
      _matchByNavigatorKeyForGoRoute({
    required GoRoute route,
    required String matchedPath, // e.g. /family/:fid
    required String remainingLocation, // e.g. person/p1
    required String matchedLocation, // e.g. /family/f2
    required Map<String, String> pathParameters,
    required GlobalKey<NavigatorState> scopedNavigatorKey,
    required Uri uri,
  }) {
    final GlobalKey<NavigatorState>? parentKey =
        route.parentNavigatorKey == scopedNavigatorKey
            ? null
            : route.parentNavigatorKey;

    final RegExpMatch? regExpMatch =
        route.matchPatternAsPrefix(remainingLocation);

    if (regExpMatch == null) {
      return _empty;
    }
    final Map<String, String> encodedParams =
        route.extractPathParams(regExpMatch);
    // A temporary map to hold path parameters. This map is merged into
    // pathParameters only when this route is part of the returned result.
    final Map<String, String> currentPathParameter =
        encodedParams.map<String, String>((String key, String value) =>
            MapEntry<String, String>(key, Uri.decodeComponent(value)));
    final String pathLoc = patternToPath(route.path, encodedParams);
    final String newMatchedLocation =
        concatenatePaths(matchedLocation, pathLoc);
    final String newMatchedPath = concatenatePaths(matchedPath, route.path);
    if (newMatchedLocation.toLowerCase() == uri.path.toLowerCase()) {
      // A complete match.
      pathParameters.addAll(currentPathParameter);

      return <GlobalKey<NavigatorState>?, List<RouteMatchBase>>{
        parentKey: <RouteMatchBase>[
          RouteMatch(
            route: route,
            matchedLocation: newMatchedLocation,
            pageKey: ValueKey<String>(newMatchedPath),
          ),
        ],
      };
    }
    assert(uri.path.startsWith(newMatchedLocation));
    assert(remainingLocation.isNotEmpty);

    final String childRestLoc = uri.path.substring(
        newMatchedLocation.length + (newMatchedLocation == '/' ? 0 : 1));

    Map<GlobalKey<NavigatorState>?, List<RouteMatchBase>>? subRouteMatches;
    for (final RouteBase subRoute in route.routes) {
      subRouteMatches = _matchByNavigatorKey(
        route: subRoute,
        matchedPath: newMatchedPath,
        remainingLocation: childRestLoc,
        matchedLocation: newMatchedLocation,
        pathParameters: pathParameters,
        uri: uri,
        scopedNavigatorKey: scopedNavigatorKey,
      );
      if (subRouteMatches.isNotEmpty) {
        break;
      }
    }
    if (subRouteMatches?.isEmpty ?? true) {
      // If not finding a sub route match, it is considered not matched for this
      // route even if this route match part of the `remainingLocation`.
      return _empty;
    }

    pathParameters.addAll(currentPathParameter);
    subRouteMatches!.putIfAbsent(parentKey, () => <RouteMatchBase>[]).insert(
        0,
        RouteMatch(
          route: route,
          matchedLocation: newMatchedLocation,
          pageKey: ValueKey<String>(newMatchedPath),
        ));
    return subRouteMatches;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RouteBase>('route', route));
  }
}

/// An matched result by matching a [GoRoute] against a location.
///
/// This is typically created by calling [RouteMatchBase.match].
@immutable
class RouteMatch extends RouteMatchBase {
  /// Constructor for [RouteMatch].
  const RouteMatch({
    required this.route,
    required this.matchedLocation,
    required this.pageKey,
  });

  /// The matched route.
  @override
  final GoRoute route;

  @override
  final String matchedLocation;

  @override
  final ValueKey<String> pageKey;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RouteMatch &&
        route == other.route &&
        matchedLocation == other.matchedLocation &&
        pageKey == other.pageKey;
  }

  @override
  int get hashCode => Object.hash(route, matchedLocation, pageKey);

  @override
  GoRouterState buildState(
      RouteConfiguration configuration, RouteMatchList matches) {
    return GoRouterState(
      configuration,
      uri: matches.uri,
      matchedLocation: matchedLocation,
      fullPath: matches.fullPath,
      pathParameters: matches.pathParameters,
      pageKey: pageKey,
      name: route.name,
      path: route.path,
      extra: matches.extra,
      topRoute: matches.lastOrNull?.route,
    );
  }
}

/// An matched result by matching a [ShellRoute] against a location.
///
/// This is typically created by calling [RouteMatchBase.match].
@immutable
class ShellRouteMatch extends RouteMatchBase {
  /// Create a match.
  ShellRouteMatch({
    required this.route,
    required this.matches,
    required this.matchedLocation,
    required this.pageKey,
    required this.navigatorKey,
  }) : assert(matches.isNotEmpty);

  @override
  final ShellRouteBase route;

  RouteMatch get _lastLeaf {
    RouteMatchBase currentMatch = matches.last;
    while (currentMatch is ShellRouteMatch) {
      currentMatch = currentMatch.matches.last;
    }
    return currentMatch as RouteMatch;
  }

  /// The navigator key used for this match.
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  final String matchedLocation;

  /// The matches that will be built under this shell route.
  final List<RouteMatchBase> matches;

  @override
  final ValueKey<String> pageKey;

  @override
  GoRouterState buildState(
      RouteConfiguration configuration, RouteMatchList matches) {
    // The route related data is stored in the leaf route match.
    final RouteMatch leafMatch = _lastLeaf;
    if (leafMatch is ImperativeRouteMatch) {
      matches = leafMatch.matches;
    }
    return GoRouterState(
      configuration,
      uri: matches.uri,
      matchedLocation: matchedLocation,
      fullPath: matches.fullPath,
      pathParameters: matches.pathParameters,
      pageKey: pageKey,
      extra: matches.extra,
      topRoute: matches.lastOrNull?.route,
    );
  }

  /// Creates a new shell route match with the given matches.
  ///
  /// This is typically used when pushing or popping [RouteMatchBase] from
  /// [RouteMatchList].
  @internal
  ShellRouteMatch copyWith({
    required List<RouteMatchBase>? matches,
  }) {
    return ShellRouteMatch(
      matches: matches ?? this.matches,
      route: route,
      matchedLocation: matchedLocation,
      pageKey: pageKey,
      navigatorKey: navigatorKey,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShellRouteMatch &&
        route == other.route &&
        matchedLocation == other.matchedLocation &&
        const ListEquality<RouteMatchBase>().equals(matches, other.matches) &&
        pageKey == other.pageKey;
  }

  @override
  int get hashCode =>
      Object.hash(route, matchedLocation, Object.hashAll(matches), pageKey);
}

/// The route match that represent route pushed through [GoRouter.push].
class ImperativeRouteMatch extends RouteMatch {
  /// Constructor for [ImperativeRouteMatch].
  ImperativeRouteMatch(
      {required super.pageKey, required this.matches, required this.completer})
      : super(
          route: _getsLastRouteFromMatches(matches),
          matchedLocation: _getsMatchedLocationFromMatches(matches),
        );

  static GoRoute _getsLastRouteFromMatches(RouteMatchList matchList) {
    if (matchList.isError) {
      return GoRoute(
          path: 'error', builder: (_, __) => throw UnimplementedError());
    }
    return matchList.last.route;
  }

  static String _getsMatchedLocationFromMatches(RouteMatchList matchList) {
    if (matchList.isError) {
      return matchList.uri.toString();
    }
    return matchList.last.matchedLocation;
  }

  /// The matches that produces this route match.
  final RouteMatchList matches;

  /// The completer for the future returned by [GoRouter.push].
  final Completer<Object?> completer;

  /// Called when the corresponding [Route] associated with this route match is
  /// completed.
  void complete([dynamic value]) {
    completer.complete(value);
  }

  @override
  GoRouterState buildState(
      RouteConfiguration configuration, RouteMatchList matches) {
    return super.buildState(configuration, this.matches);
  }

  @override
  bool operator ==(Object other) {
    return other is ImperativeRouteMatch &&
        completer == other.completer &&
        matches == other.matches &&
        super == other;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, completer, matches.hashCode);
}

/// The list of [RouteMatchBase] objects.
///
/// This can contains tree structure if there are [ShellRouteMatch] in the list.
///
/// This corresponds to the GoRouter's history.
@immutable
class RouteMatchList with Diagnosticable {
  /// RouteMatchList constructor.
  RouteMatchList({
    required this.matches,
    required this.uri,
    this.extra,
    this.error,
    required this.pathParameters,
  }) : fullPath = _generateFullPath(matches);

  /// Constructs an empty matches object.
  static RouteMatchList empty = RouteMatchList(
      matches: const <RouteMatchBase>[],
      uri: Uri(),
      pathParameters: const <String, String>{});

  /// The route matches.
  final List<RouteMatchBase> matches;

  /// Parameters for the matched route, URI-encoded.
  ///
  /// The parameters only reflects [RouteMatch]s that are not
  /// [ImperativeRouteMatch].
  final Map<String, String> pathParameters;

  /// The uri of the current match.
  ///
  /// This uri only reflects [RouteMatch]s that are not [ImperativeRouteMatch].
  final Uri uri;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// An exception if there was an error during matching.
  final GoException? error;

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
  static String _generateFullPath(Iterable<RouteMatchBase> matches) {
    String fullPath = '';
    for (final RouteMatchBase match in matches
        .where((RouteMatchBase match) => match is! ImperativeRouteMatch)) {
      final String pathSegment;
      if (match is RouteMatch) {
        pathSegment = match.route.path;
      } else if (match is ShellRouteMatch) {
        pathSegment = _generateFullPath(match.matches);
      } else {
        assert(false, 'Unexpected match type: $match');
        continue;
      }
      fullPath = concatenatePaths(fullPath, pathSegment);
    }
    return fullPath;
  }

  /// Returns true if there are no matches.
  bool get isEmpty => matches.isEmpty;

  /// Returns true if there are matches.
  bool get isNotEmpty => matches.isNotEmpty;

  /// Returns a new instance of RouteMatchList with the input `match` pushed
  /// onto the current instance.
  RouteMatchList push(ImperativeRouteMatch match) {
    if (match.matches.isError) {
      return copyWith(matches: <RouteMatchBase>[...matches, match]);
    }
    return copyWith(
      matches: _createNewMatchUntilIncompatible(
        matches,
        match.matches.matches,
        match,
      ),
    );
  }

  static List<RouteMatchBase> _createNewMatchUntilIncompatible(
    List<RouteMatchBase> currentMatches,
    List<RouteMatchBase> otherMatches,
    ImperativeRouteMatch match,
  ) {
    final List<RouteMatchBase> newMatches = currentMatches.toList();
    if (otherMatches.last is ShellRouteMatch &&
        newMatches.isNotEmpty &&
        otherMatches.last.route == newMatches.last.route) {
      assert(newMatches.last is ShellRouteMatch);
      final ShellRouteMatch lastShellRouteMatch =
          newMatches.removeLast() as ShellRouteMatch;
      newMatches.add(
        // Create a new copy of the `lastShellRouteMatch`.
        lastShellRouteMatch.copyWith(
          matches: _createNewMatchUntilIncompatible(lastShellRouteMatch.matches,
              (otherMatches.last as ShellRouteMatch).matches, match),
        ),
      );
      return newMatches;
    }
    newMatches
        .add(_cloneBranchAndInsertImperativeMatch(otherMatches.last, match));
    return newMatches;
  }

  static RouteMatchBase _cloneBranchAndInsertImperativeMatch(
      RouteMatchBase branch, ImperativeRouteMatch match) {
    if (branch is ShellRouteMatch) {
      return branch.copyWith(
        matches: <RouteMatchBase>[
          _cloneBranchAndInsertImperativeMatch(branch.matches.last, match),
        ],
      );
    }
    // Add the input `match` instead of the incompatibleMatch since it contains
    // page key and push future.
    assert(branch.route == match.route);
    return match;
  }

  /// Returns a new instance of RouteMatchList with the input `match` removed
  /// from the current instance.
  RouteMatchList remove(RouteMatchBase match) {
    final List<RouteMatchBase> newMatches =
        _removeRouteMatchFromList(matches, match);
    if (newMatches == matches) {
      return this;
    }

    final String fullPath = _generateFullPath(newMatches);
    if (this.fullPath == fullPath) {
      return copyWith(
        matches: newMatches,
      );
    }
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
    return copyWith(
      matches: newMatches,
      uri: newUri,
      pathParameters: newPathParameters,
    );
  }

  /// Returns a new List from the input matches with target removed.
  ///
  /// This method recursively looks into any ShellRouteMatch in matches and
  /// removes target if it found a match in the match list nested in
  /// ShellRouteMatch.
  ///
  /// This method returns a new list as long as the target is found in the
  /// matches' subtree.
  ///
  /// If a target is found, the target and every node after the target in tree
  /// order is removed.
  static List<RouteMatchBase> _removeRouteMatchFromList(
      List<RouteMatchBase> matches, RouteMatchBase target) {
    // Remove is caused by pop; therefore, start searching from the end.
    for (int index = matches.length - 1; index >= 0; index -= 1) {
      final RouteMatchBase match = matches[index];
      if (match == target) {
        // Remove any redirect only route immediately before the target.
        while (index > 0) {
          final RouteMatchBase lookBefore = matches[index - 1];
          if (lookBefore is! RouteMatch || !lookBefore.route.redirectOnly) {
            break;
          }
          index -= 1;
        }
        return matches.sublist(0, index);
      }
      if (match is ShellRouteMatch) {
        final List<RouteMatchBase> newSubMatches =
            _removeRouteMatchFromList(match.matches, target);
        if (newSubMatches == match.matches) {
          // Didn't find target in the newSubMatches.
          continue;
        }
        // Removes `match` if its sub match list become empty after the remove.
        return <RouteMatchBase>[
          ...matches.sublist(0, index),
          if (newSubMatches.isNotEmpty) match.copyWith(matches: newSubMatches),
        ];
      }
    }
    // Target is not in the match subtree.
    return matches;
  }

  /// The last leaf route.
  ///
  /// If the last RouteMatchBase from [matches] is a ShellRouteMatch, it
  /// recursively goes into its [ShellRouteMatch.matches] until it reach the leaf
  /// [RouteMatch].
  ///
  /// Throws a [StateError] if [matches] is empty.
  RouteMatch get last {
    if (matches.last is RouteMatch) {
      return matches.last as RouteMatch;
    }
    return (matches.last as ShellRouteMatch)._lastLeaf;
  }

  /// The last leaf route or null if [matches] is empty
  ///
  /// If the last RouteMatchBase from [matches] is a ShellRouteMatch, it
  /// recursively goes into its [ShellRouteMatch.matches] until it reach the leaf
  /// [RouteMatch].
  RouteMatch? get lastOrNull {
    if (matches.isEmpty) {
      return null;
    }
    return last;
  }

  /// Returns true if the current match intends to display an error screen.
  bool get isError => error != null;

  /// The routes for each of the matches.
  List<RouteBase> get routes {
    final List<RouteBase> result = <RouteBase>[];
    visitRouteMatches((RouteMatchBase match) {
      result.add(match.route);
      return true;
    });
    return result;
  }

  /// Traverse route matches in this match list in preorder until visitor
  /// returns false.
  ///
  /// This method visit recursively into shell route matches.
  @internal
  void visitRouteMatches(RouteMatchVisitor visitor) {
    _visitRouteMatches(matches, visitor);
  }

  static bool _visitRouteMatches(
      List<RouteMatchBase> matches, RouteMatchVisitor visitor) {
    for (final RouteMatchBase routeMatch in matches) {
      if (!visitor(routeMatch)) {
        return false;
      }
      if (routeMatch is ShellRouteMatch &&
          !_visitRouteMatches(routeMatch.matches, visitor)) {
        return false;
      }
    }
    return true;
  }

  /// Create a new [RouteMatchList] with given parameter replaced.
  @internal
  RouteMatchList copyWith({
    List<RouteMatchBase>? matches,
    Uri? uri,
    Map<String, String>? pathParameters,
  }) {
    return RouteMatchList(
        matches: matches ?? this.matches,
        uri: uri ?? this.uri,
        extra: extra,
        error: error,
        pathParameters: pathParameters ?? this.pathParameters);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RouteMatchList &&
        uri == other.uri &&
        extra == other.extra &&
        error == other.error &&
        const ListEquality<RouteMatchBase>().equals(matches, other.matches) &&
        const MapEquality<String, String>()
            .equals(pathParameters, other.pathParameters);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(matches),
      uri,
      extra,
      error,
      Object.hashAllUnordered(
        pathParameters.entries.map<int>((MapEntry<String, String> entry) =>
            Object.hash(entry.key, entry.value)),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Uri>('uri', uri));
    properties
        .add(DiagnosticsProperty<List<RouteMatchBase>>('matches', matches));
  }
}

/// Handles encoding and decoding of [RouteMatchList] objects to a format
/// suitable for using with [StandardMessageCodec].
///
/// The primary use of this class is for state restoration and browser history.
@internal
class RouteMatchListCodec extends Codec<RouteMatchList, Map<Object?, Object?>> {
  /// Creates a new [RouteMatchListCodec] object.
  RouteMatchListCodec(RouteConfiguration configuration)
      : decoder = _RouteMatchListDecoder(configuration),
        encoder = _RouteMatchListEncoder(configuration);

  static const String _locationKey = 'location';
  static const String _extraKey = 'state';
  static const String _imperativeMatchesKey = 'imperativeMatches';
  static const String _pageKey = 'pageKey';
  static const String _codecKey = 'codec';
  static const String _jsonCodecName = 'json';
  static const String _customCodecName = 'custom';
  static const String _encodedKey = 'encoded';

  @override
  final Converter<RouteMatchList, Map<Object?, Object?>> encoder;

  @override
  final Converter<Map<Object?, Object?>, RouteMatchList> decoder;
}

class _RouteMatchListEncoder
    extends Converter<RouteMatchList, Map<Object?, Object?>> {
  const _RouteMatchListEncoder(this.configuration);

  final RouteConfiguration configuration;
  @override
  Map<Object?, Object?> convert(RouteMatchList input) {
    final List<ImperativeRouteMatch> imperativeMatches =
        <ImperativeRouteMatch>[];
    input.visitRouteMatches((RouteMatchBase match) {
      if (match is ImperativeRouteMatch) {
        imperativeMatches.add(match);
      }
      return true;
    });
    final List<Map<Object?, Object?>> encodedImperativeMatches =
        imperativeMatches
            .map((ImperativeRouteMatch e) => _toPrimitives(
                e.matches.uri.toString(), e.matches.extra,
                pageKey: e.pageKey.value))
            .toList();

    return _toPrimitives(input.uri.toString(), input.extra,
        imperativeMatches: encodedImperativeMatches);
  }

  Map<Object?, Object?> _toPrimitives(String location, Object? extra,
      {List<Map<Object?, Object?>>? imperativeMatches, String? pageKey}) {
    Map<String, Object?> encodedExtra;
    if (configuration.extraCodec != null) {
      encodedExtra = <String, Object?>{
        RouteMatchListCodec._codecKey: RouteMatchListCodec._customCodecName,
        RouteMatchListCodec._encodedKey:
            configuration.extraCodec?.encode(extra),
      };
    } else {
      String jsonEncodedExtra;
      try {
        jsonEncodedExtra = json.encoder.convert(extra);
      } on JsonUnsupportedObjectError {
        jsonEncodedExtra = json.encoder.convert(null);
        log(
            'An extra with complex data type ${extra.runtimeType} is provided '
            'without a codec. Consider provide a codec to GoRouter to '
            'prevent extra being dropped during serialization.',
            level: Level.WARNING);
      }
      encodedExtra = <String, Object?>{
        RouteMatchListCodec._codecKey: RouteMatchListCodec._jsonCodecName,
        RouteMatchListCodec._encodedKey: jsonEncodedExtra,
      };
    }

    return <Object?, Object?>{
      RouteMatchListCodec._locationKey: location,
      RouteMatchListCodec._extraKey: encodedExtra,
      if (imperativeMatches != null)
        RouteMatchListCodec._imperativeMatchesKey: imperativeMatches,
      if (pageKey != null) RouteMatchListCodec._pageKey: pageKey,
    };
  }
}

class _RouteMatchListDecoder
    extends Converter<Map<Object?, Object?>, RouteMatchList> {
  _RouteMatchListDecoder(this.configuration);

  final RouteConfiguration configuration;

  @override
  RouteMatchList convert(Map<Object?, Object?> input) {
    final String rootLocation =
        input[RouteMatchListCodec._locationKey]! as String;
    final Map<Object?, Object?> encodedExtra =
        input[RouteMatchListCodec._extraKey]! as Map<Object?, Object?>;
    final Object? extra;

    if (encodedExtra[RouteMatchListCodec._codecKey] ==
        RouteMatchListCodec._jsonCodecName) {
      extra = json.decoder
          .convert(encodedExtra[RouteMatchListCodec._encodedKey]! as String);
    } else {
      extra = configuration.extraCodec
          ?.decode(encodedExtra[RouteMatchListCodec._encodedKey]);
    }
    RouteMatchList matchList =
        configuration.findMatch(Uri.parse(rootLocation), extra: extra);

    final List<Object?>? imperativeMatches =
        input[RouteMatchListCodec._imperativeMatchesKey] as List<Object?>?;
    if (imperativeMatches != null) {
      for (final Map<Object?, Object?> encodedImperativeMatch
          in imperativeMatches.whereType<Map<Object?, Object?>>()) {
        final RouteMatchList imperativeMatchList =
            convert(encodedImperativeMatch);
        final ValueKey<String> pageKey = ValueKey<String>(
            encodedImperativeMatch[RouteMatchListCodec._pageKey]! as String);
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
