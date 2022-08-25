// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'builder.dart';
import 'configuration.dart';
import 'match.dart';
import 'matching.dart';
import 'typedefs.dart';

/// GoRouter implementation of [RouterDelegate].
class GoRouterDelegate extends RouterDelegate<RouteMatchList>
    with PopNavigatorRouterDelegateMixin<RouteMatchList>, ChangeNotifier {
  /// Constructor for GoRouter's implementation of the RouterDelegate base
  /// class.
  GoRouterDelegate({
    required RouteConfiguration configuration,
    required GoRouterBuilderWithNav builderWithNav,
    required GoRouterPageBuilder? errorPageBuilder,
    required GoRouterWidgetBuilder? errorBuilder,
    required List<NavigatorObserver> observers,
    required this.routerNeglect,
    String? restorationScopeId,
  })  : _configuration = configuration,
        builder = RouteBuilder(
          configuration: configuration,
          builderWithNav: builderWithNav,
          errorPageBuilder: errorPageBuilder,
          errorBuilder: errorBuilder,
          restorationScopeId: restorationScopeId,
          observers: observers,
        );

  /// Builds the top-level Navigator given a configuration and location.
  @visibleForTesting
  final RouteBuilder builder;

  /// Set to true to disable creating history entries on the web.
  final bool routerNeglect;

  RouteMatchList _matchList = RouteMatchList.empty();
  final Map<String, int> _pushCounts = <String, int>{};
  final RouteConfiguration _configuration;

  @override
  Future<bool> popRoute() {
    // Iterate backwards through the RouteMatchList until seeing a GoRoute
    // with a non-null parentNavigatorKey or a ShellRoute with a non-null parentNavigatorKey
    // and pop from that Navigator instead of the root.
    NavigatorState? navigator;
    final int matchCount = _matchList.matches.length;
    for (int i = matchCount - 1; i >= 0; i--) {
      final GoRouteMatch match = _matchList.matches[i];
      final RouteBase route = match.route;

      // If this is a ShellRoute, then pop one of the subsequent GoRoutes, if
      // there are any.
      if (route is ShellRoute && (matchCount - i) > 2) {
        // Pop from this navigator.
        navigator = route.navigatorKey.currentState;
        break;
      } else if (route is GoRoute && route.parentNavigatorKey != null) {
        navigator = route.parentNavigatorKey!.currentState;
        break;
      }
    }

    navigator ??= navigatorKey.currentState;

    if (navigator == null) {
      return SynchronousFuture<bool>(false);
    }

    return navigator.maybePop();
  }

  /// Pushes the given location onto the page stack
  void push(GoRouteMatch match) {
    if (match.route is ShellRoute) {
      throw GoError('ShellRoutes cannot be pushed');
    }

    // Remap the pageKey to allow any number of the same page on the stack
    final String fullPath = match.template;
    final int count = (_pushCounts[fullPath] ?? 0) + 1;
    _pushCounts[fullPath] = count;
    final ValueKey<String> pageKey = ValueKey<String>('$fullPath-p$count');
    final GoRouteMatch newPageKeyMatch = GoRouteMatch(
      route: match.route,
      location: match.location,
      template: match.template,
      encodedParams: match.encodedParams,
      queryParams: match.queryParams,
      extra: match.extra,
      error: match.error,
      pageKey: pageKey,
    );

    _matchList.push(newPageKeyMatch);
    notifyListeners();
  }

  /// Returns `true` if there is more than 1 page on the stack.
  bool canPop() {
    return _matchList.canPop();
  }

  /// Pop the top page off the GoRouter's page stack.
  void pop() {
    _matchList.pop();
    notifyListeners();
  }

  /// Replaces the top-most page of the page stack with the given one.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  void replace(GoRouteMatch match) {
    _matchList.matches.last = match;
    notifyListeners();
  }

  /// For internal use; visible for testing only.
  @visibleForTesting
  RouteMatchList get matches => _matchList;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  GlobalKey<NavigatorState> get navigatorKey => _configuration.navigatorKey;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  RouteMatchList get currentConfiguration => _matchList;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Widget build(BuildContext context) {
    return builder.build(
      context,
      _matchList,
      pop,
      routerNeglect,
    );
  }

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Future<void> setNewRoutePath(RouteMatchList configuration) {
    _matchList = configuration;
    // Use [SynchronousFuture] so that the initial url is processed
    // synchronously and remove unwanted initial animations on deep-linking
    return SynchronousFuture<void>(null);
  }
}

/// Thrown when [GoRouter] is used incorrectly.
class GoError extends Error {
  /// Constructs a [GoError]
  GoError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'GoError: $message';
}
