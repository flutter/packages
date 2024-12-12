// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

typedef _PageBuilderForAppType = Page<void> Function({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
});

typedef _ErrorBuilderForAppType = Widget Function(
  BuildContext context,
  GoRouterState state,
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
    Route<dynamic> route, dynamic result, RouteMatchBase match);

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

  /// A callback called when a `route` produced by `match` is about to be popped
  /// with the `result`.
  ///
  /// If this method returns true, this builder pops the `route` and `match`.
  ///
  /// If this method returns false, this builder aborts the pop.
  final PopPageWithRouteMatchCallback onPopPageWithRouteMatch;

  /// Builds the top-level Navigator for the given [RouteMatchList].
  Widget build(
    BuildContext context,
    RouteMatchList matchList,
    bool routerNeglect, // TODO(tolo): This parameter is not used and should be
    // removed in the next major version.
  ) {
    if (matchList.isEmpty && !matchList.isError) {
      // The build method can be called before async redirect finishes. Build a
      // empty box until then.
      return const SizedBox.shrink();
    }
    assert(matchList.isError || !matchList.last.route.redirectOnly);
    return builderWithNav(
      context,
      _CustomNavigator(
        // The state needs to persist across rebuild.
        key: GlobalObjectKey(configuration.navigatorKey.hashCode),
        navigatorKey: configuration.navigatorKey,
        observers: observers,
        navigatorRestorationId: restorationScopeId,
        onPopPageWithRouteMatch: onPopPageWithRouteMatch,
        matchList: matchList,
        matches: matchList.matches,
        configuration: configuration,
        errorBuilder: errorBuilder,
        errorPageBuilder: errorPageBuilder,
      ),
    );
  }
}

class _CustomNavigator extends StatefulWidget {
  const _CustomNavigator({
    super.key,
    required this.navigatorKey,
    required this.observers,
    required this.navigatorRestorationId,
    required this.onPopPageWithRouteMatch,
    required this.matchList,
    required this.matches,
    required this.configuration,
    required this.errorBuilder,
    required this.errorPageBuilder,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final List<NavigatorObserver> observers;

  /// The actual [RouteMatchBase]s to be built.
  ///
  /// This can be different from matches in [matchList] if this widget is used
  /// to build navigator in shell route. In this case, these matches come from
  /// the [ShellRouteMatch.matches].
  final List<RouteMatchBase> matches;
  final RouteMatchList matchList;
  final RouteConfiguration configuration;
  final PopPageWithRouteMatchCallback onPopPageWithRouteMatch;
  final String? navigatorRestorationId;
  final GoRouterWidgetBuilder? errorBuilder;
  final GoRouterPageBuilder? errorPageBuilder;

  @override
  State<StatefulWidget> createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends State<_CustomNavigator> {
  HeroController? _controller;
  late Map<Page<Object?>, RouteMatchBase> _pageToRouteMatchBase;
  final GoRouterStateRegistry _registry = GoRouterStateRegistry();
  List<Page<Object?>>? _pages;

  @override
  void didUpdateWidget(_CustomNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matchList != oldWidget.matchList) {
      _pages = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create a HeroController based on the app type.
    if (_controller == null) {
      if (isMaterialApp(context)) {
        _controller = createMaterialHeroController();
      } else if (isCupertinoApp(context)) {
        _controller = createCupertinoHeroController();
      } else {
        _controller = HeroController();
      }
    }
    // This method can also be called if any of the page builders depend on
    // the context. In this case, make sure _pages are rebuilt.
    _pages = null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _registry.dispose();
    super.dispose();
  }

  void _updatePages(BuildContext context) {
    assert(_pages == null);
    final List<Page<Object?>> pages = <Page<Object?>>[];
    final Map<Page<Object?>, RouteMatchBase> pageToRouteMatchBase =
        <Page<Object?>, RouteMatchBase>{};
    final Map<Page<Object?>, GoRouterState> registry =
        <Page<Object?>, GoRouterState>{};
    if (widget.matchList.isError) {
      pages.add(_buildErrorPage(context, widget.matchList));
    } else {
      for (final RouteMatchBase match in widget.matches) {
        final Page<Object?>? page = _buildPage(context, match);
        if (page == null) {
          continue;
        }
        pages.add(page);
        pageToRouteMatchBase[page] = match;
        registry[page] =
            match.buildState(widget.configuration, widget.matchList);
      }
    }
    _pages = pages;
    _registry.updateRegistry(registry);
    _pageToRouteMatchBase = pageToRouteMatchBase;
  }

  Page<Object?>? _buildPage(BuildContext context, RouteMatchBase match) {
    if (match is RouteMatch) {
      if (match is ImperativeRouteMatch && match.matches.isError) {
        return _buildErrorPage(context, match.matches);
      }
      return _buildPageForGoRoute(context, match);
    }
    if (match is ShellRouteMatch) {
      return _buildPageForShellRoute(context, match);
    }
    throw GoError('unknown match type ${match.runtimeType}');
  }

  /// Builds a [Page] for a [RouteMatch]
  Page<Object?>? _buildPageForGoRoute(BuildContext context, RouteMatch match) {
    final GoRouterPageBuilder? pageBuilder = match.route.pageBuilder;
    final GoRouterState state =
        match.buildState(widget.configuration, widget.matchList);
    if (pageBuilder != null) {
      final Page<Object?> page = pageBuilder(context, state);
      if (page is! NoOpPage) {
        return page;
      }
    }

    final GoRouterWidgetBuilder? builder = match.route.builder;

    if (builder == null) {
      return null;
    }
    return _buildPlatformAdapterPage(context, state,
        Builder(builder: (BuildContext context) {
      return builder(context, state);
    }));
  }

  /// Builds a [Page] for a [ShellRouteMatch]
  Page<Object?> _buildPageForShellRoute(
    BuildContext context,
    ShellRouteMatch match,
  ) {
    final GoRouterState state =
        match.buildState(widget.configuration, widget.matchList);
    final GlobalKey<NavigatorState> navigatorKey = match.navigatorKey;
    final ShellRouteContext shellRouteContext = ShellRouteContext(
      route: match.route,
      routerState: state,
      navigatorKey: navigatorKey,
      match: match,
      routeMatchList: widget.matchList,
      navigatorBuilder: (
        GlobalKey<NavigatorState> navigatorKey,
        ShellRouteMatch match,
        RouteMatchList matchList,
        List<NavigatorObserver>? observers,
        String? restorationScopeId,
      ) {
        return _CustomNavigator(
          // The state needs to persist across rebuild.
          key: GlobalObjectKey(navigatorKey.hashCode),
          navigatorRestorationId: restorationScopeId,
          navigatorKey: navigatorKey,
          matches: match.matches,
          matchList: matchList,
          configuration: widget.configuration,
          observers: observers ?? const <NavigatorObserver>[],
          onPopPageWithRouteMatch: widget.onPopPageWithRouteMatch,
          // This is used to recursively build pages under this shell route.
          errorBuilder: widget.errorBuilder,
          errorPageBuilder: widget.errorPageBuilder,
        );
      },
    );
    final Page<Object?>? page =
        match.route.buildPage(context, state, shellRouteContext);
    if (page != null && page is! NoOpPage) {
      return page;
    }

    // Return the result of the route's builder() or pageBuilder()
    return _buildPlatformAdapterPage(
      context,
      state,
      Builder(
        builder: (BuildContext context) {
          return match.route.buildWidget(context, state, shellRouteContext)!;
        },
      ),
    );
  }

  _PageBuilderForAppType? _pageBuilderForAppType;

  _ErrorBuilderForAppType? _errorBuilderForAppType;

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
        _pageBuilderForAppType = ({
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
        _errorBuilderForAppType =
            (BuildContext c, GoRouterState s) => ErrorScreen(s.error);
      }
    }

    assert(_pageBuilderForAppType != null);
    assert(_errorBuilderForAppType != null);
  }

  /// builds the page based on app type, i.e. MaterialApp vs. CupertinoApp
  Page<Object?> _buildPlatformAdapterPage(
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

  GoRouterState _buildErrorState(RouteMatchList matchList) {
    assert(matchList.isError);
    return GoRouterState(
      widget.configuration,
      uri: matchList.uri,
      matchedLocation: matchList.uri.path,
      fullPath: matchList.fullPath,
      pathParameters: matchList.pathParameters,
      error: matchList.error,
      pageKey: ValueKey<String>('${matchList.uri}(error)'),
      topRoute: matchList.lastOrNull?.route,
    );
  }

  /// Builds a an error page.
  Page<void> _buildErrorPage(BuildContext context, RouteMatchList matchList) {
    final GoRouterState state = _buildErrorState(matchList);
    assert(state.error != null);

    // If the error page builder is provided, use that, otherwise, if the error
    // builder is provided, wrap that in an app-specific page (for example,
    // MaterialPage). Finally, if nothing is provided, use a default error page
    // wrapped in the app-specific page.
    _cacheAppType(context);
    final GoRouterWidgetBuilder? errorBuilder = widget.errorBuilder;
    return widget.errorPageBuilder != null
        ? widget.errorPageBuilder!(context, state)
        : _buildPlatformAdapterPage(
            context,
            state,
            errorBuilder != null
                ? errorBuilder(context, state)
                : _errorBuilderForAppType!(context, state),
          );
  }

  bool _handlePopPage(Route<Object?> route, Object? result) {
    final Page<Object?> page = route.settings as Page<Object?>;
    final RouteMatchBase match = _pageToRouteMatchBase[page]!;
    return widget.onPopPageWithRouteMatch(route, result, match);
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == null) {
      _updatePages(context);
    }
    assert(_pages != null);
    return GoRouterStateRegistryScope(
      registry: _registry,
      child: HeroControllerScope(
        controller: _controller!,
        child: Navigator(
          key: widget.navigatorKey,
          restorationScopeId: widget.navigatorRestorationId,
          pages: _pages!,
          observers: widget.observers,
          onPopPage: _handlePopPage,
        ),
      ),
    );
  }
}
