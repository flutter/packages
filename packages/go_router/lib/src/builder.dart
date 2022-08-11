// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';
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

  /// Builds the top-level Navigator for the given [RouteMatchList].
  Widget build(
    BuildContext context,
    RouteMatchList matchList,
    VoidCallback pop,
    bool routerNeglect,
  ) {
    try {
      return tryBuild(
          context, matchList, pop, routerNeglect, configuration.navigatorKey);
    } on RouteBuilderError catch (e) {
      return buildErrorNavigator(
          context,
          e,
          Uri.parse(matchList.location.toString()),
          pop,
          configuration.navigatorKey);
    }
  }

  /// Builds the top-level Navigator by invoking the build method on each
  /// matching route.
  ///
  /// Throws a [RouteBuilderError].
  @visibleForTesting
  Widget tryBuild(
    BuildContext context,
    RouteMatchList matchList,
    VoidCallback pop,
    bool routerNeglect,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    return _buildRecursive(context, matchList, 0, pop, routerNeglect,
        navigatorKey, <String, String>{}).widget;
  }

  /// Returns the top-level pages instead of the root navigator. Used for
  /// testing.
  @visibleForTesting
  List<Page<dynamic>> buildPages(
      BuildContext context, RouteMatchList matchList) {
    try {
      return _buildRecursive(context, matchList, 0, () {}, false,
          GlobalKey<NavigatorState>(), <String, String>{}).pages;
    } on RouteBuilderError catch (e) {
      return <Page<dynamic>>[
        buildErrorPage(context, e, matchList.location),
      ];
    }
  }

  _RecursiveBuildResult _buildRecursive(
    BuildContext context,
    RouteMatchList matchList,
    int startIndex,
    VoidCallback pop,
    bool routerNeglect, // TODO(johnpryan): Is this working? Needs a test...
    Key navigatorKey,
    Map<String, String> params,
  ) {
    final List<Page<dynamic>> pages = <Page<dynamic>>[];
    final List<_OutOfScopePage> pagesForOutOfScopeNavigator =
        <_OutOfScopePage>[];

    for (int i = startIndex; i < matchList.matches.length; i++) {
      final RouteMatch match = matchList.matches[i];

      if (match.error != null) {
        throw RouteBuilderError('Match error found during build phase',
            exception: match.error);
      }

      final RouteBase route = match.route;
      final Map<String, String> newParams = <String, String>{
        ...params,
        ...match.decodedParams
      };
      if (route is GoRoute) {
        final GoRouterState state = buildState(match, newParams);
        final Page<dynamic> page = buildGoRoutePage(context, state, match);

        // If this GoRoute is for a different Navigator, add it to the
        // pagesForOutOfScopeNavigator list instead.
        if (route.navigatorKey != null) {
          pagesForOutOfScopeNavigator
              .add(_OutOfScopePage(page, route.navigatorKey!));
        } else {
          pages.add(page);
        }
      } else if (route is ShellRoute) {
        final GoRouterState state = buildState(match, newParams);
        final _RecursiveBuildResult result = _buildRecursive(
            context,
            matchList,
            i + 1,
            pop,
            routerNeglect,
            // Use a default unique key for the Navigator if none is provided.
            route.shellNavigatorKey ?? state.pageKey,
            newParams);
        final Widget child = result.widget;

        final Page<dynamic> page = buildPage(context, state,
            callRouteBuilder(context, state, match, childWidget: child));

        // If this ShellRoute is for a different Navigator, add it to the
        // pagesForOutOfScopeNavigator list instead.
        if (route.navigatorKey != null) {
          pagesForOutOfScopeNavigator
              .add(_OutOfScopePage(page, route.navigatorKey!));
        } else {
          pages.add(page);
        }

        // If any descendent GoRoutes have pages that are out of scope for this
        // navigator, Add them to the list of routes that are out of scope. If
        // they are in scope, add them to the list of pages for this navigator.
        final List<_OutOfScopePage> pagesOutOfScopeForChildNavigator =
            result.pagesForOutOfScopeNavigator;
        for (final _OutOfScopePage outOfScopePage
            in pagesOutOfScopeForChildNavigator) {
          if (outOfScopePage.navigatorKey == route.shellNavigatorKey) {
            pages.add(page);
          } else {
            pagesForOutOfScopeNavigator.add(outOfScopePage);
          }
        }

        i = result.newIndex;
      }
    }

    // Add any pages that were out of scope to this Navigator if the keys match.
    for (final _OutOfScopePage outOfScopePage in pagesForOutOfScopeNavigator) {
      if (outOfScopePage.navigatorKey == navigatorKey) {
        pages.add(outOfScopePage.page);
      }
    }

    Widget? child;
    if (pages.isNotEmpty) {
      child = buildNavigator(
        context,
        Uri.parse(matchList.location.toString()),
        matchList.isError ? matchList.error : null,
        navigatorKey,
        pop,
        pages,
        root: startIndex == 0,
      );
    } else if (startIndex == 0) {
      // It's an error to have an empty pages list on the root Navigator.
      throw RouteBuilderError('No pages built for root Navigator');
    }

    return _RecursiveBuildResult(child ?? const SizedBox.shrink(), pages,
        pagesForOutOfScopeNavigator, matchList.matches.length);
  }

  /// Helper method that calls [builderWithNav] with the [GoRouterState]
  @visibleForTesting
  Widget buildNavigator(BuildContext context, Uri uri, Exception? exception,
      Key navigatorKey, VoidCallback pop, List<Page<dynamic>> pages,
      {bool root = true}) {
    if (root) {
      return builderWithNav(
        context,
        GoRouterState(
          configuration,
          location: uri.toString(),
          // no name available at the top level
          name: null,
          // trim the query params off the subloc to match route.redirect
          subloc: uri.path,
          // pass along the query params 'cuz that's all we have right now
          queryParams: uri.queryParameters,
          // pass along the error, if there is one
          error: exception,
        ),
        Navigator(
          restorationScopeId: restorationScopeId,
          key: navigatorKey,
          pages: pages,
          observers: observers,
          onPopPage: (Route<dynamic> route, dynamic result) {
            if (!route.didPop(result)) {
              return false;
            }
            pop();
            return true;
          },
        ),
      );
    } else {
      return Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (Route<dynamic> route, dynamic result) {
          if (!route.didPop(result)) {
            return false;
          }
          pop();
          return true;
        },
      );
    }
  }

  /// Helper method that buidls a [GoRouterState] object for the given [match]
  /// and [params].
  @visibleForTesting
  GoRouterState buildState(RouteMatch match, Map<String, String> params) {
    return GoRouterState(
      configuration,
      location: match.fullUriString,
      subloc: match.subloc,
      name: match.route.name,
      path: match.route.path,
      fullpath: match.fullpath,
      params: params,
      error: match.error,
      queryParams: match.queryParams,
      extra: match.extra,
      pageKey: match.pageKey, // push() remaps the page key for uniqueness
    );
  }

  /// Builds a [Page] for [StackedRoute]
  Page<dynamic> buildGoRoutePage(
      BuildContext context, GoRouterState state, RouteMatch match) {
    final RouteBase route = match.route;
    if (route is! GoRoute) {
      throw RouteBuilderError(
          'Unexpected route type in buildStackedRoute: $route');
    }

    // Call the pageBuilder if it's non-null
    final GoRouterPageBuilder? pageBuilder =
        (match.route as GoRoute).pageBuilder;
    Page<dynamic>? page;
    if (pageBuilder != null) {
      page = pageBuilder(context, state);
      if (page is NoOpPage) {
        page = null;
      }
    }

    // Return the result of the route's builder() or pageBuilder()
    return page ??
        buildPage(context, state, callRouteBuilder(context, state, match));
  }

  /// Calls the user-provided route builder from the [RouteMatch]'s [RouteBase].
  Widget callRouteBuilder(
      BuildContext context, GoRouterState state, RouteMatch match,
      {Widget? childWidget}) {
    final RouteBase route = match.route;

    if (route == null) {
      throw RouteBuilderError('No route found for match: $match');
    }

    if (route is GoRoute) {
      final GoRouterWidgetBuilder? builder = route.builder;
      if (builder != null) {
        // Use a Builder to ensure the route gets the correct BuildContext.
        return builder(context, state);
      }
    } else if (route is ShellRoute) {
      if (childWidget == null) {
        throw RouteBuilderError(
            'Attempt to build ShellRoute without a child widget');
      }
      // Use a Builder to ensure the route gets the correct BuildContext.
      return route.builder(context, state, childWidget);
    }

    throw UnimplementedError('Unsupported route type $route');
  }

  Page<void> Function({
    required LocalKey key,
    required String? name,
    required Object? arguments,
    required String restorationId,
    required Widget child,
  })? _pageBuilderForAppType;

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
  Page<dynamic> buildPage(
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
  Widget buildErrorNavigator(BuildContext context, RouteBuilderError e, Uri uri,
      VoidCallback pop, GlobalKey<NavigatorState> navigatorKey) {
    return buildNavigator(
        context, uri, Exception(e), navigatorKey, pop, <Page<dynamic>>[
      buildErrorPage(context, e, uri),
    ]);
  }

  /// Builds a an error page.
  Page<void> buildErrorPage(
    BuildContext context,
    RouteBuilderError error,
    Uri uri,
  ) {
    final GoRouterState state = GoRouterState(
      configuration,
      location: uri.toString(),
      subloc: uri.path,
      name: null,
      queryParams: uri.queryParameters,
      error: Exception(error),
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

class _RecursiveBuildResult {
  _RecursiveBuildResult(
      this.widget, this.pages, this.pagesForOutOfScopeNavigator, this.newIndex);

  final Widget widget;

  /// List of pages placed on the navigator. Used for testing.
  final List<Page<dynamic>> pages;

  /// List of pages placed on a Navigator that isn't in the current scope (such as the root navigator)
  final List<_OutOfScopePage> pagesForOutOfScopeNavigator;

  final int newIndex;
}

class _OutOfScopePage {
  _OutOfScopePage(this.page, this.navigatorKey);

  final Page<dynamic> page;
  final GlobalKey<NavigatorState> navigatorKey;
}

/// An error that occurred while building the app's UI based on the route
/// matches.
class RouteBuilderError extends Error {
  /// Constructs a [RouteBuilderError].
  RouteBuilderError(this.message, {this.exception});

  /// The error message.
  final String message;

  /// The exception that occurred.
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}
