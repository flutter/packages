// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'matching.dart';
import 'path_utils.dart';
import 'route.dart';

///  An instance of a GoRoute plus information about the current location.
class RouteMatch {
  /// Constructor for [RouteMatch].
  RouteMatch({
    required this.route,
    required this.subloc,
    required this.extra,
    required this.error,
    required this.pageKey,
  });

  // ignore: public_member_api_docs
  static RouteMatch? match({
    required RouteBase route,
    required String restLoc, // e.g. person/p1
    required String parentSubloc, // e.g. /family/f2
    required Map<String, String> pathParameters,
    required Object? extra,
  }) {
    if (route is ShellRoute) {
      return RouteMatch(
        route: route,
        subloc: restLoc,
        extra: extra,
        error: null,
        pageKey: ValueKey<String>(route.hashCode.toString()),
      );
    } else if (route is GoRoute) {
      assert(!route.path.contains('//'));

      final RegExpMatch? match = route.matchPatternAsPrefix(restLoc);
      if (match == null) {
        return null;
      }

      final Map<String, String> encodedParams = route.extractPathParams(match);
      for (final MapEntry<String, String> param in encodedParams.entries) {
        pathParameters[param.key] = Uri.decodeComponent(param.value);
      }
      final String pathLoc = patternToPath(route.path, encodedParams);
      final String subloc = concatenatePaths(parentSubloc, pathLoc);
      return RouteMatch(
        route: route,
        subloc: subloc,
        extra: extra,
        error: null,
        pageKey: ValueKey<String>(route.hashCode.toString()),
      );
    }
    throw MatcherError('Unexpected route type: $route', restLoc);
  }

  /// Completes the promise returned by [GoRouter.push], allowing comunication
  /// between pages.
  ///
  /// If the promise has already been completed, this method does nothing.
  ///
  /// E.g.:
  /// ```dart
  /// final bool? result = await context.push<bool>('/page2');
  /// if(result ?? false){
  ///   // do something
  /// }
  /// ```
  /// When the page is popped, the promise is completed with the value passed,
  /// and the push method returns.
  /// to [Navigator.pop].
  /// ```dart
  /// context.pop(true);
  /// ```
  void complete([dynamic value]) {}

  /// Returns `true` if the promise returned by [GoRouter.push] has been completed.
  bool? didComplete() => null;

  /// The matched route.
  final RouteBase route;

  /// The matched location.
  final String subloc; // e.g. /family/f2

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// An exception if there was an error during matching.
  final Exception? error;

  /// Value key of type string, to hold a unique reference to a page.
  final ValueKey<String> pageKey;
}
