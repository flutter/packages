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
    required GoRouter router,
    required this.onParserException,
  })  : _router = router,
        _routeMatchListCodec = RouteMatchListCodec(configuration),
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

  /// The fallback [GoRouter] instance used during route information parsing.
  ///
  /// During initial app launch or deep linking, route parsing may occur before the
  /// [InheritedGoRouter] is built in the widget tree. This makes [GoRouter.of] or
  /// [GoRouter.maybeOf] unavailable through [BuildContext].
  ///
  /// When route parsing happens in these early stages, [_router] ensures that
  /// navigation APIs remain accessible to features like [OnEnter], which may need to
  /// perform navigation before the widget tree is fully built.
  ///
  /// This is used internally by [GoRouter] to pass its own instance as
  /// the fallback. You typically don't need to provide this when constructing a
  /// [GoRouteInformationParser] directly.
  ///
  /// See also:
  ///  * [parseRouteInformationWithDependencies], which uses this fallback router
  ///    when [BuildContext]-based router access is unavailable.
  final GoRouter _router;

  /// The future of current route parsing.
  ///
  /// This is used for testing asynchronous redirection.
  @visibleForTesting
  Future<RouteMatchList>? debugParserFuture;

  final Random _random = Random();

  // Processes an onEnter navigation attempt. Returns an updated RouteMatchList.
  // This is where the onEnter navigation logic happens.
  // 1. Setting the Stage:
  //    We figure out the current and next states using the matchList and any previous successful match.
  // 2. Calling onEnter:
  //    We call topOnEnter. It decides if navigation can happen. If yes, we update the match and return it.
  // 3. The Safety Net (Last Successful Match):
  //    If navigation is blocked and we have a previous successful match, we go back to that.
  //    This provides a safe fallback (e.g., /) to prevent loops.
  // 4. Loop Check:
  //    If there's no previous match, we check for loops. If the current URI is in the
  //    history, we're in a loop. Throw a GoException.
  // 5. Redirection Limit:
  //    We check we haven't redirected too many times.
  // 6. The Fallback (Initial Location):
  //   If not looping, and not over the redirect limit, go back to the start (initial location,
  //    usually /). We don't recurse. This treats places like / as final destinations,
  //   not part of a loop.
  // This method avoids infinite loops but ensures we end up somewhere valid. Handling fallbacks
  // like / prevents false loop detections and unnecessary recursion. It's about smooth,
  // reliable navigation.
  Future<RouteMatchList> _processOnEnter(
    BuildContext context,
    RouteMatchList matchList,
    List<RouteMatchList> onEnterHistory,
  ) async {
    // Build states for onEnter
    final GoRouterState nextState =
        configuration.buildTopLevelGoRouterState(matchList);
    final GoRouterState currentState = _lastMatchList != null
        ? configuration.buildTopLevelGoRouterState(_lastMatchList!)
        : nextState;

    // Invoke the onEnter callback
    final bool canEnter = await configuration.topOnEnter!(
      context,
      currentState,
      nextState,
      _router,
    );

    // If navigation is allowed, update and return immediately
    if (canEnter) {
      _lastMatchList = matchList;
      return _updateRouteMatchList(
        matchList,
        baseRouteMatchList: matchList,
        completer: null,
        type: NavigatingType.go,
      );
    }

    // If we have a last successful match, use it as fallback WITHOUT recursion
    if (_lastMatchList != null) {
      return _updateRouteMatchList(
        _lastMatchList!,
        baseRouteMatchList: matchList,
        completer: null,
        type: NavigatingType.go,
      );
    }

    // Check for loops
    if (onEnterHistory.length > 1 &&
        onEnterHistory.any((RouteMatchList m) => m.uri == matchList.uri)) {
      throw GoException(
        'onEnter redirect loop detected: ${onEnterHistory.map((RouteMatchList m) => m.uri).join(' => ')} => ${matchList.uri}',
      );
    }

    // Check redirect limit before continuing
    if (onEnterHistory.length >= configuration.redirectLimit) {
      throw GoException(
        'Too many onEnter redirects: ${onEnterHistory.map((RouteMatchList m) => m.uri).join(' => ')}',
      );
    }

    // Add current match to history
    onEnterHistory.add(matchList);

    // Try initial location as fallback WITHOUT recursion
    final RouteMatchList fallbackMatches = configuration.findMatch(
      Uri.parse(_initialLocation ?? '/'),
      extra: matchList.extra,
    );

    return _updateRouteMatchList(
      fallbackMatches,
      baseRouteMatchList: matchList,
      completer: null,
      type: NavigatingType.go,
    );
  }

  /// Parses route information and handles navigation decisions based on various states and callbacks.
  /// This is called by the [Router] when a new route needs to be processed, such as during deep linking,
  /// browser navigation, or in-app navigation.
  @override
  Future<RouteMatchList> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) {
    // 1) Safety check
    if (routeInformation.state == null) {
      return SynchronousFuture<RouteMatchList>(RouteMatchList.empty);
    }

    final Object infoState = routeInformation.state!;

    // 2) Handle restored navigation
    if (infoState is! RouteInformationState) {
      final RouteMatchList matchList =
          _routeMatchListCodec.decode(infoState as Map<Object?, Object?>);

      return debugParserFuture =
          _redirect(context, matchList).then((RouteMatchList value) {
        if (value.isError && onParserException != null) {
          return onParserException!(context, value);
        }
        _lastMatchList = value;
        return value;
      });
    }

    // 3) Normalize the URI first
    Uri uri = routeInformation.uri;
    if (uri.hasEmptyPath) {
      uri = uri.replace(path: '/');
    } else if (uri.path.length > 1 && uri.path.endsWith('/')) {
      uri = uri.replace(path: uri.path.substring(0, uri.path.length - 1));
    }

    // Find initial matches for the normalized URI
    final RouteMatchList initialMatches = configuration.findMatch(
      uri,
      extra: infoState.extra,
    );

    // 4) Handle route interception via onEnter callback
    if (configuration.topOnEnter != null) {
      // Call _processOnEnter and immediately return its result
      return _processOnEnter(
        context,
        initialMatches,
        <RouteMatchList>[initialMatches], // Start history with initial match
      );
    }

    // 5) If onEnter isn't used or throws, continue with redirect processing
    if (initialMatches.isError) {
      log('No initial matches: ${routeInformation.uri.path}');
    }

    // 6) Process any redirects defined in the route configuration
    // Routes might need to redirect based on auth state or other conditions
    return debugParserFuture =
        _redirect(context, initialMatches).then((RouteMatchList matchList) {
      // Handle any errors during route matching/redirection
      if (matchList.isError && onParserException != null) {
        return onParserException!(context, matchList);
      }

      // 7) Development-time check for redirect-only routes
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

      // 8) Handle specific navigation types (push, replace, etc.)
      // Different navigation actions need different route stack manipulations
      final RouteMatchList updated = _updateRouteMatchList(
        matchList,
        baseRouteMatchList: infoState.baseRouteMatchList,
        completer: infoState.completer,
        type: infoState.type,
      );

      // 9) Cache this successful route match for future reference
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
