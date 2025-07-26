// ignore_for_file: use_build_context_synchronously

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'information_provider.dart';
import 'match.dart';
import 'misc/errors.dart';
import 'parser.dart';
import 'router.dart';
import 'state.dart';

/// The result of an [onEnter] callback.
///
/// This sealed class represents the possible outcomes of navigation interception.
sealed class OnEnterResult {
  /// Creates an [OnEnterResult].
  const OnEnterResult();
}

/// Allows the navigation to proceed.
final class Allow extends OnEnterResult {
  /// Creates an [Allow] result.
  const Allow();
}

/// Blocks the navigation from proceeding.
final class Block extends OnEnterResult {
  /// Creates a [Block] result.
  const Block();
}

/// The signature for the top-level [onEnter] callback.
///
/// This callback receives the [BuildContext], the current navigation state,
/// the state being navigated to, and a reference to the [GoRouter] instance.
/// It returns a [Future<OnEnterResult>] which should resolve to [Allow] if navigation
/// is allowed, or [Block] to block navigation.
typedef OnEnter = Future<OnEnterResult> Function(
  BuildContext context,
  GoRouterState currentState,
  GoRouterState nextState,
  GoRouter goRouter,
);

/// Handles the top-level [onEnter] callback logic and manages redirection history.
///
/// This class encapsulates the logic to execute the top-level [onEnter] callback,
/// enforce the redirection limit defined in the router configuration, and generate
/// an error match list when the limit is exceeded. It is used internally by [GoRouter]
/// during route parsing.
class OnEnterHandler {
  /// Creates an [OnEnterHandler] instance.
  ///
  /// * [configuration] is the current route configuration containing all route definitions.
  /// * [router] is the [GoRouter] instance used for navigation actions.
  /// * [onParserException] is an optional exception handler invoked on route parsing errors.
  OnEnterHandler({
    required RouteConfiguration configuration,
    required GoRouter router,
    required ParserExceptionHandler? onParserException,
  })  : _onParserException = onParserException,
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
    required RouteInformationState<dynamic> infoState,
    required Future<RouteMatchList> Function() onCanEnter,
    required Future<RouteMatchList> Function() onCanNotEnter,
  }) {
    final OnEnter? topOnEnter = _configuration.topOnEnter;
    // If no onEnter is configured, allow navigation immediately.
    if (topOnEnter == null) {
      return onCanEnter();
    }

    // Check if the redirection history exceeds the configured limit.
    final RouteMatchList? redirectionErrorMatchList =
        _redirectionErrorMatchList(context, routeInformation.uri, infoState);

    if (redirectionErrorMatchList != null) {
      // Return immediately if the redirection limit is exceeded.
      return SynchronousFuture<RouteMatchList>(redirectionErrorMatchList);
    }

    // Find route matches for the incoming URI.
    final RouteMatchList incomingMatches = _configuration.findMatch(
      routeInformation.uri,
      extra: infoState.extra,
    );

    // Build the next navigation state.
    final GoRouterState nextState =
        _buildTopLevelGoRouterState(incomingMatches);

    // Get the current state from the router delegate.
    final RouteMatchList currentMatchList =
        _router.routerDelegate.currentConfiguration;
    final GoRouterState currentState = currentMatchList.isNotEmpty
        ? _buildTopLevelGoRouterState(currentMatchList)
        : nextState;

    // Execute the onEnter callback in a try-catch to capture synchronous exceptions.
    Future<OnEnterResult> onEnterResultFuture;
    try {
      onEnterResultFuture = topOnEnter(
        context,
        currentState,
        nextState,
        _router,
      );
    } catch (error) {
      final RouteMatchList errorMatchList = _errorRouteMatchList(
        routeInformation.uri,
        error is GoException ? error : GoException(error.toString()),
        extra: infoState.extra,
      );

      _resetRedirectionHistory();

      return SynchronousFuture<RouteMatchList>(_onParserException != null
          ? _onParserException(context, errorMatchList)
          : errorMatchList);
    }

    // Reset the redirection history after attempting the callback.
    _resetRedirectionHistory();

    // Handle asynchronous completion and catch any errors.
    return onEnterResultFuture.then<RouteMatchList>(
      (OnEnterResult result) {
        if (result is Allow) {
          return onCanEnter();
        } else if (result is Block) {
          return onCanNotEnter();
        } else {
          // This should never happen with a sealed class, but provide a fallback
          throw GoException(
              'Invalid OnEnterResult type: ${result.runtimeType}');
        }
      },
      onError: (Object error, StackTrace stackTrace) {
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
    RouteInformationState<dynamic> infoState,
  ) {
    _redirectionHistory.add(redirectedUri);
    if (_redirectionHistory.length > _configuration.redirectLimit) {
      final String formattedHistory =
          _formatOnEnterRedirectionHistory(_redirectionHistory);
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
