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

  RouteMatchList _matchList = RouteMatchList.empty;

  /// Stores the number of times each route route has been pushed.
  ///
  /// This is used to generate a unique key for each route.
  ///
  /// For example, it would could be equal to:
  /// ```dart
  /// {
  ///   'family': 1,
  ///   'family/:fid': 2,
  /// }
  /// ```
  final Map<String, int> _pushCounts = <String, int>{};
  final RouteConfiguration _configuration;

  @override
  Future<bool> popRoute() async {
    // Iterate backwards through the RouteMatchList until seeing a GoRoute with
    // a non-null parentNavigatorKey or a ShellRoute with a non-null
    // parentNavigatorKey and pop from that Navigator instead of the root.
    final int matchCount = _matchList.matches.length;
    for (int i = matchCount - 1; i >= 0; i -= 1) {
      final RouteMatch match = _matchList.matches[i];
      final RouteBase route = match.route;

      if (route is GoRoute && route.parentNavigatorKey != null) {
        final bool didPop =
            await route.parentNavigatorKey!.currentState!.maybePop();

        // Continue if didPop was false.
        if (didPop) {
          return didPop;
        }
      } else if (route is ShellRoute) {
        final bool didPop = await route.navigatorKey.currentState!.maybePop();

        // Continue if didPop was false.
        if (didPop) {
          return didPop;
        }
      }
    }

    // Use the root navigator if no ShellRoute Navigators were found and didn't
    // pop
    final NavigatorState navigator = navigatorKey.currentState!;
    return navigator.maybePop();
  }

  /// Pushes the given location onto the page stack
  void push(RouteMatchList matches) {
    assert(matches.last.route is! ShellRoute);

    // Remap the pageKey to allow any number of the same page on the stack
    final int count = (_pushCounts[matches.fullpath] ?? 0) + 1;
    _pushCounts[matches.fullpath] = count;
    final ValueKey<String> pageKey =
        ValueKey<String>('${matches.fullpath}-p$count');
    final ImperativeRouteMatch newPageKeyMatch = ImperativeRouteMatch(
      route: matches.last.route,
      subloc: matches.last.subloc,
      extra: matches.last.extra,
      error: matches.last.error,
      pageKey: pageKey,
      matches: matches,
    );

    _matchList.push(newPageKeyMatch);
    notifyListeners();
  }

  /// Returns `true` if the active Navigator can pop.
  bool canPop() {
    // Loop through navigators in reverse and call canPop()
    final int matchCount = _matchList.matches.length;
    for (int i = matchCount - 1; i >= 0; i -= 1) {
      final RouteMatch match = _matchList.matches[i];
      final RouteBase route = match.route;
      if (route is GoRoute && route.parentNavigatorKey != null) {
        final bool canPop =
            route.parentNavigatorKey!.currentState?.canPop() ?? false;

        // Continue if canPop is false.
        if (canPop) {
          return canPop;
        }
      } else if (route is ShellRoute) {
        final bool canPop = route.navigatorKey.currentState?.canPop() ?? false;

        // Continue if canPop is false.
        if (canPop) {
          return canPop;
        }
      }
    }
    return navigatorKey.currentState?.canPop() ?? false;
  }

  void _debugAssertMatchListNotEmpty() {
    assert(
      _matchList.isNotEmpty,
      'You have popped the last page off of the stack,'
      ' there are no pages left to show',
    );
  }

  /// Pop the top page off the GoRouter's page stack.
  void pop() {
    _matchList.pop();
    assert(() {
      _debugAssertMatchListNotEmpty();
      return true;
    }());
    notifyListeners();
  }

  /// Replaces the top-most page of the page stack with the given one.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  void replace(RouteMatchList matches) {
    _matchList.pop();
    push(matches); // [push] will notify the listeners.
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
    assert(_matchList.isNotEmpty);
    notifyListeners();
    // Use [SynchronousFuture] so that the initial url is processed
    // synchronously and remove unwanted initial animations on deep-linking
    return SynchronousFuture<void>(null);
  }
}

/// The route match that represent route pushed through [GoRouter.push].
// TODO(chunhtai): Removes this once imperative API no longer insert route match.
class ImperativeRouteMatch extends RouteMatch {
  /// Constructor for [ImperativeRouteMatch].
  ImperativeRouteMatch({
    required super.route,
    required super.subloc,
    required super.extra,
    required super.error,
    required super.pageKey,
    required this.matches,
  });

  /// The matches that produces this route match.
  final RouteMatchList matches;
}
