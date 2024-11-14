// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'configuration.dart';
import 'match.dart';
import 'path_utils.dart';
import 'router.dart';
import 'state.dart';

/// The page builder for [GoRoute].
typedef GoRouterPageBuilder = Page<dynamic> Function(
  BuildContext context,
  GoRouterState state,
);

/// The widget builder for [GoRoute].
typedef GoRouterWidgetBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

/// The widget builder for [ShellRoute].
typedef ShellRouteBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

/// The page builder for [ShellRoute].
typedef ShellRoutePageBuilder = Page<dynamic> Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

/// The widget builder for [StatefulShellRoute].
typedef StatefulShellRouteBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  StatefulNavigationShell navigationShell,
);

/// The page builder for [StatefulShellRoute].
typedef StatefulShellRoutePageBuilder = Page<dynamic> Function(
  BuildContext context,
  GoRouterState state,
  StatefulNavigationShell navigationShell,
);

/// Signature for functions used to build Navigators
typedef NavigatorBuilder = Widget Function(
    GlobalKey<NavigatorState> navigatorKey,
    ShellRouteMatch match,
    RouteMatchList matchList,
    List<NavigatorObserver>? observers,
    String? restorationScopeId);

/// Signature for function used in [RouteBase.onExit].
///
/// If the return value is true or the future resolve to true, the route will
/// exit as usual. Otherwise, the operation will abort.
typedef ExitCallback = FutureOr<bool> Function(
    BuildContext context, GoRouterState state);

/// The base class for [GoRoute] and [ShellRoute].
///
/// Routes are defined in a tree such that parent routes must match the
/// current location for their child route to be considered a match. For
/// example the location "/home/user/12" matches with parent route "/home" and
/// child route "user/:userId".
///
/// To create sub-routes for a route, provide them as a [GoRoute] list
/// with the sub routes.
///
/// For example these routes:
/// ```none
/// /         => HomePage()
///   family/f1 => FamilyPage('f1')
///     person/p2 => PersonPage('f1', 'p2') ← showing this page, Back pops ↑
/// ```
///
/// Can be represented as:
///
/// ```dart
/// final GoRouter _router = GoRouter(
///   routes: <GoRoute>[
///     GoRoute(
///       path: '/',
///       pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage<void>(
///         key: state.pageKey,
///         child: HomePage(families: Families.data),
///       ),
///       routes: <GoRoute>[
///         GoRoute(
///           path: 'family/:fid',
///           pageBuilder: (BuildContext context, GoRouterState state) {
///             final Family family = Families.family(state.pathParameters['fid']!);
///             return MaterialPage<void>(
///               key: state.pageKey,
///               child: FamilyPage(family: family),
///             );
///           },
///           routes: <GoRoute>[
///             GoRoute(
///               path: 'person/:pid',
///               pageBuilder: (BuildContext context, GoRouterState state) {
///                 final Family family = Families.family(state.pathParameters['fid']!);
///                 final Person person = family.person(state.pathParameters['pid']!);
///                 return MaterialPage<void>(
///                   key: state.pageKey,
///                   child: PersonPage(family: family, person: person),
///                 );
///               },
///             ),
///           ],
///         ),
///       ],
///     ),
///   ],
/// );
/// ```
///
/// If there are multiple routes that match the location, the first match is used.
/// To make predefined routes to take precedence over dynamic routes eg. '/:id'
/// consider adding the dynamic route at the end of the routes.
///
/// For example:
/// ```dart
/// final GoRouter _router = GoRouter(
///   routes: <GoRoute>[
///     GoRoute(
///       path: '/',
///       redirect: (_, __) => '/family/${Families.data[0].id}',
///     ),
///     GoRoute(
///       path: '/family',
///       pageBuilder: (BuildContext context, GoRouterState state) => ...,
///     ),
///     GoRoute(
///       path: '/:username',
///       pageBuilder: (BuildContext context, GoRouterState state) => ...,
///     ),
///   ],
/// );
/// ```
///
/// In the above example, if `/family` route is matched, it will be used.
/// else `/:username` route will be used.
///
/// See [main.dart](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/main.dart)
@immutable
abstract class RouteBase with Diagnosticable {
  const RouteBase._({
    this.redirect,
    required this.routes,
    required this.parentNavigatorKey,
  });

  /// An optional redirect function for this route.
  ///
  /// In the case that you like to make a redirection decision for a specific
  /// route (or sub-route), consider doing so by passing a redirect function to
  /// the GoRoute constructor.
  ///
  /// For example:
  /// ```dart
  /// final GoRouter _router = GoRouter(
  ///   routes: <GoRoute>[
  ///     GoRoute(
  ///       path: '/',
  ///       redirect: (_, __) => '/family/${Families.data[0].id}',
  ///     ),
  ///     GoRoute(
  ///       path: '/family/:fid',
  ///       pageBuilder: (BuildContext context, GoRouterState state) => ...,
  ///     ),
  ///   ],
  /// );
  /// ```
  ///
  /// If there are multiple redirects in the matched routes, the parent route's
  /// redirect takes priority over sub-route's.
  ///
  /// For example:
  /// ```dart
  /// final GoRouter _router = GoRouter(
  ///   routes: <GoRoute>[
  ///     GoRoute(
  ///       path: '/',
  ///       redirect: (_, __) => '/page1', // this takes priority over the sub-route.
  ///       routes: <GoRoute>[
  ///         GoRoute(
  ///           path: 'child',
  ///           redirect: (_, __) => '/page2',
  ///         ),
  ///       ],
  ///     ),
  ///   ],
  /// );
  /// ```
  ///
  /// The `context.go('/child')` will be redirected to `/page1` instead of
  /// `/page2`.
  ///
  /// Redirect can also be used for conditionally preventing users from visiting
  /// routes, also known as route guards. One canonical example is user
  /// authentication. See [Redirection](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart)
  /// for a complete runnable example.
  ///
  /// If [BuildContext.dependOnInheritedWidgetOfExactType] is used during the
  /// redirection (which is how `of` method is usually implemented), a
  /// re-evaluation will be triggered if the [InheritedWidget] changes.
  final GoRouterRedirect? redirect;

  /// The list of child routes associated with this route.
  final List<RouteBase> routes;

  /// An optional key specifying which Navigator to display this route's screen
  /// onto.
  ///
  /// Specifying the root Navigator will stack this route onto that
  /// Navigator instead of the nearest ShellRoute ancestor.
  final GlobalKey<NavigatorState>? parentNavigatorKey;

  /// Builds a lists containing the provided routes along with all their
  /// descendant [routes].
  static Iterable<RouteBase> routesRecursively(Iterable<RouteBase> routes) {
    return routes.expand(
        (RouteBase e) => <RouteBase>[e, ...routesRecursively(e.routes)]);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (parentNavigatorKey != null) {
      properties.add(DiagnosticsProperty<GlobalKey<NavigatorState>>(
          'parentNavKey', parentNavigatorKey));
    }
  }
}

/// A route that is displayed visually above the matching parent route using the
/// [Navigator].
///
/// The widget returned by [builder] is wrapped in [Page] and provided to the
/// root Navigator, the nearest ShellRoute ancestor's Navigator, or the
/// Navigator with a matching [parentNavigatorKey].
///
/// The Page depends on the application type: [MaterialPage] for
/// [MaterialApp], [CupertinoPage] for [CupertinoApp], or
/// [NoTransitionPage] for [WidgetsApp].
///
/// {@category Get started}
/// {@category Configuration}
/// {@category Transition animations}
/// {@category Named routes}
/// {@category Redirection}
class GoRoute extends RouteBase {
  /// Constructs a [GoRoute].
  /// - [path] and [name] cannot be empty strings.
  /// - One of either [builder] or [pageBuilder] must be provided.
  GoRoute({
    required this.path,
    this.name,
    this.builder,
    this.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    this.onExit,
    super.routes = const <RouteBase>[],
  })  : assert(path.isNotEmpty, 'GoRoute path cannot be empty'),
        assert(name == null || name.isNotEmpty, 'GoRoute name cannot be empty'),
        assert(pageBuilder != null || builder != null || redirect != null,
            'builder, pageBuilder, or redirect must be provided'),
        assert(onExit == null || pageBuilder != null || builder != null,
            'if onExit is provided, one of pageBuilder or builder must be provided'),
        super._() {
    // cache the path regexp and parameters
    _pathRE = patternToRegExp(path, pathParameters);
  }

  /// Whether this [GoRoute] only redirects to another route.
  ///
  /// If this is true, this route must redirect location other than itself.
  bool get redirectOnly => pageBuilder == null && builder == null;

  /// Optional name of the route.
  ///
  /// If used, a unique string name must be provided and it can not be empty.
  ///
  /// This is used in [GoRouter.namedLocation] and its related API. This
  /// property can be used to navigate to this route without knowing exact the
  /// URI of it.
  ///
  /// {@tool snippet}
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// GoRoute(
  ///   name: 'home',
  ///   path: '/',
  ///   builder: (BuildContext context, GoRouterState state) =>
  ///       HomeScreen(),
  ///   routes: <GoRoute>[
  ///     GoRoute(
  ///       name: 'family',
  ///       path: 'family/:fid',
  ///       builder: (BuildContext context, GoRouterState state) =>
  ///           FamilyScreen(),
  ///     ),
  ///   ],
  /// );
  ///
  /// context.go(
  ///   context.namedLocation('family'),
  ///   pathParameters: <String, String>{'fid': 123},
  ///   queryParameters: <String, String>{'qid': 'quid'},
  /// );
  /// ```
  /// {@end-tool}
  ///
  /// See the [named routes example](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/named_routes.dart)
  /// for a complete runnable app.
  final String? name;

  /// The path of this go route.
  ///
  /// For example:
  /// ```dart
  /// GoRoute(
  ///   path: '/',
  ///   pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage<void>(
  ///     key: state.pageKey,
  ///     child: HomePage(families: Families.data),
  ///   ),
  /// ),
  /// ```
  ///
  /// The path also support path parameters. For a path: `/family/:fid`, it
  /// matches all URIs start with `/family/...`, e.g. `/family/123`,
  /// `/family/456` and etc. The parameter values are stored in [GoRouterState]
  /// that are passed into [pageBuilder] and [builder].
  ///
  /// The query parameter are also capture during the route parsing and stored
  /// in [GoRouterState].
  ///
  /// See [Query parameters and path parameters](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/path_and_query_parameters.dart)
  /// to learn more about parameters.
  final String path;

  /// A page builder for this route.
  ///
  /// Typically a MaterialPage, as in:
  /// ```dart
  /// GoRoute(
  ///   path: '/',
  ///   pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage<void>(
  ///     key: state.pageKey,
  ///     child: HomePage(families: Families.data),
  ///   ),
  /// ),
  /// ```
  ///
  /// You can also use CupertinoPage, and for a custom page builder to use
  /// custom page transitions, you can use [CustomTransitionPage].
  final GoRouterPageBuilder? pageBuilder;

  /// A custom builder for this route.
  ///
  /// For example:
  /// ```dart
  /// GoRoute(
  ///   path: '/',
  ///   builder: (BuildContext context, GoRouterState state) => FamilyPage(
  ///     families: Families.family(
  ///       state.pathParameters['id'],
  ///     ),
  ///   ),
  /// ),
  /// ```
  ///
  final GoRouterWidgetBuilder? builder;

  /// Called when this route is removed from GoRouter's route history.
  ///
  /// Some example this callback may be called:
  ///  * This route is removed as the result of [GoRouter.pop].
  ///  * This route is no longer in the route history after a [GoRouter.go].
  ///
  /// This method can be useful it one wants to launch a dialog for user to
  /// confirm if they want to exit the screen.
  ///
  /// ```dart
  /// final GoRouter _router = GoRouter(
  ///   routes: <GoRoute>[
  ///     GoRoute(
  ///       path: '/',
  ///       onExit: (BuildContext context) => showDialog<bool>(
  ///         context: context,
  ///         builder: (BuildContext context) {
  ///           return AlertDialog(
  ///             title: const Text('Do you want to exit this page?'),
  ///             actions: <Widget>[
  ///               TextButton(
  ///                 style: TextButton.styleFrom(
  ///                   textStyle: Theme.of(context).textTheme.labelLarge,
  ///                 ),
  ///                 child: const Text('Go Back'),
  ///                 onPressed: () {
  ///                   Navigator.of(context).pop(false);
  ///                 },
  ///               ),
  ///               TextButton(
  ///                 style: TextButton.styleFrom(
  ///                   textStyle: Theme.of(context).textTheme.labelLarge,
  ///                 ),
  ///                 child: const Text('Confirm'),
  ///                 onPressed: () {
  ///                   Navigator.of(context).pop(true);
  ///                 },
  ///               ),
  ///             ],
  ///           );
  ///         },
  ///       ),
  ///     ),
  ///   ],
  /// );
  /// ```
  final ExitCallback? onExit;

  // TODO(chunhtai): move all regex related help methods to path_utils.dart.
  /// Match this route against a location.
  RegExpMatch? matchPatternAsPrefix(String loc) {
    return _pathRE.matchAsPrefix('/$loc') as RegExpMatch? ??
        _pathRE.matchAsPrefix(loc) as RegExpMatch?;
  }

  /// Extract the path parameters from a match.
  Map<String, String> extractPathParams(RegExpMatch match) =>
      extractPathParameters(pathParameters, match);

  /// The path parameters in this route.
  @internal
  final List<String> pathParameters = <String>[];

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('name', name));
    properties.add(StringProperty('path', path));
    properties.add(
        FlagProperty('redirect', value: redirectOnly, ifTrue: 'Redirect Only'));
  }

  late final RegExp _pathRE;
}

/// Base class for classes that act as shells for sub-routes, such
/// as [ShellRoute] and [StatefulShellRoute].
abstract class ShellRouteBase extends RouteBase {
  /// Constructs a [ShellRouteBase].
  const ShellRouteBase._({
    super.redirect,
    required super.routes,
    required super.parentNavigatorKey,
  }) : super._();

  static void _debugCheckSubRouteParentNavigatorKeys(
      List<RouteBase> subRoutes, GlobalKey<NavigatorState> navigatorKey) {
    for (final RouteBase route in subRoutes) {
      assert(
          route.parentNavigatorKey == null ||
              route.parentNavigatorKey == navigatorKey,
          "sub-route's parent navigator key must either be null or has the same navigator key as parent's key");
      if (route is GoRoute && route.redirectOnly) {
        // This route does not produce a page, need to check its sub-routes
        // instead.
        _debugCheckSubRouteParentNavigatorKeys(route.routes, navigatorKey);
      }
    }
  }

  /// Attempts to build the Widget representing this shell route.
  ///
  /// Returns null if this shell route does not build a Widget, but instead uses
  /// a Page to represent itself (see [buildPage]).
  Widget? buildWidget(BuildContext context, GoRouterState state,
      ShellRouteContext shellRouteContext);

  /// Attempts to build the Page representing this shell route.
  ///
  /// Returns null if this shell route does not build a Page, but instead uses
  /// a Widget to represent itself (see [buildWidget]).
  Page<dynamic>? buildPage(BuildContext context, GoRouterState state,
      ShellRouteContext shellRouteContext);

  /// Returns the key for the [Navigator] that is to be used for the specified
  /// immediate sub-route of this shell route.
  GlobalKey<NavigatorState> navigatorKeyForSubRoute(RouteBase subRoute);
}

/// Context object used when building the shell and Navigator for a shell route.
class ShellRouteContext {
  /// Constructs a [ShellRouteContext].
  ShellRouteContext({
    required this.route,
    required this.routerState,
    required this.navigatorKey,
    required this.match,
    required this.routeMatchList,
    required this.navigatorBuilder,
  });

  /// The associated shell route.
  final ShellRouteBase route;

  /// The current route state associated with [route].
  final GoRouterState routerState;

  /// The [Navigator] key to be used for the nested navigation associated with
  /// [route].
  final GlobalKey<NavigatorState> navigatorKey;

  /// The `ShellRouteMatch` in [routeMatchList] that corresponds to the
  /// associated shell route.
  final ShellRouteMatch match;

  /// The route match list representing the current location within the
  /// associated shell route.
  final RouteMatchList routeMatchList;

  /// Function used to build the [Navigator] for the current route.
  final NavigatorBuilder navigatorBuilder;

  Widget _buildNavigatorForCurrentRoute(
      List<NavigatorObserver>? observers, String? restorationScopeId) {
    return navigatorBuilder(
        navigatorKey, match, routeMatchList, observers, restorationScopeId);
  }
}

/// A route that displays a UI shell around the matching child route.
///
/// When a ShellRoute is added to the list of routes on GoRouter or GoRoute, a
/// new Navigator is used to display any matching sub-routes instead of placing
/// them on the root Navigator.
///
/// To display a child route on a different Navigator, provide it with a
/// [parentNavigatorKey] that matches the key provided to either the [GoRouter]
/// or [ShellRoute] constructor. In this example, the _rootNavigator key is
/// passed to the /b/details route so that it displays on the root Navigator
/// instead of the ShellRoute's Navigator:
///
/// ```dart
/// final GlobalKey<NavigatorState> _rootNavigatorKey =
///     GlobalKey<NavigatorState>();
///
///   final GoRouter _router = GoRouter(
///     navigatorKey: _rootNavigatorKey,
///     initialLocation: '/a',
///     routes: [
///       ShellRoute(
///         navigatorKey: _shellNavigatorKey,
///         builder: (context, state, child) {
///           return ScaffoldWithNavBar(child: child);
///         },
///         routes: [
///           // This screen is displayed on the ShellRoute's Navigator.
///           GoRoute(
///             path: '/a',
///             builder: (context, state) {
///               return const ScreenA();
///             },
///             routes: <RouteBase>[
///               // This screen is displayed on the ShellRoute's Navigator.
///               GoRoute(
///                 path: 'details',
///                 builder: (BuildContext context, GoRouterState state) {
///                   return const DetailsScreen(label: 'A');
///                 },
///               ),
///             ],
///           ),
///           // Displayed ShellRoute's Navigator.
///           GoRoute(
///             path: '/b',
///             builder: (BuildContext context, GoRouterState state) {
///               return const ScreenB();
///             },
///             routes: <RouteBase>[
///               // Displayed on the root Navigator by specifying the
///               // [parentNavigatorKey].
///               GoRoute(
///                 path: 'details',
///                 parentNavigatorKey: _rootNavigatorKey,
///                 builder: (BuildContext context, GoRouterState state) {
///                   return const DetailsScreen(label: 'B');
///                 },
///               ),
///             ],
///           ),
///         ],
///       ),
///     ],
///   );
/// ```
///
/// The widget built by the matching sub-route becomes the child parameter
/// of the [builder].
///
/// For example:
///
/// ```dart
/// ShellRoute(
///   builder: (BuildContext context, GoRouterState state, Widget child) {
///     return Scaffold(
///       appBar: AppBar(
///         title: Text('App Shell')
///       ),
///       body: Center(
///         child: child,
///       ),
///     );
///   },
///   routes: [
///     GoRoute(
///       path: 'a'
///       builder: (BuildContext context, GoRouterState state) {
///         return Text('Child Route "/a"');
///       }
///     ),
///   ],
/// ),
/// ```
///
/// {@category Configuration}
class ShellRoute extends ShellRouteBase {
  /// Constructs a [ShellRoute].
  ShellRoute({
    super.redirect,
    this.builder,
    this.pageBuilder,
    this.observers,
    required super.routes,
    super.parentNavigatorKey,
    GlobalKey<NavigatorState>? navigatorKey,
    this.restorationScopeId,
  })  : assert(routes.isNotEmpty),
        navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        super._() {
    assert(() {
      ShellRouteBase._debugCheckSubRouteParentNavigatorKeys(
          routes, this.navigatorKey);
      return true;
    }());
  }

  /// The widget builder for a shell route.
  ///
  /// Similar to [GoRoute.builder], but with an additional child parameter. This
  /// child parameter is the Widget managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget.
  final ShellRouteBuilder? builder;

  /// The page builder for a shell route.
  ///
  /// Similar to [GoRoute.pageBuilder], but with an additional child parameter.
  /// This child parameter is the Widget managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget.
  final ShellRoutePageBuilder? pageBuilder;

  @override
  Widget? buildWidget(BuildContext context, GoRouterState state,
      ShellRouteContext shellRouteContext) {
    if (builder != null) {
      final Widget navigator = shellRouteContext._buildNavigatorForCurrentRoute(
          observers, restorationScopeId);
      return builder!(context, state, navigator);
    }
    return null;
  }

  @override
  Page<dynamic>? buildPage(BuildContext context, GoRouterState state,
      ShellRouteContext shellRouteContext) {
    if (pageBuilder != null) {
      final Widget navigator = shellRouteContext._buildNavigatorForCurrentRoute(
          observers, restorationScopeId);
      return pageBuilder!(context, state, navigator);
    }
    return null;
  }

  /// The observers for a shell route.
  ///
  /// The observers parameter is used by the [Navigator] built for this route.
  /// sub-route's observers.
  final List<NavigatorObserver>? observers;

  /// The [GlobalKey] to be used by the [Navigator] built for this route.
  /// All ShellRoutes build a Navigator by default. Child GoRoutes
  /// are placed onto this Navigator instead of the root Navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  @override
  GlobalKey<NavigatorState> navigatorKeyForSubRoute(RouteBase subRoute) {
    assert(routes.contains(subRoute));
    return navigatorKey;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey<NavigatorState>>(
        'navigatorKey', navigatorKey));
  }
}

/// A route that displays a UI shell with separate [Navigator]s for its
/// sub-routes.
///
/// Similar to [ShellRoute], this route class places its sub-route on a
/// different Navigator than the root [Navigator]. However, this route class
/// differs in that it creates separate [Navigator]s for each of its nested
/// branches (i.e. parallel navigation trees), making it possible to build an
/// app with stateful nested navigation. This is convenient when for instance
/// implementing a UI with a [BottomNavigationBar], with a persistent navigation
/// state for each tab.
///
/// A StatefulShellRoute is created by specifying a List of
/// [StatefulShellBranch] items, each representing a separate stateful branch
/// in the route tree. StatefulShellBranch provides the root routes and the
/// Navigator key ([GlobalKey]) for the branch, as well as an optional initial
/// location.
///
/// Like [ShellRoute], either a [builder] or a [pageBuilder] must be provided
/// when creating a StatefulShellRoute. However, these builders differ slightly
/// in that they accept a [StatefulNavigationShell] parameter instead of a
/// child Widget. The StatefulNavigationShell can be used to access information
/// about the state of the route, as well as to switch the active branch (i.e.
/// restoring the navigation stack of another branch). The latter is
/// accomplished by using the method [StatefulNavigationShell.goBranch], for
/// example:
///
/// ```dart
/// void _onItemTapped(int index) {
///   navigationShell.goBranch(index: index);
/// }
/// ```
///
/// The StatefulNavigationShell is also responsible for managing and maintaining
/// the state of the branch Navigators. Typically, a shell is built around this
/// Widget, for example by using it as the body of [Scaffold] with a
/// [BottomNavigationBar].
///
/// When creating a StatefulShellRoute, a [navigatorContainerBuilder] function
/// must be provided. This function is responsible for building the actual
/// container for the Widgets representing the branch Navigators. Typically,
/// the Widget returned by this function handles the layout (including
/// [Offstage] handling etc) of the branch Navigators and any animations needed
/// when switching active branch.
///
/// For a default implementation of [navigatorContainerBuilder] that is
/// appropriate for most use cases, consider using the constructor
/// [StatefulShellRoute.indexedStack].
///
/// With StatefulShellRoute (and any route below it), animated transitions
/// between routes in the same navigation stack works the same way as with other
/// route classes, and can be customized using pageBuilder. However, since
/// StatefulShellRoute maintains a set of parallel navigation stacks,
/// any transitions when switching between branches is the responsibility of the
/// branch Navigator container (i.e. [navigatorContainerBuilder]). The default
/// [IndexedStack] implementation ([StatefulShellRoute.indexedStack]) does not
/// use animated transitions, but an example is provided on how to accomplish
/// this (see link to custom StatefulShellRoute example below).
///
/// See also:
/// * [StatefulShellRoute.indexedStack] which provides a default
/// StatefulShellRoute implementation suitable for most use cases.
/// * [Stateful Nested Navigation example](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart)
/// for a complete runnable example using StatefulShellRoute.
/// * [Custom StatefulShellRoute example](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/others/custom_stateful_shell_route.dart)
/// which demonstrates how to customize the container for the branch Navigators
/// and how to implement animated transitions when switching branches.
///
/// {@category Configuration}
class StatefulShellRoute extends ShellRouteBase {
  /// Constructs a [StatefulShellRoute] from a list of [StatefulShellBranch]es,
  /// each representing a separate nested navigation tree (branch).
  ///
  /// A separate [Navigator] will be created for each of the branches, using
  /// the navigator key specified in [StatefulShellBranch]. The Widget
  /// implementing the container for the branch Navigators is provided by
  /// [navigatorContainerBuilder].
  StatefulShellRoute({
    required this.branches,
    super.redirect,
    this.builder,
    this.pageBuilder,
    required this.navigatorContainerBuilder,
    super.parentNavigatorKey,
    this.restorationScopeId,
    GlobalKey<StatefulNavigationShellState>? key,
  })  : assert(branches.isNotEmpty),
        assert((pageBuilder != null) || (builder != null),
            'One of builder or pageBuilder must be provided'),
        assert(_debugUniqueNavigatorKeys(branches).length == branches.length,
            'Navigator keys must be unique'),
        assert(_debugValidateParentNavigatorKeys(branches)),
        assert(_debugValidateRestorationScopeIds(restorationScopeId, branches)),
        _shellStateKey = key ?? GlobalKey<StatefulNavigationShellState>(),
        super._(routes: _routes(branches));

  /// Constructs a StatefulShellRoute that uses an [IndexedStack] for its
  /// nested [Navigator]s.
  ///
  /// This constructor provides an IndexedStack based implementation for the
  /// container ([navigatorContainerBuilder]) used to manage the Widgets
  /// representing the branch Navigators. Apart from that, this constructor
  /// works the same way as the default constructor.
  ///
  /// See [Stateful Nested Navigation](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stacked_shell_route.dart)
  /// for a complete runnable example using StatefulShellRoute.indexedStack.
  StatefulShellRoute.indexedStack({
    required List<StatefulShellBranch> branches,
    GoRouterRedirect? redirect,
    StatefulShellRouteBuilder? builder,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    StatefulShellRoutePageBuilder? pageBuilder,
    String? restorationScopeId,
    GlobalKey<StatefulNavigationShellState>? key,
  }) : this(
          branches: branches,
          redirect: redirect,
          builder: builder,
          pageBuilder: pageBuilder,
          parentNavigatorKey: parentNavigatorKey,
          restorationScopeId: restorationScopeId,
          navigatorContainerBuilder: _indexedStackContainerBuilder,
          key: key,
        );

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  /// The widget builder for a stateful shell route.
  ///
  /// Similar to [GoRoute.builder], but with an additional
  /// [StatefulNavigationShell] parameter. StatefulNavigationShell is a Widget
  /// responsible for managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget. StatefulNavigationShell can also be used to access information
  /// about which branch is active, and also to navigate to a different branch
  /// (using [StatefulNavigationShell.goBranch]).
  ///
  /// Custom implementations may choose to ignore the child parameter passed to
  /// the builder function, and instead use [StatefulNavigationShell] to
  /// create a custom container for the branch Navigators.
  final StatefulShellRouteBuilder? builder;

  /// The page builder for a stateful shell route.
  ///
  /// Similar to [GoRoute.pageBuilder], but with an additional
  /// [StatefulNavigationShell] parameter. StatefulNavigationShell is a Widget
  /// responsible for managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget. StatefulNavigationShell can also be used to access information
  /// about which branch is active, and also to navigate to a different branch
  /// (using [StatefulNavigationShell.goBranch]).
  ///
  /// Custom implementations may choose to ignore the child parameter passed to
  /// the builder function, and instead use [StatefulNavigationShell] to
  /// create a custom container for the branch Navigators.
  final StatefulShellRoutePageBuilder? pageBuilder;

  /// The builder for the branch Navigator container.
  ///
  /// The function responsible for building the container for the branch
  /// Navigators. When this function is invoked, access is provided to a List of
  /// Widgets representing the branch Navigators, where the the index
  /// corresponds to the index of in [branches].
  ///
  /// The builder function is expected to return a Widget that ensures that the
  /// state of the branch Widgets is maintained, for instance by inducting them
  /// in the Widget tree.
  final ShellNavigationContainerBuilder navigatorContainerBuilder;

  /// Representations of the different stateful route branches that this
  /// shell route will manage.
  ///
  /// Each branch uses a separate [Navigator], identified
  /// [StatefulShellBranch.navigatorKey].
  final List<StatefulShellBranch> branches;

  final GlobalKey<StatefulNavigationShellState> _shellStateKey;

  @override
  Widget? buildWidget(BuildContext context, GoRouterState state,
      ShellRouteContext shellRouteContext) {
    if (builder != null) {
      return builder!(context, state, _createShell(context, shellRouteContext));
    }
    return null;
  }

  @override
  Page<dynamic>? buildPage(BuildContext context, GoRouterState state,
      ShellRouteContext shellRouteContext) {
    if (pageBuilder != null) {
      return pageBuilder!(
          context, state, _createShell(context, shellRouteContext));
    }
    return null;
  }

  @override
  GlobalKey<NavigatorState> navigatorKeyForSubRoute(RouteBase subRoute) {
    final StatefulShellBranch? branch = branches.firstWhereOrNull(
        (StatefulShellBranch e) => e.routes.contains(subRoute));
    assert(branch != null);
    return branch!.navigatorKey;
  }

  Iterable<GlobalKey<NavigatorState>> get _navigatorKeys =>
      branches.map((StatefulShellBranch b) => b.navigatorKey);

  StatefulNavigationShell _createShell(
          BuildContext context, ShellRouteContext shellRouteContext) =>
      StatefulNavigationShell(
          shellRouteContext: shellRouteContext,
          router: GoRouter.of(context),
          containerBuilder: navigatorContainerBuilder);

  static Widget _indexedStackContainerBuilder(BuildContext context,
      StatefulNavigationShell navigationShell, List<Widget> children) {
    return _IndexedStackedRouteBranchContainer(
        currentIndex: navigationShell.currentIndex, children: children);
  }

  static List<RouteBase> _routes(List<StatefulShellBranch> branches) =>
      branches.expand((StatefulShellBranch e) => e.routes).toList();

  static Set<GlobalKey<NavigatorState>> _debugUniqueNavigatorKeys(
          List<StatefulShellBranch> branches) =>
      Set<GlobalKey<NavigatorState>>.from(
          branches.map((StatefulShellBranch e) => e.navigatorKey));

  static bool _debugValidateParentNavigatorKeys(
      List<StatefulShellBranch> branches) {
    for (final StatefulShellBranch branch in branches) {
      for (final RouteBase route in branch.routes) {
        if (route is GoRoute) {
          assert(route.parentNavigatorKey == null ||
              route.parentNavigatorKey == branch.navigatorKey);
        }
      }
    }
    return true;
  }

  static bool _debugValidateRestorationScopeIds(
      String? restorationScopeId, List<StatefulShellBranch> branches) {
    if (branches
        .map((StatefulShellBranch e) => e.restorationScopeId)
        .whereNotNull()
        .isNotEmpty) {
      assert(
          restorationScopeId != null,
          'A restorationScopeId must be set for '
          'the StatefulShellRoute when using restorationScopeIds on one or more '
          'of the branches');
    }
    return true;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Iterable<GlobalKey<NavigatorState>>>(
        'navigatorKeys', _navigatorKeys));
  }
}

/// Representation of a separate branch in a stateful navigation tree, used to
/// configure [StatefulShellRoute].
///
/// The only required argument when creating a StatefulShellBranch is the
/// sub-routes ([routes]), however sometimes it may be convenient to also
/// provide a [initialLocation]. The value of this parameter is used when
/// loading the branch for the first time (for instance when switching branch
/// using the goBranch method in [StatefulNavigationShell]).
///
/// A separate [Navigator] will be built for each StatefulShellBranch in a
/// [StatefulShellRoute], and the routes of this branch will be placed onto that
/// Navigator instead of the root Navigator. A custom [navigatorKey] can be
/// provided when creating a StatefulShellBranch, which can be useful when the
/// Navigator needs to be accessed elsewhere. If no key is provided, a default
/// one will be created.
@immutable
class StatefulShellBranch {
  /// Constructs a [StatefulShellBranch].
  StatefulShellBranch({
    required this.routes,
    GlobalKey<NavigatorState>? navigatorKey,
    this.initialLocation,
    this.restorationScopeId,
    this.observers,
    this.preload = false,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    assert(() {
      ShellRouteBase._debugCheckSubRouteParentNavigatorKeys(
          routes, this.navigatorKey);
      return true;
    }());
  }

  /// The [GlobalKey] to be used by the [Navigator] built for this branch.
  ///
  /// A separate Navigator will be built for each StatefulShellBranch in a
  /// [StatefulShellRoute] and this key will be used to identify the Navigator.
  /// The routes associated with this branch will be placed o onto that
  /// Navigator instead of the root Navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The list of child routes associated with this route branch.
  final List<RouteBase> routes;

  /// The initial location for this route branch.
  ///
  /// If none is specified, the location of the first descendant [GoRoute] will
  /// be used (i.e. [defaultRoute]). The initial location is used when loading
  /// the branch for the first time (for instance when switching branch using
  /// the goBranch method).
  final String? initialLocation;

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  /// The observers for this branch.
  ///
  /// The observers parameter is used by the [Navigator] built for this branch.
  final List<NavigatorObserver>? observers;

  /// Whether this route branch should be eagerly loaded when navigating to the
  /// associated StatefulShellRoute for the first time.
  ///
  /// If this property is `false` (the default), the branch will only be loaded
  /// when needed. Set the value to `true` to force the branch to be loaded
  /// immediately when the associated [StatefulShellRoute] is visited for the
  /// first time. In that case, the branch will be preloaded by navigating to
  /// the initial location (see [initialLocation]).
  ///
  /// *Note:* The primary purpose of branch preloading is to enhance the user
  /// experience when switching branches. As with all preloading, there is a
  /// cost in terms of resource use. **Use sparingly** and only after a thorough
  /// trade-off analysis.
  final bool preload;

  /// The default route of this branch, i.e. the first descendant [GoRoute].
  ///
  /// This route will be used when loading the branch for the first time, if
  /// an [initialLocation] has not been provided.
  GoRoute? get defaultRoute =>
      RouteBase.routesRecursively(routes).whereType<GoRoute>().firstOrNull;
}

/// Builder for a custom container for the branch Navigators of a
/// [StatefulShellRoute].
typedef ShellNavigationContainerBuilder = Widget Function(BuildContext context,
    StatefulNavigationShell navigationShell, List<Widget> children);

/// Widget for managing the state of a [StatefulShellRoute].
///
/// Normally, this widget is not used directly, but is instead created
/// internally by StatefulShellRoute. However, if a custom container for the
/// branch Navigators is required, StatefulNavigationShell can be used in
/// the builder or pageBuilder methods of StatefulShellRoute to facilitate this.
/// The container is created using the provided [ShellNavigationContainerBuilder],
/// where the List of Widgets represent the Navigators for each branch.
///
/// Example:
/// ```dart
/// builder: (BuildContext context, GoRouterState state,
///     StatefulNavigationShell navigationShell) {
///   return StatefulNavigationShell(
///     shellRouteState: state,
///     containerBuilder: (_, __, List<Widget> children) => MyCustomShell(shellState: state, children: children),
///   );
/// }
/// ```
class StatefulNavigationShell extends StatefulWidget {
  /// Constructs an [StatefulNavigationShell].
  StatefulNavigationShell({
    required this.shellRouteContext,
    required GoRouter router,
    required this.containerBuilder,
  })  : assert(shellRouteContext.route is StatefulShellRoute),
        _router = router,
        currentIndex = _indexOfBranchNavigatorKey(
            shellRouteContext.route as StatefulShellRoute,
            shellRouteContext.navigatorKey),
        super(
            key:
                (shellRouteContext.route as StatefulShellRoute)._shellStateKey);

  /// The ShellRouteContext responsible for building the Navigator for the
  /// current [StatefulShellBranch].
  final ShellRouteContext shellRouteContext;

  final GoRouter _router;

  /// The builder for a custom container for shell route Navigators.
  final ShellNavigationContainerBuilder containerBuilder;

  /// The index of the currently active [StatefulShellBranch].
  ///
  /// Corresponds to the index in the branches field of [StatefulShellRoute].
  final int currentIndex;

  /// The associated [StatefulShellRoute].
  StatefulShellRoute get route => shellRouteContext.route as StatefulShellRoute;

  /// Navigate to the last location of the [StatefulShellBranch] at the provided
  /// index in the associated [StatefulShellBranch].
  ///
  /// This method will switch the currently active branch [Navigator] for the
  /// [StatefulShellRoute]. If the branch has not been visited before, or if
  /// initialLocation is true, this method will navigate to initial location of
  /// the branch (see [StatefulShellBranch.initialLocation]).
  // TODO(chunhtai): figure out a way to avoid putting navigation API in widget
  // class.
  void goBranch(int index, {bool initialLocation = false}) {
    final StatefulShellRoute route =
        shellRouteContext.route as StatefulShellRoute;
    final StatefulNavigationShellState? shellState =
        route._shellStateKey.currentState;
    if (shellState != null) {
      shellState.goBranch(index, initialLocation: initialLocation);
    } else {
      _router.go(_effectiveInitialBranchLocation(index));
    }
  }

  /// Checks if the provided branch is loaded (i.e. has navigation state
  /// associated with it).
  @visibleForTesting
  List<StatefulShellBranch> get debugLoadedBranches =>
      route._shellStateKey.currentState?._loadedBranches ??
      <StatefulShellBranch>[];

  /// Gets the effective initial location for the branch at the provided index
  /// in the associated [StatefulShellRoute].
  ///
  /// The effective initial location is either the
  /// [StatefulShellBranch.initialLocation], if specified, or the location of the
  /// [StatefulShellBranch.defaultRoute].
  String _effectiveInitialBranchLocation(int index) {
    final StatefulShellRoute route =
        shellRouteContext.route as StatefulShellRoute;
    final StatefulShellBranch branch = route.branches[index];
    final String? initialLocation = branch.initialLocation;
    if (initialLocation != null) {
      return initialLocation;
    } else {
      /// Recursively traverses the routes of the provided StackedShellBranch to
      /// find the first GoRoute, from which a full path will be derived.
      final GoRoute route = branch.defaultRoute!;
      final List<String> parameters = <String>[];
      patternToRegExp(route.path, parameters);
      assert(parameters.isEmpty);
      final String fullPath = _router.configuration.locationForRoute(route)!;
      return patternToPath(
          fullPath, shellRouteContext.routerState.pathParameters);
    }
  }

  @override
  State<StatefulWidget> createState() => StatefulNavigationShellState();

  /// Gets the state for the nearest stateful shell route in the Widget tree.
  static StatefulNavigationShellState of(BuildContext context) {
    final StatefulNavigationShellState? shellState =
        context.findAncestorStateOfType<StatefulNavigationShellState>();
    assert(shellState != null);
    return shellState!;
  }

  /// Gets the state for the nearest stateful shell route in the Widget tree.
  ///
  /// Returns null if no stateful shell route is found.
  static StatefulNavigationShellState? maybeOf(BuildContext context) {
    final StatefulNavigationShellState? shellState =
        context.findAncestorStateOfType<StatefulNavigationShellState>();
    return shellState;
  }

  static int _indexOfBranchNavigatorKey(
      StatefulShellRoute route, GlobalKey<NavigatorState> navigatorKey) {
    final int index = route.branches.indexWhere(
        (StatefulShellBranch branch) => branch.navigatorKey == navigatorKey);
    assert(index >= 0);
    return index;
  }
}

/// State for StatefulNavigationShell.
class StatefulNavigationShellState extends State<StatefulNavigationShell>
    with RestorationMixin {
  final Map<StatefulShellBranch, _StatefulShellBranchState> _branchState =
      <StatefulShellBranch, _StatefulShellBranchState>{};

  /// The associated [StatefulShellRoute].
  StatefulShellRoute get route => widget.route;

  GoRouter get _router => widget._router;

  bool _isBranchLoaded(StatefulShellBranch branch) =>
      _branchState[branch] != null;

  List<StatefulShellBranch> get _loadedBranches => _branchState.keys.toList();

  @override
  String? get restorationId => route.restorationScopeId;

  /// Generates a derived restoration ID for the branch location property,
  /// falling back to the identity hash code of the branch to ensure an ID is
  /// always returned (needed for _RestorableRouteMatchList/RestorableValue).
  String _branchLocationRestorationScopeId(StatefulShellBranch branch) {
    return branch.restorationScopeId != null
        ? '${branch.restorationScopeId}-location'
        : identityHashCode(branch).toString();
  }

  _StatefulShellBranchState _branchStateFor(StatefulShellBranch branch,
      [bool register = true]) {
    return _branchState.putIfAbsent(branch, () {
      final _StatefulShellBranchState branchState = _StatefulShellBranchState(
          location: _RestorableRouteMatchList(_router.configuration));
      if (register) {
        registerForRestoration(
            branchState.location, _branchLocationRestorationScopeId(branch));
      }
      return branchState;
    });
  }

  RouteMatchList? _matchListForBranch(int index) =>
      _branchState[route.branches[index]]?.location.value;

  /// Creates a new RouteMatchList that is scoped to the Navigators of the
  /// current shell route or it's descendants. This involves removing all the
  /// trailing imperative matches from the RouterMatchList that are targeted at
  /// any other (often top-level) Navigator.
  RouteMatchList _scopedMatchList(RouteMatchList matchList) {
    return matchList.copyWith(matches: _scopeMatches(matchList.matches));
  }

  List<RouteMatchBase> _scopeMatches(List<RouteMatchBase> matches) {
    final List<RouteMatchBase> result = <RouteMatchBase>[];
    for (final RouteMatchBase match in matches) {
      if (match is ShellRouteMatch) {
        if (match.route == route) {
          result.add(match);
          // Discard any other route match after current shell route.
          break;
        }
        result.add(match.copyWith(matches: _scopeMatches(match.matches)));
        continue;
      }
      result.add(match);
    }
    return result;
  }

  void _updateCurrentBranchStateFromWidget() {
    _preloadBranches();

    final StatefulShellBranch branch = route.branches[widget.currentIndex];
    final ShellRouteContext shellRouteContext = widget.shellRouteContext;
    final RouteMatchList currentBranchLocation =
        _scopedMatchList(shellRouteContext.routeMatchList);

    final _StatefulShellBranchState branchState =
        _branchStateFor(branch, false);
    final RouteMatchList previousBranchLocation = branchState.location.value;
    branchState.location.value = currentBranchLocation;
    final bool hasExistingNavigator = branchState.navigator != null;

    /// Only update the Navigator of the route match list has changed
    final bool locationChanged =
        previousBranchLocation != currentBranchLocation;
    if (locationChanged || !hasExistingNavigator) {
      branchState.navigator = shellRouteContext._buildNavigatorForCurrentRoute(
          branch.observers, branch.restorationScopeId);
    }

    _cleanUpObsoleteBranches();
  }

  void _preloadBranches() {
    for (int i = 0; i < route.branches.length; i++) {
      final StatefulShellBranch branch = route.branches[i];
      if (i != currentIndex && branch.preload && !_isBranchLoaded(branch)) {
        // Find the match for the current StatefulShellRoute in matchList
        // returned by _effectiveInitialBranchLocation (the initial location
        // should already have been validated by RouteConfiguration).
        final RouteMatchList matchList = _router.configuration
            .findMatch(Uri.parse(widget._effectiveInitialBranchLocation(i)));
        ShellRouteMatch? match;
        matchList.visitRouteMatches((RouteMatchBase e) {
          match = e is ShellRouteMatch && e.route == route ? e : match;
          return match == null;
        });
        assert(match != null);

        final Widget navigator = widget.shellRouteContext.navigatorBuilder(
          branch.navigatorKey,
          match!,
          matchList,
          branch.observers,
          branch.restorationScopeId,
        );

        final _StatefulShellBranchState branchState =
            _branchStateFor(branch, false);
        branchState.location.value = matchList;
        branchState.navigator = navigator;
      }
    }
  }

  void _cleanUpObsoleteBranches() {
    _branchState.removeWhere(
        (StatefulShellBranch branch, _StatefulShellBranchState branchState) {
      if (!route.branches.contains(branch)) {
        branchState.dispose();
        return true;
      }
      return false;
    });
  }

  /// The index of the currently active [StatefulShellBranch].
  ///
  /// Corresponds to the index in the branches field of [StatefulShellRoute].
  int get currentIndex => widget.currentIndex;

  /// Navigate to the last location of the [StatefulShellBranch] at the provided
  /// index in the associated [StatefulShellBranch].
  ///
  /// This method will switch the currently active branch [Navigator] for the
  /// [StatefulShellRoute]. If the branch has not been visited before, or if
  /// initialLocation is true, this method will navigate to initial location of
  /// the branch (see [StatefulShellBranch.initialLocation]).
  void goBranch(int index, {bool initialLocation = false}) {
    assert(index >= 0 && index < route.branches.length);
    final RouteMatchList? matchList =
        initialLocation ? null : _matchListForBranch(index);
    if (matchList != null && matchList.isNotEmpty) {
      _router.restore(matchList);
    } else {
      _router.go(widget._effectiveInitialBranchLocation(index));
    }
  }

  @override
  void initState() {
    super.initState();
    _updateCurrentBranchStateFromWidget();
  }

  @override
  void dispose() {
    super.dispose();
    for (final _StatefulShellBranchState branchState in _branchState.values) {
      branchState.dispose();
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    route.branches.forEach(_branchStateFor);
  }

  @override
  void didUpdateWidget(covariant StatefulNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCurrentBranchStateFromWidget();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = route.branches
        .map((StatefulShellBranch branch) => _BranchNavigatorProxy(
            key: ObjectKey(branch),
            branch: branch,
            navigatorForBranch: (StatefulShellBranch branch) =>
                _branchState[branch]?.navigator))
        .toList();

    return widget.containerBuilder(context, widget, children);
  }
}

class _StatefulShellBranchState {
  _StatefulShellBranchState({
    required this.location,
  });

  Widget? navigator;
  final _RestorableRouteMatchList location;

  void dispose() {
    location.dispose();
  }
}

/// [RestorableProperty] for enabling state restoration of [RouteMatchList]s.
class _RestorableRouteMatchList extends RestorableProperty<RouteMatchList> {
  _RestorableRouteMatchList(RouteConfiguration configuration)
      : _matchListCodec = RouteMatchListCodec(configuration);

  final RouteMatchListCodec _matchListCodec;

  RouteMatchList get value => _value;
  RouteMatchList _value = RouteMatchList.empty;
  set value(RouteMatchList newValue) {
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }
  }

  @override
  void initWithValue(RouteMatchList value) {
    _value = value;
  }

  @override
  RouteMatchList createDefaultValue() => RouteMatchList.empty;

  @override
  RouteMatchList fromPrimitives(Object? data) {
    return data == null
        ? RouteMatchList.empty
        : _matchListCodec.decode(data as Map<Object?, Object?>);
  }

  @override
  Object? toPrimitives() {
    if (value.isNotEmpty) {
      return _matchListCodec.encode(value);
    }
    return null;
  }
}

typedef _NavigatorForBranch = Widget? Function(StatefulShellBranch);

/// Widget that serves as the proxy for a branch Navigator Widget, which
/// possibly hasn't been created yet.
///
/// This Widget hides the logic handling whether a Navigator Widget has been
/// created yet for a branch or not, and at the same time ensures that the same
/// Widget class is consistently passed to the containerBuilder. The latter is
/// important for container implementations that cache child widgets,
/// such as [TabBarView].
class _BranchNavigatorProxy extends StatefulWidget {
  const _BranchNavigatorProxy({
    super.key,
    required this.branch,
    required this.navigatorForBranch,
  });

  final StatefulShellBranch branch;
  final _NavigatorForBranch navigatorForBranch;

  @override
  State<StatefulWidget> createState() => _BranchNavigatorProxyState();
}

/// State for _BranchNavigatorProxy, using AutomaticKeepAliveClientMixin to
/// properly handle some scenarios where Slivers are used to manage the branches
/// (such as [TabBarView]).
class _BranchNavigatorProxyState extends State<_BranchNavigatorProxy>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.navigatorForBranch(widget.branch) ?? const SizedBox.shrink();
  }

  @override
  bool get wantKeepAlive => true;
}

/// Default implementation of a container widget for the [Navigator]s of the
/// route branches. This implementation uses an [IndexedStack] as a container.
class _IndexedStackedRouteBranchContainer extends StatelessWidget {
  const _IndexedStackedRouteBranchContainer(
      {required this.currentIndex, required this.children});

  final int currentIndex;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> stackItems = children
        .mapIndexed((int index, Widget child) =>
            _buildRouteBranchContainer(context, currentIndex == index, child))
        .toList();

    return IndexedStack(index: currentIndex, children: stackItems);
  }

  Widget _buildRouteBranchContainer(
      BuildContext context, bool isActive, Widget child) {
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: child,
      ),
    );
  }
}
