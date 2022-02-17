import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:path_to_regexp/path_to_regexp.dart' as p2re;

import 'custom_transition_page.dart';
import 'go_router_state.dart';
import 'typedefs.dart';

/// A declarative mapping between a route path and a page builder.
class GoRoute {
  /// Default constructor used to create mapping between a
  /// route path and a page builder.
  GoRoute({
    required this.path,
    this.name,
    this.pageBuilder,
    this.builder = _builder,
    this.routes = const [],
    this.redirect = _redirect,
  }) {
    if (path.isEmpty) {
      throw Exception('GoRoute path cannot be empty');
    }

    if (name != null && name!.isEmpty) {
      throw Exception('GoRoute name cannot be empty');
    }

    // cache the path regexp and parameters
    _pathRE = p2re.pathToRegExp(
      path,
      prefix: true,
      caseSensitive: false,
      parameters: _pathParams,
    );

    // check path params
    final paramNames = <String>[];
    p2re.parse(path, parameters: paramNames);
    final groupedParams = paramNames.groupListsBy((p) => p);
    final dupParams = Map<String, List<String>>.fromEntries(
      groupedParams.entries.where((e) => e.value.length > 1),
    );
    if (dupParams.isNotEmpty) {
      throw Exception(
        'duplicate path params: ${dupParams.keys.join(', ')}',
      );
    }

    // check sub-routes
    for (final route in routes) {
      // check paths
      if (route.path != '/' &&
          (route.path.startsWith('/') || route.path.endsWith('/'))) {
        throw Exception(
          'sub-route path may not start or end with /: ${route.path}',
        );
      }
    }
  }

  final _pathParams = <String>[];
  late final RegExp _pathRE;

  /// Optional name of the route.
  ///
  /// If used, a unique string name must be provided and it can not be empty.
  final String? name;

  /// The path of this go route.
  ///
  /// For example in:
  /// ```
  /// GoRoute(
  ///   path: '/',
  ///   pageBuilder: (context, state) => MaterialPage<void>(
  ///     key: state.pageKey,
  ///     child: HomePage(families: Families.data),
  ///   ),
  /// ),
  /// ```
  final String path;

  /// A page builder for this route.
  ///
  /// Typically a MaterialPage, as in:
  /// ```
  /// GoRoute(
  ///   path: '/',
  ///   pageBuilder: (context, state) => MaterialPage<void>(
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
  ///   builder: (context, state) => FamilyPage(
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
  /// final _router = GoRouter(
  ///   routes: [
  ///     GoRoute(
  ///       path: '/',
  ///       pageBuilder: (context, state) => MaterialPage<void>(
  ///         key: state.pageKey,
  ///         child: HomePage(families: Families.data),
  ///       ),
  ///       routes: [
  ///         GoRoute(
  ///           path: 'family/:fid',
  ///           pageBuilder: (context, state) {
  ///             final family = Families.family(state.params['fid']!);
  ///             return MaterialPage<void>(
  ///               key: state.pageKey,
  ///               child: FamilyPage(family: family),
  ///             );
  ///           },
  ///           routes: [
  ///             GoRoute(
  ///               path: 'person/:pid',
  ///               pageBuilder: (context, state) {
  ///                 final family = Families.family(state.params['fid']!);
  ///                 final person = family.person(state.params['pid']!);
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
  final List<GoRoute> routes;

  /// An optional redirect function for this route.
  ///
  /// In the case that you like to make a redirection decision for a specific
  /// route (or sub-route), you can do so by passing a redirect function to
  /// the GoRoute constructor.
  ///
  /// For example:
  /// ```
  /// final _router = GoRouter(
  ///   routes: [
  ///     GoRoute(
  ///       path: '/',
  ///       redirect: (_) => '/family/${Families.data[0].id}',
  ///     ),
  ///     GoRoute(
  ///       path: '/family/:fid',
  ///       pageBuilder: (context, state) => ...,
  ///     ),
  ///   ],
  /// );
  /// ```
  final GoRouterRedirect redirect;

  /// Match this route against a location.
  Match? matchPatternAsPrefix(String loc) => _pathRE.matchAsPrefix(loc);

  /// Extract the path parameters from a match.
  Map<String, String> extractPathParams(Match match) =>
      p2re.extract(_pathParams, match);

  static String? _redirect(GoRouterState state) => null;

  static Widget _builder(BuildContext context, GoRouterState state) =>
      throw Exception(
        'GoRoute builder parameter not set\n'
        'See gorouter.dev/redirection#considerations for details',
      );
}
