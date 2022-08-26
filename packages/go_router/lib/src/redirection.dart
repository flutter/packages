// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'configuration.dart';
import 'logging.dart';
import 'match.dart';
import 'matching.dart';

/// A GoRouter redirector function.
// TODO(johnpryan): make redirector async
// See https://github.com/flutter/flutter/issues/105808
typedef RouteRedirector = RouteMatchList Function(RouteMatchList matches,
    RouteConfiguration configuration, RouteMatcher matcher,
    {Object? extra});

/// Processes redirects by returning a new [RouteMatchList] representing the new
/// location.
RouteMatchList redirect(RouteMatchList prevMatchList,
    RouteConfiguration configuration, RouteMatcher matcher,
    {Object? extra}) {
  RouteMatchList matches;

  // Store each redirect to detect loops
  final List<RouteMatchList> redirects = <RouteMatchList>[prevMatchList];

  // Keep looping until redirecting is done
  while (true) {
    final RouteMatchList currentMatches = redirects.last;

    // Check for top-level redirect
    final Uri uri = currentMatches.location;
    final String? topRedirectLocation = configuration.topRedirect(
      GoRouterState(
        configuration,
        location: currentMatches.location.toString(),
        name: null,
        // No name available at the top level trim the query params off the
        // sub-location to match route.redirect
        subloc: uri.path,
        queryParams: uri.queryParameters,
        queryParametersAll: uri.queryParametersAll,
        extra: extra,
      ),
    );

    if (topRedirectLocation != null) {
      final RouteMatchList newMatch = matcher.findMatch(topRedirectLocation);
      _addRedirect(redirects, newMatch, prevMatchList.location,
          configuration.redirectLimit);
      continue;
    }

    // If there's no top-level redirect, keep the matches the same as before.
    matches = currentMatches;

    // Merge new params to keep params from previously matched paths, e.g.
    // /users/:userId/book/:bookId provides userId and bookId to book/:bookId
    Map<String, String> previouslyMatchedParams = <String, String>{};
    for (final RouteMatch match in currentMatches.matches) {
      assert(
        !previouslyMatchedParams.keys.any(match.encodedParams.containsKey),
        'Duplicated parameter names',
      );
      match.encodedParams.addAll(previouslyMatchedParams);
      previouslyMatchedParams = match.encodedParams;
    }

    // check top route for redirect
    final RouteMatch? top = matches.isNotEmpty ? matches.last : null;
    if (top == null) {
      break;
    }
    final String? topRouteLocation = top.route.redirect(
      GoRouterState(
        configuration,
        location: currentMatches.location.toString(),
        subloc: top.subloc,
        name: top.route.name,
        path: top.route.path,
        fullpath: top.fullpath,
        extra: top.extra,
        params: top.decodedParams,
        queryParams: top.queryParams,
        queryParametersAll: top.queryParametersAll,
      ),
    );

    if (topRouteLocation == null) {
      break;
    }

    final RouteMatchList newMatchList = matcher.findMatch(topRouteLocation);
    _addRedirect(redirects, newMatchList, prevMatchList.location,
        configuration.redirectLimit);
    continue;
  }
  return matches;
}

/// A configuration error detected while processing redirects.
class RedirectionError extends Error implements UnsupportedError {
  /// RedirectionError constructor.
  RedirectionError(this.message, this.matches, this.location);

  /// The matches that were found while processing redirects.
  final List<RouteMatchList> matches;

  @override
  final String message;

  /// The location that was originally navigated to, before redirection began.
  final Uri location;

  @override
  String toString() => '${super.toString()} ${<String>[
        ...matches.map(
            (RouteMatchList routeMatches) => routeMatches.location.toString()),
      ].join(' => ')}';
}

/// Adds the redirect to [redirects] if it is valid.
void _addRedirect(List<RouteMatchList> redirects, RouteMatchList newMatch,
    Uri prevLocation, int redirectLimit) {
  // Verify that the redirect can be parsed and is not already
  // in the list of redirects
  assert(() {
    if (redirects.contains(newMatch)) {
      throw RedirectionError('redirect loop detected',
          <RouteMatchList>[...redirects, newMatch], prevLocation);
    }
    if (redirects.length > redirectLimit) {
      throw RedirectionError('too many redirects',
          <RouteMatchList>[...redirects, newMatch], prevLocation);
    }
    return true;
  }());

  redirects.add(newMatch);

  assert(() {
    log.info('redirecting to $newMatch');
    return true;
  }());
}
