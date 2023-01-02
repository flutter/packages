// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'delegate.dart';
import 'logging.dart';
import 'match.dart';
import 'matching.dart';
import 'misc/error_screen.dart';
import 'pages/cupertino.dart';
import 'pages/custom_transition_page.dart';
import 'pages/material.dart';
import 'route_data.dart';
import 'typedefs.dart';

/// Builds the top-level Navigator for GoRouter.
class RouteBuilder {
  /// [RouteBuilder] constructor.
  RouteBuilder({
    required this.configuration,
    required this.builderWithNav,
    required this.errorPageBuilder,
    required this.errorBuilder,
    required this.restorationScopeId,
    required this.observers,
  });

  /// Builder function for a go router with Navigator.
  final GoRouterBuilderWithNav builderWithNav;

  /// Error page builder for the go router delegate.
  final GoRouterPageBuilder? errorPageBuilder;

  /// Error widget builder for the go router delegate.
  final GoRouterWidgetBuilder? errorBuilder;

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  /// NavigatorObserver used to receive notifications when navigating in between routes.
  /// changes.
  final List<NavigatorObserver> observers;

  final GoRouterStateRegistry _registry = GoRouterStateRegistry();

  /// Builds the top-level Navigator for the given [RouteMatchList].
  Widget build(
    BuildContext context,
    RouteMatchList matchList,
    PopPageCallback onPopPage,
    bool routerNeglect,
  ) {
    if (matchList.isEmpty) {
      // The build method can be called before async redirect finishes. Build a
      // empty box until then.
      return const SizedBox.shrink();
    }
    return builderWithNav(
      context,
      Builder(
        builder: (BuildContext context) {
          try {
            final Map<Page<Object?>, GoRouterState> newRegistry =
                <Page<Object?>, GoRouterState>{};
            final Widget result = tryBuild(context, matchList, onPopPage,
                routerNeglect, configuration.navigatorKey, newRegistry);
            _registry.updateRegistry(newRegistry);
            return GoRouterStateRegistryScope(
                registry: _registry, child: result);
          } on _RouteBuilderError catch (e) {
            return _buildErrorNavigator(context, e, matchList.uri, onPopPage,
                configuration.navigatorKey);
          }
        },
      ),
    );
  }

  /// Builds the top-level Navigator by invoking the build method on each
  /// matching route.
  ///
  /// Throws a [_RouteBuilderError].
  @visibleForTesting
  Widget tryBuild(
    BuildContext context,
    RouteMatchList matchList,
    PopPageCallback onPopPage,
    bool routerNeglect,
    GlobalKey<NavigatorState> navigatorKey,
    Map<Page<Object?>, GoRouterState> registry,
  ) {
    return builderWithNav(
      context,
      _buildNavigator(
        onPopPage,
        buildPages(context, matchList, onPopPage, routerNeglect, navigatorKey,
            registry),
        navigatorKey,
        observers: observers,
      ),
    );
  }

  /// Returns the top-level pages instead of the root navigator. Used for
  /// testing.
  @visibleForTesting
  List<Page<Object?>> buildPages(
      BuildContext context,
      RouteMatchList matchList,
      PopPageCallback onPopPage,
      bool routerNeglect,
      GlobalKey<NavigatorState> navigatorKey,
      Map<Page<Object?>, GoRouterState> registry) {
    try {
      final Map<GlobalKey<NavigatorState>, List<Page<Object?>>> keyToPage =
          <GlobalKey<NavigatorState>, List<Page<Object?>>>{};
      _buildRecursive(context, matchList, 0, onPopPage, routerNeglect,
          keyToPage, navigatorKey, registry);
      return keyToPage[navigatorKey]!;
    } on _RouteBuilderError catch (e) {
      return <Page<Object?>>[
        _buildErrorPage(context, e, matchList.uri),
      ];
    }
  }

  void _buildRecursive(
    BuildContext context,
    RouteMatchList matchList,
    int startIndex,
    PopPageCallback onPopPage,
    bool routerNeglect,
    Map<GlobalKey<NavigatorState>, List<Page<Object?>>> keyToPages,
    GlobalKey<NavigatorState> navigatorKey,
    Map<Page<Object?>, GoRouterState> registry,
  ) {
    if (startIndex >= matchList.matches.length) {
      return;
    }
    final RouteMatch match = matchList.matches[startIndex];

    if (match.error != null) {
      throw _RouteBuilderError('Match error found during build phase',
          exception: match.error);
    }

    final RouteBase route = match.route;
    final GoRouterState state = buildState(matchList, match);
    if (route is GoRoute) {
      final Page<Object?> page = _buildPageForRoute(context, state, match);
      registry[page] = state;
      // If this GoRoute is for a different Navigator, add it to the
      // list of out of scope pages
      final GlobalKey<NavigatorState> goRouteNavKey =
          route.parentNavigatorKey ?? navigatorKey;

      keyToPages.putIfAbsent(goRouteNavKey, () => <Page<Object?>>[]).add(page);

      _buildRecursive(context, matchList, startIndex + 1, onPopPage,
          routerNeglect, keyToPages, navigatorKey, registry);
    } else if (route is ShellRoute) {
      // The key for the Navigator that will display this ShellRoute's page.
      final GlobalKey<NavigatorState> parentNavigatorKey = navigatorKey;

      // The key to provide to the ShellRoute's Navigator.
      final GlobalKey<NavigatorState> shellNavigatorKey = route.navigatorKey;

      // Add an entry for the parent navigator if none exists.
      keyToPages.putIfAbsent(parentNavigatorKey, () => <Page<Object?>>[]);

      // Add an entry for the shell route's navigator
      keyToPages.putIfAbsent(shellNavigatorKey, () => <Page<Object?>>[]);

      // Calling _buildRecursive can result in adding pages to the
      // parentNavigatorKey entry's list. Store the current length so
      // that the page for this ShellRoute is placed at the right index.
      final int shellPageIdx = keyToPages[parentNavigatorKey]!.length;

      // Build the remaining pages
      _buildRecursive(context, matchList, startIndex + 1, onPopPage,
          routerNeglect, keyToPages, shellNavigatorKey, registry);

      // Build the Navigator
      final Widget child = _buildNavigator(
        onPopPage,
        keyToPages[shellNavigatorKey]!,
        shellNavigatorKey,
        observers: <NavigatorObserver>[
          ...observers.map<NavigatorObserver>((NavigatorObserver observer) =>
              _ProxyNavigatorObserver(observer)),
          ...route.observers,
        ],
      );

      // Build the Page for this route
      final Page<Object?> page =
          _buildPageForRoute(context, state, match, child: child);
      registry[page] = state;
      // Place the ShellRoute's Page onto the list for the parent navigator.
      keyToPages
          .putIfAbsent(parentNavigatorKey, () => <Page<Object?>>[])
          .insert(shellPageIdx, page);
    }
  }

  Navigator _buildNavigator(
    PopPageCallback onPopPage,
    List<Page<Object?>> pages,
    Key? navigatorKey, {
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) {
    return Navigator(
      key: navigatorKey,
      restorationScopeId: restorationScopeId,
      pages: pages,
      observers: observers,
      onPopPage: onPopPage,
    );
  }

  /// Helper method that builds a [GoRouterState] object for the given [match]
  /// and [params].
  @visibleForTesting
  GoRouterState buildState(RouteMatchList matchList, RouteMatch match) {
    final RouteBase route = match.route;
    String? name;
    String path = '';
    if (route is GoRoute) {
      name = route.name;
      path = route.path;
    }
    final RouteMatchList effectiveMatchList =
        match is ImperativeRouteMatch ? match.matches : matchList;
    return GoRouterState(
      configuration,
      location: effectiveMatchList.uri.toString(),
      subloc: match.subloc,
      name: name,
      path: path,
      fullpath: effectiveMatchList.fullpath,
      params: effectiveMatchList.pathParameters,
      error: match.error,
      queryParams: effectiveMatchList.uri.queryParameters,
      queryParametersAll: effectiveMatchList.uri.queryParametersAll,
      extra: match.extra,
      pageKey: match.pageKey,
    );
  }

  /// Builds a [Page] for [StackedRoute]
  Page<Object?> _buildPageForRoute(
      BuildContext context, GoRouterState state, RouteMatch match,
      {Widget? child}) {
    final RouteBase route = match.route;
    Page<Object?>? page;

    if (route is GoRoute) {
      // Call the pageBuilder if it's non-null
      final GoRouterPageBuilder? pageBuilder = route.pageBuilder;
      if (pageBuilder != null) {
        page = pageBuilder(context, state);
      }
    } else if (route is ShellRoute) {
      final ShellRoutePageBuilder? pageBuilder = route.pageBuilder;
      assert(child != null, 'ShellRoute must contain a child route');
      if (pageBuilder != null) {
        page = pageBuilder(context, state, child!);
      }
    }

    if (page is NoOpPage) {
      page = null;
    }

    // Return the result of the route's builder() or pageBuilder()
    return page ??
        // Uses a Builder to make sure its rebuild scope is limited to the page.
        buildPage(context, state, Builder(builder: (BuildContext context) {
          return _callRouteBuilder(context, state, match, childWidget: child);
        }));
  }

  /// Calls the user-provided route builder from the [RouteMatch]'s [RouteBase].
  Widget _callRouteBuilder(
      BuildContext context, GoRouterState state, RouteMatch match,
      {Widget? childWidget}) {
    final RouteBase route = match.route;

    if (route == null) {
      throw _RouteBuilderError('No route found for match: $match');
    }

    if (route is GoRoute) {
      final GoRouterWidgetBuilder? builder = route.builder;

      if (builder == null) {
        throw _RouteBuilderError('No routeBuilder provided to GoRoute: $route');
      }

      return builder(context, state);
    } else if (route is ShellRoute) {
      if (childWidget == null) {
        throw _RouteBuilderException(
            'Attempt to build ShellRoute without a child widget');
      }

      final ShellRouteBuilder? builder = route.builder;

      if (builder == null) {
        throw _RouteBuilderError('No builder provided to ShellRoute: $route');
      }

      return builder(context, state, childWidget);
    }

    throw _RouteBuilderException('Unsupported route type $route');
  }

  _PageBuilderForAppType? _pageBuilderForAppType;

  Widget Function(
    BuildContext context,
    GoRouterState state,
  )? _errorBuilderForAppType;

  void _cacheAppType(BuildContext context) {
    // cache app type-specific page and error builders
    if (_pageBuilderForAppType == null) {
      assert(_errorBuilderForAppType == null);

      // can be null during testing
      final Element? elem = context is Element ? context : null;

      if (elem != null && isMaterialApp(elem)) {
        log.info('Using MaterialApp configuration');
        _pageBuilderForAppType = pageBuilderForMaterialApp;
        _errorBuilderForAppType =
            (BuildContext c, GoRouterState s) => MaterialErrorScreen(s.error);
      } else if (elem != null && isCupertinoApp(elem)) {
        log.info('Using CupertinoApp configuration');
        _pageBuilderForAppType = pageBuilderForCupertinoApp;
        _errorBuilderForAppType =
            (BuildContext c, GoRouterState s) => CupertinoErrorScreen(s.error);
      } else {
        log.info('Using WidgetsApp configuration');
        _pageBuilderForAppType = pageBuilderForWidgetApp;
        _errorBuilderForAppType =
            (BuildContext c, GoRouterState s) => ErrorScreen(s.error);
      }
    }

    assert(_pageBuilderForAppType != null);
    assert(_errorBuilderForAppType != null);
  }

  /// builds the page based on app type, i.e. MaterialApp vs. CupertinoApp
  @visibleForTesting
  Page<Object?> buildPage(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    // build the page based on app type
    _cacheAppType(context);
    return _pageBuilderForAppType!(
      key: state.pageKey,
      name: state.name ?? state.fullpath,
      arguments: <String, String>{...state.params, ...state.queryParams},
      restorationId: state.pageKey.value,
      child: child,
    );
  }

  /// Builds a page without any transitions.
  Page<void> pageBuilderForWidgetApp({
    required LocalKey key,
    required String? name,
    required Object? arguments,
    required String restorationId,
    required Widget child,
  }) =>
      NoTransitionPage<void>(
        name: name,
        arguments: arguments,
        key: key,
        restorationId: restorationId,
        child: child,
      );

  /// Builds a Navigator containing an error page.
  Widget _buildErrorNavigator(
      BuildContext context,
      _RouteBuilderError e,
      Uri uri,
      PopPageCallback onPopPage,
      GlobalKey<NavigatorState> navigatorKey) {
    return _buildNavigator(
      onPopPage,
      <Page<Object?>>[
        _buildErrorPage(context, e, uri),
      ],
      navigatorKey,
    );
  }

  /// Builds a an error page.
  Page<void> _buildErrorPage(
    BuildContext context,
    _RouteBuilderError error,
    Uri uri,
  ) {
    final GoRouterState state = GoRouterState(
      configuration,
      location: uri.toString(),
      subloc: uri.path,
      name: null,
      queryParams: uri.queryParameters,
      queryParametersAll: uri.queryParametersAll,
      error: Exception(error),
      pageKey: const ValueKey<String>('error'),
    );

    // If the error page builder is provided, use that, otherwise, if the error
    // builder is provided, wrap that in an app-specific page (for example,
    // MaterialPage). Finally, if nothing is provided, use a default error page
    // wrapped in the app-specific page.
    _cacheAppType(context);
    final GoRouterWidgetBuilder? errorBuilder = this.errorBuilder;
    return errorPageBuilder != null
        ? errorPageBuilder!(context, state)
        : buildPage(
            context,
            state,
            errorBuilder != null
                ? errorBuilder(context, state)
                : _errorBuilderForAppType!(context, state),
          );
  }
}

typedef _PageBuilderForAppType = Page<void> Function({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
});

/// An error that occurred while building the app's UI based on the route
/// matches.
class _RouteBuilderError extends Error {
  /// Constructs a [_RouteBuilderError].
  _RouteBuilderError(this.message, {this.exception});

  /// The error message.
  final String message;

  /// The exception that occurred.
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}

/// An error that occurred while building the app's UI based on the route
/// matches.
class _RouteBuilderException implements Exception {
  /// Constructs a [_RouteBuilderException].
  //ignore: unused_element
  _RouteBuilderException(this.message, {this.exception});

  /// The error message.
  final String message;

  /// The exception that occurred.
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}

/// An navigator observer that is a proxy for the parent navigator observer.
class _ProxyNavigatorObserver extends NavigatorObserver {
  _ProxyNavigatorObserver(this.parent);

  /// The navigator observer whose methods this navigator observer will call.
  final NavigatorObserver parent;

  /// The navigator that the observer is observing, if any.
  @override
  NavigatorState? get navigator => _navigator;
  NavigatorState? _navigator;

  /// The [Navigator] pushed `route`.
  ///
  /// The route immediately below that one, and thus the previously active
  /// route, is `previousRoute`.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      parent.didPush(route, previousRoute);

  /// The [Navigator] popped `route`.
  ///
  /// The route immediately below that one, and thus the newly active
  /// route, is `previousRoute`.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      parent.didPop(route, previousRoute);

  /// The [Navigator] removed `route`.
  ///
  /// If only one route is being removed, then the route immediately below
  /// that one, if any, is `previousRoute`.
  ///
  /// If multiple routes are being removed, then the route below the
  /// bottommost route being removed, if any, is `previousRoute`, and this
  /// method will be called once for each removed route, from the topmost route
  /// to the bottommost route.
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      parent.didRemove(route, previousRoute);

  /// The [Navigator] replaced `oldRoute` with `newRoute`.
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      parent.didReplace(newRoute: newRoute, oldRoute: oldRoute);

  /// The [Navigator]'s routes are being moved by a user gesture.
  ///
  /// For example, this is called when an iOS back gesture starts, and is used
  /// to disabled hero animations during such interactions.
  @override
  void didStartUserGesture(
          Route<dynamic> route, Route<dynamic>? previousRoute) =>
      parent.didStartUserGesture(route, previousRoute);

  /// User gesture is no longer controlling the [Navigator].
  ///
  /// Paired with an earlier call to [didStartUserGesture].
  @override
  void didStopUserGesture() => parent.didStopUserGesture();
}
