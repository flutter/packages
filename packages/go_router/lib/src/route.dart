// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'configuration.dart';
import 'pages/custom_transition_page.dart';
import 'path_utils.dart';
import 'typedefs.dart';

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
/// ```
/// /         => HomePage()
///   family/f1 => FamilyPage('f1')
///     person/p2 => PersonPage('f1', 'p2') ← showing this page, Back pops ↑
/// ```
///
/// Can be represented as:
///
/// ```
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
///             final Family family = Families.family(state.params['fid']!);
///             return MaterialPage<void>(
///               key: state.pageKey,
///               child: FamilyPage(family: family),
///             );
///           },
///           routes: <GoRoute>[
///             GoRoute(
///               path: 'person/:pid',
///               pageBuilder: (BuildContext context, GoRouterState state) {
///                 final Family family = Families.family(state.params['fid']!);
///                 final Person person = family.person(state.params['pid']!);
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
///
/// If there are multiple routes that match the location, the first match is used.
/// To make predefined routes to take precedence over dynamic routes eg. '/:id'
/// consider adding the dynamic route at the end of the routes
/// For example:
/// ```
/// final GoRouter _router = GoRouter(
///   routes: <GoRoute>[
///     GoRoute(
///       path: '/',
///       redirect: (_) => '/family/${Families.data[0].id}',
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
/// In the above example, if /family route is matched, it will be used.
/// else /:username route will be used.
/// ///
/// See [main.dart](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/main.dart)
@immutable
abstract class RouteBase {
  const RouteBase._({
    this.routes = const <RouteBase>[],
  });

  /// The list of child routes associated with this route.
  final List<RouteBase> routes;
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
    this.parentNavigatorKey,
    this.redirect,
    super.routes = const <RouteBase>[],
  })  : assert(path.isNotEmpty, 'GoRoute path cannot be empty'),
        assert(name == null || name.isNotEmpty, 'GoRoute name cannot be empty'),
        assert(pageBuilder != null || builder != null || redirect != null,
            'builder, pageBuilder, or redirect must be provided'),
        super._() {
    // cache the path regexp and parameters
    _pathRE = patternToRegExp(path, pathParams);
  }

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
  ///   params: <String, String>{'fid': 123},
  ///   queryParams: <String, String>{'qid': 'quid'},
  /// );
  /// ```
  ///
  /// See the [named routes example](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/named_routes.dart)
  /// for a complete runnable app.
  final String? name;

  /// The path of this go route.
  ///
  /// For example:
  /// ```
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
  /// See [Query parameters and path parameters](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/sub_routes.dart)
  /// to learn more about parameters.
  final String path;

  /// A page builder for this route.
  ///
  /// Typically a MaterialPage, as in:
  /// ```
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
  /// ```
  /// GoRoute(
  ///   path: '/',
  ///   builder: (BuildContext context, GoRouterState state) => FamilyPage(
  ///     families: Families.family(
  ///       state.params['id'],
  ///     ),
  ///   ),
  /// ),
  /// ```
  ///
  final GoRouterWidgetBuilder? builder;

  /// An optional redirect function for this route.
  ///
  /// In the case that you like to make a redirection decision for a specific
  /// route (or sub-route), consider doing so by passing a redirect function to
  /// the GoRoute constructor.
  ///
  /// For example:
  /// ```
  /// final GoRouter _router = GoRouter(
  ///   routes: <GoRoute>[
  ///     GoRoute(
  ///       path: '/',
  ///       redirect: (_) => '/family/${Families.data[0].id}',
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
  /// ```
  /// final GoRouter _router = GoRouter(
  ///   routes: <GoRoute>[
  ///     GoRoute(
  ///       path: '/',
  ///       redirect: (_) => '/page1', // this takes priority over the sub-route.
  ///       routes: <GoRoute>[
  ///         GoRoute(
  ///           path: 'child',
  ///           redirect: (_) => '/page2',
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

  /// An optional key specifying which Navigator to display this route's screen
  /// onto.
  ///
  /// Specifying the root Navigator will stack this route onto that
  /// Navigator instead of the nearest ShellRoute ancestor.
  final GlobalKey<NavigatorState>? parentNavigatorKey;

  // TODO(chunhtai): move all regex related help methods to path_utils.dart.
  /// Match this route against a location.
  RegExpMatch? matchPatternAsPrefix(String loc) =>
      _pathRE.matchAsPrefix(loc) as RegExpMatch?;

  /// Extract the path parameters from a match.
  Map<String, String> extractPathParams(RegExpMatch match) =>
      extractPathParameters(pathParams, match);

  /// The path parameters in this route.
  @internal
  final List<String> pathParams = <String>[];

  @override
  String toString() {
    return 'GoRoute(name: $name, path: $path)';
  }

  late final RegExp _pathRE;
}

/// Base class for classes that act as shells for sub-routes, such
/// as [ShellRoute] and [StatefulShellRoute].
abstract class ShellRouteBase extends RouteBase {
  const ShellRouteBase._({this.builder, this.pageBuilder, super.routes})
      : super._();

  /// The widget builder for a shell route.
  ///
  /// Similar to GoRoute builder, but with an additional child parameter. This
  /// child parameter is the Widget managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget.
  final ShellRouteBuilder? builder;

  /// The page builder for a shell route.
  ///
  /// Similar to GoRoute builder, but with an additional child parameter. This
  /// child parameter is the Widget managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget.
  final ShellRoutePageBuilder? pageBuilder;

  /// Returns the key for the [Navigator] that is to be used for the specified
  /// immediate sub-route of this shell route.
  GlobalKey<NavigatorState> navigatorKeyForSubRoute(RouteBase subRoute);
}

/// A route that displays a UI shell around the matching child route.
///
/// When a ShellRoute is added to the list of routes on GoRouter or GoRoute, a
/// new Navigator that is used to display any matching sub-routes, instead of
/// placing them on the root Navigator.
///
/// To display a child route on a different Navigator, provide it with a
/// [parentNavigatorKey] that matches the key provided to either the [GoRouter]
/// or [ShellRoute] constructor. In this example, the _rootNavigator key is
/// passed to the /b/details route so that it displays on the root Navigator
/// instead of the ShellRoute's Navigator:
///
/// ```
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
/// ```
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
    super.builder,
    super.pageBuilder,
    super.routes,
    GlobalKey<NavigatorState>? navigatorKey,
    this.restorationScopeId,
  })  : assert(routes.isNotEmpty),
        navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        super._() {
    for (final RouteBase route in routes) {
      if (route is GoRoute) {
        assert(route.parentNavigatorKey == null ||
            route.parentNavigatorKey == navigatorKey);
      }
    }
  }

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
}

/// A route that displays a UI shell with separate [Navigator]s for its
/// sub-routes.
///
/// Similar to [ShellRoute], this route class places its sub-route on a
/// different Navigator than the root Navigator. However, this route class
/// differs in that it creates separate Navigators for each of its nested
/// branches (i.e. parallel navigation trees), making it possible to build an
/// app with stateful nested navigation. This is convenient when for instance
/// implementing a UI with a [BottomNavigationBar], with a persistent navigation
/// state for each tab.
///
/// A StatefulShellRoute is created by specifying a List of [StatefulShellBranch]
/// items, each representing a separate stateful branch in the route tree.
/// StatefulShellBranch provides the root routes and the Navigator key ([GlobalKey])
/// for the branch, as well as an optional default location.
///
/// Like [ShellRoute], a [builder] and [pageBuilder] can be provided when
/// creating a StatefulShellRoute. However, StatefulShellRoute differs in that
/// the builder is mandatory and the pageBuilder may optionally be used in
/// addition to the builder. The reason for this is that the builder function is
/// not used to generate the final Widget used to represent the
/// StatefulShellRoute. Instead, the returned Widget will only form part of the
/// stateful navigation shell for this route. This means that the role of the
/// [builder] is to provide part of the navigation shell, whereas the role of
/// [pageBuilder] is simply to customize the Page used for this route (see
/// example below).
///
/// In the builder function, the child parameter is a Widget that contains - and is
/// responsible for managing - the Navigators for the different route branches
/// of this StatefulShellRoute. This widget is meant to be used as the body of a
/// custom shell implementation, for example as the body of [Scaffold] with a
/// [BottomNavigationBar].
///
/// The state of a StatefulShellRoute is represented by
/// [StatefulShellRouteState], which can be accessed by calling
/// [StatefulShellRouteState.of]. This state object exposes information such
/// as the current branch index, the state of the route branches etc. The state
/// object also provides support for changing the active branch, i.e. restoring
/// the navigation stack of another branch. This is accomplished using the
/// method [StatefulShellRouteState.goBranch], and providing either a Navigator
/// key, branch name or branch index. For example:
///
/// ```
/// void _onBottomNavigationBarItemTapped(BuildContext context, int index) {
///   final StatefulShellRouteState shellState = StatefulShellRouteState.of(context);
///   shellState.goBranch(index: index);
/// }
/// ```
///
/// Sometimes greater control is needed over the layout and animations of the
/// Widgets representing the branch Navigators. In such cases, the child
/// argument in the builder function can be ignored, and a custom implementation
/// can instead be built using the child widgets of the branches
/// (see [StatefulShellRouteState.children]) directly. For example:
///
/// ```
/// final StatefulShellRouteState shellState = StatefulShellRouteState.of(context);
/// final int currentIndex = shellState.currentIndex;
/// final List<Widget> children = shellRouteState.children;
/// return MyCustomShell(currentIndex, children);
/// ```
///
/// Below is a simple example of how a router configuration with
/// StatefulShellRoute could be achieved. In this example, a
/// BottomNavigationBar with two tabs is used, and each of the tabs gets its
/// own Navigator. A container widget responsible for managing the Navigators
/// for all route branches will then be passed as the child argument
/// of the builder function.
///
/// ```
/// final GlobalKey<NavigatorState> _tabANavigatorKey =
///   GlobalKey<NavigatorState>(debugLabel: 'tabANavigator');
/// final GlobalKey<NavigatorState> _tabBNavigatorKey =
///   GlobalKey<NavigatorState>(debugLabel: 'tabBNavigator');
///
/// final GoRouter _router = GoRouter(
///   initialLocation: '/a',
///   routes: <RouteBase>[
///     StatefulShellRoute(
///       builder: (BuildContext context, GoRouterState state,
///           Widget navigatorContainer) {
///         return ScaffoldWithNavBar(body: navigatorContainer);
///       },
///       branches: [
///         /// The first branch, i.e. tab 'A'
///         StatefulShellBranch(
///           navigatorKey: _tabANavigatorKey,
///           routes: <RouteBase>[
///             GoRoute(
///               path: '/a',
///               builder: (BuildContext context, GoRouterState state) =>
///                   const RootScreen(label: 'A', detailsPath: '/a/details'),
///               routes: <RouteBase>[
///                 /// Will cover screen A but not the bottom navigation bar
///                 GoRoute(
///                   path: 'details',
///                   builder: (BuildContext context, GoRouterState state) =>
///                       const DetailsScreen(label: 'A'),
///                 ),
///               ],
///             ),
///           ],
///         ),
///         /// The second branch, i.e. tab 'B'
///         StatefulShellBranch(
///           navigatorKey: _tabBNavigatorKey,
///           routes: <RouteBase>[
///             GoRoute(
///               path: '/b',
///               builder: (BuildContext context, GoRouterState state) =>
///                   const RootScreen(label: 'B', detailsPath: '/b/details'),
///               routes: <RouteBase>[
///                 /// Will cover screen B but not the bottom navigation bar
///                 GoRoute(
///                   path: 'details',
///                   builder: (BuildContext context, GoRouterState state) =>
///                       const DetailsScreen(label: 'B'),
///                 ),
///               ],
///             ),
///           ],
///         ),
///       ],
///     ),
///   ],
/// );
/// ```
///
/// When the [Page] for this route needs to be customized, a pageBuilder needs
/// to be provided. Note that this page builder doesn't replace the builder
/// function, but instead receives the stateful shell built by
/// [StatefulShellRoute] (using the builder function) as input. In other words,
/// builder and pageBuilder must both be provided when using a custom page for
/// a StatefulShellRoute. For example:
///
/// ```
/// final GoRouter _router = GoRouter(
///   initialLocation: '/a',
///   routes: <RouteBase>[
///     StatefulShellRoute(
///       builder: (BuildContext context, GoRouterState state,
///           Widget navigationContainer) {
///         return ScaffoldWithNavBar(body: navigationContainer);
///       },
///       pageBuilder:
///           (BuildContext context, GoRouterState state, Widget statefulShell) {
///         return NoTransitionPage<dynamic>(child: statefulShell);
///       },
///       branches: <StatefulShellBranch>[
///         /// The first branch, i.e. root of tab 'A'
///         StatefulShellBranch(routes: <RouteBase>[
///           GoRoute(
///             parentNavigatorKey: _tabANavigatorKey,
///             path: '/a',
///             builder: (BuildContext context, GoRouterState state) =>
///               const RootScreen(label: 'A', detailsPath: '/a/details'),
///           ),
///         ]),
///         /// The second branch, i.e. root of tab 'B'
///         StatefulShellBranch(routes: <RouteBase>[
///           GoRoute(
///             parentNavigatorKey: _tabBNavigatorKey,
///             path: '/b',
///             builder: (BuildContext context, GoRouterState state) =>
///               const RootScreen(label: 'B', detailsPath: '/b/details/1'),
///           ),
///         ]),
///       ],
///     ),
///   ],
/// );
/// ```
///
/// To access the current state of this route, to for instance access the
/// index of the current route branch - use the method
/// [StatefulShellRouteState.of]. For example:
///
/// ```
/// final StatefulShellRouteState shellState = StatefulShellRouteState.of(context);
/// ```
///
/// See [Stateful Nested Navigation](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_nested_navigation.dart)
/// for a complete runnable example using StatefulShellRoute.
class StatefulShellRoute extends ShellRouteBase {
  /// Constructs a [StatefulShellRoute] from a list of [StatefulShellBranch]es,
  /// each representing a separate nested navigation tree (branch).
  ///
  /// A separate [Navigator] will be created for each of the branches, using
  /// the navigator key specified in [StatefulShellBranch]. Note that unlike
  /// [ShellRoute], a builder must always be provided when creating a
  /// StatefulShellRoute. The pageBuilder however is optional, and is used
  /// in addition to the builder.
  StatefulShellRoute({
    required this.branches,
    required super.builder,
    super.pageBuilder,
  })  : assert(branches.isNotEmpty),
        assert(_debugUniqueNavigatorKeys(branches).length == branches.length,
            'Navigator keys must be unique'),
        super._(routes: _routes(branches)) {
    for (int i = 0; i < routes.length; ++i) {
      final RouteBase route = routes[i];
      if (route is GoRoute) {
        assert(route.parentNavigatorKey == null ||
            route.parentNavigatorKey == branches[i].navigatorKey);
      }
    }
  }

  /// Representations of the different stateful route branches that this
  /// shell route will manage.
  ///
  /// Each branch uses a separate [Navigator], identified
  /// [StatefulShellBranch.navigatorKey].
  final List<StatefulShellBranch> branches;

  @override
  GlobalKey<NavigatorState> navigatorKeyForSubRoute(RouteBase subRoute) {
    return branchForSubRoute(subRoute).navigatorKey;
  }

  /// Returns the StatefulShellBranch that is to be used for the specified
  /// immediate sub-route of this shell route.
  StatefulShellBranch branchForSubRoute(RouteBase subRoute) {
    final StatefulShellBranch? branch = branches.firstWhereOrNull(
        (StatefulShellBranch e) => e.routes.contains(subRoute));
    assert(branch != null);
    return branch!;
  }

  static List<RouteBase> _routes(List<StatefulShellBranch> branches) =>
      branches.expand((StatefulShellBranch e) => e.routes).toList();

  static Set<GlobalKey<NavigatorState>> _debugUniqueNavigatorKeys(
          List<StatefulShellBranch> branches) =>
      Set<GlobalKey<NavigatorState>>.from(
          branches.map((StatefulShellBranch e) => e.navigatorKey));
}

/// Representation of a separate branch in a stateful navigation tree, used to
/// configure [StatefulShellRoute].
///
/// The only required argument when creating a StatefulShellBranch is the
/// sub-routes ([routes]), however sometimes it may be convenient to also
/// provide a [defaultLocation]. The value of this parameter is used when
/// loading the branch for the first time (for instance when switching branch
/// using the goBranch method in [StatefulShellBranchState]). A [navigatorKey]
/// can be useful to provide in case it's necessary to access the [Navigator]
/// created for this branch elsewhere.
@immutable
class StatefulShellBranch {
  /// Constructs a [StatefulShellBranch].
  StatefulShellBranch({
    required this.routes,
    GlobalKey<NavigatorState>? navigatorKey,
    this.defaultLocation,
    this.name,
    this.restorationScopeId,
    this.preload = false,
  }) : navigatorKey = navigatorKey ??
            GlobalKey<NavigatorState>(
                debugLabel: name != null ? 'Branch-$name' : null);

  /// The [GlobalKey] to be used by the [Navigator] built for this branch.
  ///
  /// A separate Navigator will be built for each StatefulShellBranch in a
  /// [StatefulShellRoute] and this key will be used to identify the Navigator.
  /// The routes associated with this branch will be placed o onto that
  /// Navigator instead of the root Navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The list of child routes associated with this route branch.
  final List<RouteBase> routes;

  /// The default location for this route branch.
  ///
  /// If none is specified, the location of the first descendant [GoRoute] will
  /// be used (i.e. first element in [routes], or a descendant). The default
  /// location is used when loading the branch for the first time (for instance
  /// when switching branch using the goBranch method in
  /// [StatefulShellBranchState]).
  final String? defaultLocation;

  /// An optional name for this branch.
  final String? name;

  /// Whether this route branch should be preloaded when the associated
  /// [StatefulShellRoute] is visited for the first time.
  ///
  /// If this is true, this branch will be preloaded by navigating to
  /// the default location (see [defaultLocation]). The primary purpose of
  /// branch preloading is to enhance the user experience when switching
  /// branches, which might for instance involve preparing the UI for animated
  /// transitions etc. Care must be taken to **keep the preloading to an
  /// absolute minimum** to avoid any unnecessary resource use.
  final bool preload;

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! StatefulShellBranch) {
      return false;
    }
    return other.navigatorKey == navigatorKey &&
        other.defaultLocation == defaultLocation &&
        other.name == name &&
        other.preload == preload &&
        other.restorationScopeId == restorationScopeId;
  }

  @override
  int get hashCode => Object.hash(
      navigatorKey, defaultLocation, name, preload, restorationScopeId);
}
