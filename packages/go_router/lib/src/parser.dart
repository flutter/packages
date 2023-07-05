// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';
import 'configuration.dart';
import 'information_provider.dart';
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
    required this.onParserException,
  }) : _routeMatchListCodec = RouteMatchListCodec(configuration);

  /// The route configuration used for parsing [RouteInformation]s.
  final RouteConfiguration configuration;

  /// The exception handler that is called when parser can't handle the incoming
  /// uri.
  ///
  /// This method must return a [RouteMatchList] for the parsed result.
  final ParserExceptionHandler? onParserException;

  final RouteMatchListCodec _routeMatchListCodec;

  final Random _random = Random();

  /// The future of current route parsing.
  ///
  /// This is used for testing asynchronous redirection.
  @visibleForTesting
  Future<RouteMatchList>? debugParserFuture;

  /// Called by the [Router]. The
  @override
  Future<RouteMatchList> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) {
    assert(routeInformation.state != null);
    final Object state = routeInformation.state!;

    if (state is! RouteInformationState) {
      // This is a result of browser backward/forward button or state
      // restoration. In this case, the route match list is already stored in
      // the state.
      final RouteMatchList matchList =
          _routeMatchListCodec.decode(state as Map<Object?, Object?>);
      return debugParserFuture = _redirect(context, matchList)
          .then<RouteMatchList>((RouteMatchList value) {
        if (value.isError && onParserException != null) {
          return onParserException!(context, value);
        }
        return value;
      });
    }

    late final RouteMatchList initialMatches;
    initialMatches =
        // TODO(chunhtai): remove this ignore and migrate the code
        // https://github.com/flutter/flutter/issues/124045.
        // ignore: deprecated_member_use, unnecessary_non_null_assertion
        configuration.findMatch(routeInformation.location!, extra: state.extra);
    if (initialMatches.isError) {
      // TODO(chunhtai): remove this ignore and migrate the code
      // https://github.com/flutter/flutter/issues/124045.
      // ignore: deprecated_member_use
      log.info('No initial matches: ${routeInformation.location}');
    }

    return debugParserFuture = _redirect(
      context,
      initialMatches,
    ).then<RouteMatchList>((RouteMatchList matchList) {
      if (matchList.isError && onParserException != null) {
        return onParserException!(context, matchList);
      }
      return _updateRouteMatchList(
        matchList,
        baseRouteMatchList: state.baseRouteMatchList,
        completer: state.completer,
        type: state.type,
      );
    });
  }

  @override
  Future<RouteMatchList> parseRouteInformation(
      RouteInformation routeInformation) {
    throw UnimplementedError(
        'use parseRouteInformationWithDependencies instead');
  }

  /// for use by the Router architecture as part of the RouteInformationParser
  @override
  RouteInformation? restoreRouteInformation(RouteMatchList configuration) {
    if (configuration.isEmpty) {
      return null;
    }
    if (GoRouter.optionURLReflectsImperativeAPIs &&
        configuration.matches.last is ImperativeRouteMatch) {
      configuration =
          (configuration.matches.last as ImperativeRouteMatch).matches;
    }
    return RouteInformation(
      // TODO(chunhtai): remove this ignore and migrate the code
      // https://github.com/flutter/flutter/issues/124045.
      // ignore: deprecated_member_use
      location: configuration.uri.toString(),
      state: _routeMatchListCodec.encode(configuration),
    );
  }

  Future<RouteMatchList> _redirect(
      BuildContext context, RouteMatchList routeMatch) {
    final FutureOr<RouteMatchList> redirectedFuture = configuration
        .redirect(context, routeMatch, redirectHistory: <RouteMatchList>[]);
    if (redirectedFuture is RouteMatchList) {
      return SynchronousFuture<RouteMatchList>(redirectedFuture);
    }
    return redirectedFuture;
  }

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
        return baseRouteMatchList.remove(routeMatch).push(
              ImperativeRouteMatch(
                pageKey: _getUniqueValueKey(),
                completer: completer!,
                matches: newMatchList,
              ),
            );
      case NavigatingType.replace:
        final RouteMatch routeMatch = baseRouteMatchList!.last;
        return baseRouteMatchList.remove(routeMatch).push(
              ImperativeRouteMatch(
                pageKey: routeMatch.pageKey,
                completer: completer!,
                matches: newMatchList,
              ),
            );
      case NavigatingType.go:
        return newMatchList;
    }
  }

  ValueKey<String> _getUniqueValueKey() {
    return ValueKey<String>(String.fromCharCodes(
        List<int>.generate(32, (_) => _random.nextInt(33) + 89)));
  }
}
