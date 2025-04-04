// on_enter.dart
// ignore_for_file: use_build_context_synchronously
// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';

/// Handles the `onEnter` callback logic and redirection history for GoRouter.
///
/// This class encapsulates the logic to execute the top-level `onEnter`
/// callback, track redirection history, enforce the redirection limit,
/// and generate an error match list when the limit is exceeded.
class OnEnterHandler {
  /// Creates an [OnEnterHandler] instance.
  ///
  /// [configuration] is the route configuration.
  /// [router] is used to access GoRouter methods.
  /// [onParserException] is the exception handler for the parser.
  OnEnterHandler({
    required RouteConfiguration configuration,
    required GoRouter router,
    required ParserExceptionHandler? onParserException,
  })  : _onParserException = onParserException,
        _configuration = configuration,
        _router = router;

  /// The route configuration for the current router.
  ///
  /// This object contains all the route definitions, redirection logic, and other
  /// navigation settings. It is used to determine which routes match the incoming
  /// URI and to build the corresponding navigation state.
  final RouteConfiguration _configuration;

  /// Optional exception handler for route parsing errors.
  ///
  /// When an error occurs during route parsing (e.g., when the onEnter redirection
  /// limit is exceeded), this handler is invoked with the current [BuildContext]
  /// and a [RouteMatchList] that contains the error details. It must conform to the
  /// [ParserExceptionHandler] typedef and is responsible for returning a fallback
  /// [RouteMatchList].
  final ParserExceptionHandler? _onParserException;

  /// The [GoRouter] instance used to perform navigation actions.
  ///
  /// This instance provides access to various navigation methods and serves as a
  /// fallback when the [BuildContext] does not have an inherited GoRouter. It is
  /// essential for executing onEnter callbacks and handling redirections.
  final GoRouter _router;

  /// A history of URIs encountered during onEnter redirections.
  ///
  /// This list tracks each URI that triggers an onEnter redirection and is used to
  /// enforce the redirection limit defined in [RouteConfiguration.redirectLimit]. It
  /// helps prevent infinite redirection loops by generating an error if the limit is exceeded.
  final List<Uri> _redirectionHistory = <Uri>[];

  /// Executes the top-level `onEnter` callback and decides whether navigation
  /// should proceed.
  ///
  /// This method first checks for redirection errors via
  /// [_redirectionErrorMatchList]. If no error is found, it builds the current
  /// and next navigation states, executes the onEnter callback, and based on its
  /// result returns either [onCanEnter] or [onCanNotEnter].
  ///
  /// [context] is the BuildContext.
  /// [routeInformation] is the current RouteInformation.
  /// [infoState] is the state embedded in the RouteInformation.
  /// [lastMatchList] is the last successful match list (if any).
  /// [onCanEnter] is called when navigation is allowed.
  /// [onCanNotEnter] is called when navigation is blocked.
  ///
  /// Returns a Future that resolves to a [RouteMatchList].
  Future<RouteMatchList> handleTopOnEnter({
    required BuildContext context,
    required RouteInformation routeInformation,
    required RouteInformationState<dynamic> infoState,
    required RouteMatchList? lastMatchList,
    required Future<RouteMatchList> Function() onCanEnter,
    required Future<RouteMatchList> Function() onCanNotEnter,
  }) {
    final OnEnter? topOnEnter = _configuration.topOnEnter;
    // If no onEnter is configured, simply allow navigation.
    if (topOnEnter == null) {
      return onCanEnter();
    }

    // Check if the redirection history already exceeds the configured limit.
    final RouteMatchList? redirectionErrorMatchList =
        _redirectionErrorMatchList(context, routeInformation.uri, infoState);

    if (redirectionErrorMatchList != null) {
      // Return immediately if the redirection limit is exceeded.
      return SynchronousFuture<RouteMatchList>(redirectionErrorMatchList);
    }

    // Build route matches for the incoming URI.
    final RouteMatchList incomingMatches = _configuration.findMatch(
      routeInformation.uri,
      extra: infoState.extra,
    );

    // Build the next navigation state.
    final GoRouterState nextState =
        _configuration.buildTopLevelGoRouterState(incomingMatches);
    // Use the last successful state if available.
    final GoRouterState currentState = lastMatchList != null
        ? _configuration.buildTopLevelGoRouterState(lastMatchList)
        : nextState;

    // Execute the onEnter callback and get a Future<bool> result.
    final Future<bool> canEnterFuture = topOnEnter(
      context,
      currentState,
      nextState,
      _router,
    );
    // Reset history after attempting the callback.
    _resetRedirectionHistory();
    // Return the appropriate match list based on whether navigation is allowed.
    return canEnterFuture.then(
      (bool canEnter) => canEnter ? onCanEnter() : onCanNotEnter(),
    );
  }

  /// Processes the redirection history and checks for redirection limits.
  ///
  /// Adds [redirectedUri] to the redirection history. If the number of redirections
  /// exceeds [_configuration.redirectLimit], returns an error match list.
  /// Otherwise, returns null.
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
      // Use onParserException if available to process the error match list.
      return _onParserException != null
          ? _onParserException(context, errorMatchList)
          : errorMatchList;
    }
    return null;
  }

  /// Resets the onEnter redirection history.
  void _resetRedirectionHistory() {
    _redirectionHistory.clear();
  }

  /// Formats the redirection history as a string for error messages.
  String _formatOnEnterRedirectionHistory(List<Uri> history) {
    return history.map((Uri uri) => uri.toString()).join(' => ');
  }

  /// Creates an error match list for a given [uri] and [exception].
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
