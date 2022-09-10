// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'information_provider.dart';
import 'logging.dart';
import 'match.dart';
import 'matching.dart';
import 'redirection.dart';

/// Converts between incoming URLs and a [RouteMatchList] using [RouteMatcher].
/// Also performs redirection using [RouteRedirector].
class GoRouteInformationParser extends RouteInformationParser<RouteMatchList> {
  /// Creates a [GoRouteInformationParser].
  GoRouteInformationParser({
    required this.configuration,
    this.debugRequireGoRouteInformationProvider = false,
  })  : matcher = RouteMatcher(configuration),
        redirector = redirect;

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// The route matcher.
  final RouteMatcher matcher;

  /// The route redirector.
  final RouteRedirector redirector;

  /// A debug property to assert [GoRouteInformationProvider] is in use along
  /// with this parser.
  ///
  /// An assertion error will be thrown if this property set to true and the
  /// [GoRouteInformationProvider] is not in use.
  ///
  /// Defaults to false.
  final bool debugRequireGoRouteInformationProvider;

  /// Called by the [Router]. The
  @override
  Future<RouteMatchList> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    assert(() {
      if (debugRequireGoRouteInformationProvider) {
        assert(
          routeInformation is DebugGoRouteInformation,
          'This GoRouteInformationParser needs to be used with '
          'GoRouteInformationProvider, did you forget to pass in '
          'GoRouter.routeInformationProvider to the Router constructor?',
        );
      }
      return true;
    }());
    try {
      late final RouteMatchList initialMatches;
      try {
        initialMatches = matcher.findMatch(routeInformation.location!,
            extra: routeInformation.state);
      } on MatcherError {
        log.info('No initial matches: ${routeInformation.location}');

        // If there is a matching error for the initial location, we should
        // still try to process the top-level redirects.
        initialMatches = RouteMatchList.empty();
      }
      final RouteMatchList matches = redirector(
          initialMatches, configuration, matcher,
          extra: routeInformation.state);
      if (matches.isEmpty) {
        return SynchronousFuture<RouteMatchList>(_errorScreen(
            Uri.parse(routeInformation.location!),
            MatcherError('no routes for location', routeInformation.location!)
                .toString()));
      }

      // Use [SynchronousFuture] so that the initial url is processed
      // synchronously and remove unwanted initial animations on deep-linking
      return SynchronousFuture<RouteMatchList>(matches);
    } on RedirectionError catch (e) {
      log.info('Redirection error: ${e.message}');
      final Uri uri = e.location;
      return SynchronousFuture<RouteMatchList>(_errorScreen(uri, e.message));
    } on MatcherError catch (e) {
      // The RouteRedirector uses the matcher to find the match, so a match
      // exception can happen during redirection. For example, the redirector
      // redirects from `/a` to `/b`, it needs to get the matches for `/b`.
      log.info('Match error: ${e.message}');
      final Uri uri = Uri.parse(e.location);
      return SynchronousFuture<RouteMatchList>(_errorScreen(uri, e.message));
    }
  }

  /// for use by the Router architecture as part of the RouteInformationParser
  @override
  RouteInformation restoreRouteInformation(RouteMatchList configuration) {
    return RouteInformation(
      location: configuration.location.toString(),
      state: configuration.extra,
    );
  }

  /// Creates a match that routes to the error page.
  RouteMatchList _errorScreen(Uri uri, String errorMessage) {
    final Exception error = Exception(errorMessage);
    return RouteMatchList(<RouteMatch>[
      RouteMatch(
        subloc: uri.path,
        fullpath: uri.path,
        encodedParams: <String, String>{},
        queryParams: uri.queryParameters,
        queryParametersAll: uri.queryParametersAll,
        extra: null,
        error: error,
        route: GoRoute(
          path: uri.toString(),
          pageBuilder: (BuildContext context, GoRouterState state) {
            throw UnimplementedError();
          },
        ),
      ),
    ]);
  }
}
