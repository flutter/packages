// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'path_utils.dart';
import 'state.dart';
import 'typedefs.dart';

/// A declarative mapping between a route path and a page builder.
class GoRoute {
  /// Default constructor used to create mapping between a route path and a page
  /// builder.
  GoRoute({
    required this.path,
    this.name,
    this.pageBuilder,
    this.builder = _invalidBuilder,
    this.routes = const <GoRoute>[],
    this.redirect = _noRedirection,
  })  : assert(path.isNotEmpty, 'GoRoute path cannot be empty'),
        assert(name == null || name.isNotEmpty, 'GoRoute name cannot be empty'),
        assert(
            pageBuilder != null ||
                builder != _invalidBuilder ||
                redirect != _noRedirection,
            'GoRoute builder parameter not set\n'
            'See gorouter.dev/redirection#considerations for details') {
    // cache the path regexp and parameters
    _pathRE = patternToRegExp(path, _pathParams);

    assert(() {
      // check path params
      final Map<String, List<String>> groupedParams =
          _pathParams.groupListsBy<String>((String p) => p);
      final Map<String, List<String>> dupParams =
          Map<String, List<String>>.fromEntries(
        groupedParams.entries
            .where((MapEntry<String, List<String>> e) => e.value.length > 1),
      );
      assert(dupParams.isEmpty,
          'duplicate path params: ${dupParams.keys.join(', ')}');

      // check sub-routes
      for (final GoRoute route in routes) {
        // check paths
        assert(
            route.path == '/' ||
                (!route.path.startsWith('/') && !route.path.endsWith('/')),
            'sub-route path may not start or end with /: ${route.path}');
      }
      return true;
    }());
  }

  final List<String> _pathParams = <String>[];
  late final RegExp _pathRE;

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
  final GoRouterWidgetBuilder builder;

  /// A list of sub go routes for this route.
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
  ///
  /// See [Sub-routes](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/sub_routes.dart)
  /// for a complete runnable example.
  final List<GoRoute> routes;

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
  /// Redirect can also be used for conditionally preventing users from visiting
  /// routes, also known as route guards. One canonical example is user
  /// authentication. See [Redirection](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart)
  /// for a complete runnable example.
  final GoRouterRedirect redirect;

  /// Match this route against a location.
  RegExpMatch? matchPatternAsPrefix(String loc) =>
      _pathRE.matchAsPrefix(loc) as RegExpMatch?;

  /// Extract the path parameters from a match.
  Map<String, String> extractPathParams(RegExpMatch match) =>
      extractPathParameters(_pathParams, match);

  static String? _noRedirection(GoRouterState state) => null;

  static Widget _invalidBuilder(
    BuildContext context,
    GoRouterState state,
  ) =>
      const SizedBox.shrink();
}
