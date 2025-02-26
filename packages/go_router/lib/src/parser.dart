// go_route_information_parser.dart
// ignore_for_file: use_build_context_synchronously
// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';
import 'logging.dart';
import 'match.dart';
import 'on_enter.dart';

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
///
/// Also performs redirection using [RouteRedirector] and integrates the top-level
/// onEnter logic via [OnEnterHandler].
class GoRouteInformationParser extends RouteInformationParser<RouteMatchList> {
  /// Creates a [GoRouteInformationParser].
  GoRouteInformationParser({
    required this.configuration,
    required String? initialLocation,
    required GoRouter router,
    required this.onParserException,
  })  : _routeMatchListCodec = RouteMatchListCodec(configuration),
        _initialLocation = initialLocation,
        _onEnterHandler = OnEnterHandler(
          configuration: configuration,
          router: router,
          onParserException: onParserException,
        );

  /// The route configuration used for parsing [RouteInformation]s.
  final RouteConfiguration configuration;

  /// Exception handler for parser errors.
  final ParserExceptionHandler? onParserException;

  final RouteMatchListCodec _routeMatchListCodec;

  final String? _initialLocation;

  /// Stores the last successful match list to enable "stay" on the same route.
  RouteMatchList? _lastMatchList;

  /// Instance of [OnEnterHandler] to process top-level onEnter logic.
  final OnEnterHandler _onEnterHandler;

  /// The future of current route parsing (used for testing asynchronous redirection).
  @visibleForTesting
  Future<RouteMatchList>? debugParserFuture;

  final Random _random = Random();

  @override
  Future<RouteMatchList> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) {
    // Safety check: if no state is provided, return an empty match list.
    if (routeInformation.state == null) {
      return SynchronousFuture<RouteMatchList>(RouteMatchList.empty);
    }

    final Object infoState = routeInformation.state!;
    // Process legacy state if necessary.
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

    return _onEnterHandler.handleTopOnEnter(
      context: context,
      routeInformation: routeInformation,
      infoState: infoState,
      lastMatchList: _lastMatchList,
      onCanEnter: () => _navigate(routeInformation, context, infoState),
      onCanNotEnter: () {
        // If navigation is blocked, return the last successful match or a fallback.
        if (_lastMatchList != null) {
          return SynchronousFuture<RouteMatchList>(_lastMatchList!);
        } else {
          final Uri defaultUri = Uri.parse(_initialLocation ?? '/');
          final RouteMatchList fallbackMatches = configuration.findMatch(
            defaultUri,
            extra: infoState.extra,
          );
          _lastMatchList = fallbackMatches;
          return SynchronousFuture<RouteMatchList>(fallbackMatches);
        }
      },
    );
  }

  /// Normalizes the URI, finds matching routes, processes redirects, and updates
  /// the route match list based on the navigation type.
  Future<RouteMatchList> _navigate(
    RouteInformation routeInformation,
    BuildContext context,
    RouteInformationState<dynamic> infoState,
  ) {
    // Normalize the URI: ensure it has a valid path and remove trailing slashes.
    Uri uri = routeInformation.uri;
    if (uri.hasEmptyPath) {
      uri = uri.replace(path: '/');
    } else if (uri.path.length > 1 && uri.path.endsWith('/')) {
      uri = uri.replace(path: uri.path.substring(0, uri.path.length - 1));
    }

    // Find initial route matches.
    final RouteMatchList initialMatches = configuration.findMatch(
      uri,
      extra: infoState.extra,
    );
    if (initialMatches.isError) {
      log('No initial matches: ${routeInformation.uri.path}');
    }

    // Process any defined redirects.
    return debugParserFuture =
        _redirect(context, initialMatches).then((RouteMatchList matchList) {
      if (matchList.isError && onParserException != null) {
        return onParserException!(context, matchList);
      }

      // Validate that redirect-only routes actually perform a redirection.
      assert(() {
        if (matchList.isNotEmpty) {
          assert(
            !matchList.last.route.redirectOnly,
            'Redirect-only route must redirect to a new location.\n'
            'Offending route: ${matchList.last.route}',
          );
        }
        return true;
      }());

      // Update the route match list based on the navigation type.
      final RouteMatchList updated = _updateRouteMatchList(
        matchList,
        baseRouteMatchList: infoState.baseRouteMatchList,
        completer: infoState.completer,
        type: infoState.type,
      );

      // Cache the successful match list.
      _lastMatchList = updated;
      return updated;
    });
  }

  @override
  Future<RouteMatchList> parseRouteInformation(
      RouteInformation routeInformation) {
    // Not used in go_router; instruct users to use parseRouteInformationWithDependencies.
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
      // Drill down to find the appropriate ImperativeRouteMatch.
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

  /// Calls [configuration.redirect] and wraps the result in a synchronous future if needed.
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

  /// Updates the route match list based on the navigation type (push, replace, etc.).
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
        // If the URIs differ, use the new one; otherwise, keep the old.
        if (baseRouteMatchList!.uri.toString() != newMatchList.uri.toString()) {
          return newMatchList;
        } else {
          return baseRouteMatchList;
        }
    }
  }

  /// Returns a unique [ValueKey<String>] for a new route.
  ValueKey<String> _getUniqueValueKey() {
    return ValueKey<String>(
      String.fromCharCodes(
        List<int>.generate(32, (_) => _random.nextInt(33) + 89),
      ),
    );
  }
}
