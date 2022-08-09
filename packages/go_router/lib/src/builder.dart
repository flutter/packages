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
  final StackedRouteBuilder? errorBuilder;

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  /// NavigatorObserver used to receive notifications when navigating in between routes.
  /// changes.
  final List<NavigatorObserver> observers;

  Widget build(
    BuildContext context,
    RouteMatchList matchList,
    VoidCallback pop,
    bool routerNeglect,
  ) {
    try {
      return tryBuild(context, matchList, pop, routerNeglect);
    } on RouteBuilderError catch (e) {
      final String location = matchList.location.toString();
      final uri = Uri.parse(location);

      // Build error page
      return buildNavigator(
          context, uri, Exception(e), configuration.navigatorKey, pop, [
        buildErrorPage(context, e, uri),
      ]);
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
  ) {
    List<Page<dynamic>>? pages;
    Exception? exception;
    final String location = matchList.location.toString();
    final uri = Uri.parse(location);

    if (routerNeglect) {
      Router.neglect(
        context,
        () => pages = buildPages(context, matchList).toList(),
      );
    } else {
      pages = buildPages(context, matchList).toList();
    }

    // we should've set pages to something by now
    assert(pages != null);

    // pass either the match error or the build error along to the navigator
    // builder, preferring the match error
    if (matchList.isError) {
      exception = matchList.error;
    }

    return buildNavigator(
        context, uri, exception, configuration.navigatorKey, pop, pages!);
  }

  @visibleForTesting
  Widget buildNavigator(BuildContext context, Uri uri, Exception? exception,
      Key navigatorKey, VoidCallback pop, List<Page> pages) {
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
  }

  /// Builds the pages for the given [RouteMatchList].
  @visibleForTesting
  List<Page<dynamic>> buildPages(
    BuildContext context,
    RouteMatchList matchList,
  ) {
    try {
      return [...tryBuildPages(context, matchList)];
    } on RouteBuilderError catch (e) {
      return [
        buildErrorPage(context, e, Uri.parse(matchList.location.toString())),
      ];
    }
  }

  @visibleForTesting
  List<Page> tryBuildPages(
    BuildContext context,
    RouteMatchList matchList,
  ) {
    return _buildPagesRecursive(context, matchList, 0);
  }

  List<Page> _buildPagesRecursive(
      BuildContext context, RouteMatchList matchList, int startIndex) {
    final pages = <Page>[];
    var params = <String, String>{};
    for (var i = startIndex; i < matchList.matches.length; i++) {
      final match = matchList.matches[i];
      // Merge the parameters to combine them with previously matched paths
      params = <String, String>{...params, ...match.decodedParams};

      /// If matching reported an error, rethrow to build the error screen.
      if (match.error != null) {
        throw RouteBuilderError('Match error found during build phase: ',
            exception: match.error);
      }

      final route = match.route;
      if (route is GoRoute) {
        final state = buildState(match, params);

        pages.add(buildGoRoute(context, state, match));
      } else if (route is ShellRoute) {
        final state = buildState(match, params);
        // Build the rest of the routes recursively
        final result = buildShellRouteRecursive(context, state, matchList, i);
        final child = result.widget;

        pages.add(buildPage(context, state, child));

        // buildShellRouteRecursive looks ahead and can potentially build
        // additional StackedRoute objects. Adjust the index to the next route
        // that hasn't been built yet.
        i = result.newIndex;
      }
    }
    if (pages.isEmpty) {
      throw RouteBuilderError('No pages built');
    }
    return pages;
  }

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
  Page buildGoRoute(
      BuildContext context, GoRouterState state, RouteMatch match) {
    final route = match.route;
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

    // Return the result of builder() or pageBuilder()
    return page ??
        buildPage(
            context, state, (match.route as GoRoute).builder!(context, state));
  }

  /// Builds a [Page] for [ShellRoute]. Child routes are placed onto the root
  /// navigator.
  RecursiveBuildResult buildShellRouteRecursive(BuildContext context,
      GoRouterState state, RouteMatchList matchList, int i) {
    final parentMatch = matchList.matches[i];
    late final RouteMatch? childMatch;

    if (i + 1 < matchList.matches.length) {
      childMatch = matchList.matches[i + 1];
    } else {
      childMatch = null;
    }

    final childRoute = childMatch?.route ?? null;

    Widget? childWidget;
    if (childRoute is GoRoute) {
      // Build the child route
      childWidget = callRouteBuilder(context, state, childMatch!);
      i++;
    } else if (childRoute == null) {
      childWidget = const SizedBox.shrink();
      i++;
    }

    // // TODO: build Navigator?
    // final navigator = Navigator(
    //   key: (parentMatch.route as ShellRoute).navigatorKey,
    //   pages: [
    //     buildPage(context, state, childWidget!),
    //   ],
    // );

    final parentWidget =
        callRouteBuilder(context, state, parentMatch, childWidget: childWidget);
    return RecursiveBuildResult(parentWidget, i);
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
      final builder = route.builder;
      if (builder != null) {
        return builder(context, state);
      } else {
        // TODO(johnpryan): call pageBuilder
        throw UnimplementedError('pageBuilder is not supported yet...');
      }
    } else if (route is ShellRoute) {
      if (childWidget == null) {
        throw RouteBuilderError(
            'Attempt to build ShellRoute without a child widget');
      }
      return route.builder(context, state, childWidget);
    }

    throw UnimplementedError('Unsupported route type ${route}');
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

  // builds the page based on app type, i.e. MaterialApp vs. CupertinoApp
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

  Page<void> buildErrorPage(
    BuildContext context,
    RouteBuilderError error,
    Uri uri,
  ) {
    final state = GoRouterState(
      configuration,
      location: uri.toString(),
      subloc: uri.path,
      name: null,
      queryParams: uri.queryParameters,
      error: Exception(error),
    );

    // if the error page builder is provided, use that; otherwise, if the error
    // builder is provided, wrap that in an app-specific page, e.g.
    // MaterialPage; finally, if nothing is provided, use a default error page
    // wrapped in the app-specific page, e.g.
    // MaterialPage(GoRouterMaterialErrorPage(...))
    _cacheAppType(context);
    final errorBuilder = this.errorBuilder;
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

class RecursiveBuildResult {
  final Widget widget;
  final int newIndex;

  RecursiveBuildResult(this.widget, this.newIndex);
}

/// An error that occurred while building the app's UI based on the route
/// matches.
class RouteBuilderError extends Error {
  /// Constructs a [RouteBuilderError].
  RouteBuilderError(String message, {this.exception}) : message = message;

  /// The error message.
  final String message;
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}
