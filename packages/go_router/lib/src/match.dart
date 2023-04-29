// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'matching.dart';
import 'path_utils.dart';
import 'route.dart';

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
    if (route is ShellRoute) {
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
    throw MatcherError('Unexpected route type: $route', remainingLocation);
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
class ImperativeRouteMatch<T> extends RouteMatch {
  /// Constructor for [ImperativeRouteMatch].
  ImperativeRouteMatch({
    required super.route,
    required super.matchedLocation,
    required super.extra,
    required super.error,
    required super.pageKey,
    required this.matches,
  }) : _completer = Completer<T?>();

  /// The matches that produces this route match.
  final RouteMatchList matches;

  /// The completer for the future returned by [GoRouter.push].
  final Completer<T?> _completer;

  /// Called when the corresponding [Route] associated with this route match is
  /// completed.
  void complete([dynamic value]) {
    _completer.complete(value as T?);
  }

  /// The future of the [RouteMatch] completer.
  /// When the future completes, this will return the value passed to [complete].
  Future<T?> get future => _completer.future;

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
