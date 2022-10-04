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
/// [typed routing](https://gorouter.dev/typed-routing).
///
/// Subclasses must override one of [build], [buildPageWithState], or
/// [redirect].
abstract class GoRouteData {
  /// Allows subclasses to have `const` constructors.
  ///
  /// [GoRouteData] is abstract and cannot be instantiated directly.
  const GoRouteData();

  /// Creates the [Widget] for `this` route.
  ///
  /// Subclasses must override one of [build], [buildPageWithState], or
  /// [redirect].
  ///
  /// Corresponds to [BaseRoute.builder].
  Widget build(BuildContext context, Widget? child) => throw UnimplementedError(
        'One of `build` or `buildPageWithState` must be implemented.',
      );

  /// A page builder for this route.
  ///
  /// Subclasses can override this function to provide a custom [Page].
  ///
  /// Subclasses must override one of [build], [buildPageWithState] or
  /// [redirect].
  ///
  /// Corresponds to [BaseRoute.pageBuilder].
  ///
  /// By default, returns a [Page] instance that is ignored, causing a default
  /// [Page] implementation to be used with the results of [build].
  @Deprecated(
    'This method has been deprecated in favor of buildPageWithState. '
    'This feature was deprecated after v4.3.0.',
  )
  Page<void> buildPage(BuildContext context) => const NoOpPage();

  /// A page builder for this route with [GoRouterState].
  ///
  /// Subclasses can override this function to provide a custom [Page].
  ///
  /// Subclasses must override one of [build], [buildPageWithState] or
  /// [redirect].
  ///
  /// Corresponds to [BaseRoute.pageBuilder].
  ///
  /// By default, returns a [Page] instance that is ignored, causing a default
  /// [Page] implementation to be used with the results of [build].
  Page<void> buildPageWithState(
    BuildContext context,
    GoRouterState state,
    Widget? child,
  ) =>
      // ignore: deprecated_member_use_from_same_package
      buildPage(context);

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPageWithState], or
  /// [redirect].
  ///
  /// Corresponds to [BaseRoute.redirect].
  FutureOr<String?> redirect() => null;

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static String $location(String path, {Map<String, String>? queryParams}) =>
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
  static RouteBase $route<T extends GoRouteData>({
    String path = '',
    required T Function(GoRouterState) factory,
    List<RouteBase> routes = const <RouteBase>[],
    GlobalKey<NavigatorState>? key,
    bool shouldShell = false,
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
        factoryImpl(state).build(context, null);

    Page<void> pageBuilder(BuildContext context, GoRouterState state) =>
        factoryImpl(state).buildPageWithState(context, state, null);

    FutureOr<String?> redirect(BuildContext context, GoRouterState state) =>
        factoryImpl(state).redirect();

    if (shouldShell) {
      Widget builder(
              BuildContext context, GoRouterState state, Widget? child) =>
          factoryImpl(state).build(context, child);
      Page<void> pageBuilder(
              BuildContext context, GoRouterState state, Widget? child) =>
          factoryImpl(state).buildPageWithState(context, state, child);
      return ShellRoute(
        navigatorKey: key,
        routes: routes,
        builder: builder,
        pageBuilder: pageBuilder,
      );
    }

    return GoRoute(
        path: path,
        builder: builder,
        pageBuilder: pageBuilder,
        redirect: redirect,
        routes: routes,
        parentNavigatorKey: key);
  }

  /// Used to cache [GoRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<GoRouteData> _stateObjectExpando = Expando<GoRouteData>(
    'GoRouteState to GoRouteData expando',
  );
}

/// Annotation for types that support typed routing.
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedGoRoute<T extends GoRouteData> {
  /// Instantiates a new instance of [TypedGoRoute].
  const TypedGoRoute({
    this.path = '',
    this.routes = const <TypedGoRoute<GoRouteData>>[],
    this.key,
    this.isShellRoute = false,
  });

  /// The path that corresponds to this rout.
  ///
  /// See [BaseRoute.path].
  final String path;

  /// Child route definitions.
  ///
  /// See [BaseRoute.routes].
  final List<TypedGoRoute<GoRouteData>> routes;

  /// Key for pointing to a certain navigator
  final Object? key;

  /// Whether this route should be a shell route.
  /// See [ShellRoute].
  /// Defaults to `false`.
  final bool isShellRoute;
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
