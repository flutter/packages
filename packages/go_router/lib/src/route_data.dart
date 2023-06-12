// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

import 'route.dart';
import 'state.dart';

/// A superclass for each route data
abstract class RouteData {
  /// Default const constructor
  const RouteData();
}

/// Baseclass for supporting
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

    return GoRoute(
      path: path,
      name: name,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
    );
  }

  /// Used to cache [GoRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<GoRouteData> _stateObjectExpando = Expando<GoRouteData>(
    'GoRouteState to GoRouteData expando',
  );
}

/// Base class for supporting
/// [nested navigation](https://pub.dev/packages/go_router#nested-navigation)
abstract class ShellRouteData extends RouteData {
  /// Default const constructor
  const ShellRouteData();

  /// [pageBuilder] is used to build the page
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      const NoOpPage();

  /// [pageBuilder] is used to build the page
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      throw UnimplementedError(
        'One of `builder` or `pageBuilder` must be implemented.',
      );

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static ShellRoute $route<T extends ShellRouteData>({
    required T Function(GoRouterState) factory,
    GlobalKey<NavigatorState>? navigatorKey,
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
      routes: routes,
      navigatorKey: navigatorKey,
    );
  }

  /// Used to cache [ShellRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<ShellRouteData> _stateObjectExpando =
      Expando<ShellRouteData>(
    'GoRouteState to ShellRouteData expando',
  );
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

/// Internal class used to signal that the default page behavior should be used.
@internal
class NoOpPage extends Page<void> {
  /// Creates an instance of NoOpPage;
  const NoOpPage();

  @override
  Route<void> createRoute(BuildContext context) =>
      throw UnsupportedError('Should never be called');
}
