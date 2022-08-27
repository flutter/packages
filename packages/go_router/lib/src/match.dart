// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'path_utils.dart';
import 'route.dart';

/// Each RouteMatch instance represents an instance of a GoRoute for a specific
/// portion of a location.
class RouteMatch {
  /// Constructor for [RouteMatch], each instance represents an instance of a
  /// [GoRoute] for a specific portion of a location.
  RouteMatch({
    required this.route,
    required this.subloc,
    required this.fullpath,
    required this.encodedParams,
    required this.queryParams,
    required this.queryParametersAll,
    required this.extra,
    required this.error,
    this.pageKey,
  })  : fullUriString = _addQueryParams(subloc, queryParametersAll),
        assert(subloc.startsWith('/')),
        assert(Uri.parse(subloc).queryParameters.isEmpty),
        assert(fullpath.startsWith('/')),
        assert(Uri.parse(fullpath).queryParameters.isEmpty),
        assert(() {
          for (final MapEntry<String, String> p in encodedParams.entries) {
            assert(p.value == Uri.encodeComponent(Uri.decodeComponent(p.value)),
                'encodedParams[${p.key}] is not encoded properly: "${p.value}"');
          }
          return true;
        }());

  // ignore: public_member_api_docs
  static RouteMatch? match({
    required GoRoute route,
    required String restLoc, // e.g. person/p1
    required String parentSubloc, // e.g. /family/f2
    required String fullpath, // e.g. /family/:fid/person/:pid
    required Map<String, String> queryParams,
    required Map<String, List<String>> queryParametersAll,
    required Object? extra,
  }) {
    assert(!route.path.contains('//'));

    final RegExpMatch? match = route.matchPatternAsPrefix(restLoc);
    if (match == null) {
      return null;
    }

    final Map<String, String> encodedParams = route.extractPathParams(match);
    final String pathLoc = patternToPath(route.path, encodedParams);
    final String subloc = concatenatePaths(parentSubloc, pathLoc);
    return RouteMatch(
      route: route,
      subloc: subloc,
      fullpath: fullpath,
      encodedParams: encodedParams,
      queryParams: queryParams,
      queryParametersAll: queryParametersAll,
      extra: extra,
      error: null,
    );
  }

  /// The matched route.
  final GoRoute route;

  /// Matched sub-location.
  final String subloc; // e.g. /family/f2

  /// Matched full path.
  final String fullpath; // e.g. /family/:fid

  /// Parameters for the matched route, URI-encoded.
  final Map<String, String> encodedParams;

  /// The URI query split into a map according to the rules specified for FORM
  /// post in the [HTML 4.01 specification section
  /// 17.13.4](https://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4
  /// "HTML 4.01 section 17.13.4").
  ///
  /// If a key occurs more than once in the query string, it is mapped to an
  /// arbitrary choice of possible value.
  ///
  /// If the request is `a/b/?q1=v1&q2=v2&q2=v3`, then [queryParameter] will be
  /// `{q1: 'v1', q2: 'v2'}`.
  ///
  /// See also
  /// * [queryParametersAll] that can provide a map that maps keys to all of
  ///   their values.
  final Map<String, String> queryParams;

  /// Returns the URI query split into a map according to the rules specified
  /// for FORM post in the [HTML 4.01 specification section
  /// 17.13.4](https://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4
  /// "HTML 4.01 section 17.13.4").
  ///
  /// Keys are mapped to lists of their values. If a key occurs only once, its
  /// value is a singleton list. If a key occurs with no value, the empty string
  /// is used as the value for that occurrence.
  ///
  /// If the request is `a/b/?q1=v1&q2=v2&q2=v3`, then [queryParameterAll] with
  /// be `{q1: ['v1'], q2: ['v2', 'v3']}`.
  final Map<String, List<String>> queryParametersAll;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// An exception if there was an error during matching.
  final Exception? error;

  /// Optional value key of type string, to hold a unique reference to a page.
  final ValueKey<String>? pageKey;

  /// The full uri string
  final String fullUriString; // e.g. /family/12?query=14

  static String _addQueryParams(
      String loc, Map<String, dynamic> queryParametersAll) {
    final Uri uri = Uri.parse(loc);
    assert(uri.queryParameters.isEmpty);
    return Uri(
            path: uri.path,
            queryParameters:
                queryParametersAll.isEmpty ? null : queryParametersAll)
        .toString();
  }

  /// Parameters for the matched route, URI-decoded.
  Map<String, String> get decodedParams => <String, String>{
        for (final MapEntry<String, String> param in encodedParams.entries)
          param.key: Uri.decodeComponent(param.value)
      };

  /// For use by the Router architecture as part of the RouteMatch
  @override
  String toString() => 'RouteMatch($fullpath, $encodedParams)';
}
