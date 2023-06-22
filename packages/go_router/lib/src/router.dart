// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'delegate.dart';
import 'information_provider.dart';
import 'logging.dart';
import 'match.dart';
import 'misc/errors.dart';
import 'misc/inherited_router.dart';
import 'parser.dart';
import 'typedefs.dart';

/// The route configuration for the app.
///
/// The `routes` list specifies the top-level routes for the app. It must not be
/// empty and must contain an [GoRouter] to match `/`.
///
/// See the [Get
/// started](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/main.dart)
/// example, which shows an app with a simple route configuration.
///
/// The [redirect] callback allows the app to redirect to a new location.
/// Alternatively, you can specify a redirect for an individual route using
/// [GoRoute.redirect]. If [BuildContext.dependOnInheritedWidgetOfExactType] is
/// used during the redirection (which is how `of` methods are usually
/// implemented), a re-evaluation will be triggered when the [InheritedWidget]
/// changes.
///
/// See also:
/// * [Configuration](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
/// * [GoRoute], which provides APIs to define the routing table.
/// * [examples](https://github.com/flutter/packages/tree/main/packages/go_router/example),
///    which contains examples for different routing scenarios.
/// {@category Get started}
/// {@category Upgrading}
/// {@category Configuration}
/// {@category Navigation}
/// {@category Redirection}
/// {@category Web}
/// {@category Deep linking}
/// {@category Error handling}
/// {@category Named routes}
class GoRouter extends ChangeNotifier implements RouterConfig<RouteMatchList> {
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
    Object? initialExtra,
    List<NavigatorObserver>? observers,
    bool debugLogDiagnostics = false,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
  })  : backButtonDispatcher = RootBackButtonDispatcher(),
        assert(
          initialExtra == null || initialLocation != null,
          'initialLocation must be set in order to use initialExtra',
        ),
        assert(_debugCheckPath(routes, true)),
        assert(
            _debugVerifyNoDuplicatePathParameter(routes, <String, GoRoute>{})),
        assert(_debugCheckParentNavigatorKeys(
            routes,
            navigatorKey == null
                ? <GlobalKey<NavigatorState>>[]
                : <GlobalKey<NavigatorState>>[navigatorKey])) {
    setLogging(enabled: debugLogDiagnostics);
    WidgetsFlutterBinding.ensureInitialized();

    navigatorKey ??= GlobalKey<NavigatorState>();

    configuration = RouteConfiguration(
      routes: routes,
      topRedirect: redirect ?? (_, __) => null,
      redirectLimit: redirectLimit,
      navigatorKey: navigatorKey,
    );

    routeInformationParser = GoRouteInformationParser(
      configuration: configuration,
    );

    routeInformationProvider = GoRouteInformationProvider(
      initialLocation: _effectiveInitialLocation(initialLocation),
      initialExtra: initialExtra,
      refreshListenable: refreshListenable,
    );

    routerDelegate = GoRouterDelegate(
      configuration: configuration,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      routerNeglect: routerNeglect,
      observers: <NavigatorObserver>[
        ...observers ?? <NavigatorObserver>[],
      ],
      restorationScopeId: restorationScopeId,
      // wrap the returned Navigator to enable GoRouter.of(context).go() et al,
      // allowing the caller to wrap the navigator themselves
      builderWithNav: (BuildContext context, Widget child) =>
          InheritedGoRouter(goRouter: this, child: child),
    );
    routerDelegate.addListener(_handleStateMayChange);

    assert(() {
      log.info('setting initial location $initialLocation');
      return true;
    }());
  }

  static bool _debugCheckPath(List<RouteBase> routes, bool isTopLevel) {
    for (final RouteBase route in routes) {
      late bool subRouteIsTopLevel;
      if (route is GoRoute) {
        if (isTopLevel) {
          assert(route.path.startsWith('/'),
              'top-level path must start with "/": $route');
        } else {
          assert(!route.path.startsWith('/') && !route.path.endsWith('/'),
              'sub-route path may not start or end with /: $route');
        }
        subRouteIsTopLevel = false;
      } else if (route is ShellRouteBase) {
        subRouteIsTopLevel = isTopLevel;
      }
      _debugCheckPath(route.routes, subRouteIsTopLevel);
    }
    return true;
  }

  // Check that each parentNavigatorKey refers to either a ShellRoute's
  // navigatorKey or the root navigator key.
  static bool _debugCheckParentNavigatorKeys(
      List<RouteBase> routes, List<GlobalKey<NavigatorState>> allowedKeys) {
    for (final RouteBase route in routes) {
      if (route is GoRoute) {
        final GlobalKey<NavigatorState>? parentKey = route.parentNavigatorKey;
        if (parentKey != null) {
          // Verify that the root navigator or a ShellRoute ancestor has a
          // matching navigator key.
          assert(
              allowedKeys.contains(parentKey),
              'parentNavigatorKey $parentKey must refer to'
              " an ancestor ShellRoute's navigatorKey or GoRouter's"
              ' navigatorKey');

          _debugCheckParentNavigatorKeys(
            route.routes,
            <GlobalKey<NavigatorState>>[
              // Once a parentNavigatorKey is used, only that navigator key
              // or keys above it can be used.
              ...allowedKeys.sublist(0, allowedKeys.indexOf(parentKey) + 1),
            ],
          );
        } else {
          _debugCheckParentNavigatorKeys(
            route.routes,
            <GlobalKey<NavigatorState>>[
              ...allowedKeys,
            ],
          );
        }
      } else if (route is ShellRoute) {
        _debugCheckParentNavigatorKeys(
          route.routes,
          <GlobalKey<NavigatorState>>[...allowedKeys..add(route.navigatorKey)],
        );
      } else if (route is StatefulShellRoute) {
        for (final StatefulShellBranch branch in route.branches) {
          assert(
              !allowedKeys.contains(branch.navigatorKey),
              'StatefulShellBranch must not reuse an ancestor navigatorKey '
              '(${branch.navigatorKey})');

          _debugCheckParentNavigatorKeys(
            branch.routes,
            <GlobalKey<NavigatorState>>[
              ...allowedKeys,
              branch.navigatorKey,
            ],
          );
        }
      }
    }
    return true;
  }

  static bool _debugVerifyNoDuplicatePathParameter(
      List<RouteBase> routes, Map<String, GoRoute> usedPathParams) {
    for (final RouteBase route in routes) {
      if (route is! GoRoute) {
        continue;
      }
      for (final String pathParam in route.pathParameters) {
        if (usedPathParams.containsKey(pathParam)) {
          final bool sameRoute = usedPathParams[pathParam] == route;
          throw GoError(
              "duplicate path parameter, '$pathParam' found in ${sameRoute ? '$route' : '${usedPathParams[pathParam]}, and $route'}");
        }
        usedPathParams[pathParam] = route;
      }
      _debugVerifyNoDuplicatePathParameter(route.routes, usedPathParams);
      route.pathParameters.forEach(usedPathParams.remove);
    }
    return true;
  }

  /// Whether the imperative API affects browser URL bar.
  ///
  /// The Imperative APIs refer to [push], [pushReplacement], or [Replace].
  ///
  /// If this option is set to true. The URL bar reflects the top-most [GoRoute]
  /// regardless the [RouteBase]s underneath.
  ///
  /// If this option is set to false. The URL bar reflects the [RouteBase]s
  /// in the current state but ignores any [RouteBase]s that are results of
  /// imperative API calls.
  ///
  /// Defaults to false.
  ///
  /// This option is for backward compatibility. It is strongly suggested
  /// against setting this value to true, as the URL of the top-most [GoRoute]
  /// is not always deeplink-able.
  ///
  /// This option only affects web platform.
  static bool optionURLReflectsImperativeAPIs = false;

  /// The route configuration used in go_router.
  late final RouteConfiguration configuration;

  @override
  final BackButtonDispatcher backButtonDispatcher;

  /// The router delegate. Provide this to the MaterialApp or CupertinoApp's
  /// `.router()` constructor
  @override
  late final GoRouterDelegate routerDelegate;

  /// The route information provider used by [GoRouter].
  @override
  late final GoRouteInformationProvider routeInformationProvider;

  /// The route information parser used by [GoRouter].
  @override
  late final GoRouteInformationParser routeInformationParser;

  /// Gets the current location.
  // TODO(chunhtai): deprecates this once go_router_builder is migrated to
  // GoRouterState.of.
  String get location => _location;
  String _location = '/';

  /// Returns `true` if there is at least two or more route can be pop.
  bool canPop() => routerDelegate.canPop();

  void _handleStateMayChange() {
    final String newLocation;
    if (routerDelegate.currentConfiguration.isNotEmpty &&
        routerDelegate.currentConfiguration.matches.last
            is ImperativeRouteMatch) {
      newLocation = (routerDelegate.currentConfiguration.matches.last
              as ImperativeRouteMatch)
          .matches
          .uri
          .toString();
    } else {
      newLocation = routerDelegate.currentConfiguration.uri.toString();
    }
    if (_location != newLocation) {
      _location = newLocation;
      notifyListeners();
    }
  }

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  }) =>
      configuration.namedLocation(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      );

  /// Navigate to a URI location w/ optional query parameters, e.g.
  /// `/family/f2/person/p1?color=blue`
  void go(String location, {Object? extra}) {
    log.info('going to $location');
    routeInformationProvider.go(location, extra: extra);
  }

  /// Restore the RouteMatchList
  void restore(RouteMatchList matchList) {
    log.info('going to ${matchList.uri}');
    routeInformationProvider.restore(
      matchList.uri.toString(),
      encodedMatchList: RouteMatchListCodec(configuration).encode(matchList),
    );
  }

  /// Navigate to a named route w/ optional parameters, e.g.
  /// `name='person', pathParameters={'fid': 'f2', 'pid': 'p1'}`
  /// Navigate to the named route.
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      go(
        namedLocation(name,
            pathParameters: pathParameters, queryParameters: queryParameters),
        extra: extra,
      );

  /// Push a URI location onto the page stack w/ optional query parameters, e.g.
  /// `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [pushReplacement] which replaces the top-most page of the page stack and
  ///   always use a new page key.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  Future<T?> push<T extends Object?>(String location, {Object? extra}) async {
    log.info('pushing $location');
    return routeInformationProvider.push<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  /// Push a named route onto the page stack w/ optional parameters, e.g.
  /// `name='person', pathParameters={'fid': 'f2', 'pid': 'p1'}`
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      push<T>(
        namedLocation(name,
            pathParameters: pathParameters, queryParameters: queryParameters),
        extra: extra,
      );

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the given location onto the page stack.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  Future<T?> pushReplacement<T extends Object?>(String location,
      {Object? extra}) {
    log.info('pushReplacement $location');
    return routeInformationProvider.pushReplacement<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', pathParameters={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  Future<T?> pushReplacementNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    return pushReplacement<T>(
      namedLocation(name,
          pathParameters: pathParameters, queryParameters: queryParameters),
      extra: extra,
    );
  }

  /// Replaces the top-most page of the page stack with the given one but treats
  /// it as the same page.
  ///
  /// The page key will be reused. This will preserve the state and not run any
  /// page animation.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  /// * [pushReplacement] which replaces the top-most page of the page stack but
  ///   always uses a new page key.
  Future<T?> replace<T>(String location, {Object? extra}) {
    log.info('replace $location');
    return routeInformationProvider.replace<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  /// Replaces the top-most page with the named route and optional parameters,
  /// preserving the page key.
  ///
  /// This will preserve the state and not run any page animation. Optional
  /// parameters can be providded to the named route, e.g. `name='person',
  /// pathParameters={'fid': 'f2', 'pid': 'p1'}`.
  ///
  /// See also:
  /// * [pushNamed] which pushes the given location onto the page stack.
  /// * [pushReplacementNamed] which replaces the top-most page of the page
  ///   stack but always uses a new page key.
  Future<T?> replaceNamed<T>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    return replace(
      namedLocation(name,
          pathParameters: pathParameters, queryParameters: queryParameters),
      extra: extra,
    );
  }

  /// Pop the top-most route off the current screen.
  ///
  /// If the top-most route is a pop up or dialog, this method pops it instead
  /// of any GoRoute under it.
  void pop<T extends Object?>([T? result]) {
    assert(() {
      log.info('popping $location');
      return true;
    }());
    routerDelegate.pop<T>(result);
  }

  /// Refresh the route.
  void refresh() {
    assert(() {
      log.info('refreshing $location');
      return true;
    }());
    routeInformationProvider.notifyListeners();
  }

  /// Find the current GoRouter in the widget tree.
  ///
  /// This method throws when it is called during redirects.
  static GoRouter of(BuildContext context) {
    final InheritedGoRouter? inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedGoRouter>();
    assert(inherited != null, 'No GoRouter found in context');
    return inherited!.goRouter;
  }

  /// The current GoRouter in the widget tree, if any.
  ///
  /// This method returns null when it is called during redirects.
  static GoRouter? maybeOf(BuildContext context) {
    final InheritedGoRouter? inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedGoRouter>();
    return inherited?.goRouter;
  }

  @override
  void dispose() {
    routeInformationProvider.dispose();
    routerDelegate.removeListener(_handleStateMayChange);
    routerDelegate.dispose();
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
