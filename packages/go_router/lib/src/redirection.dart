// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'configuration.dart';
import 'logging.dart';
import 'match.dart';
import 'matching.dart';

/// A GoRouter redirector function.
// TODO(johnpryan): make redirector async (#105808)
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

  // Adds the redirect to the list of redirects if it is valid.
  bool redirected(RouteMatchList newRedirect) {
    if (newRedirect == null) {
      return false;
    }

    // Verify that the redirect can be parsed and is not already
    // in the list of redirects
    assert(() {
      if (redirects.contains(newRedirect)) {
        throw RedirectionError(
            'redirect loop detected',
            <RouteMatchList>[...redirects, newRedirect],
            prevMatchList.location);
      }
      if (redirects.length > configuration.redirectLimit) {
        throw RedirectionError(
            'too many redirects',
            <RouteMatchList>[...redirects, newRedirect],
            prevMatchList.location);
      }
      return true;
    }());

    redirects.add(newRedirect);

    assert(() {
      log.info('redirecting to $newRedirect');
      return true;
    }());
    return true;
  }

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
        extra: extra,
      ),
    );

    // If the new location is null, keep the matches the same as before.
    if (topRedirectLocation != null) {
      final RouteMatchList newMatch = matcher.findMatch(topRedirectLocation);

      if (redirected(newMatch)) {
        continue;
      } else {
        matches = newMatch;
      }
    } else {
      matches = currentMatches;
    }

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
        params: top.decodedParams,
        queryParams: top.queryParams,
      ),
    );

    if (topRouteLocation == null) {
      break;
    }

    final RouteMatchList newMatchList = matcher.findMatch(topRouteLocation);
    if (redirected(newMatchList)) {
      continue;
    }

    break;
  }
  return matches;
}

/// A configuration error detected while processing redirects.
class RedirectionError extends Error implements UnsupportedError {
  /// RedirectionError constructor
  RedirectionError(this.message, this.matches, this.location);

  /// The matches that were found while processing redirects.
  final List<RouteMatchList> matches;

  @override
  final String message;

  /// The location that was originally navigated to, before redirection began.
  final Uri location;

  @override
  String toString() =>
      super.toString() +
      <String>[
        ...matches.map(
            (RouteMatchList routeMatches) => routeMatches.location.toString()),
      ].join(' => ');
}
