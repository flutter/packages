// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

import 'route.dart';
import 'state.dart';

/// Baseclass for supporting
/// [Type-safe routing](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html).
abstract class RouteData {
  /// Allows subclasses to have `const` constructors.
  const RouteData();
}

/// A class to represent a [GoRoute] in
/// [Type-safe routing](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html).
///
/// Subclasses must override one of [build], [buildPage], or
/// [redirect].
/// {@category Type-safe routes}
abstract class GoRouteData extends RouteData {
  /// Allows subclasses to have `const` constructors.
  ///
  /// [GoRouteData] is abstract and cannot be instantiated directly.
  const GoRouteData();

  /// Creates the [Widget] for `this` route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.builder].
  Widget build(BuildContext context, GoRouterState state) =>
      throw UnimplementedError(
        'One of `build` or `buildPage` must be implemented.',
      );

  /// A page builder for this route.
  ///
  /// Subclasses can override this function to provide a custom [Page].
  ///
  /// Subclasses must override one of [build], [buildPage] or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.pageBuilder].
  ///
  /// By default, returns a [Page] instance that is ignored, causing a default
  /// [Page] implementation to be used with the results of [build].
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoOpPage();

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.redirect].
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) => null;

  /// Called when this route is removed from GoRouter's route history.
  ///
  /// Corresponds to [GoRoute.onExit].
  FutureOr<bool> onExit(BuildContext context, GoRouterState state) => true;

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static String $location(String path, {Map<String, dynamic>? queryParams}) =>
      Uri.parse(path)
          .replace(
            queryParameters:
                // Avoid `?` in generated location if `queryParams` is empty
                queryParams?.isNotEmpty ?? false ? queryParams : null,
          )
          .toString();

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static GoRoute $route<T extends GoRouteData>({
    required String path,
    String? name,
    bool caseSensitive = true,
    required T Function(GoRouterState) factory,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    T factoryImpl(GoRouterState state) {
      final Object? extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `GoRouteData`, so it doesn't need to be recreated.
      if (extra is T) {
        return extra;
      }

      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(BuildContext context, GoRouterState state) =>
        factoryImpl(state).build(context, state);

    Page<void> pageBuilder(BuildContext context, GoRouterState state) =>
        factoryImpl(state).buildPage(context, state);

    FutureOr<String?> redirect(BuildContext context, GoRouterState state) =>
        factoryImpl(state).redirect(context, state);

    FutureOr<bool> onExit(BuildContext context, GoRouterState state) =>
        factoryImpl(state).onExit(context, state);

    return GoRoute(
      path: path,
      name: name,
      caseSensitive: caseSensitive,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
      onExit: onExit,
    );
  }

  /// Used to cache [GoRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<GoRouteData> _stateObjectExpando = Expando<GoRouteData>(
    'GoRouteState to GoRouteData expando',
  );

  /// The location of this route.
  String get location => throw _shouldBeGeneratedError;

  /// Navigate to the route.
  void go(BuildContext context) => throw _shouldBeGeneratedError;

  /// Push the route onto the page stack.
  Future<T?> push<T>(BuildContext context) => throw _shouldBeGeneratedError;

  /// Replaces the top-most page of the page stack with the route.
  void pushReplacement(BuildContext context) => throw _shouldBeGeneratedError;

  /// Replaces the top-most page of the page stack with the route but treats
  /// it as the same page.
  ///
  /// The page key will be reused. This will preserve the state and not run any
  /// page animation.
  ///
  void replace(BuildContext context) => throw _shouldBeGeneratedError;

  static UnimplementedError get _shouldBeGeneratedError => UnimplementedError(
        'Should be generated using [Type-safe routing](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html).',
      );
}

/// A class to represent a [ShellRoute] in
/// [Type-safe routing](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html).
abstract class ShellRouteData extends RouteData {
  /// Allows subclasses to have `const` constructors.
  ///
  /// [ShellRouteData] is abstract and cannot be instantiated directly.
  const ShellRouteData();

  /// [pageBuilder] is used to build the page
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      const NoOpPage();

  /// [builder] is used to build the widget
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      throw UnimplementedError(
        'One of `builder` or `pageBuilder` must be implemented.',
      );

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.redirect].
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) => null;

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static ShellRoute $route<T extends ShellRouteData>({
    required T Function(GoRouterState) factory,
    GlobalKey<NavigatorState>? navigatorKey,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
  }) {
    T factoryImpl(GoRouterState state) {
      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    FutureOr<String?> redirect(BuildContext context, GoRouterState state) =>
        factoryImpl(state).redirect(context, state);

    Widget builder(
      BuildContext context,
      GoRouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).builder(
          context,
          state,
          navigator,
        );

    Page<void> pageBuilder(
      BuildContext context,
      GoRouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).pageBuilder(
          context,
          state,
          navigator,
        );

    return ShellRoute(
      builder: builder,
      pageBuilder: pageBuilder,
      parentNavigatorKey: parentNavigatorKey,
      routes: routes,
      navigatorKey: navigatorKey,
      observers: observers,
      restorationScopeId: restorationScopeId,
      redirect: redirect,
    );
  }

  /// Used to cache [ShellRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<ShellRouteData> _stateObjectExpando =
      Expando<ShellRouteData>(
    'GoRouteState to ShellRouteData expando',
  );
}

/// Base class for supporting
/// [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
abstract class StatefulShellRouteData extends RouteData {
  /// Default const constructor
  const StatefulShellRouteData();

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.redirect].
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) => null;

  /// [pageBuilder] is used to build the page
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) =>
      const NoOpPage();

  /// [builder] is used to build the widget
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) =>
      throw UnimplementedError(
        'One of `builder` or `pageBuilder` must be implemented.',
      );

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static StatefulShellRoute $route<T extends StatefulShellRouteData>({
    required T Function(GoRouterState) factory,
    required List<StatefulShellBranch> branches,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    ShellNavigationContainerBuilder? navigatorContainerBuilder,
    String? restorationScopeId,
  }) {
    T factoryImpl(GoRouterState state) {
      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(
      BuildContext context,
      GoRouterState state,
      StatefulNavigationShell navigationShell,
    ) =>
        factoryImpl(state).builder(
          context,
          state,
          navigationShell,
        );

    Page<void> pageBuilder(
      BuildContext context,
      GoRouterState state,
      StatefulNavigationShell navigationShell,
    ) =>
        factoryImpl(state).pageBuilder(
          context,
          state,
          navigationShell,
        );

    FutureOr<String?> redirect(BuildContext context, GoRouterState state) =>
        factoryImpl(state).redirect(context, state);

    if (navigatorContainerBuilder != null) {
      return StatefulShellRoute(
        branches: branches,
        builder: builder,
        pageBuilder: pageBuilder,
        navigatorContainerBuilder: navigatorContainerBuilder,
        parentNavigatorKey: parentNavigatorKey,
        restorationScopeId: restorationScopeId,
        redirect: redirect,
      );
    }
    return StatefulShellRoute.indexedStack(
      branches: branches,
      builder: builder,
      pageBuilder: pageBuilder,
      parentNavigatorKey: parentNavigatorKey,
      restorationScopeId: restorationScopeId,
      redirect: redirect,
    );
  }

  /// Used to cache [StatefulShellRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<StatefulShellRouteData> _stateObjectExpando =
      Expando<StatefulShellRouteData>(
    'GoRouteState to StatefulShellRouteData expando',
  );
}

/// Base class for supporting
/// [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
abstract class StatefulShellBranchData {
  /// Default const constructor
  const StatefulShellBranchData();

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static StatefulShellBranch $branch<T extends StatefulShellBranchData>({
    GlobalKey<NavigatorState>? navigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
    List<NavigatorObserver>? observers,
    String? initialLocation,
    String? restorationScopeId,
    bool preload = false,
  }) {
    return StatefulShellBranch(
      routes: routes,
      navigatorKey: navigatorKey,
      observers: observers,
      initialLocation: initialLocation,
      restorationScopeId: restorationScopeId,
      preload: preload,
    );
  }
}

/// A superclass for each typed route descendant
class TypedRoute<T extends RouteData> {
  /// Default const constructor
  const TypedRoute();
}

/// A superclass for each typed go route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedGoRoute<T extends GoRouteData> extends TypedRoute<T> {
  /// Default const constructor
  const TypedGoRoute({
    required this.path,
    this.name,
    this.routes = const <TypedRoute<RouteData>>[],
    this.caseSensitive = true,
  });

  /// The path that corresponds to this route.
  ///
  /// See [GoRoute.path].
  ///
  ///
  final String path;

  /// The name that corresponds to this route.
  /// Used by Analytics services such as Firebase Analytics
  /// to log the screen views in their system.
  ///
  /// See [GoRoute.name].
  ///
  final String? name;

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;

  /// Determines whether the route matching is case sensitive.
  ///
  /// When `true`, the path must match the specified case. For example,
  /// a route with `path: '/family/:fid'` will not match `/FaMiLy/f2`.
  ///
  /// When `false`, the path matching is case insensitive.  The route
  /// with `path: '/family/:fid'` will match `/FaMiLy/f2`.
  ///
  /// Defaults to `true`.
  final bool caseSensitive;
}

/// A superclass for each typed shell route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedShellRoute<T extends ShellRouteData> extends TypedRoute<T> {
  /// Default const constructor
  const TypedShellRoute({
    this.routes = const <TypedRoute<RouteData>>[],
  });

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;
}

/// A superclass for each typed shell route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedStatefulShellRoute<T extends StatefulShellRouteData>
    extends TypedRoute<T> {
  /// Default const constructor
  const TypedStatefulShellRoute({
    this.branches = const <TypedStatefulShellBranch<StatefulShellBranchData>>[],
  });

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedStatefulShellBranch<StatefulShellBranchData>> branches;
}

/// A superclass for each typed shell route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedStatefulShellBranch<T extends StatefulShellBranchData> {
  /// Default const constructor
  const TypedStatefulShellBranch({
    this.routes = const <TypedRoute<RouteData>>[],
  });

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;
}

/// Internal class used to signal that the default page behavior should be used.
@internal
class NoOpPage extends Page<void> {
  /// Creates an instance of NoOpPage;
  const NoOpPage();

  @override
  Route<void> createRoute(BuildContext context) =>
      throw UnsupportedError('Should never be called');
}
