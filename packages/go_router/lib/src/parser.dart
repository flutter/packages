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

  /// Tracks the URIs of onEnter redirections.
  final List<Uri> _onEnterRedirectionHistory = <Uri>[];

  /// Checks if the top-level onEnter callback allows navigation.
  /// Returns true if allowed; otherwise, false.
  /// If onEnter is null, navigation is always allowed.
  Future<bool> _handleTopOnEnter(
    BuildContext context,
    RouteInformation routeInformation,
    RouteInformationState<dynamic> infoState,
  ) {
    final OnEnter? topOnEnter = configuration.topOnEnter;
    if (topOnEnter == null) {
      return SynchronousFuture<bool>(true);
    }

    // Build route matches for the incoming URI.
    final RouteMatchList incomingMatches = configuration.findMatch(
      routeInformation.uri,
      extra: infoState.extra,
    );

    // Construct navigation states.
    final GoRouterState nextState =
        configuration.buildTopLevelGoRouterState(incomingMatches);
    final GoRouterState currentState = _lastMatchList != null
        ? configuration.buildTopLevelGoRouterState(_lastMatchList!)
        : nextState;

    // Execute the onEnter callback.
    final FutureOr<bool> result = topOnEnter(
      context,
      currentState,
      nextState,
      GoRouter.maybeOf(context) ?? _router,
    );

    // Wrap immediate results in a SynchronousFuture.
    return (result is bool)
        ? SynchronousFuture<bool>(result)
        : Future<bool>.value(result);
  }

  /// Parses route information and determines the navigation outcome.
  /// Handles both legacy (non-RouteInformationState) and current route states.
  @override
  Future<RouteMatchList> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) {
    // Safety check
    if (routeInformation.state == null) {
      return SynchronousFuture<RouteMatchList>(RouteMatchList.empty);
    }

    final Object infoState = routeInformation.state!;
    if (infoState is! RouteInformationState) {
      // Decode the legacy state and apply redirects.
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

    // handle redirection limit
    if (configuration.topOnEnter != null) {
      // A redirection is being triggered via onEnter.
      _onEnterRedirectionHistory.add(routeInformation.uri);
      if (_onEnterRedirectionHistory.length > configuration.redirectLimit) {
        final String formattedHistory =
            _formatOnEnterRedirectionHistory(_onEnterRedirectionHistory);

        final RouteMatchList errorMatchList = _errorRouteMatchList(
          routeInformation.uri,
          GoException('Too many onEnter calls detected: $formattedHistory'),
        );

        _onEnterRedirectionHistory.clear();
        return SynchronousFuture<RouteMatchList>(
          onParserException != null
              ? onParserException!(context, errorMatchList)
              : errorMatchList,
        );
      }
    }

    // Use onEnter to decide if navigation should proceed.
    final Future<bool> canEnterFuture = _handleTopOnEnter(
      context,
      routeInformation,
      infoState,
    );

    return canEnterFuture.then(
      (bool canEnter) {
        _onEnterRedirectionHistory.clear();
        if (!canEnter) {
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
        } else {
          // Navigation allowed: clear redirection history.
          return _navigate(routeInformation, context, infoState);
        }
      },
    );
  }

  /// The match used when there is an error during parsing.
  static RouteMatchList _errorRouteMatchList(
    Uri uri,
    GoException exception, {
    Object? extra,
  }) {
    return RouteMatchList(
      matches: const <RouteMatch>[],
      extra: extra,
      error: exception,
      uri: uri,
      pathParameters: const <String, String>{},
    );
  }

  /// Formats the redirection history for error messages.
  String _formatOnEnterRedirectionHistory(List<Uri> history) {
    return history.map((Uri uri) => uri.toString()).join(' => ');
  }

  /// Normalizes the URI, finds matching routes, processes redirects,
  /// and updates the route match list based on the navigation type.
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

      // Ensure that redirect-only routes actually perform a redirection.
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

      // Update the route match list according to the navigation type (push, replace, etc.).
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
