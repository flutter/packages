// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: use_build_context_synchronously
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
typedef ParserExceptionHandler =
    RouteMatchList Function(
      BuildContext context,
      RouteMatchList routeMatchList,
    );

/// The function signature for navigation callbacks in [_OnEnterHandler].
typedef NavigationCallback = Future<RouteMatchList> Function();

/// Type alias for route information state with dynamic type parameter.
typedef RouteInfoState = RouteInformationState<dynamic>;

/// Converts between incoming URLs and a [RouteMatchList] using [RouteMatcher].
///
/// Also integrates the top-level `onEnter` guard and then performs legacy
/// top-level redirect (if any) followed by route-level redirects. See order of
/// operations in `GoRouter` docs.
class GoRouteInformationParser extends RouteInformationParser<RouteMatchList> {
  /// Creates a [GoRouteInformationParser].
  GoRouteInformationParser({
    required this.configuration,
    required String? initialLocation,
    required GoRouter router,
    required this.onParserException,
  }) : _routeMatchListCodec = RouteMatchListCodec(configuration),
       _initialLocation = initialLocation,
       _onEnterHandler = _OnEnterHandler(
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

  /// Instance of [_OnEnterHandler] to process top-level onEnter logic.
  final _OnEnterHandler _onEnterHandler;

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

    // If we're restoring (pop/back or restoring a branch stack), skip onEnter
    // but still run legacy + route-level redirects so state can be updated.
    if (infoState is RouteInformationState &&
        infoState.type == NavigatingType.restore) {
      final RouteMatchList restored = infoState.baseRouteMatchList!;
      return debugParserFuture = _redirect(context, restored).then((
        RouteMatchList value,
      ) {
        if (value.isError && onParserException != null) {
          return onParserException!(context, value);
        }
        _lastMatchList = value;
        return value;
      });
    }

    // Process legacy state if necessary.
    if (infoState is! RouteInformationState) {
      // This is a result of browser backward/forward button or state
      // restoration. In this case, the route match list is already stored in
      // the state. Run redirects to allow state updates.
      final RouteMatchList matchList = _routeMatchListCodec.decode(
        infoState as Map<Object?, Object?>,
      );
      return debugParserFuture = _redirect(context, matchList).then((
        RouteMatchList value,
      ) {
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
      onCanEnter: () => _navigate(routeInformation, context, infoState),
      onCanNotEnter: () {
        // If navigation is blocked, return the last successful match or empty.
        if (_lastMatchList != null) {
          return SynchronousFuture<RouteMatchList>(_lastMatchList!);
        } else {
          return SynchronousFuture<RouteMatchList>(RouteMatchList.empty);
        }
      },
    );
  }

  /// Normalizes the URI, finds matching routes, processes redirects, and updates
  /// the route match list based on the navigation type.
  ///
  /// This method is called ONLY AFTER onEnter has allowed the navigation.
  /// It includes the deprecated redirect logic.
  Future<RouteMatchList> _navigate(
    RouteInformation routeInformation,
    BuildContext context,
    RouteInfoState infoState,
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

    // Process the deprecated redirect AFTER onEnter has allowed navigation
    return debugParserFuture = _redirect(context, initialMatches).then((
      RouteMatchList matchList,
    ) {
      if (matchList.isError && onParserException != null) {
        return onParserException!(context, matchList);
      }

      // Validate that redirect-only routes actually perform a redirection.
      assert(() {
        if (matchList.isNotEmpty) {
          assert(
            !matchList.last.route.redirectOnly,
            'A redirect-only route must redirect to location different from itself.\n The offending route: ${matchList.last.route}',
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
    RouteInformation routeInformation,
  ) {
    // Not used in go_router; instruct users to use parseRouteInformationWithDependencies.
    throw UnimplementedError(
      'Use parseRouteInformationWithDependencies instead',
    );
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
    BuildContext context,
    RouteMatchList routeMatch,
  ) {
    final FutureOr<RouteMatchList> redirectedFuture = configuration.redirect(
      context,
      routeMatch,
      redirectHistory: <RouteMatchList>[],
    );
    if (redirectedFuture is RouteMatchList) {
      return SynchronousFuture<RouteMatchList>(redirectedFuture);
    }
    return redirectedFuture;
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

/// Handles the top-level [onEnter] callback logic and manages redirection history.
///
/// This class encapsulates the logic to execute the top-level [onEnter] callback,
/// enforce the redirection limit defined in the router configuration, and generate
/// an error match list when the limit is exceeded. It is used internally by [GoRouter]
/// during route parsing.
class _OnEnterHandler {
  /// Creates an [_OnEnterHandler] instance.
  ///
  /// * [configuration] is the current route configuration containing all route definitions.
  /// * [router] is the [GoRouter] instance used for navigation actions.
  /// * [onParserException] is an optional exception handler invoked on route parsing errors.
  _OnEnterHandler({
    required RouteConfiguration configuration,
    required GoRouter router,
    required ParserExceptionHandler? onParserException,
  }) : _onParserException = onParserException,
       _configuration = configuration,
       _router = router;

  /// The current route configuration.
  ///
  /// Contains all route definitions, redirection logic, and navigation settings.
  final RouteConfiguration _configuration;

  /// Optional exception handler for route parsing errors.
  ///
  /// This handler is invoked when errors occur during route parsing (for example,
  /// when the [onEnter] redirection limit is exceeded) to return a fallback [RouteMatchList].
  final ParserExceptionHandler? _onParserException;

  /// The [GoRouter] instance used to perform navigation actions.
  ///
  /// This provides access to the imperative navigation methods (like [go], [push],
  /// [replace], etc.) and serves as a fallback reference in case the [BuildContext]
  /// does not include a [GoRouter].
  final GoRouter _router;

  /// A history of URIs encountered during [onEnter] redirections.
  ///
  /// This list tracks every URI that triggers an [onEnter] redirection, ensuring that
  /// the number of redirections does not exceed the limit defined in the router's configuration.
  final List<Uri> _redirectionHistory = <Uri>[];

  /// Executes the top-level [onEnter] callback and determines whether navigation should proceed.
  ///
  /// It checks for redirection errors by verifying if the redirection history exceeds the
  /// configured limit. If everything is within limits, this method builds the current and
  /// next navigation states, then executes the [onEnter] callback.
  ///
  /// * If [onEnter] returns [Allow], the [onCanEnter] callback is invoked to allow navigation.
  /// * If [onEnter] returns [Block], the [onCanNotEnter] callback is invoked to block navigation.
  ///
  /// Exceptions thrown synchronously or asynchronously by [onEnter] are caught and processed
  /// via the [_onParserException] handler if available.
  ///
  /// Returns a [Future<RouteMatchList>] representing the final navigation state.
  Future<RouteMatchList> handleTopOnEnter({
    required BuildContext context,
    required RouteInformation routeInformation,
    required RouteInfoState infoState,
    required NavigationCallback onCanEnter,
    required NavigationCallback onCanNotEnter,
  }) {
    final OnEnter? topOnEnter = _configuration.topOnEnter;
    // If no onEnter is configured, allow navigation immediately.
    if (topOnEnter == null) {
      return onCanEnter();
    }

    // Normalize the incoming URI (match what _navigate() does)
    Uri normalizedUri = routeInformation.uri;
    if (normalizedUri.hasEmptyPath) {
      normalizedUri = normalizedUri.replace(path: '/');
    } else if (normalizedUri.path.length > 1 &&
        normalizedUri.path.endsWith('/')) {
      normalizedUri = normalizedUri.replace(
        path: normalizedUri.path.substring(0, normalizedUri.path.length - 1),
      );
    }

    // Check if the redirection history exceeds the configured limit.
    final RouteMatchList? redirectionErrorMatchList =
        _redirectionErrorMatchList(context, normalizedUri, infoState);

    if (redirectionErrorMatchList != null) {
      // Return immediately if the redirection limit is exceeded.
      return SynchronousFuture<RouteMatchList>(redirectionErrorMatchList);
    }

    // Find route matches for the normalized URI.
    final RouteMatchList incomingMatches = _configuration.findMatch(
      normalizedUri,
      extra: infoState.extra,
    );

    // Build the next navigation state.
    final GoRouterState nextState = _buildTopLevelGoRouterState(
      incomingMatches,
    );

    // Get the current state from the router delegate.
    final RouteMatchList currentMatchList =
        _router.routerDelegate.currentConfiguration;
    final GoRouterState currentState =
        currentMatchList.isNotEmpty
            ? _buildTopLevelGoRouterState(currentMatchList)
            : nextState;

    // Execute the onEnter callback in a try-catch to capture synchronous exceptions.
    Future<OnEnterResult> onEnterResultFuture;
    try {
      final FutureOr<OnEnterResult> result = topOnEnter(
        context,
        currentState,
        nextState,
        _router,
      );
      // Convert FutureOr to Future
      onEnterResultFuture =
          result is OnEnterResult
              ? SynchronousFuture<OnEnterResult>(result)
              : result;
    } catch (error) {
      final RouteMatchList errorMatchList = _errorRouteMatchList(
        routeInformation.uri,
        error is GoException ? error : GoException(error.toString()),
        extra: infoState.extra,
      );

      _resetRedirectionHistory();

      return SynchronousFuture<RouteMatchList>(
        _onParserException != null
            ? _onParserException(context, errorMatchList)
            : errorMatchList,
      );
    }

    // Handle asynchronous completion and catch any errors.
    return onEnterResultFuture.then<RouteMatchList>(
      (OnEnterResult result) async {
        RouteMatchList matchList;
        final FutureOr<void> Function()? callback = result.then;

        if (result is Allow) {
          matchList = await onCanEnter();
          _resetRedirectionHistory(); // reset after committed navigation
        } else {
          // Block: check if this is a hard stop or chaining block
          log(
            'onEnter blocked navigation from ${currentState.uri} to ${nextState.uri}',
          );
          matchList = await onCanNotEnter();

          // Hard stop (no then callback): reset history so user retries don't trigger limit
          final bool hardStop = result is Block && callback == null;
          if (hardStop) {
            _resetRedirectionHistory();
          }
          // For chaining blocks (with then), keep history to detect loops
        }

        if (callback != null) {
          unawaited(
            Future<void>.microtask(callback).catchError((
              Object error,
              StackTrace stack,
            ) {
              // Log error but don't crash - navigation already committed
              log('Error in then callback: $error');
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: error,
                  stack: stack,
                  library: 'go_router',
                  context: ErrorDescription('while executing then callback'),
                ),
              );
            }),
          );
        }

        return matchList;
      },
      onError: (Object error, StackTrace stackTrace) {
        // Reset history on error to prevent stale state
        _resetRedirectionHistory();

        final RouteMatchList errorMatchList = _errorRouteMatchList(
          routeInformation.uri,
          error is GoException ? error : GoException(error.toString()),
          extra: infoState.extra,
        );

        return _onParserException != null
            ? _onParserException(context, errorMatchList)
            : errorMatchList;
      },
    );
  }

  /// Builds a [GoRouterState] based on the given [matchList].
  ///
  /// This method derives the effective URI, full path, path parameters, and extra data from
  /// the topmost route match, drilling down through nested shells if necessary.
  ///
  /// Returns a constructed [GoRouterState] reflecting the current or next navigation state.
  GoRouterState _buildTopLevelGoRouterState(RouteMatchList matchList) {
    // Determine effective navigation state from the match list.
    Uri effectiveUri = matchList.uri;
    String? effectiveFullPath = matchList.fullPath;
    Map<String, String> effectivePathParams = matchList.pathParameters;
    String effectiveMatchedLocation = matchList.uri.path;
    Object? effectiveExtra = matchList.extra; // Base extra

    if (matchList.matches.isNotEmpty) {
      RouteMatchBase lastMatch = matchList.matches.last;
      // Drill down to the actual leaf match even inside shell routes.
      while (lastMatch is ShellRouteMatch) {
        if (lastMatch.matches.isEmpty) {
          break;
        }
        lastMatch = lastMatch.matches.last;
      }

      if (lastMatch is ImperativeRouteMatch) {
        // Use state from the imperative match.
        effectiveUri = lastMatch.matches.uri;
        effectiveFullPath = lastMatch.matches.fullPath;
        effectivePathParams = lastMatch.matches.pathParameters;
        effectiveMatchedLocation = lastMatch.matches.uri.path;
        effectiveExtra = lastMatch.matches.extra;
      } else {
        // For non-imperative matches, use the matched location and extra from the match list.
        effectiveMatchedLocation = lastMatch.matchedLocation;
        effectiveExtra = matchList.extra;
      }
    }

    return GoRouterState(
      _configuration,
      uri: effectiveUri,
      matchedLocation: effectiveMatchedLocation,
      name: matchList.lastOrNull?.route.name,
      path: matchList.lastOrNull?.route.path,
      fullPath: effectiveFullPath,
      pathParameters: effectivePathParams,
      extra: effectiveExtra,
      pageKey: const ValueKey<String>('topLevel'),
      topRoute: matchList.lastOrNull?.route,
      error: matchList.error,
    );
  }

  /// Processes the redirection history and checks against the configured redirection limit.
  ///
  /// Adds [redirectedUri] to the history and, if the limit is exceeded, returns an error
  /// match list. Otherwise, returns null.
  RouteMatchList? _redirectionErrorMatchList(
    BuildContext context,
    Uri redirectedUri,
    RouteInfoState infoState,
  ) {
    _redirectionHistory.add(redirectedUri);
    if (_redirectionHistory.length > _configuration.redirectLimit) {
      final String formattedHistory = _formatOnEnterRedirectionHistory(
        _redirectionHistory,
      );
      final RouteMatchList errorMatchList = _errorRouteMatchList(
        redirectedUri,
        GoException('Too many onEnter calls detected: $formattedHistory'),
        extra: infoState.extra,
      );
      _resetRedirectionHistory();
      return _onParserException != null
          ? _onParserException(context, errorMatchList)
          : errorMatchList;
    }
    return null;
  }

  /// Clears the redirection history.
  void _resetRedirectionHistory() {
    _redirectionHistory.clear();
  }

  /// Formats the redirection history into a string for error reporting.
  String _formatOnEnterRedirectionHistory(List<Uri> history) {
    return history.map((Uri uri) => uri.toString()).join(' => ');
  }

  /// Creates an error [RouteMatchList] for the given [uri] and [exception].
  ///
  /// This is used to encapsulate errors encountered during redirection or parsing.
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
}
