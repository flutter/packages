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
import 'misc/errors.dart';
import 'typedefs.dart';

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

  _NavigatorStateIterator _createNavigatorStateIterator() =>
      _NavigatorStateIterator(_matchList, navigatorKey.currentState!);

  @override
  Future<bool> popRoute() async {
    final _NavigatorStateIterator iterator = _createNavigatorStateIterator();
    while (iterator.moveNext()) {
      final bool didPop = await iterator.current.maybePop();
      if (didPop) {
        return true;
      }
    }
    return false;
  }

  /// Pushes the given location onto the page stack
  void push(RouteMatchList matches) {
    assert(matches.last.route is! ShellRouteBase);

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
      _matchList.isNotEmpty,
      'You have popped the last page off of the stack,'
      ' there are no pages left to show',
    );
  }

  bool _onPopPage(Route<Object?> route, Object? result) {
    if (!route.didPop(result)) {
      return false;
    }
    final Page<Object?> page = route.settings as Page<Object?>;
    final RouteMatch? match = builder.getRouteMatchForPage(page);
    if (match == null) {
      return true;
    }
    _matchList.remove(match);
    notifyListeners();
    assert(() {
      _debugAssertMatchListNotEmpty();
      return true;
    }());
    return true;
  }

  /// Replaces the top-most page of the page stack with the given one.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  void pushReplacement(RouteMatchList matches) {
    _matchList.remove(_matchList.last);
    push(matches); // [push] will notify the listeners.
  }

  /// For internal use; visible for testing only.
  @visibleForTesting
  RouteMatchList get matches => _matchList;

  /// For use by the Router architecture as part of the RouterDelegate.
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
      _onPopPage,
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

/// An iterator that iterates through navigators that [GoRouterDelegate]
/// created from the inner to outer.
///
/// The iterator starts with the navigator that hosts the top-most route. This
/// navigator may not be the inner-most navigator if the top-most route is a
/// pageless route, such as a dialog or bottom sheet.
class _NavigatorStateIterator extends Iterator<NavigatorState> {
  _NavigatorStateIterator(this.matchList, this.root)
      : index = matchList.matches.length;

  final RouteMatchList matchList;
  int index = 0;
  final NavigatorState root;
  @override
  late NavigatorState current;

  @override
  bool moveNext() {
    if (index < 0) {
      return false;
    }
    late RouteBase subRoute;
    for (index -= 1; index >= 0; index -= 1) {
      final RouteMatch match = matchList.matches[index];
      final RouteBase route = match.route;
      if (route is GoRoute && route.parentNavigatorKey != null) {
        final GlobalKey<NavigatorState> parentNavigatorKey =
            route.parentNavigatorKey!;
        final ModalRoute<Object?>? parentModalRoute =
            ModalRoute.of(parentNavigatorKey.currentContext!);
        // The ModalRoute can be null if the parentNavigatorKey references the
        // root navigator.
        if (parentModalRoute == null) {
          index = -1;
          assert(root == parentNavigatorKey.currentState);
          current = root;
          return true;
        }
        // It must be a ShellRoute that holds this parentNavigatorKey;
        // otherwise, parentModalRoute would have been null. Updates the index
        // to the ShellRoute
        for (index -= 1; index >= 0; index -= 1) {
          final RouteBase route = matchList.matches[index].route;
          if (route is ShellRoute) {
            if (route.navigatorKey == parentNavigatorKey) {
              break;
            }
          }
        }
        // There may be a pageless route on top of ModalRoute that the
        // NavigatorState of parentNavigatorKey is in. For example, an open
        // dialog. In that case we want to find the navigator that host the
        // pageless route.
        if (parentModalRoute.isCurrent == false) {
          continue;
        }

        current = parentNavigatorKey.currentState!;
        return true;
      } else if (route is ShellRouteBase) {
        // Must have a ModalRoute parent because the navigator ShellRoute
        // created must not be the root navigator.
        final GlobalKey<NavigatorState> navigatorKey =
            route.navigatorKeyForSubRoute(subRoute);
        final ModalRoute<Object?> parentModalRoute =
            ModalRoute.of(navigatorKey.currentContext!)!;
        // There may be pageless route on top of ModalRoute that the
        // parentNavigatorKey is in. For example an open dialog.
        if (parentModalRoute.isCurrent == false) {
          continue;
        }
        current = navigatorKey.currentState!;
        return true;
      }
      subRoute = route;
    }
    assert(index == -1);
    current = root;
    return true;
  }
}

/// The route match that represent route pushed through [GoRouter.push].
// TODO(chunhtai): Removes this once imperative API no longer insert route match.
class ImperativeRouteMatch extends RouteMatch {
  /// Constructor for [ImperativeRouteMatch].
  const ImperativeRouteMatch({
    required super.route,
    required super.subloc,
    required super.extra,
    required super.error,
    required super.pageKey,
    required this.matches,
  });

  /// The matches that produces this route match.
  final RouteMatchList matches;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! ImperativeRouteMatch) {
      return false;
    }
    return super == this && other.matches == matches;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, matches);
}
