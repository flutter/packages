// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'delegate.dart';
import 'information_provider.dart';
import 'logging.dart';
import 'match.dart';
import 'misc/constants.dart';
import 'misc/inherited_router.dart';
import 'on_enter.dart';
import 'parser.dart';
import 'route.dart';
import 'state.dart';

/// The function signature of [GoRouter.onException].
///
/// Use `state.error` to access the exception.
typedef GoExceptionHandler =
    void Function(BuildContext context, GoRouterState state, GoRouter router);

/// The signature for the top-level [onEnter] callback.
///
/// This callback receives the [BuildContext], the current navigation state,
/// the state being navigated to, and a reference to the [GoRouter] instance.
/// It returns a [FutureOr<OnEnterResult>] which should resolve to [Allow] if navigation
/// is allowed, or [Block] to block navigation.
typedef OnEnter =
    FutureOr<OnEnterResult> Function(
      BuildContext context,
      GoRouterState currentState,
      GoRouterState nextState,
      GoRouter goRouter,
    );

/// A set of parameters that defines routing in GoRouter.
///
/// This is typically used with [GoRouter.routingConfig] to create a go router
/// with dynamic routing config.
///
/// See [routing_config.dart](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/routing_config.dart).
///
/// {@category Configuration}
class RoutingConfig {
  /// Creates a routing config.
  ///
  /// The [routes] must not be empty.
  const RoutingConfig({
    required this.routes,
    this.onEnter,
    this.redirect = _defaultRedirect,
    this.redirectLimit = 5,
  });

  static FutureOr<String?> _defaultRedirect(
    BuildContext context,
    GoRouterState state,
  ) => null;

  /// The supported routes.
  ///
  /// The `routes` list specifies the top-level routes for the app. It must not be
  /// empty and must contain an [GoRoute] to match `/`.
  ///
  /// See [GoRouter].
  final List<RouteBase> routes;

  /// The top-level callback allows the app to redirect to a new location.
  ///
  /// Alternatively, you can specify a redirect for an individual route using
  /// [GoRoute.redirect]. If [BuildContext.dependOnInheritedWidgetOfExactType] is
  /// used during the redirection (which is how `of` methods are usually
  /// implemented), a re-evaluation will be triggered when the [InheritedWidget]
  /// changes.
  ///
  /// This legacy callback remains supported alongside [onEnter]. If both are
  /// provided, [onEnter] executes first and may block the navigation. When
  /// allowed, this callback runs once per navigation cycle before any
  /// route-level redirects.
  final GoRouterRedirect redirect;

  /// The maximum number of redirection allowed.
  ///
  /// See [GoRouter].
  final int redirectLimit;

  /// A callback invoked for every incoming route before it is processed.
  ///
  /// This callback allows you to control navigation by inspecting the incoming
  /// route and conditionally preventing the navigation. Return [Allow] to proceed
  /// with navigation or [Block] to cancel it. Both can optionally include an
  /// `then` callback for deferred actions.
  ///
  /// When a deep link opens the app and `onEnter` returns [Block], GoRouter
  /// will stay on the current route or redirect to the initial route.
  ///
  /// Example:
  /// ```dart
  /// final GoRouter router = GoRouter(
  ///   routes: [...],
  ///   onEnter: (BuildContext context, GoRouterState current,
  ///             GoRouterState next, GoRouter router) async {
  ///     if (next.uri.path == '/login' && isUserLoggedIn()) {
  ///       return const Block.stop(); // Prevent navigation to /login
  ///     }
  ///     if (next.uri.path == '/protected' && !isUserLoggedIn()) {
  ///       // Block and redirect to login
  ///       return Block.then(() => router.go('/login?from=${next.uri}'));
  ///     }
  ///     return const Allow(); // Allow navigation
  ///   },
  /// );
  /// ```
  final OnEnter? onEnter;
}

/// The route configuration for the app.
///
/// The `routes` list specifies the top-level routes for the app. It must not be
/// empty and must contain an [GoRoute] to match `/`.
///
/// See the [Get
/// started](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/main.dart)
/// example, which shows an app with a simple route configuration.
///
/// The [onEnter] callback allows intercepting navigation before routes are
/// processed. Return [Allow] to proceed or [Block] to prevent navigation.
/// Order of operations:
/// 1) `onEnter` (your guard) - can block navigation
/// 2) If allowed: legacy top-level `redirect` - runs in same navigation cycle
/// 3) route-level `GoRoute.redirect`
///
/// The [redirect] callback allows the app to redirect to a new location.
/// Alternatively, you can specify a redirect for an individual route using
/// [GoRoute.redirect]. If [BuildContext.dependOnInheritedWidgetOfExactType] is
/// used during the redirection (which is how `of` methods are usually
/// implemented), a re-evaluation will be triggered when the [InheritedWidget]
/// changes.
///
/// To handle exceptions, use one of `onException`, `errorBuilder`, or
/// `errorPageBuilder`. The `onException` is called when an exception is thrown.
/// If `onException` is not provided, the exception is passed to
/// `errorPageBuilder` to build a page for the Router if it is not null;
/// otherwise, it is passed to `errorBuilder` instead. If none of them are
/// provided, go_router builds a default error screen to show the exception.
/// See [Error handling](https://pub.dev/documentation/go_router/latest/topics/Error%20handling-topic.html)
/// for more details.
///
/// To disable automatically requesting focus when new routes are pushed to the navigator, set `requestFocus` to false.
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
/// {@category State restoration}
class GoRouter implements RouterConfig<RouteMatchList> {
  /// Default constructor to configure a GoRouter with a routes builder
  /// and an error page builder.
  ///
  /// The `routes` must not be null and must contain an [GoRouter] to match `/`.
  factory GoRouter({
    required List<RouteBase> routes,
    OnEnter? onEnter,
    Codec<Object?, Object?>? extraCodec,
    GoExceptionHandler? onException,
    GoRouterPageBuilder? errorPageBuilder,
    GoRouterWidgetBuilder? errorBuilder,
    GoRouterRedirect? redirect,
    int redirectLimit = 5,
    Listenable? refreshListenable,
    bool routerNeglect = false,
    String? initialLocation,
    bool overridePlatformDefaultLocation = false,
    Object? initialExtra,
    List<NavigatorObserver>? observers,
    bool debugLogDiagnostics = false,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
    bool requestFocus = true,
  }) {
    return GoRouter.routingConfig(
      routingConfig: _ConstantRoutingConfig(
        RoutingConfig(
          routes: routes,
          redirect: redirect ?? RoutingConfig._defaultRedirect,
          onEnter: onEnter,
          redirectLimit: redirectLimit,
        ),
      ),
      extraCodec: extraCodec,
      onException: onException,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      refreshListenable: refreshListenable,
      routerNeglect: routerNeglect,
      initialLocation: initialLocation,
      overridePlatformDefaultLocation: overridePlatformDefaultLocation,
      initialExtra: initialExtra,
      observers: observers,
      debugLogDiagnostics: debugLogDiagnostics,
      navigatorKey: navigatorKey,
      restorationScopeId: restorationScopeId,
      requestFocus: requestFocus,
    );
  }

  /// Creates a [GoRouter] with a dynamic [RoutingConfig].
  ///
  /// See [routing_config.dart](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/routing_config.dart).
  GoRouter.routingConfig({
    required ValueListenable<RoutingConfig> routingConfig,
    Codec<Object?, Object?>? extraCodec,
    GoExceptionHandler? onException,
    GoRouterPageBuilder? errorPageBuilder,
    GoRouterWidgetBuilder? errorBuilder,
    Listenable? refreshListenable,
    bool routerNeglect = false,
    String? initialLocation,
    this.overridePlatformDefaultLocation = false,
    Object? initialExtra,
    List<NavigatorObserver>? observers,
    bool debugLogDiagnostics = false,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
    bool requestFocus = true,
  }) : _routingConfig = routingConfig,
       backButtonDispatcher = RootBackButtonDispatcher(),
       assert(
         initialExtra == null || initialLocation != null,
         'initialLocation must be set in order to use initialExtra',
       ),
       assert(
         !overridePlatformDefaultLocation || initialLocation != null,
         'Initial location must be set to override platform default',
       ),
       assert(
         (onException == null ? 0 : 1) +
                 (errorPageBuilder == null ? 0 : 1) +
                 (errorBuilder == null ? 0 : 1) <
             2,
         'Only one of onException, errorPageBuilder, or errorBuilder can be provided.',
       ) {
    setLogging(enabled: debugLogDiagnostics);
    WidgetsFlutterBinding.ensureInitialized();

    navigatorKey ??= GlobalKey<NavigatorState>(debugLabel: 'root');

    _routingConfig.addListener(_handleRoutingConfigChanged);
    configuration = RouteConfiguration(
      _routingConfig,
      navigatorKey: navigatorKey,
      extraCodec: extraCodec,
      router: this,
    );

    final ParserExceptionHandler? parserExceptionHandler;
    if (onException != null) {
      parserExceptionHandler = (
        BuildContext context,
        RouteMatchList routeMatchList,
      ) {
        onException(
          context,
          configuration.buildTopLevelGoRouterState(routeMatchList),
          this,
        );
        // Avoid updating GoRouterDelegate if onException is provided.
        return routerDelegate.currentConfiguration;
      };
    } else {
      parserExceptionHandler = null;
    }

    routeInformationParser = GoRouteInformationParser(
      onParserException: parserExceptionHandler,
      configuration: configuration,
      router: this,
    );

    routeInformationProvider = GoRouteInformationProvider(
      initialLocation: _effectiveInitialLocation(initialLocation),
      initialExtra: initialExtra,
      refreshListenable: refreshListenable,
      routerNeglect: routerNeglect,
    );

    routerDelegate = GoRouterDelegate(
      configuration: configuration,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      routerNeglect: routerNeglect,
      observers: <NavigatorObserver>[...observers ?? <NavigatorObserver>[]],
      restorationScopeId: restorationScopeId,
      requestFocus: requestFocus,
      // wrap the returned Navigator to enable GoRouter.of(context).go() et al,
      // allowing the caller to wrap the navigator themselves
      builderWithNav:
          (BuildContext context, Widget child) =>
              InheritedGoRouter(goRouter: this, child: child),
    );

    assert(() {
      log('setting initial location $initialLocation');
      return true;
    }());
  }

  /// The top [GoRouterState], the state of the route that was
  /// last used in either [GoRouter.go] or [GoRouter.push].
  ///
  /// Accessing this property via GoRouter.of(context).state will not
  /// cause rebuild if the state has changed, consider using
  /// GoRouterState.of(context) instead.
  GoRouterState get state => routerDelegate.state;

  /// Whether the imperative API affects browser URL bar.
  ///
  /// The Imperative APIs refer to [push], [pushReplacement], or [replace].
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

  void _handleRoutingConfigChanged() {
    // Reparse is needed to update its builder
    restore(configuration.reparse(routerDelegate.currentConfiguration));
  }

  /// Whether to ignore platform's default initial location when
  /// `initialLocation` is set.
  ///
  /// When set to [true], the [initialLocation] will take
  /// precedence over the platform's default initial location.
  /// This allows developers to control the starting route of the application
  /// independently of the platform.
  ///
  /// Platform's initial location is set when the app opens via a deeplink.
  /// Use [overridePlatformDefaultLocation] only if one wants to override
  /// platform implemented initial location.
  ///
  /// Setting this parameter to [false] (default) will allow the platform's
  /// default initial location to be used even if the `initialLocation` is set.
  /// It's advisable to only set this to [true] if one explicitly wants to.
  final bool overridePlatformDefaultLocation;

  final ValueListenable<RoutingConfig> _routingConfig;

  /// Returns `true` if there is at least two or more route can be pop.
  bool canPop() => routerDelegate.canPop();

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    String? fragment,
  }) => configuration.namedLocation(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    fragment: fragment,
  );

  /// Navigate to a URI location w/ optional query parameters, e.g.
  /// `/family/f2/person/p1?color=blue`
  void go(String location, {Object? extra}) {
    log('going to $location');
    routeInformationProvider.go(location, extra: extra);
  }

  /// Restore the RouteMatchList
  void restore(RouteMatchList matchList) {
    log('restoring ${matchList.uri}');
    routeInformationProvider.restore(
      matchList.uri.toString(),
      matchList: matchList,
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
    String? fragment,
  }) =>
  // Construct location with optional fragment
  go(
    namedLocation(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      fragment: fragment,
    ),
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
    log('pushing $location');
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
  }) => push<T>(
    namedLocation(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    ),
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
  Future<T?> pushReplacement<T extends Object?>(
    String location, {
    Object? extra,
  }) {
    log('pushReplacement $location');
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
      namedLocation(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
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
    log('replace $location');
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
      namedLocation(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
      extra: extra,
    );
  }

  /// Pop the top-most route off the current screen.
  ///
  /// If the top-most route is a pop up or dialog, this method pops it instead
  /// of any GoRoute under it.
  ///
  /// Ensure that the `value` of `routeInformationProvider` is synced
  ///  with `routerDelegate.currentConfiguration`.
  void pop<T extends Object?>([T? result]) {
    assert(() {
      log('popping ${routerDelegate.currentConfiguration.uri}');
      return true;
    }());
    routerDelegate.pop<T>(result);
    restore(routerDelegate.currentConfiguration);
  }

  /// Refresh the route.
  void refresh() {
    assert(() {
      log('refreshing ${routerDelegate.currentConfiguration.uri}');
      return true;
    }());
    routeInformationProvider.notifyListeners();
  }

  /// Find the current GoRouter in the widget tree.
  static GoRouter of(BuildContext context) {
    final GoRouter? router = maybeOf(context);
    if (router == null) {
      throw FlutterError('No GoRouter found in context');
    }
    return router;
  }

  /// The current GoRouter in the widget tree, if any.
  static GoRouter? maybeOf(BuildContext context) {
    final InheritedGoRouter? inherited =
        context
                .getElementForInheritedWidgetOfExactType<InheritedGoRouter>()
                ?.widget
            as InheritedGoRouter?;
    if (inherited != null) {
      return inherited.goRouter;
    }

    // Check if we're in a redirect context
    return Zone.current[currentRouterKey] as GoRouter?;
  }

  /// Disposes resource created by this object.
  void dispose() {
    _routingConfig.removeListener(_handleRoutingConfigChanged);
    routeInformationProvider.dispose();
    routerDelegate.dispose();
  }

  String _effectiveInitialLocation(String? initialLocation) {
    if (overridePlatformDefaultLocation) {
      // The initialLocation must not be null as it's already
      // verified by assert() during the initialization.
      return initialLocation!;
    }
    Uri platformDefaultUri = Uri.parse(
      WidgetsBinding.instance.platformDispatcher.defaultRouteName,
    );
    if (platformDefaultUri.hasEmptyPath) {
      platformDefaultUri = platformDefaultUri.replace(path: '/');
    }
    final String platformDefault = platformDefaultUri.toString();
    if (initialLocation == null) {
      return platformDefault;
    } else if (platformDefault == '/') {
      return initialLocation;
    } else {
      return platformDefault;
    }
  }
}

/// A routing config that is never going to change.
class _ConstantRoutingConfig extends ValueListenable<RoutingConfig> {
  const _ConstantRoutingConfig(this.value);

  @override
  void addListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  void removeListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  final RoutingConfig value;
}
