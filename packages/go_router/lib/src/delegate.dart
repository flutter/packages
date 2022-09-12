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
  }) : builder = RouteBuilder(
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

  final GlobalKey<NavigatorState> _key = GlobalKey<NavigatorState>();

  RouteMatchList _matches = RouteMatchList.empty();
  final Map<String, int> _pushCounts = <String, int>{};

  /// Pushes the given location onto the page stack
  void push(RouteMatch match) {
    // Remap the pageKey to allow any number of the same page on the stack
    final String fullPath = match.fullpath;
    final int count = (_pushCounts[fullPath] ?? 0) + 1;
    _pushCounts[fullPath] = count;
    final ValueKey<String> pageKey = ValueKey<String>('$fullPath-p$count');
    final RouteMatch newPageKeyMatch = RouteMatch(
      route: match.route,
      subloc: match.subloc,
      fullpath: match.fullpath,
      encodedParams: match.encodedParams,
      queryParams: match.queryParams,
      queryParametersAll: match.queryParametersAll,
      extra: match.extra,
      error: match.error,
      pageKey: pageKey,
    );

    _matches.push(newPageKeyMatch);
    notifyListeners();
  }

  /// Returns `true` if there is more than 1 page on the stack.
  bool canPop() {
    return _matches.canPop();
  }

  /// Pop the top page off the GoRouter's page stack.
  void pop() {
    _matches.pop();
    notifyListeners();
  }

  /// Replaces the top-most page of the page stack with the given one.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  void replace(RouteMatch match) {
    _matches.matches.last = match;
    notifyListeners();
  }

  /// For internal use; visible for testing only.
  @visibleForTesting
  RouteMatchList get matches => _matches;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  GlobalKey<NavigatorState> get navigatorKey => _key;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  RouteMatchList get currentConfiguration => _matches;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Widget build(BuildContext context) => builder.build(
        context,
        _matches,
        pop,
        navigatorKey,
        routerNeglect,
      );

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Future<void> setNewRoutePath(RouteMatchList configuration) {
    _matches = configuration;
    // Use [SynchronousFuture] so that the initial url is processed
    // synchronously and remove unwanted initial animations on deep-linking
    return SynchronousFuture<void>(null);
  }
}
