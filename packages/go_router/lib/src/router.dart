// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'delegate.dart';
import 'information_provider.dart';
import 'logging.dart';
import 'matching.dart';
import 'misc/inherited_router.dart';
import 'parser.dart';
import 'platform.dart';
import 'typedefs.dart';

/// The top-level go router class.
///
/// This is the main entry point for defining app's routing policy.
///
/// The `routes` defines the routing table. It must not be empty and must
/// contain an [GoRouter] to match `/`.
///
/// See [Routes](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/main.dart)
/// for an example of defining a simple routing table.
///
/// See [Sub-routes](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/sub_routes.dart)
/// for an example of defining a multi-level routing table.
///
/// The `redirect` does top-level redirection before the URIs are parsed by
/// the `routes`. Consider using [GoRoute.redirect] for individual route
/// redirection. If [BuildContext.dependOnInheritedWidgetOfExactType] is used
/// during the redirection (which is how `of` methods are usually implemented),
/// a re-evaluation will be triggered when the [InheritedWidget] changes.
///
/// See also:
///  * [GoRoute], which provides APIs to define the routing table.
///  * [examples](https://github.com/flutter/packages/tree/main/packages/go_router/example),
///    which contains examples for different routing scenarios.
class GoRouter extends ChangeNotifier
    with NavigatorObserver
    implements RouterConfig<RouteMatchList> {
  /// Default constructor to configure a GoRouter with a routes builder
  /// and an error page builder.
  ///
  /// The `routes` must not be null and must contain an [GoRouter] to match `/`.
  GoRouter({
    required List<RouteBase> routes,
    // TODO(johnpryan): Change to a route, improve error API
    // See https://github.com/flutter/flutter/issues/108144
    GoRouterPageBuilder? errorPageBuilder,
    GoRouterWidgetBuilder? errorBuilder,
    GoRouterRedirect? redirect,
    Listenable? refreshListenable,
    int redirectLimit = 5,
    bool routerNeglect = false,
    String? initialLocation,
    List<NavigatorObserver>? observers,
    bool debugLogDiagnostics = false,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
  }) : backButtonDispatcher = RootBackButtonDispatcher() {
    setLogging(enabled: debugLogDiagnostics);
    WidgetsFlutterBinding.ensureInitialized();

    navigatorKey ??= GlobalKey<NavigatorState>();

    _routeConfiguration = RouteConfiguration(
      routes: routes,
      topRedirect: redirect ?? (_, __) => null,
      redirectLimit: redirectLimit,
      navigatorKey: navigatorKey,
    );

    _routeInformationParser = GoRouteInformationParser(
      configuration: _routeConfiguration,
      debugRequireGoRouteInformationProvider: true,
    );

    _routeInformationProvider = GoRouteInformationProvider(
        initialRouteInformation: RouteInformation(
            location: _effectiveInitialLocation(initialLocation)),
        refreshListenable: refreshListenable);

    _routerDelegate = GoRouterDelegate(
      configuration: _routeConfiguration,
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
        child: nav,
      ),
    );

    assert(() {
      log.info('setting initial location $initialLocation');
      return true;
    }());
  }

  late final RouteConfiguration _routeConfiguration;
  late final GoRouteInformationParser _routeInformationParser;
  late final GoRouterDelegate _routerDelegate;
  late final GoRouteInformationProvider _routeInformationProvider;

  @override
  final BackButtonDispatcher backButtonDispatcher;

  /// The router delegate. Provide this to the MaterialApp or CupertinoApp's
  /// `.router()` constructor
  @override
  GoRouterDelegate get routerDelegate => _routerDelegate;

  /// The route information provider used by [GoRouter].
  @override
  GoRouteInformationProvider get routeInformationProvider =>
      _routeInformationProvider;

  /// The route information parser used by [GoRouter].
  @override
  GoRouteInformationParser get routeInformationParser =>
      _routeInformationParser;

  /// The route configuration. Used for testing.
  // TODO(johnpryan): Remove this, integration tests shouldn't need access
  @visibleForTesting
  RouteConfiguration get routeConfiguration => _routeConfiguration;

  /// Get the current location.
  String get location =>
      _routerDelegate.currentConfiguration.location.toString();

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) =>
      _routeInformationParser.configuration.namedLocation(
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
    _routeInformationProvider.value =
        RouteInformation(location: location, state: extra);
  }

  /// Navigate to a named route w/ optional parameters, e.g.
  /// `name='person', params={'fid': 'f2', 'pid': 'p1'}`
  /// Navigate to the named route.
  void goNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
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
    _routeInformationParser
        .parseRouteInformationWithDependencies(
      DebugGoRouteInformation(location: location, state: extra),
      // TODO(chunhtai): avoid accessing the context directly through global key.
      // https://github.com/flutter/flutter/issues/99112
      _routerDelegate.navigatorKey.currentContext!,
    )
        .then<void>((RouteMatchList matches) {
      _routerDelegate.push(matches.last);
    });
  }

  /// Push a named route onto the page stack w/ optional parameters, e.g.
  /// `name='person', params={'fid': 'f2', 'pid': 'p1'}`
  void pushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      push(
        namedLocation(name, params: params, queryParams: queryParams),
        extra: extra,
      );

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the location onto the page stack.
  void replace(String location, {Object? extra}) {
    routeInformationParser
        .parseRouteInformationWithDependencies(
      DebugGoRouteInformation(location: location, state: extra),
      // TODO(chunhtai): avoid accessing the context directly through global key.
      // https://github.com/flutter/flutter/issues/99112
      _routerDelegate.navigatorKey.currentContext!,
    )
        .then<void>((RouteMatchList matchList) {
      routerDelegate.replace(matchList.matches.last);
    });
  }

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', params={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  void replaceNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    replace(
      namedLocation(name, params: params, queryParams: queryParams),
      extra: extra,
    );
  }

  /// Returns `true` if there is more than 1 page on the stack.
  bool canPop() => _routerDelegate.canPop();

  /// Pop the top page off the GoRouter's page stack.
  void pop() {
    assert(() {
      log.info('popping $location');
      return true;
    }());
    _routerDelegate.pop();
  }

  /// Refresh the route.
  void refresh() {
    assert(() {
      log.info('refreshing $location');
      return true;
    }());
    _routeInformationProvider.notifyListeners();
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
    _routeInformationProvider.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }

  String _effectiveInitialLocation(String? initialLocation) {
    final String platformDefault =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    if (initialLocation == null) {
      return platformDefault;
    } else if (platformDefault == '/') {
      return initialLocation;
    } else {
      return platformDefault;
    }
  }
}
