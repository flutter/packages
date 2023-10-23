// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'logging.dart';
import 'match.dart';
import 'misc/error_screen.dart';
import 'misc/errors.dart';
import 'pages/cupertino.dart';
import 'pages/custom_transition_page.dart';
import 'pages/material.dart';
import 'route.dart';
import 'route_data.dart';
import 'state.dart';

/// Signature of a go router builder function with navigator.
typedef GoRouterBuilderWithNav = Widget Function(
  BuildContext context,
  Widget child,
);

/// Signature for a function that takes in a `route` to be popped with
/// the `result` and returns a boolean decision on whether the pop
/// is successful.
///
/// The `match` is the corresponding [RouteMatch] the `route`
/// associates with.
///
/// Used by of [RouteBuilder.onPopPageWithRouteMatch].
typedef PopPageWithRouteMatchCallback = bool Function(
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
    required this.onPopPageWithRouteMatch,
    this.requestFocus = true,
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

  /// Whether or not the navigator created by this builder and it's new topmost route should request focus
  /// when the new route is pushed onto the navigator.
  ///
  /// Defaults to true.
  final bool requestFocus;

  /// NavigatorObserver used to receive notifications when navigating in between routes.
  /// changes.
  final List<NavigatorObserver> observers;

  final GoRouterStateRegistry _registry = GoRouterStateRegistry();

  /// A callback called when a `route` produced by `match` is about to be popped
  /// with the `result`.
  ///
  /// If this method returns true, this builder pops the `route` and `match`.
  ///
  /// If this method returns false, this builder aborts the pop.
  final PopPageWithRouteMatchCallback onPopPageWithRouteMatch;

  /// Caches a HeroController for the nested Navigator, which solves cases where the
  /// Hero Widget animation stops working when navigating.
  // TODO(chunhtai): Remove _goHeroCache once below issue is fixed:
  // https://github.com/flutter/flutter/issues/54200
  final Map<GlobalKey<NavigatorState>, HeroController> _goHeroCache =
      <GlobalKey<NavigatorState>, HeroController>{};

  /// Builds the top-level Navigator for the given [RouteMatchList].
  Widget build(
    BuildContext context,
    RouteMatchList matchList,
    bool routerNeglect,
  ) {
    if (matchList.isEmpty && !matchList.isError) {
      // The build method can be called before async redirect finishes. Build a
      // empty box until then.
      return const SizedBox.shrink();
    }
    assert(
        matchList.isError || !(matchList.last.route as GoRoute).redirectOnly);
    return builderWithNav(
      context,
      Builder(
        builder: (BuildContext context) {
          final Map<Page<Object?>, GoRouterState> newRegistry =
              <Page<Object?>, GoRouterState>{};
          final Widget result = tryBuild(context, matchList, routerNeglect,
              configuration.navigatorKey, newRegistry);
          _registry.updateRegistry(newRegistry);
          return GoRouterStateRegistryScope(registry: _registry, child: result);
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
    bool routerNeglect,
    GlobalKey<NavigatorState> navigatorKey,
    Map<Page<Object?>, GoRouterState> registry,
  ) {
    // TODO(chunhtai): move the state from local scope to a central place.
    // https://github.com/flutter/flutter/issues/126365
    final _PagePopContext pagePopContext =
        _PagePopContext._(onPopPageWithRouteMatch);
    return builderWithNav(
      context,
      _buildNavigator(
        pagePopContext.onPopPage,
        _buildPages(context, matchList, pagePopContext, routerNeglect,
            navigatorKey, registry),
        navigatorKey,
        observers: observers,
        restorationScopeId: restorationScopeId,
        requestFocus: requestFocus,
      ),
    );
  }

  /// Returns the top-level pages instead of the root navigator. Used for
  /// testing.
  List<Page<Object?>> _buildPages(
      BuildContext context,
      RouteMatchList matchList,
      _PagePopContext pagePopContext,
      bool routerNeglect,
      GlobalKey<NavigatorState> navigatorKey,
      Map<Page<Object?>, GoRouterState> registry) {
    final Map<GlobalKey<NavigatorState>, List<Page<Object?>>> keyToPage;
    if (matchList.isError) {
      keyToPage = <GlobalKey<NavigatorState>, List<Page<Object?>>>{
        navigatorKey: <Page<Object?>>[
          _buildErrorPage(context, _buildErrorState(matchList)),
        ]
      };
    } else {
      keyToPage = <GlobalKey<NavigatorState>, List<Page<Object?>>>{};
      _buildRecursive(context, matchList, 0, pagePopContext, routerNeglect,
          keyToPage, navigatorKey, registry);

      // Every Page should have a corresponding RouteMatch.
      assert(keyToPage.values.flattened.every((Page<Object?> page) =>
          pagePopContext.getRouteMatchesForPage(page) != null));
    }

    /// Clean up previous cache to prevent memory leak, making sure any nested
    /// stateful shell routes for the current match list are kept.
    final Set<Key> activeKeys = keyToPage.keys.toSet()
      ..addAll(_nestedStatefulNavigatorKeys(matchList));
    _goHeroCache.removeWhere(
        (GlobalKey<NavigatorState> key, _) => !activeKeys.contains(key));
    return keyToPage[navigatorKey]!;
  }

  static Set<GlobalKey<NavigatorState>> _nestedStatefulNavigatorKeys(
      RouteMatchList matchList) {
    final StatefulShellRoute? shellRoute =
        matchList.routes.whereType<StatefulShellRoute>().firstOrNull;
    if (shellRoute == null) {
      return <GlobalKey<NavigatorState>>{};
    }
    return RouteBase.routesRecursively(<RouteBase>[shellRoute])
        .whereType<StatefulShellRoute>()
        .expand((StatefulShellRoute e) =>
            e.branches.map((StatefulShellBranch b) => b.navigatorKey))
        .toSet();
  }

  void _buildRecursive(
    BuildContext context,
    RouteMatchList matchList,
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

    final RouteBase route = match.route;
    final GoRouterState state = buildState(matchList, match);
    Page<Object?>? page;
    if (state.error != null) {
      page = _buildErrorPage(context, state);
      keyToPages.putIfAbsent(navigatorKey, () => <Page<Object?>>[]).add(page);
      _buildRecursive(context, matchList, startIndex + 1, pagePopContext,
          routerNeglect, keyToPages, navigatorKey, registry);
    } else {
      // If this RouteBase is for a different Navigator, add it to the
      // list of out of scope pages
      final GlobalKey<NavigatorState> routeNavKey =
          route.parentNavigatorKey ?? navigatorKey;
      if (route is GoRoute) {
        page =
            _buildPageForGoRoute(context, state, match, route, pagePopContext);
        assert(page != null || route.redirectOnly);
        if (page != null) {
          keyToPages
              .putIfAbsent(routeNavKey, () => <Page<Object?>>[])
              .add(page);
        }

        _buildRecursive(context, matchList, startIndex + 1, pagePopContext,
            routerNeglect, keyToPages, navigatorKey, registry);
      } else if (route is ShellRouteBase) {
        assert(startIndex + 1 < matchList.matches.length,
            'Shell routes must always have child routes');

        // Add an entry for the parent navigator if none exists.
        //
        // Calling _buildRecursive can result in adding pages to the
        // parentNavigatorKey entry's list. Store the current length so
        // that the page for this ShellRoute is placed at the right index.
        final int shellPageIdx =
            keyToPages.putIfAbsent(routeNavKey, () => <Page<Object?>>[]).length;

        // Find the the navigator key for the sub-route of this shell route.
        final RouteBase subRoute = matchList.matches[startIndex + 1].route;
        final GlobalKey<NavigatorState> shellNavigatorKey =
            route.navigatorKeyForSubRoute(subRoute);

        keyToPages.putIfAbsent(shellNavigatorKey, () => <Page<Object?>>[]);

        // Build the remaining pages
        _buildRecursive(context, matchList, startIndex + 1, pagePopContext,
            routerNeglect, keyToPages, shellNavigatorKey, registry);

        final HeroController heroController = _goHeroCache.putIfAbsent(
            shellNavigatorKey, () => _getHeroController(context));

        // Build the Navigator for this shell route
        Widget buildShellNavigator(
          List<NavigatorObserver>? observers,
          String? restorationScopeId, {
          bool requestFocus = true,
        }) {
          return _buildNavigator(
            pagePopContext.onPopPage,
            keyToPages[shellNavigatorKey]!,
            shellNavigatorKey,
            observers: observers ?? const <NavigatorObserver>[],
            restorationScopeId: restorationScopeId,
            heroController: heroController,
            requestFocus: requestFocus,
          );
        }

        // Call the ShellRouteBase to create/update the shell route state
        final ShellRouteContext shellRouteContext = ShellRouteContext(
          route: route,
          routerState: state,
          navigatorKey: shellNavigatorKey,
          routeMatchList: matchList,
          navigatorBuilder: buildShellNavigator,
        );

        // Build the Page for this route
        page = _buildPageForShellRoute(
            context, state, match, route, pagePopContext, shellRouteContext);
        // Place the ShellRoute's Page onto the list for the parent navigator.
        keyToPages[routeNavKey]!.insert(shellPageIdx, page);
      }
    }
    if (page != null) {
      registry[page] = state;
      // Insert the route match in reverse order.
      pagePopContext._insertRouteMatchAtStartForPage(page, match);
    }
  }

  static Widget _buildNavigator(
    PopPageCallback onPopPage,
    List<Page<Object?>> pages,
    Key? navigatorKey, {
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    String? restorationScopeId,
    HeroController? heroController,
    bool requestFocus = true,
  }) {
    final Widget navigator = Navigator(
      key: navigatorKey,
      restorationScopeId: restorationScopeId,
      pages: pages,
      observers: observers,
      onPopPage: onPopPage,
      requestFocus: requestFocus,
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

  /// Helper method that builds a [GoRouterState] object for the given [match]
  /// and [pathParameters].
  @visibleForTesting
  GoRouterState buildState(RouteMatchList matchList, RouteMatch match) {
    final RouteBase route = match.route;
    String? name;
    String path = '';
    if (route is GoRoute) {
      name = route.name;
      path = route.path;
    }
    final RouteMatchList effectiveMatchList;
    if (match is ImperativeRouteMatch) {
      effectiveMatchList = match.matches;
      if (effectiveMatchList.isError) {
        return _buildErrorState(effectiveMatchList);
      }
    } else {
      effectiveMatchList = matchList;
      assert(!effectiveMatchList.isError);
    }
    return GoRouterState(
      configuration,
      uri: effectiveMatchList.uri,
      matchedLocation: match.matchedLocation,
      name: name,
      path: path,
      fullPath: effectiveMatchList.fullPath,
      pathParameters:
          Map<String, String>.from(effectiveMatchList.pathParameters),
      error: effectiveMatchList.error,
      extra: effectiveMatchList.extra,
      pageKey: match.pageKey,
    );
  }

  /// Builds a [Page] for [GoRoute]
  Page<Object?>? _buildPageForGoRoute(BuildContext context, GoRouterState state,
      RouteMatch match, GoRoute route, _PagePopContext pagePopContext) {
    // Call the pageBuilder if it's non-null
    final GoRouterPageBuilder? pageBuilder = route.pageBuilder;
    if (pageBuilder != null) {
      final Page<Object?> page = pageBuilder(context, state);
      if (page is! NoOpPage) {
        return page;
      }
    }
    return _callGoRouteBuilder(context, state, route);
  }

  /// Calls the user-provided route builder from the [GoRoute].
  Page<Object?>? _callGoRouteBuilder(
      BuildContext context, GoRouterState state, GoRoute route) {
    final GoRouterWidgetBuilder? builder = route.builder;

    if (builder == null) {
      return null;
    }
    return buildPage(context, state, Builder(builder: (BuildContext context) {
      return builder(context, state);
    }));
  }

  /// Builds a [Page] for [ShellRouteBase]
  Page<Object?> _buildPageForShellRoute(
      BuildContext context,
      GoRouterState state,
      RouteMatch match,
      ShellRouteBase route,
      _PagePopContext pagePopContext,
      ShellRouteContext shellRouteContext) {
    Page<Object?>? page = route.buildPage(context, state, shellRouteContext);
    if (page is NoOpPage) {
      page = null;
    }

    // Return the result of the route's builder() or pageBuilder()
    return page ??
        buildPage(context, state, Builder(builder: (BuildContext context) {
          return _callShellRouteBaseBuilder(
              context, state, route, shellRouteContext);
        }));
  }

  /// Calls the user-provided route builder from the [ShellRouteBase].
  Widget _callShellRouteBaseBuilder(BuildContext context, GoRouterState state,
      ShellRouteBase route, ShellRouteContext? shellRouteContext) {
    assert(shellRouteContext != null,
        'ShellRouteContext must be provided for ${route.runtimeType}');
    final Widget? widget =
        route.buildWidget(context, state, shellRouteContext!);
    if (widget == null) {
      throw GoError('No builder provided to ShellRoute: $route');
    }

    return widget;
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
        log('Using MaterialApp configuration');
        _pageBuilderForAppType = pageBuilderForMaterialApp;
        _errorBuilderForAppType =
            (BuildContext c, GoRouterState s) => MaterialErrorScreen(s.error);
      } else if (elem != null && isCupertinoApp(elem)) {
        log('Using CupertinoApp configuration');
        _pageBuilderForAppType = pageBuilderForCupertinoApp;
        _errorBuilderForAppType =
            (BuildContext c, GoRouterState s) => CupertinoErrorScreen(s.error);
      } else {
        log('Using WidgetsApp configuration');
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
      arguments: <String, String>{
        ...state.pathParameters,
        ...state.uri.queryParameters
      },
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

  GoRouterState _buildErrorState(RouteMatchList matchList) {
    assert(matchList.isError);
    return GoRouterState(
      configuration,
      uri: matchList.uri,
      matchedLocation: matchList.uri.path,
      fullPath: matchList.fullPath,
      pathParameters: matchList.pathParameters,
      error: matchList.error,
      pageKey: ValueKey<String>('${matchList.uri}(error)'),
    );
  }

  /// Builds a an error page.
  Page<void> _buildErrorPage(BuildContext context, GoRouterState state) {
    assert(state.error != null);

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

/// Context used to provide a route to page association when popping routes.
class _PagePopContext {
  _PagePopContext._(this.onPopPageWithRouteMatch);

  /// A page can be mapped to a RouteMatch list, such as a const page being
  /// pushed multiple times.
  final Map<Page<dynamic>, List<RouteMatch>> _routeMatchesLookUp =
      <Page<Object?>, List<RouteMatch>>{};

  /// On pop page callback that includes the associated [RouteMatch].
  final PopPageWithRouteMatchCallback onPopPageWithRouteMatch;

  /// Looks for the [RouteMatch] for a given [Page].
  ///
  /// The [Page] must have been previously built via the [RouteBuilder] that
  /// created this [PagePopContext]; otherwise, this method returns null.
  List<RouteMatch>? getRouteMatchesForPage(Page<Object?> page) =>
      _routeMatchesLookUp[page];

  /// This is called in _buildRecursive to insert route matches in reverse order.
  void _insertRouteMatchAtStartForPage(Page<Object?> page, RouteMatch match) {
    _routeMatchesLookUp
        .putIfAbsent(page, () => <RouteMatch>[])
        .insert(0, match);
  }

  /// Function used as [Navigator.onPopPage] callback when creating Navigators.
  ///
  /// This function forwards to [onPopPageWithRouteMatch], including the
  /// [RouteMatch] associated with the popped route.
  ///
  /// This assumes always pop the last route match for the page.
  bool onPopPage(Route<dynamic> route, dynamic result) {
    final Page<Object?> page = route.settings as Page<Object?>;
    final RouteMatch match = _routeMatchesLookUp[page]!.last;
    if (onPopPageWithRouteMatch(route, result, match)) {
      _routeMatchesLookUp[page]!.removeLast();
      return true;
    }
    return false;
  }
}
