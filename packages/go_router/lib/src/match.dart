// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/src/matching.dart';

import 'path_utils.dart';
import 'route.dart';

///  An instance of a GoRoute plus information about the current location.
class GoRouteMatch {
  /// Constructor for [GoRouteMatch].
  GoRouteMatch({
    required this.route,
    required this.location,
    required this.template,
    required this.encodedParams,
    required this.queryParams,
    required this.extra,
    required this.error,
    this.pageKey,
  })  : fullUriString = _addQueryParams(location, queryParams),
        assert(Uri.parse(location).queryParameters.isEmpty),
        assert(Uri.parse(template).queryParameters.isEmpty),
        assert(() {
          for (final MapEntry<String, String> p in encodedParams.entries) {
            assert(p.value == Uri.encodeComponent(Uri.decodeComponent(p.value)),
                'encodedParams[${p.key}] is not encoded properly: "${p.value}"');
          }
          return true;
        }());

  // ignore: public_member_api_docs
  static GoRouteMatch? match({
    required RouteBase route,
    required String restLoc, // e.g. person/p1
    required String parentSubloc, // e.g. /family/f2
    required String fullpath, // e.g. /family/:fid/person/:pid
    required Map<String, String> queryParams,
    required Object? extra,
  }) {
    if (route is ShellRoute) {
      return GoRouteMatch(
        route: route,
        location: restLoc,
        template: '',
        encodedParams: <String, String>{},
        queryParams: queryParams,
        extra: extra,
        error: null,
        // Provide a unique pageKey to ensure that the page for this ShellRoute is
        // reused.
        pageKey: ValueKey<String>(route.hashCode.toString()),
      );
    } else if (route is GoRoute) {
      assert(!route.path.contains('//'));

      final RegExpMatch? match = route.matchPatternAsPrefix(restLoc);
      if (match == null) {
        return null;
      }

      final Map<String, String> encodedParams = route.extractPathParams(match);
      final String pathLoc = patternToPath(route.path, encodedParams);
      final String subloc = concatenatePaths(parentSubloc, pathLoc);
      return GoRouteMatch(
        route: route,
        location: subloc,
        template: fullpath,
        encodedParams: encodedParams,
        queryParams: queryParams,
        extra: extra,
        error: null,
      );
    }
    throw MatcherError('Unexpected route type: $route', restLoc);
  }

  /// The matched route.
  final RouteBase route;

  /// The matched location.
  final String location; // e.g. /family/f2

  /// The matched template.
  final String template; // e.g. /family/:fid

  /// Parameters for the matched route, URI-encoded.
  final Map<String, String> encodedParams;

  /// Query parameters for the matched route.
  final Map<String, String> queryParams;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// An exception if there was an error during matching.
  final Exception? error;

  /// Optional value key of type string, to hold a unique reference to a page.
  final ValueKey<String>? pageKey;

  /// The full uri string
  final String fullUriString; // e.g. /family/12?query=14

  static String _addQueryParams(String loc, Map<String, String> queryParams) {
    final Uri uri = Uri.parse(loc);
    assert(uri.queryParameters.isEmpty);
    return Uri(
            path: uri.path,
            queryParameters: queryParams.isEmpty ? null : queryParams)
        .toString();
  }

  /// Parameters for the matched route, URI-decoded.
  Map<String, String> get decodedParams => <String, String>{
        for (final MapEntry<String, String> param in encodedParams.entries)
          param.key: Uri.decodeComponent(param.value)
      };

  /// For use by the Router architecture as part of the RouteMatch
  @override
  String toString() => 'RouteMatch($template, $encodedParams)';
}
