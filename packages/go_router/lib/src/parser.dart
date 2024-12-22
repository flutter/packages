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

  // Store the last successful match list so we can truly "stay" on the same route.
  RouteMatchList? _lastMatchList;

  /// The future of current route parsing.
  ///
  /// This is used for testing asynchronous redirection.
  @visibleForTesting
  Future<RouteMatchList>? debugParserFuture;

  final Random _random = Random();

  /// Called by the [Router]. The
  @override
  Future<RouteMatchList> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) {
    // 1) Defensive check: if we get a null state, just return empty (unlikely).
    if (routeInformation.state == null) {
      return SynchronousFuture<RouteMatchList>(RouteMatchList.empty);
    }

    final Object infoState = routeInformation.state!;

    // 2) If state is not RouteInformationState => typically browser nav or state restoration
    // => decode an existing match from the saved Map.
    if (infoState is! RouteInformationState) {
      final RouteMatchList matchList =
          _routeMatchListCodec.decode(infoState as Map<Object?, Object?>);

      return debugParserFuture =
          _redirect(context, matchList).then((RouteMatchList value) {
        if (value.isError && onParserException != null) {
          return onParserException!(context, value);
        }
        _lastMatchList = value; // store after success
        return value;
      });
    }

    // 3) If there's an `onEnter` callback, let's see if we want to short-circuit.
    //    (Note that .host.isNotEmpty check is optional — depends on your scenario.)

    if (configuration.onEnter != null) {
      final RouteMatchList onEnterMatches = configuration.findMatch(
        routeInformation.uri,
        extra: infoState.extra,
      );

      final GoRouterState state =
          configuration.buildTopLevelGoRouterState(onEnterMatches);

      final bool canEnter = configuration.onEnter!(
        context,
        state,
      );

      if (!canEnter) {
        // The user "handled" the deep link => do NOT navigate.
        // Return our *last known route* if possible.
        if (_lastMatchList != null) {
          return SynchronousFuture<RouteMatchList>(_lastMatchList!);
        } else {
          // Fallback if we've never parsed a route before:
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

    // 4) Otherwise, do normal route matching:
    Uri uri = routeInformation.uri;
    if (uri.hasEmptyPath) {
      uri = uri.replace(path: '/');
    } else if (uri.path.length > 1 && uri.path.endsWith('/')) {
      uri = uri.replace(path: uri.path.substring(0, uri.path.length - 1));
    }

    final RouteMatchList initialMatches = configuration.findMatch(
      uri,
      extra: infoState.extra,
    );
    if (initialMatches.isError) {
      log('No initial matches: ${routeInformation.uri.path}');
    }

    // 5) Possibly do a redirect:
    return debugParserFuture =
        _redirect(context, initialMatches).then((RouteMatchList matchList) {
      // If error, call parser exception if any
      if (matchList.isError && onParserException != null) {
        return onParserException!(context, matchList);
      }

      // 6) Check for redirect-only route leftover
      assert(() {
        if (matchList.isNotEmpty) {
          assert(
              !matchList.last.route.redirectOnly,
              'A redirect-only route must redirect to a different location.\n'
              'Offending route: ${matchList.last.route}');
        }
        return true;
      }());

      // 7) If it's a push/replace etc., handle that
      final RouteMatchList updated = _updateRouteMatchList(
        matchList,
        baseRouteMatchList: infoState.baseRouteMatchList,
        completer: infoState.completer,
        type: infoState.type,
      );

      // 8) Save as our "last known good" config
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
