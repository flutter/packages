// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';
import 'configuration.dart';
import 'delegate.dart';
import 'logging.dart';
import 'match.dart';
import 'matching.dart';
import 'misc/error_screen.dart';
import 'pages/cupertino.dart';
import 'pages/material.dart';
import 'parser.dart';
import 'route_data.dart';
import 'typedefs.dart';

/// On pop page callback that includes the associated [RouteMatch].
///
/// This is a specialized version of [Navigator.onPopPage], used when creating
/// Navigators in [RouteBuilder].
typedef RouteBuilderPopPageCallback = bool Function(
    Route<dynamic> route, dynamic result, RouteMatch? match);

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

  /// Caches a HeroController for the nested Navigator, which solves cases where the
  /// Hero Widget animation stops working when navigating.
  final Map<GlobalKey<NavigatorState>, HeroController> _goHeroCache =
      <GlobalKey<NavigatorState>, HeroController>{};

  /// Builds the top-level Navigator for the given [RouteMatchList].
  Widget build(
    BuildContext context,
    RouteMatchList matchList,
    RouteBuilderPopPageCallback onPopPage,
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
            return _buildErrorNavigator(
                context, e, matchList, onPopPage, configuration.navigatorKey);
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
    RouteBuilderPopPageCallback onPopPage,
    bool routerNeglect,
    GlobalKey<NavigatorState> navigatorKey,
    Map<Page<Object?>, GoRouterState> registry,
  ) {
    final _PagePopContext pagePopContext = _PagePopContext._(onPopPage);
    return builderWithNav(
      context,
      _RouteNavigatorBuilder.buildNavigator(
        pagePopContext.onPopPage,
        _buildPages(context, matchList, 0, pagePopContext, routerNeglect,
            navigatorKey, registry),
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
          RouteBuilderPopPageCallback onPopPage,
          int startIndex,
          bool routerNeglect,
          GlobalKey<NavigatorState> navigatorKey,
          Map<Page<Object?>, GoRouterState> registry) =>
      _buildPages(context, matchList, startIndex, _PagePopContext._(onPopPage),
          routerNeglect, navigatorKey, registry);

  List<Page<Object?>> _buildPages(
      BuildContext context,
      RouteMatchList matchList,
      int startIndex,
      _PagePopContext pagePopContext,
      bool routerNeglect,
      GlobalKey<NavigatorState> navigatorKey,
      Map<Page<Object?>, GoRouterState> registry) {
    final Map<GlobalKey<NavigatorState>, List<Page<Object?>>> keyToPage =
        <GlobalKey<NavigatorState>, List<Page<Object?>>>{};
    try {
      _buildRecursive(context, matchList.unmodifiableMatchList(), startIndex,
          pagePopContext, routerNeglect, keyToPage, navigatorKey, registry);

      // Every Page should have a corresponding RouteMatch.
      assert(keyToPage.values.flattened.every((Page<Object?> page) =>
          pagePopContext.getRouteMatchForPage(page) != null));
      return keyToPage[navigatorKey]!;
    } on _RouteBuilderError catch (e) {
      return <Page<Object?>>[
        _buildErrorPage(context, e, matchList),
      ];
    } finally {
      /// Clean up previous cache to prevent memory leak.
      _goHeroCache.removeWhere(
          (GlobalKey<NavigatorState> key, _) => !keyToPage.keys.contains(key));
    }
  }

  /// Builds a preloaded nested [Navigator], containing a sub-tree (beginning
  /// at startIndex) of the provided route match list.
  Widget buildPreloadedNestedNavigator(
      BuildContext context,
      RouteMatchList matchList,
      int startIndex,
      RouteBuilderPopPageCallback onPopPage,
      bool routerNeglect,
      GlobalKey<NavigatorState> navigatorKey,
      {List<NavigatorObserver>? observers,
      String? restorationScopeId}) {
    final Map<GlobalKey<NavigatorState>, List<Page<Object?>>> keyToPage =
        <GlobalKey<NavigatorState>, List<Page<Object?>>>{};
    try {
      final _PagePopContext pagePopContext = _PagePopContext._(onPopPage);
      _buildRecursive(
          context,
          matchList.unmodifiableMatchList(),
          startIndex,
          pagePopContext,
          routerNeglect,
          keyToPage,
          navigatorKey, <Page<Object?>, GoRouterState>{});

      return _RouteNavigatorBuilder.buildNavigator(
        pagePopContext.onPopPage,
        keyToPage[navigatorKey]!,
        navigatorKey,
        observers: observers,
        restorationScopeId: restorationScopeId,
        heroController: _getHeroController(context),
      );
    } on _RouteBuilderError catch (e) {
      return _buildErrorNavigator(
          context, e, matchList, onPopPage, configuration.navigatorKey);
    }
  }

  void _buildRecursive(
    BuildContext context,
    UnmodifiableRouteMatchList matchList,
    int startIndex,
    _PagePopContext pagePopContext,
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
      final Page<Object?> page =
          _buildPageForRoute(context, state, match, pagePopContext);
      registry[page] = state;
      // If this GoRoute is for a different Navigator, add it to the
      // list of out of scope pages
      final GlobalKey<NavigatorState> goRouteNavKey =
          route.parentNavigatorKey ?? navigatorKey;

      keyToPages.putIfAbsent(goRouteNavKey, () => <Page<Object?>>[]).add(page);

      _buildRecursive(context, matchList, startIndex + 1, pagePopContext,
          routerNeglect, keyToPages, navigatorKey, registry);
    } else if (route is ShellRouteBase) {
      assert(startIndex + 1 < matchList.matches.length,
          'Shell routes must always have child routes');
      // The key for the Navigator that will display this ShellRoute's page.
      final GlobalKey<NavigatorState> parentNavigatorKey = navigatorKey;

      // Add an entry for the parent navigator if none exists.
      keyToPages.putIfAbsent(parentNavigatorKey, () => <Page<Object?>>[]);

      // Calling _buildRecursive can result in adding pages to the
      // parentNavigatorKey entry's list. Store the current length so
      // that the page for this ShellRoute is placed at the right index.
      final int shellPageIdx = keyToPages[parentNavigatorKey]!.length;

      // Get the current sub-route of this shell route from the match list.
      final RouteBase subRoute = matchList.matches[startIndex + 1].route;

      // The key to provide to the shell route's Navigator.
      final GlobalKey<NavigatorState> shellNavigatorKey =
          route.navigatorKeyForSubRoute(subRoute);

      // Add an entry for the shell route's navigator
      keyToPages.putIfAbsent(shellNavigatorKey, () => <Page<Object?>>[]);

      // Build the remaining pages
      _buildRecursive(context, matchList, startIndex + 1, pagePopContext,
          routerNeglect, keyToPages, shellNavigatorKey, registry);

      final HeroController heroController = _goHeroCache.putIfAbsent(
          shellNavigatorKey, () => _getHeroController(context));

      // Build the Navigator builder for this shell route
      final _RouteNavigatorBuilder navigatorBuilder = _RouteNavigatorBuilder._(
          this,
          state,
          route,
          heroController,
          shellNavigatorKey,
          keyToPages[shellNavigatorKey]!,
          pagePopContext);

      // Build the Page for this route
      final Page<Object?> page = _buildPageForRoute(
          context, state, match, pagePopContext,
          child: navigatorBuilder);
      registry[page] = state;
      // Place the ShellRoute's Page onto the list for the parent navigator.
      keyToPages
          .putIfAbsent(parentNavigatorKey, () => <Page<Object?>>[])
          .insert(shellPageIdx, page);
    }
  }

  /// Helper method that builds a [GoRouterState] object for the given [match]
  /// and [params].
  @visibleForTesting
  GoRouterState buildState(
      UnmodifiableRouteMatchList matchList, RouteMatch match) {
    final RouteBase route = match.route;
    String? name;
    String path = '';
    if (route is GoRoute) {
      name = route.name;
      path = route.path;
    }
    final RouteMatchList effectiveMatchList =
        match is ImperativeRouteMatch ? match.matches : matchList;
    final GoRouterState state = GoRouterState(
      configuration,
      matchList,
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
    return state;
  }

  /// Builds a [Page] for [StackedRoute]
  Page<Object?> _buildPageForRoute(BuildContext context, GoRouterState state,
      RouteMatch match, _PagePopContext pagePopContext,
      {Object? child}) {
    final RouteBase route = match.route;
    Page<Object?>? page;

    if (route is GoRoute) {
      // Call the pageBuilder if it's non-null
      final GoRouterPageBuilder? pageBuilder = route.pageBuilder;
      if (pageBuilder != null) {
        page = pageBuilder(context, state);
      }
    } else if (route is ShellRouteBase) {
      assert(child is ShellNavigatorBuilder,
          '${route.runtimeType} must contain a child');
      page = route.buildPage(context, state, child! as ShellNavigatorBuilder);
    }

    if (page is NoOpPage) {
      page = null;
    }

    page ??= buildPage(context, state, Builder(builder: (BuildContext context) {
      return _callRouteBuilder(context, state, match, child: child);
    }));
    pagePopContext._setRouteMatchForPage(page, match);

    // Return the result of the route's builder() or pageBuilder()
    return page;
  }

  /// Calls the user-provided route builder from the [RouteMatch]'s [RouteBase].
  Widget _callRouteBuilder(
      BuildContext context, GoRouterState state, RouteMatch match,
      {Object? child}) {
    final RouteBase route = match.route;

    if (route is GoRoute) {
      final GoRouterWidgetBuilder? builder = route.builder;

      if (builder == null) {
        throw _RouteBuilderError('No routeBuilder provided to GoRoute: $route');
      }

      return builder(context, state);
    } else if (route is ShellRouteBase) {
      if (child is! ShellNavigatorBuilder) {
        throw _RouteBuilderException(
            'Attempt to build ShellRoute without a child widget');
      }

      final Widget? widget = route.buildWidget(context, state, child);
      if (widget == null) {
        throw _RouteBuilderError('No builder provided to ShellRoute: $route');
      }

      return widget;
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
      name: state.name ?? state.path,
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
      RouteMatchList matchList,
      RouteBuilderPopPageCallback onPopPage,
      GlobalKey<NavigatorState> navigatorKey) {
    return _RouteNavigatorBuilder.buildNavigator(
      (Route<dynamic> route, dynamic result) => onPopPage(route, result, null),
      <Page<Object?>>[
        _buildErrorPage(context, e, matchList),
      ],
      navigatorKey,
    );
  }

  /// Builds a an error page.
  Page<void> _buildErrorPage(
    BuildContext context,
    _RouteBuilderError error,
    RouteMatchList matchList,
  ) {
    final Uri uri = matchList.uri;
    final GoRouterState state = GoRouterState(
      configuration,
      matchList.unmodifiableMatchList(),
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

  /// Return a HeroController based on the app type.
  HeroController _getHeroController(BuildContext context) {
    if (context is Element) {
      if (isMaterialApp(context)) {
        return createMaterialHeroController();
      } else if (isCupertinoApp(context)) {
        return createCupertinoHeroController();
      }
    }
    return HeroController();
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

/// Context used to provide a route to page association when popping routes.
class _PagePopContext {
  _PagePopContext._(this.routeBuilderOnPopPage);

  final Map<Page<dynamic>, RouteMatch> _routeMatchLookUp =
      <Page<Object?>, RouteMatch>{};

  /// On pop page callback that includes the associated [RouteMatch].
  final RouteBuilderPopPageCallback routeBuilderOnPopPage;

  /// Looks for the [RouteMatch] for a given [Page].
  ///
  /// The [Page] must have been previously built via the [RouteBuilder] that
  /// created this [PagePopContext]; otherwise, this method returns null.
  RouteMatch? getRouteMatchForPage(Page<Object?> page) =>
      _routeMatchLookUp[page];

  void _setRouteMatchForPage(Page<Object?> page, RouteMatch match) =>
      _routeMatchLookUp[page] = match;

  /// Function used as [Navigator.onPopPage] callback when creating Navigators.
  ///
  /// This function forwards to [routeBuilderOnPopPage], including the
  /// [RouteMatch] associated with the popped route.
  bool onPopPage(Route<dynamic> route, dynamic result) {
    final Page<Object?> page = route.settings as Page<Object?>;
    return routeBuilderOnPopPage(route, result, _routeMatchLookUp[page]);
  }
}

/// Provides support for building Navigators for routes.
class _RouteNavigatorBuilder extends ShellNavigatorBuilder {
  /// Constructs a NavigatorBuilder.
  _RouteNavigatorBuilder._(
    this.routeBuilder,
    this.state,
    this.currentRoute,
    this.heroController,
    this.navigatorKeyForCurrentRoute,
    this.pages,
    this.pagePopContext,
  );

  /// The route builder.
  final RouteBuilder routeBuilder;

  @override
  final GoRouterState state;

  @override
  final ShellRouteBase currentRoute;

  /// The hero controller.
  final HeroController heroController;

  @override
  final GlobalKey<NavigatorState> navigatorKeyForCurrentRoute;

  /// The pages for the current route.
  final List<Page<Object?>> pages;

  /// The page pop context.
  final _PagePopContext pagePopContext;

  /// Builds a navigator.
  static Widget buildNavigator(
    PopPageCallback onPopPage,
    List<Page<Object?>> pages,
    Key? navigatorKey, {
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
    HeroController? heroController,
  }) {
    final Widget navigator = Navigator(
      key: navigatorKey,
      restorationScopeId: restorationScopeId,
      pages: pages,
      observers: observers ?? const <NavigatorObserver>[],
      onPopPage: onPopPage,
    );
    if (heroController != null) {
      return HeroControllerScope(
        controller: heroController,
        child: navigator,
      );
    } else {
      return navigator;
    }
  }

  @override
  Widget buildNavigatorForCurrentRoute({
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return buildNavigator(
      pagePopContext.onPopPage,
      pages,
      navigatorKey ?? navigatorKeyForCurrentRoute,
      observers: observers,
      restorationScopeId: restorationScopeId,
      heroController: heroController,
    );
  }

  @override
  Future<Widget?> buildPreloadedShellNavigator({
    required BuildContext context,
    required String location,
    required GlobalKey<NavigatorState> navigatorKey,
    required ShellRouteBase parentShellRoute,
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
  }) {
    // Parse a RouteMatchList from location and handle any redirects
    final GoRouteInformationParser parser =
        GoRouter.of(context).routeInformationParser;
    final Future<RouteMatchList> routeMatchList =
        parser.parseRouteInformationWithDependencies(
      RouteInformation(location: location),
      context,
    );

    Widget? buildNavigator(RouteMatchList matchList) {
      // Find the index of fromRoute in the match list
      final int parentShellRouteIndex = matchList.matches
          .indexWhere((RouteMatch e) => e.route == parentShellRoute);
      if (parentShellRouteIndex >= 0) {
        final int startIndex = parentShellRouteIndex + 1;
        final GlobalKey<NavigatorState> routeNavigatorKey = parentShellRoute
            .navigatorKeyForSubRoute(matchList.matches[startIndex].route);
        assert(
            navigatorKey == routeNavigatorKey,
            'Incorrect shell navigator key '
            'for preloaded match list for location "$location"');

        return routeBuilder.buildPreloadedNestedNavigator(
          context,
          matchList,
          parentShellRouteIndex + 1,
          pagePopContext.routeBuilderOnPopPage,
          true,
          navigatorKey,
          restorationScopeId: restorationScopeId,
          observers: observers,
        );
      } else {
        return null;
      }
    }

    return routeMatchList.then(buildNavigator);
  }
}
