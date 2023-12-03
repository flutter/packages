// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'builder.dart';
import 'configuration.dart';
import 'match.dart';
import 'misc/errors.dart';
import 'route.dart';

/// GoRouter implementation of [RouterDelegate].
class GoRouterDelegate extends RouterDelegate<RouteMatchList>
    with ChangeNotifier {
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
    bool requestFocus = true,
  }) : _configuration = configuration {
    builder = RouteBuilder(
      configuration: configuration,
      builderWithNav: builderWithNav,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      restorationScopeId: restorationScopeId,
      observers: observers,
      onPopPageWithRouteMatch: _handlePopPageWithRouteMatch,
      requestFocus: requestFocus,
    );
  }

  /// Builds the top-level Navigator given a configuration and location.
  @visibleForTesting
  late final RouteBuilder builder;

  /// Set to true to disable creating history entries on the web.
  final bool routerNeglect;

  final RouteConfiguration _configuration;

  _NavigatorStateIterator _createNavigatorStateIterator() =>
      _NavigatorStateIterator(currentConfiguration, navigatorKey.currentState!);

  @override
  Future<bool> popRoute() async {
    final _NavigatorStateIterator iterator = _createNavigatorStateIterator();
    while (iterator.moveNext()) {
      final bool didPop = await iterator.current.maybePop();
      if (didPop) {
        return true;
      }
    }
    // This should be the only place where the last GoRoute exit the screen.
    final GoRoute lastRoute =
        currentConfiguration.matches.last.route as GoRoute;
    if (lastRoute.onExit != null && navigatorKey.currentContext != null) {
      return !(await lastRoute.onExit!(navigatorKey.currentContext!));
    }
    return false;
  }

  /// Returns `true` if the active Navigator can pop.
  bool canPop() {
    final _NavigatorStateIterator iterator = _createNavigatorStateIterator();
    while (iterator.moveNext()) {
      if (iterator.current.canPop()) {
        return true;
      }
    }
    return false;
  }

  /// Pops the top-most route.
  void pop<T extends Object?>([T? result]) {
    final _NavigatorStateIterator iterator = _createNavigatorStateIterator();
    while (iterator.moveNext()) {
      if (iterator.current.canPop()) {
        iterator.current.pop<T>(result);
        return;
      }
    }
    throw GoError('There is nothing to pop');
  }

  void _debugAssertMatchListNotEmpty() {
    assert(
      currentConfiguration.isNotEmpty,
      'You have popped the last page off of the stack,'
      ' there are no pages left to show',
    );
  }

  bool _handlePopPageWithRouteMatch(
      Route<Object?> route, Object? result, RouteMatch? match) {
    if (route.willHandlePopInternally) {
      final bool popped = route.didPop(result);
      assert(!popped);
      return popped;
    }
    assert(match != null);
    final RouteBase routeBase = match!.route;
    if (routeBase is! GoRoute || routeBase.onExit == null) {
      route.didPop(result);
      _completeRouteMatch(result, match);
      return true;
    }

    // The _handlePopPageWithRouteMatch is called during draw frame, schedule
    // a microtask in case the onExit callback want to launch dialog or other
    // navigator operations.
    scheduleMicrotask(() async {
      final bool onExitResult =
          await routeBase.onExit!(navigatorKey.currentContext!);
      if (onExitResult) {
        _completeRouteMatch(result, match);
      }
    });
    return false;
  }

  void _completeRouteMatch(Object? result, RouteMatch match) {
    if (match is ImperativeRouteMatch) {
      match.complete(result);
    }
    currentConfiguration = currentConfiguration.remove(match);
    notifyListeners();
    assert(() {
      _debugAssertMatchListNotEmpty();
      return true;
    }());
  }

  /// For use by the Router architecture as part of the RouterDelegate.
  GlobalKey<NavigatorState> get navigatorKey => _configuration.navigatorKey;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  RouteMatchList currentConfiguration = RouteMatchList.empty;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Widget build(BuildContext context) {
    return builder.build(
      context,
      currentConfiguration,
      routerNeglect,
    );
  }

  /// For use by the Router architecture as part of the RouterDelegate.
  // This class avoids using async to make sure the route is processed
  // synchronously if possible.
  @override
  Future<void> setNewRoutePath(RouteMatchList configuration) {
    if (currentConfiguration == configuration) {
      return SynchronousFuture<void>(null);
    }

    assert(configuration.isNotEmpty || configuration.isError);

    final BuildContext? navigatorContext = navigatorKey.currentContext;
    // If navigator is not built or disposed, the GoRoute.onExit is irrelevant.
    if (navigatorContext != null) {
      final int compareUntil = math.min(
        currentConfiguration.matches.length,
        configuration.matches.length,
      );
      int indexOfFirstDiff = 0;
      for (; indexOfFirstDiff < compareUntil; indexOfFirstDiff++) {
        if (currentConfiguration.matches[indexOfFirstDiff] !=
            configuration.matches[indexOfFirstDiff]) {
          break;
        }
      }
      if (indexOfFirstDiff < currentConfiguration.matches.length) {
        final List<GoRoute> exitingGoRoutes = currentConfiguration.matches
            .sublist(indexOfFirstDiff)
            .map<RouteBase>((RouteMatch match) => match.route)
            .whereType<GoRoute>()
            .toList();
        return _callOnExitStartsAt(exitingGoRoutes.length - 1,
                navigatorContext: navigatorContext, routes: exitingGoRoutes)
            .then<void>((bool exit) {
          if (!exit) {
            return SynchronousFuture<void>(null);
          }
          return _setCurrentConfiguration(configuration);
        });
      }
    }

    return _setCurrentConfiguration(configuration);
  }

  /// Calls [GoRoute.onExit] starting from the index
  ///
  /// The returned future resolves to true if all routes below the index all
  /// return true. Otherwise, the returned future resolves to false.
  static Future<bool> _callOnExitStartsAt(int index,
      {required BuildContext navigatorContext, required List<GoRoute> routes}) {
    if (index < 0) {
      return SynchronousFuture<bool>(true);
    }
    final GoRoute goRoute = routes[index];
    if (goRoute.onExit == null) {
      return _callOnExitStartsAt(index - 1,
          navigatorContext: navigatorContext, routes: routes);
    }

    Future<bool> handleOnExitResult(bool exit) {
      if (exit) {
        return _callOnExitStartsAt(index - 1,
            navigatorContext: navigatorContext, routes: routes);
      }
      return SynchronousFuture<bool>(false);
    }

    final FutureOr<bool> exitFuture = goRoute.onExit!(navigatorContext);
    if (exitFuture is bool) {
      return handleOnExitResult(exitFuture);
    }
    return exitFuture.then<bool>(handleOnExitResult);
  }

  Future<void> _setCurrentConfiguration(RouteMatchList configuration) {
    currentConfiguration = configuration;
    notifyListeners();
    return SynchronousFuture<void>(null);
  }
}

/// An iterator that iterates through navigators that [GoRouterDelegate]
/// created from the inner to outer.
///
/// The iterator starts with the navigator that hosts the top-most route. This
/// navigator may not be the inner-most navigator if the top-most route is a
/// pageless route, such as a dialog or bottom sheet.
class _NavigatorStateIterator implements Iterator<NavigatorState> {
  _NavigatorStateIterator(this.matchList, this.root)
      : index = matchList.matches.length - 1;

  final RouteMatchList matchList;
  int index;

  final NavigatorState root;
  @override
  late NavigatorState current;

  RouteBase _getRouteAtIndex(int index) => matchList.matches[index].route;

  void _findsNextIndex() {
    final GlobalKey<NavigatorState>? parentNavigatorKey =
        _getRouteAtIndex(index).parentNavigatorKey;
    if (parentNavigatorKey == null) {
      index -= 1;
      return;
    }

    for (index -= 1; index >= 0; index -= 1) {
      final RouteBase route = _getRouteAtIndex(index);
      if (route is ShellRouteBase) {
        if (route.navigatorKeyForSubRoute(_getRouteAtIndex(index + 1)) ==
            parentNavigatorKey) {
          return;
        }
      }
    }
    assert(root == parentNavigatorKey.currentState);
  }

  @override
  bool moveNext() {
    if (index < 0) {
      return false;
    }
    _findsNextIndex();

    while (index >= 0) {
      final RouteBase route = _getRouteAtIndex(index);
      if (route is ShellRouteBase) {
        final GlobalKey<NavigatorState> navigatorKey =
            route.navigatorKeyForSubRoute(_getRouteAtIndex(index + 1));
        // Must have a ModalRoute parent because the navigator ShellRoute
        // created must not be the root navigator.
        final ModalRoute<Object?> parentModalRoute =
            ModalRoute.of(navigatorKey.currentContext!)!;
        // There may be pageless route on top of ModalRoute that the
        // parentNavigatorKey is in. For example an open dialog.
        if (parentModalRoute.isCurrent) {
          current = navigatorKey.currentState!;
          return true;
        }
      }
      _findsNextIndex();
    }
    assert(index == -1);
    current = root;
    return true;
  }
}
