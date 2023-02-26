// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../go_router.dart';
import 'path_utils.dart';

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
  /// Constructs a [ShellRouteBase].
  const ShellRouteBase._({super.routes}) : super._();

  /// Attempts to build the Widget representing this shell route.
  ///
  /// Returns null if this shell route does not build a Widget, but instead uses
  /// a Page to represent itself (see [buildPage]).
  Widget? buildWidget(BuildContext context, GoRouterState state,
      ShellNavigatorBuilder navigatorBuilder);

  /// Attempts to build the Page representing this shell route.
  ///
  /// Returns null if this shell route does not build a Page, , but instead uses
  /// a Widget to represent itself (see [buildWidget]).
  Page<dynamic>? buildPage(BuildContext context, GoRouterState state,
      ShellNavigatorBuilder navigatorBuilder);

  /// Returns the key for the [Navigator] that is to be used for the specified
  /// immediate sub-route of this shell route.
  GlobalKey<NavigatorState> navigatorKeyForSubRoute(RouteBase subRoute);
}

/// Navigator builder for shell routes.
abstract class ShellNavigatorBuilder {
  /// The [GlobalKey] to be used by the [Navigator] built for the current route.
  GlobalKey<NavigatorState> get navigatorKeyForCurrentRoute;

  /// The current route state.
  GoRouterState get state;

  /// The current shell route.
  ShellRouteBase get currentRoute;

  /// Builds a [Navigator] for the current route.
  Widget buildNavigatorForCurrentRoute({
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
    GlobalKey<NavigatorState>? navigatorKey,
  });

  /// Builds a preloaded [Navigator] for a specific location.
  Future<Widget?> buildPreloadedShellNavigator({
    required BuildContext context,
    required String location,
    required GlobalKey<NavigatorState> navigatorKey,
    required ShellRouteBase parentShellRoute,
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
  });
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
    this.builder,
    this.pageBuilder,
    this.observers,
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

  /// The widget builder for a shell route.
  ///
  /// Similar to GoRoute builder, but with an additional child parameter. This
  /// child parameter is the Widget managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget.
  final ShellRouteBuilder? builder;

  /// The page builder for a shell route.
  ///
  /// Similar to GoRoute pageBuilder, but with an additional child parameter.
  /// This child parameter is the Widget managing the nested navigation for the
  /// matching sub-routes. Typically, a shell route builds its shell around this
  /// Widget.
  final ShellRoutePageBuilder? pageBuilder;

  @override
  Widget? buildWidget(BuildContext context, GoRouterState state,
      ShellNavigatorBuilder navigatorBuilder) {
    if (builder != null) {
      final Widget navigator = navigatorBuilder.buildNavigatorForCurrentRoute(
          restorationScopeId: restorationScopeId, observers: observers);
      return builder!(context, state, navigator);
    }
    return null;
  }

  @override
  Page<dynamic>? buildPage(BuildContext context, GoRouterState state,
      ShellNavigatorBuilder navigatorBuilder) {
    if (pageBuilder != null) {
      final Widget navigator = navigatorBuilder.buildNavigatorForCurrentRoute(
          restorationScopeId: restorationScopeId, observers: observers);
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
/// for the branch, as well as an optional initial location.
///
/// Like [ShellRoute], either a [builder] or a [pageBuilder] must be provided
/// when creating a StatefulShellRoute. However, these builders differ in that
/// they both accept only a single [StatefulShellBuilder] parameter, used for
/// building the stateful shell for the route. The shell builder in turn accepts
/// a [ShellBodyWidgetBuilder] parameter, used for providing the actual body of
/// the shell.
///
/// In the ShellBodyWidgetBuilder function, the child parameter
/// ([ShellNavigatorContainer]) is a Widget that contains - and is responsible
/// for managing - the Navigators for the different route branches
/// of this StatefulShellRoute. This widget is meant to be used as the body of
/// the actual shell implementation, for example as the body of [Scaffold] with a
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
/// Widgets representing the branch Navigators. In such cases, a custom
/// implementation can access the Widgets containing the branch Navigators
/// directly through the field [ShellNavigatorContainer.children]. For example:
///
/// ```
/// builder: (StatefulShellBuilder shellBuilder) {
///   return shellBuilder.buildShell(
///         (BuildContext context, GoRouterState state,
///         ShellNavigatorContainer child) =>
///         TabbedRootScreen(children: child.children),
///   );
/// }
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
///       builder: (StatefulShellBuilder shellBuilder) {
///         return shellBuilder.buildShell(
///           (BuildContext context, GoRouterState state, Widget child) =>
///             ScaffoldWithNavBar(body: child));
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
/// To access the current state of this route, to for instance access the
/// index of the current route branch - use the method
/// [StatefulShellRouteState.of]. For example:
///
/// ```
/// final StatefulShellRouteState shellState = StatefulShellRouteState.of(context);
/// ```
///
/// See [Stateful Nested Navigation](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart)
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
    this.builder,
    this.pageBuilder,
  })  : assert(branches.isNotEmpty),
        assert((pageBuilder != null) ^ (builder != null),
            'builder or pageBuilder must be provided'),
        assert(_debugUniqueNavigatorKeys(branches).length == branches.length,
            'Navigator keys must be unique'),
        assert(_debugValidateParentNavigatorKeys(branches)),
        super._(routes: _routes(branches));

  /// The widget builder for a stateful shell route.
  ///
  /// Similar to [GoRoute.builder], but this builder function accepts a single
  /// [StatefulShellBuilder] parameter, used for building the stateful shell for
  /// this route. The shell builder in turn accepts a [ShellBodyWidgetBuilder]
  /// parameter, used for providing the actual body of the shell.
  ///
  /// Example:
  /// ```
  /// StatefulShellRoute(
  ///   builder: (StatefulShellBuilder shellBuilder) {
  ///     return shellBuilder.buildShell(
  ///        (BuildContext context, GoRouterState state, Widget child) =>
  ///          ScaffoldWithNavBar(body: child));
  ///   },
  /// )
  /// ```
  final StatefulShellRouteBuilder? builder;

  /// The page builder for a stateful shell route.
  ///
  /// Similar to [GoRoute.pageBuilder], This builder function accepts a single
  /// [StatefulShellBuilder] parameter, used for building the stateful shell for
  /// this route. The shell builder in turn accepts a [ShellBodyWidgetBuilder]
  /// parameter, used for providing the actual body of the shell.
  ///
  /// Example:
  /// ```
  /// StatefulShellRoute(
  ///   pageBuilder: (StatefulShellBuilder shellBuilder) {
  ///     final Widget statefulShell = shellBuilder.buildShell(
  ///        (BuildContext context, GoRouterState state, Widget child) =>
  ///          ScaffoldWithNavBar(body: child));
  ///     return MaterialPage<dynamic>(child: statefulShell);
  ///   },
  /// )
  /// ```
  final StatefulShellRoutePageBuilder? pageBuilder;

  /// Representations of the different stateful route branches that this
  /// shell route will manage.
  ///
  /// Each branch uses a separate [Navigator], identified
  /// [StatefulShellBranch.navigatorKey].
  final List<StatefulShellBranch> branches;

  @override
  Widget? buildWidget(BuildContext context, GoRouterState state,
      ShellNavigatorBuilder navigatorBuilder) {
    if (builder != null) {
      return builder!(StatefulShellBuilder(this, navigatorBuilder));
    }
    return null;
  }

  @override
  Page<dynamic>? buildPage(BuildContext context, GoRouterState state,
      ShellNavigatorBuilder navigatorBuilder) {
    if (pageBuilder != null) {
      return pageBuilder!(StatefulShellBuilder(this, navigatorBuilder));
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
}

/// Builds the Widget managing a StatefulShellRoute.
class StatefulShellBuilder {
  /// Constructs a [StatefulShellBuilder].
  StatefulShellBuilder(this._shellRoute, this._builder);

  final StatefulShellRoute _shellRoute;
  final ShellNavigatorBuilder _builder;

  /// Builds the Widget managing a StatefulShellRoute.
  Widget buildShell(ShellBodyWidgetBuilder body) {
    return _StatefulNavigationShell._(
      shellRoute: _shellRoute,
      navigatorBuilder: _builder,
      shellBodyWidgetBuilder: body,
    );
  }
}

/// Widget containing the Navigators for the branches in a [StatefulShellRoute].
abstract class ShellNavigatorContainer extends StatelessWidget {
  /// Constructs a [ShellNavigatorContainer].
  const ShellNavigatorContainer({super.key});

  /// The children (i.e. Navigators) of this ShellNavigatorContainer.
  List<Widget> get children;
}

/// Representation of a separate branch in a stateful navigation tree, used to
/// configure [StatefulShellRoute].
///
/// The only required argument when creating a StatefulShellBranch is the
/// sub-routes ([routes]), however sometimes it may be convenient to also
/// provide a [initialLocation]. The value of this parameter is used when
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
    this.initialLocation,
    this.restorationScopeId,
    this.observers,
    this.preload = false,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

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
  /// be used (i.e. first element in [routes], or a descendant). The default
  /// location is used when loading the branch for the first time (for instance
  /// when switching branch using the goBranch method in
  /// [StatefulShellBranchState]).
  final String? initialLocation;

  /// Whether this route branch should be preloaded when the associated
  /// [StatefulShellRoute] is visited for the first time.
  ///
  /// If this is true, this branch will be preloaded by navigating to
  /// the initial location (see [initialLocation]). The primary purpose of
  /// branch preloading is to enhance the user experience when switching
  /// branches, which might for instance involve preparing the UI for animated
  /// transitions etc. Care must be taken to **keep the preloading to an
  /// absolute minimum** to avoid any unnecessary resource use.
  final bool preload;

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  /// The observers for this branch.
  ///
  /// The observers parameter is used by the [Navigator] built for this branch.
  final List<NavigatorObserver>? observers;
}

/// [StatefulShellRouteState] extension, providing support for fetching the state
/// associated with the nearest [StatefulShellRoute] in the Widget tree.
extension StatefulShellRouteStateContext on StatefulShellRouteState {
  /// Gets the state for the nearest stateful shell route in the Widget tree.
  static StatefulShellRouteState of(BuildContext context) {
    final _InheritedStatefulNavigationShell? inherited =
        context.dependOnInheritedWidgetOfExactType<
            _InheritedStatefulNavigationShell>();
    assert(inherited != null,
        'No InheritedStatefulNavigationShell found in context');
    return inherited!.routeState;
  }
}

/// [InheritedWidget] for providing a reference to the closest
/// [_StatefulNavigationShellState].
class _InheritedStatefulNavigationShell extends InheritedWidget {
  /// Constructs an [_InheritedStatefulNavigationShell].
  const _InheritedStatefulNavigationShell({
    required super.child,
    required this.routeState,
  });

  /// The [StatefulShellRouteState] that is exposed by this InheritedWidget.
  final StatefulShellRouteState routeState;

  @override
  bool updateShouldNotify(
      covariant _InheritedStatefulNavigationShell oldWidget) {
    return routeState != oldWidget.routeState;
  }
}

/// Widget that manages and maintains the state of a [StatefulShellRoute],
/// including the [Navigator]s of the configured route branches.
///
/// This widget acts as a wrapper around the builder function specified for the
/// associated StatefulShellRoute, and exposes the state (represented by
/// [StatefulShellRouteState]) to its child widgets with the help of the
/// InheritedWidget [_InheritedStatefulNavigationShell]. The state for each route
/// branch is represented by [StatefulShellBranchState] and can be accessed via the
/// StatefulShellRouteState.
///
/// By default, this widget creates a container for the branch route Navigators,
/// provided as the child argument to the builder of the StatefulShellRoute.
/// However, implementors can choose to disregard this and use an alternate
/// container around the branch navigators
/// (see [StatefulShellRouteState.children]) instead.
class _StatefulNavigationShell extends StatefulWidget {
  /// Constructs an [_StatefulNavigationShell].
  const _StatefulNavigationShell._({
    required this.shellRoute,
    required this.navigatorBuilder,
    required this.shellBodyWidgetBuilder,
  });

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute shellRoute;

  /// The shell navigator builder.
  final ShellNavigatorBuilder navigatorBuilder;

  /// The shell body widget builder.
  final ShellBodyWidgetBuilder shellBodyWidgetBuilder;

  @override
  State<StatefulWidget> createState() => _StatefulNavigationShellState();
}

/// State for StatefulNavigationShell.
class _StatefulNavigationShellState extends State<_StatefulNavigationShell> {
  final Map<Key, Widget> _navigatorCache = <Key, Widget>{};

  late _StatefulShellRouteState _routeState;

  List<StatefulShellBranch> get _branches => widget.shellRoute.branches;

  GoRouterState get _currentGoRouterState => widget.navigatorBuilder.state;
  GlobalKey<NavigatorState> get _currentNavigatorKey =>
      widget.navigatorBuilder.navigatorKeyForCurrentRoute;

  Widget? _navigatorForBranch(StatefulShellBranch branch) {
    return _navigatorCache[branch.navigatorKey];
  }

  void _setNavigatorForBranch(StatefulShellBranch branch, Widget? navigator) {
    navigator != null
        ? _navigatorCache[branch.navigatorKey] = navigator
        : _navigatorCache.remove(branch.navigatorKey);
  }

  int _findCurrentIndex() {
    final int index = _branches.indexWhere(
        (StatefulShellBranch e) => e.navigatorKey == _currentNavigatorKey);
    assert(index >= 0);
    return index;
  }

  void _switchActiveBranch(StatefulShellBranchState branchState) {
    final GoRouter goRouter = GoRouter.of(context);
    final GoRouterState? routeState = branchState.routeState;
    if (routeState != null) {
      goRouter.goState(routeState, context).onError(
          (_, __) => goRouter.go(_defaultBranchLocation(branchState.branch)));
    } else {
      goRouter.go(_defaultBranchLocation(branchState.branch));
    }
  }

  String _defaultBranchLocation(StatefulShellBranch branch) {
    return branch.initialLocation ??
        GoRouter.of(context)
            .routeConfiguration
            .findStatefulShellBranchDefaultLocation(branch);
  }

  void _preloadBranches() {
    final List<_StatefulShellBranchState> states = _routeState._branchStates;
    for (_StatefulShellBranchState state in states) {
      if (state.branch.preload && !state.isLoaded) {
        state = _updateStatefulShellBranchState(state, loaded: true);
        _preloadBranch(state).then((_StatefulShellBranchState branchState) {
          setState(() {
            _updateRouteBranchState(branchState);
          });
        });
      }
    }
  }

  Future<_StatefulShellBranchState> _preloadBranch(
      _StatefulShellBranchState branchState) {
    final Future<Widget?> navigatorBuilder =
        widget.navigatorBuilder.buildPreloadedShellNavigator(
      context: context,
      location: _defaultBranchLocation(branchState.branch),
      parentShellRoute: widget.shellRoute,
      navigatorKey: branchState.navigatorKey,
      observers: branchState.branch.observers,
      restorationScopeId: branchState.branch.restorationScopeId,
    );

    return navigatorBuilder.then((Widget? navigator) {
      return _updateStatefulShellBranchState(
        branchState,
        navigator: navigator,
      );
    });
  }

  void _updateRouteBranchState(_StatefulShellBranchState branchState,
      {int? currentIndex}) {
    final List<_StatefulShellBranchState> existingStates =
        _routeState._branchStates;
    final List<_StatefulShellBranchState> newStates =
        <_StatefulShellBranchState>[];

    // Build a new list of the current StatefulShellBranchStates, with an
    // updated state for the current branch etc.
    for (final StatefulShellBranch branch in _branches) {
      if (branch.navigatorKey == branchState.navigatorKey) {
        newStates.add(branchState);
      } else {
        newStates.add(existingStates.firstWhereOrNull(
                (StatefulShellBranchState e) => e.branch == branch) ??
            _createStatefulShellBranchState(branch));
      }
    }

    // Remove any obsolete cached Navigators
    final Set<Key> validKeys =
        _branches.map((StatefulShellBranch e) => e.navigatorKey).toSet();
    _navigatorCache.removeWhere((Key key, _) => !validKeys.contains(key));

    _routeState = _routeState._copy(
      branchStates: newStates,
      currentIndex: currentIndex,
    );
  }

  void _updateRouteStateFromWidget() {
    final int index = _findCurrentIndex();
    final StatefulShellBranch branch = _branches[index];

    final Widget currentNavigator =
        widget.navigatorBuilder.buildNavigatorForCurrentRoute(
      observers: branch.observers,
      restorationScopeId: branch.restorationScopeId,
    );

    // Update or create a new StatefulShellBranchState for the current branch
    // (i.e. the arguments currently provided to the Widget).
    _StatefulShellBranchState? currentBranchState = _routeState._branchStates
        .firstWhereOrNull((_StatefulShellBranchState e) => e.branch == branch);
    if (currentBranchState != null) {
      currentBranchState = _updateStatefulShellBranchState(
        currentBranchState,
        navigator: currentNavigator,
        routeState: _currentGoRouterState,
      );
    } else {
      currentBranchState = _createStatefulShellBranchState(
        branch,
        navigator: currentNavigator,
        routeState: _currentGoRouterState,
      );
    }

    _updateRouteBranchState(
      currentBranchState,
      currentIndex: index,
    );

    _preloadBranches();
  }

  _StatefulShellBranchState _updateStatefulShellBranchState(
    _StatefulShellBranchState branchState, {
    Widget? navigator,
    GoRouterState? routeState,
    bool? loaded,
  }) {
    bool dirty = false;
    if (routeState != null) {
      dirty = branchState.routeState != routeState;
    }

    if (navigator != null) {
      // Only update Navigator for branch if matchList is different (i.e.
      // dirty == true) or if Navigator didn't already exist
      final bool hasExistingNav =
          _navigatorForBranch(branchState.branch) != null;
      if (!hasExistingNav || dirty) {
        dirty = true;
        _setNavigatorForBranch(branchState.branch, navigator);
      }
    }

    final bool isLoaded =
        loaded ?? _navigatorForBranch(branchState.branch) != null;
    dirty = dirty || isLoaded != branchState.isLoaded;

    if (dirty) {
      return branchState._copy(
        isLoaded: isLoaded,
        routeState: routeState,
      );
    } else {
      return branchState;
    }
  }

  _StatefulShellBranchState _createStatefulShellBranchState(
    StatefulShellBranch branch, {
    Widget? navigator,
    GoRouterState? routeState,
  }) {
    if (navigator != null) {
      _setNavigatorForBranch(branch, navigator);
    }
    return _StatefulShellBranchState._(
      branch: branch,
      routeState: routeState,
    );
  }

  void _setupInitialStatefulShellRouteState() {
    final List<_StatefulShellBranchState> states = _branches
        .map((StatefulShellBranch e) => _createStatefulShellBranchState(e))
        .toList();

    _routeState = _StatefulShellRouteState._(
      widget.shellRoute,
      states,
      0,
      _switchActiveBranch,
    );
  }

  @override
  void initState() {
    super.initState();
    _setupInitialStatefulShellRouteState();
  }

  @override
  void didUpdateWidget(covariant _StatefulNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRouteStateFromWidget();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRouteStateFromWidget();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = _branches
        .map((StatefulShellBranch branch) => _BranchNavigatorProxy(
            branch: branch, navigatorForBranch: _navigatorForBranch))
        .toList();

    return _InheritedStatefulNavigationShell(
      routeState: _routeState,
      child: Builder(builder: (BuildContext context) {
        // This Builder Widget is mainly used to make it possible to access the
        // StatefulShellRouteState via the BuildContext in the ShellRouteBuilder
        final ShellBodyWidgetBuilder shellWidgetBuilder =
            widget.shellBodyWidgetBuilder;
        return shellWidgetBuilder(
          context,
          _currentGoRouterState,
          _IndexedStackedRouteBranchContainer(
              routeState: _routeState, children: children),
        );
      }),
    );
  }
}

typedef _NavigatorForBranch = Widget? Function(StatefulShellBranch);

/// Widget that serves as the proxy for a branch Navigator Widget, which
/// possibly hasn't been created yet.
class _BranchNavigatorProxy extends StatelessWidget {
  const _BranchNavigatorProxy({
    required this.branch,
    required this.navigatorForBranch,
  });

  final StatefulShellBranch branch;
  final _NavigatorForBranch navigatorForBranch;

  @override
  Widget build(BuildContext context) {
    return navigatorForBranch(branch) ?? const SizedBox.shrink();
  }
}

/// Default implementation of a container widget for the [Navigator]s of the
/// route branches. This implementation uses an [IndexedStack] as a container.
class _IndexedStackedRouteBranchContainer extends ShellNavigatorContainer {
  const _IndexedStackedRouteBranchContainer(
      {required this.routeState, required this.children});

  final StatefulShellRouteState routeState;

  @override
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final int currentIndex = routeState.currentIndex;
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

extension _StatefulShellBranchStateHelper on StatefulShellBranchState {
  GlobalKey<NavigatorState> get navigatorKey => branch.navigatorKey;
}

typedef _BranchSwitcher = void Function(StatefulShellBranchState);

/// The snapshot of the current state of a [StatefulShellRoute].
///
/// Note that this an immutable class, that represents the snapshot of the state
/// of a StatefulShellRoute at a given point in time. Therefore, instances of
/// this object should not be stored, but instead fetched fresh when needed,
/// using the method [StatefulShellRouteState.of].
@immutable
class _StatefulShellRouteState implements StatefulShellRouteState {
  /// Constructs a [StatefulShellRouteState].
  const _StatefulShellRouteState._(
    this.route,
    this._branchStates,
    this.currentIndex,
    _BranchSwitcher switchActiveBranch,
  ) : _switchActiveBranch = switchActiveBranch;

  /// Constructs a copy of this [StatefulShellRouteState], with updated values
  /// for some of the fields.
  _StatefulShellRouteState _copy(
      {List<_StatefulShellBranchState>? branchStates, int? currentIndex}) {
    return _StatefulShellRouteState._(
      route,
      branchStates ?? _branchStates,
      currentIndex ?? this.currentIndex,
      _switchActiveBranch,
    );
  }

  /// The associated [StatefulShellRoute]
  @override
  final StatefulShellRoute route;

  final List<_StatefulShellBranchState> _branchStates;

  /// The state for all separate route branches associated with a
  /// [StatefulShellRoute].
  @override
  List<StatefulShellBranchState> get branchStates => _branchStates;

  /// The state associated with the current [StatefulShellBranch].
  @override
  StatefulShellBranchState get currentBranchState => branchStates[currentIndex];

  /// The index of the currently active [StatefulShellBranch].
  ///
  /// Corresponds to the index of the branch in the List returned from
  /// branchBuilder of [StatefulShellRoute].
  @override
  final int currentIndex;

  /// The Navigator key of the current navigator.
  @override
  GlobalKey<NavigatorState> get currentNavigatorKey =>
      currentBranchState.branch.navigatorKey;

  final _BranchSwitcher _switchActiveBranch;

  /// Navigate to the current location of the shell navigator with the provided
  /// index.
  ///
  /// This method will switch the currently active [Navigator] for the
  /// [StatefulShellRoute] by replacing the current navigation stack with the
  /// one of the route branch identified by the provided index. If resetLocation
  /// is true, the branch will be reset to its initial location
  /// (see [StatefulShellBranch.initialLocation]).
  @override
  void goBranch({
    required int index,
  }) {
    _switchActiveBranch(branchStates[index]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! _StatefulShellRouteState) {
      return false;
    }
    return other.route == route &&
        listEquals(other._branchStates, _branchStates) &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode => Object.hash(route, currentIndex, currentIndex);
}

/// The snapshot of the current state for a particular route branch
/// ([StatefulShellBranch]) in a [StatefulShellRoute].
///
/// Note that this an immutable class, that represents the snapshot of the state
/// of a StatefulShellBranchState at a given point in time. Therefore, instances of
/// this object should not be stored, but instead fetched fresh when needed,
/// via the [StatefulShellRouteState] returned by the method
/// [StatefulShellRouteState.of].
@immutable
class _StatefulShellBranchState implements StatefulShellBranchState {
  /// Constructs a [StatefulShellBranchState].
  const _StatefulShellBranchState._({
    required this.branch,
    this.isLoaded = false,
    this.routeState,
  });

  /// Constructs a copy of this [StatefulShellBranchState], with updated values for
  /// some of the fields.
  _StatefulShellBranchState _copy({bool? isLoaded, GoRouterState? routeState}) {
    return _StatefulShellBranchState._(
      branch: branch,
      isLoaded: isLoaded ?? this.isLoaded,
      routeState: routeState ?? this.routeState,
    );
  }

  /// The associated [StatefulShellBranch]
  @override
  final StatefulShellBranch branch;

  /// The current GoRouterState associated with the branch.
  @override
  final GoRouterState? routeState;

  /// Returns true if this branch has been loaded (i.e. visited once or
  /// pre-loaded).
  @override
  final bool isLoaded;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! StatefulShellBranchState) {
      return false;
    }
    return other.branch == branch && other.routeState == routeState;
  }

  @override
  int get hashCode => Object.hash(branch, routeState);
}
