// ignore_for_file: use_build_context_synchronously
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';
import 'logging.dart';
import 'match.dart';

/// The function signature of [GoRouteInformationParser.onParserException].
///
/// The `routeMatchList` parameter contains the exception explains the issue
/// occurred.
///
/// The returned [RouteMatchList] is used as parsed result for the
/// [GoRouterDelegate].
typedef ParserExceptionHandler = RouteMatchList Function(
  BuildContext context,
  RouteMatchList routeMatchList,
);

/// Converts between incoming URLs and a [RouteMatchList] using [RouteMatcher].
/// Also performs redirection using [RouteRedirector].
class GoRouteInformationParser extends RouteInformationParser<RouteMatchList> {
  /// Creates a [GoRouteInformationParser].
  GoRouteInformationParser({
    required this.configuration,
    required String? initialLocation,
    required this.onParserException,
  })  : _routeMatchListCodec = RouteMatchListCodec(configuration),
        _initialLocation = initialLocation;

  /// The route configuration used for parsing [RouteInformation]s.
  final RouteConfiguration configuration;

  /// The exception handler that is called when parser can't handle the incoming
  /// uri.
  ///
  /// This method must return a [RouteMatchList] for the parsed result.
  final ParserExceptionHandler? onParserException;

  final RouteMatchListCodec _routeMatchListCodec;

  final String? _initialLocation;

  /// Store the last successful match list so we can truly "stay" on the same route.
  RouteMatchList? _lastMatchList;

  /// The future of current route parsing.
  ///
  /// This is used for testing asynchronous redirection.
  @visibleForTesting
  Future<RouteMatchList>? debugParserFuture;

  final Random _random = Random();

  /// Parses route information and handles navigation decisions based on various states and callbacks.
  /// This is called by the [Router] when a new route needs to be processed, such as during deep linking,
  /// browser navigation, or in-app navigation.
  @override
  Future<RouteMatchList> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) {
    // 1) Safety check: routeInformation.state should never be null in normal operation,
    // but if it somehow is, return an empty route list rather than crashing.
    if (routeInformation.state == null) {
      return SynchronousFuture<RouteMatchList>(RouteMatchList.empty);
    }

    final Object infoState = routeInformation.state!;

    // 2) Handle restored or browser-initiated navigation
    // Browser navigation (back/forward) and state restoration don't create a RouteInformationState,
    // instead they provide a saved Map of the previous route state that needs to be decoded
    if (infoState is! RouteInformationState) {
      final RouteMatchList matchList =
          _routeMatchListCodec.decode(infoState as Map<Object?, Object?>);

      return debugParserFuture =
          _redirect(context, matchList).then((RouteMatchList value) {
        if (value.isError && onParserException != null) {
          return onParserException!(context, value);
        }
        _lastMatchList = value; // Cache successful route for future reference
        return value;
      });
    }

    // 3) Handle route interception via onEnter callback
    if (configuration.topOnEnter != null) {
      // Create route matches for the incoming navigation attempt
      final RouteMatchList onEnterMatches = configuration.findMatch(
        routeInformation.uri,
        extra: infoState.extra,
      );

      // Build states for the navigation decision
      // nextState: Where we're trying to go
      final GoRouterState nextState =
          configuration.buildTopLevelGoRouterState(onEnterMatches);

      // currentState: Where we are now (or nextState if this is initial launch)
      final GoRouterState currentState = _lastMatchList != null
          ? configuration.buildTopLevelGoRouterState(_lastMatchList!)
          : nextState;

      // Let the app decide if this navigation should proceed
      final bool canEnter = configuration.topOnEnter!(
        context,
        currentState,
        nextState,
      );

      // If navigation was intercepted (canEnter == false):
      if (!canEnter) {
        // Stay on current route if we have one
        if (_lastMatchList != null) {
          return SynchronousFuture<RouteMatchList>(_lastMatchList!);
        } else {
          // If no current route (e.g., app just launched), go to default location
          final Uri defaultUri = Uri.parse(_initialLocation ?? '/');
          final RouteMatchList fallbackMatches = configuration.findMatch(
            defaultUri,
            extra: infoState.extra,
          );
          _lastMatchList = fallbackMatches;
          return SynchronousFuture<RouteMatchList>(fallbackMatches);
        }
      }
    }

    // 4) Normalize the URI path
    // We want consistent route matching regardless of trailing slashes
    // - Empty paths become "/"
    // - Trailing slashes are removed (except for root "/")
    Uri uri = routeInformation.uri;
    if (uri.hasEmptyPath) {
      uri = uri.replace(path: '/');
    } else if (uri.path.length > 1 && uri.path.endsWith('/')) {
      uri = uri.replace(path: uri.path.substring(0, uri.path.length - 1));
    }

    // Find matching routes for the normalized URI
    final RouteMatchList initialMatches = configuration.findMatch(
      uri,
      extra: infoState.extra,
    );
    if (initialMatches.isError) {
      log('No initial matches: ${routeInformation.uri.path}');
    }

    // 5) Process any redirects defined in the route configuration
    // Routes might need to redirect based on auth state or other conditions
    return debugParserFuture =
        _redirect(context, initialMatches).then((RouteMatchList matchList) {
      // Handle any errors during route matching/redirection
      if (matchList.isError && onParserException != null) {
        return onParserException!(context, matchList);
      }

      // 6) Development-time check for redirect-only routes
      // Redirect-only routes must actually redirect somewhere else
      assert(() {
        if (matchList.isNotEmpty) {
          assert(
              !matchList.last.route.redirectOnly,
              'A redirect-only route must redirect to a different location.\n'
              'Offending route: ${matchList.last.route}');
        }
        return true;
      }());

      // 7) Handle specific navigation types (push, replace, etc.)
      // Different navigation actions need different route stack manipulations
      final RouteMatchList updated = _updateRouteMatchList(
        matchList,
        baseRouteMatchList: infoState.baseRouteMatchList,
        completer: infoState.completer,
        type: infoState.type,
      );

      // 8) Cache this successful route match for future reference
      // We need this for comparison in onEnter and fallback in navigation failure
      _lastMatchList = updated;
      return updated;
    });
  }

  @override
  Future<RouteMatchList> parseRouteInformation(
      RouteInformation routeInformation) {
    // Not used in go_router, so we can unimplement or throw:
    throw UnimplementedError(
        'Use parseRouteInformationWithDependencies instead');
  }

  @override
  RouteInformation? restoreRouteInformation(RouteMatchList configuration) {
    if (configuration.isEmpty) {
      return null;
    }
    String? location;
    if (GoRouter.optionURLReflectsImperativeAPIs &&
        (configuration.matches.last is ImperativeRouteMatch ||
            configuration.matches.last is ShellRouteMatch)) {
      RouteMatchBase route = configuration.matches.last;
      while (route is! ImperativeRouteMatch) {
        if (route is ShellRouteMatch && route.matches.isNotEmpty) {
          route = route.matches.last;
        } else {
          break;
        }
      }
      if (route case final ImperativeRouteMatch safeRoute) {
        location = safeRoute.matches.uri.toString();
      }
    }
    return RouteInformation(
      uri: Uri.parse(location ?? configuration.uri.toString()),
      state: _routeMatchListCodec.encode(configuration),
    );
  }

  // Just calls configuration.redirect, wrapped in synchronous future if needed.
  Future<RouteMatchList> _redirect(
      BuildContext context, RouteMatchList matchList) {
    final FutureOr<RouteMatchList> result = configuration.redirect(
      context,
      matchList,
      redirectHistory: <RouteMatchList>[],
    );
    if (result is RouteMatchList) {
      return SynchronousFuture<RouteMatchList>(result);
    }
    return result;
  }

  // If the user performed push/pushReplacement, etc., we might wrap newMatches
  // in ImperativeRouteMatches.
  RouteMatchList _updateRouteMatchList(
    RouteMatchList newMatchList, {
    required RouteMatchList? baseRouteMatchList,
    required Completer<Object?>? completer,
    required NavigatingType type,
  }) {
    switch (type) {
      case NavigatingType.push:
        return baseRouteMatchList!.push(
          ImperativeRouteMatch(
            pageKey: _getUniqueValueKey(),
            completer: completer!,
            matches: newMatchList,
          ),
        );
      case NavigatingType.pushReplacement:
        final RouteMatch routeMatch = baseRouteMatchList!.last;
        baseRouteMatchList = baseRouteMatchList.remove(routeMatch);
        if (baseRouteMatchList.isEmpty) {
          return newMatchList;
        }
        return baseRouteMatchList.push(
          ImperativeRouteMatch(
            pageKey: _getUniqueValueKey(),
            completer: completer!,
            matches: newMatchList,
          ),
        );
      case NavigatingType.replace:
        final RouteMatch routeMatch = baseRouteMatchList!.last;
        baseRouteMatchList = baseRouteMatchList.remove(routeMatch);
        if (baseRouteMatchList.isEmpty) {
          return newMatchList;
        }
        return baseRouteMatchList.push(
          ImperativeRouteMatch(
            pageKey: routeMatch.pageKey,
            completer: completer!,
            matches: newMatchList,
          ),
        );
      case NavigatingType.go:
        return newMatchList;
      case NavigatingType.restore:
        // If the URIs differ, we might want the new one; if they're the same,
        // keep the old.
        if (baseRouteMatchList!.uri.toString() != newMatchList.uri.toString()) {
          return newMatchList;
        } else {
          return baseRouteMatchList;
        }
    }
  }

  ValueKey<String> _getUniqueValueKey() {
    return ValueKey<String>(
      String.fromCharCodes(
        List<int>.generate(32, (_) => _random.nextInt(33) + 89),
      ),
    );
  }
}
