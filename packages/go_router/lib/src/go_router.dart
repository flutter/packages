// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'go_route.dart';
import 'go_route_information_parser.dart';
import 'go_route_information_provider.dart';
import 'go_route_match.dart';
import 'go_router_delegate.dart';
import 'go_router_state.dart';
import 'inherited_go_router.dart';
import 'logging.dart';
import 'path_strategy_nonweb.dart'
    if (dart.library.html) 'path_strategy_web.dart';
import 'typedefs.dart';
import 'url_path_strategy.dart';

/// The top-level go router class.
///
/// Create one of these to initialize your app's routing policy.
// ignore: prefer_mixin
class GoRouter extends ChangeNotifier with NavigatorObserver {
  /// Default constructor to configure a GoRouter with a routes builder
  /// and an error page builder.
  GoRouter({
    required List<GoRoute> routes,
    GoRouterPageBuilder? errorPageBuilder,
    GoRouterWidgetBuilder? errorBuilder,
    GoRouterRedirect? redirect,
    Listenable? refreshListenable,
    int redirectLimit = 5,
    bool routerNeglect = false,
    String? initialLocation,
    UrlPathStrategy? urlPathStrategy,
    List<NavigatorObserver>? observers,
    bool debugLogDiagnostics = false,
    GoRouterNavigatorBuilder? navigatorBuilder,
    String? restorationScopeId,
  }) {
    if (urlPathStrategy != null) {
      setUrlPathStrategy(urlPathStrategy);
    }

    setLogging(enabled: debugLogDiagnostics);
    WidgetsFlutterBinding.ensureInitialized();

    final String _effectiveInitialLocation = initialLocation ??
        // ignore: unnecessary_non_null_assertion
        WidgetsBinding.instance!.platformDispatcher.defaultRouteName;
    routeInformationParser = GoRouteInformationParser(
      routes: routes,
      topRedirect: redirect ?? (_) => null,
      redirectLimit: redirectLimit,
      debugRequireGoRouteInformationProvider: true,
    );
    routeInformationProvider = GoRouteInformationProvider(
        initialRouteInformation:
            RouteInformation(location: _effectiveInitialLocation),
        refreshListenable: refreshListenable);

    routerDelegate = GoRouterDelegate(
      routeInformationParser,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      routerNeglect: routerNeglect,
      observers: <NavigatorObserver>[
        ...observers ?? <NavigatorObserver>[],
        this
      ],
      restorationScopeId: restorationScopeId,
      // wrap the returned Navigator to enable GoRouter.of(context).go() et al,
      // allowing the caller to wrap the navigator themselves
      builderWithNav:
          (BuildContext context, GoRouterState state, Navigator nav) =>
              InheritedGoRouter(
        goRouter: this,
        child: navigatorBuilder?.call(context, state, nav) ?? nav,
      ),
    );
    assert(() {
      log.info('setting initial location $initialLocation');
      return true;
    }());
  }

  /// The route information parser used by the go router.
  late final GoRouteInformationParser routeInformationParser;

  /// The router delegate used by the go router.
  late final GoRouterDelegate routerDelegate;

  /// The route information provider used by the go router.
  late final GoRouteInformationProvider routeInformationProvider;

  /// Get the current location.
  String get location => routerDelegate.currentConfiguration.last.fullUriString;

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
  }) =>
      routeInformationParser.namedLocation(
        name,
        params: params,
        queryParams: queryParams,
      );

  /// Navigate to a URI location w/ optional query parameters, e.g.
  /// `/family/f2/person/p1?color=blue`
  void go(String location, {Object? extra}) {
    assert(() {
      log.info('going to $location');
      return true;
    }());
    routeInformationProvider.value =
        RouteInformation(location: location, state: extra);
  }

  /// Navigate to a named route w/ optional parameters, e.g.
  /// `name='person', params={'fid': 'f2', 'pid': 'p1'}`
  /// Navigate to the named route.
  void goNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
    Object? extra,
  }) =>
      go(
        namedLocation(name, params: params, queryParams: queryParams),
        extra: extra,
      );

  /// Push a URI location onto the page stack w/ optional query parameters, e.g.
  /// `/family/f2/person/p1?color=blue`
  void push(String location, {Object? extra}) {
    assert(() {
      log.info('pushing $location');
      return true;
    }());
    routeInformationParser
        .parseRouteInformation(
            DebugGoRouteInformation(location: location, state: extra))
        .then<void>((List<GoRouteMatch> matches) {
      routerDelegate.push(matches.last);
    });
  }

  /// Push a named route onto the page stack w/ optional parameters, e.g.
  /// `name='person', params={'fid': 'f2', 'pid': 'p1'}`
  void pushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
    Object? extra,
  }) =>
      push(
        namedLocation(name, params: params, queryParams: queryParams),
        extra: extra,
      );

  /// Pop the top page off the GoRouter's page stack.
  void pop() => routerDelegate.pop();

  /// Refresh the route.
  void refresh() {
    assert(() {
      log.info('refreshing $location');
      return true;
    }());
    routeInformationProvider.notifyListeners();
  }

  /// Set the app's URL path strategy (defaults to hash). call before runApp().
  static void setUrlPathStrategy(UrlPathStrategy strategy) =>
      setUrlPathStrategyImpl(strategy);

  /// Find the current GoRouter in the widget tree.
  static GoRouter of(BuildContext context) {
    final InheritedGoRouter? inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedGoRouter>();
    assert(inherited != null, 'No GoRouter found in context');
    return inherited!.goRouter;
  }

  /// The [Navigator] pushed `route`.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      notifyListeners();

  /// The [Navigator] popped `route`.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      notifyListeners();

  /// The [Navigator] removed `route`.
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      notifyListeners();

  /// The [Navigator] replaced `oldRoute` with `newRoute`.
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      notifyListeners();

  @override
  void dispose() {
    routeInformationProvider.dispose();
    routerDelegate.dispose();
    super.dispose();
  }
}
