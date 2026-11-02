// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('RouteMatch', () {
    test('simple', () {
      final route = GoRoute(path: '/users/:userId', builder: _builder);
      final pathParameters = <String, String>{};
      final List<RouteMatchBase> matches = RouteMatchBase.match(
        route: route,
        pathParameters: pathParameters,
        uri: Uri.parse('/users/123'),
        rootNavigatorKey: GlobalKey<NavigatorState>(),
      );
      expect(matches.length, 1);
      final RouteMatchBase match = matches.first;
      expect(match.route, route);
      expect(match.matchedLocation, '/users/123');
      expect(pathParameters['userId'], '123');
      expect(match.pageKey, isNotNull);
    });

    test('ShellRoute has a unique pageKey', () {
      final route = ShellRoute(
        builder: _shellBuilder,
        routes: <GoRoute>[GoRoute(path: '/users/:userId', builder: _builder)],
      );
      final pathParameters = <String, String>{};
      final List<RouteMatchBase> matches = RouteMatchBase.match(
        route: route,
        uri: Uri.parse('/users/123'),
        rootNavigatorKey: GlobalKey<NavigatorState>(),
        pathParameters: pathParameters,
      );
      expect(matches.length, 1);
      expect(matches.first.pageKey, isNotNull);
    });

    test('ShellRoute Match has stable unique key', () {
      final route = ShellRoute(
        builder: _shellBuilder,
        routes: <GoRoute>[GoRoute(path: '/users/:userId', builder: _builder)],
      );
      final pathParameters = <String, String>{};
      final List<RouteMatchBase> matches1 = RouteMatchBase.match(
        route: route,
        pathParameters: pathParameters,
        uri: Uri.parse('/users/123'),
        rootNavigatorKey: GlobalKey<NavigatorState>(),
      );
      final List<RouteMatchBase> matches2 = RouteMatchBase.match(
        route: route,
        pathParameters: pathParameters,
        uri: Uri.parse('/users/1234'),
        rootNavigatorKey: GlobalKey<NavigatorState>(),
      );
      expect(matches1.length, 1);
      expect(matches2.length, 1);
      expect(matches1.first.pageKey, matches2.first.pageKey);
      expect((matches1.first as ShellRouteMatch).navigatorKey, same(route.navigatorKey));
      expect((matches2.first as ShellRouteMatch).navigatorKey, same(route.navigatorKey));
    });

    test('GoRoute Match has stable unique key', () {
      final route = GoRoute(path: '/users/:userId', builder: _builder);
      final pathParameters = <String, String>{};
      final List<RouteMatchBase> matches1 = RouteMatchBase.match(
        route: route,
        uri: Uri.parse('/users/123'),
        rootNavigatorKey: GlobalKey<NavigatorState>(),
        pathParameters: pathParameters,
      );

      final List<RouteMatchBase> matches2 = RouteMatchBase.match(
        route: route,
        uri: Uri.parse('/users/1234'),
        rootNavigatorKey: GlobalKey<NavigatorState>(),
        pathParameters: pathParameters,
      );
      expect(matches1.length, 1);
      expect(matches2.length, 1);
      expect(matches1.first.pageKey, matches2.first.pageKey);
    });
  });

  test('complex parentNavigatorKey works', () {
    final root = GlobalKey<NavigatorState>();
    final shell1 = GlobalKey<NavigatorState>();
    final shell2 = GlobalKey<NavigatorState>();
    final route = GoRoute(
      path: '/',
      builder: _builder,
      routes: <RouteBase>[
        ShellRoute(
          navigatorKey: shell1,
          builder: _shellBuilder,
          routes: <RouteBase>[
            GoRoute(
              path: 'a',
              builder: _builder,
              routes: <RouteBase>[
                GoRoute(
                  parentNavigatorKey: root,
                  path: 'b',
                  builder: _builder,
                  routes: <RouteBase>[
                    ShellRoute(
                      navigatorKey: shell2,
                      builder: _shellBuilder,
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'c',
                          builder: _builder,
                          routes: <RouteBase>[
                            GoRoute(parentNavigatorKey: root, path: 'd', builder: _builder),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final pathParameters = <String, String>{};
    final List<RouteMatchBase> matches = RouteMatchBase.match(
      route: route,
      pathParameters: pathParameters,
      uri: Uri.parse('/a/b/c/d'),
      rootNavigatorKey: root,
    );
    expect(matches.length, 4);
    expect(matches[0].route, isA<GoRoute>().having((GoRoute route) => route.path, 'path', '/'));
    expect(
      matches[1].route,
      isA<ShellRoute>().having((ShellRoute route) => route.navigatorKey, 'navigator key', shell1),
    );
    expect(matches[2].route, isA<GoRoute>().having((GoRoute route) => route.path, 'path', 'b'));
    expect(matches[3].route, isA<GoRoute>().having((GoRoute route) => route.path, 'path', 'd'));
  });

  group('ImperativeRouteMatch', () {
    final matchList1 = RouteMatchList(
      matches: <RouteMatch>[
        RouteMatch(
          route: GoRoute(path: '/', builder: (_, _) => const Text('hi')),
          matchedLocation: '/',
          pageKey: const ValueKey<String>('dummy'),
        ),
      ],
      uri: Uri.parse('/'),
      pathParameters: const <String, String>{},
    );

    final matchList2 = RouteMatchList(
      matches: <RouteMatch>[
        RouteMatch(
          route: GoRoute(path: '/a', builder: (_, _) => const Text('a')),
          matchedLocation: '/a',
          pageKey: const ValueKey<String>('dummy'),
        ),
      ],
      uri: Uri.parse('/a'),
      pathParameters: const <String, String>{},
    );

    const key1 = ValueKey<String>('key1');
    const key2 = ValueKey<String>('key2');

    final completer1 = Completer<void>();
    final completer2 = Completer<void>();

    test('can equal and has', () async {
      var match1 = ImperativeRouteMatch(pageKey: key1, matches: matchList1, completer: completer1);
      var match2 = ImperativeRouteMatch(pageKey: key1, matches: matchList1, completer: completer1);
      expect(match1 == match2, isTrue);
      expect(match1.hashCode == match2.hashCode, isTrue);

      match1 = ImperativeRouteMatch(pageKey: key1, matches: matchList1, completer: completer1);
      match2 = ImperativeRouteMatch(pageKey: key2, matches: matchList1, completer: completer1);
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);

      match1 = ImperativeRouteMatch(pageKey: key1, matches: matchList1, completer: completer1);
      match2 = ImperativeRouteMatch(pageKey: key1, matches: matchList2, completer: completer1);
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);

      match1 = ImperativeRouteMatch(pageKey: key1, matches: matchList1, completer: completer1);
      match2 = ImperativeRouteMatch(pageKey: key1, matches: matchList1, completer: completer2);
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);
    });

    test('push scopes key collisions in nested ShellRouteMatch', () {
      final leafRoute = GoRoute(path: '/leaf', builder: _builder);
      // Deliberately create separate instances to verify value equality below.
      // ignore: prefer_const_constructors
      final nestedNavigatorKey = _ValueNavigatorKey('nested');
      final nestedRoute = ShellRoute(
        navigatorKey: nestedNavigatorKey,
        builder: _shellBuilder,
        routes: <RouteBase>[leafRoute],
      );
      final currentOuterRoute = ShellRoute(
        builder: _shellBuilder,
        routes: <RouteBase>[nestedRoute],
      );
      final pushedOuterRoute = ShellRoute(builder: _shellBuilder, routes: <RouteBase>[nestedRoute]);
      const nestedPageKey = ValueKey<String>('nested');
      const currentOuterPageKey = ValueKey<String>('current-outer');
      const pushedOuterPageKey = ValueKey<String>('pushed-outer');
      expect(currentOuterPageKey, isNot(pushedOuterPageKey));
      expect(currentOuterRoute.navigatorKey, isNot(equals(pushedOuterRoute.navigatorKey)));

      ShellRouteMatch nestedMatch() => ShellRouteMatch(
        route: nestedRoute,
        matches: <RouteMatchBase>[
          RouteMatch(
            route: leafRoute,
            matchedLocation: '/leaf',
            pageKey: const ValueKey<String>('/leaf'),
          ),
        ],
        matchedLocation: '/leaf',
        pageKey: nestedPageKey,
        navigatorKey: nestedNavigatorKey,
      );

      final currentMatchList = RouteMatchList(
        matches: <RouteMatchBase>[
          ShellRouteMatch(
            route: currentOuterRoute,
            matches: <RouteMatchBase>[nestedMatch()],
            matchedLocation: '/leaf',
            pageKey: currentOuterPageKey,
            navigatorKey: currentOuterRoute.navigatorKey,
          ),
        ],
        uri: Uri.parse('/leaf'),
        pathParameters: const <String, String>{},
      );
      final pushedMatchList = RouteMatchList(
        matches: <RouteMatchBase>[
          ShellRouteMatch(
            route: pushedOuterRoute,
            matches: <RouteMatchBase>[nestedMatch()],
            matchedLocation: '/leaf',
            pageKey: pushedOuterPageKey,
            navigatorKey: pushedOuterRoute.navigatorKey,
          ),
        ],
        uri: Uri.parse('/leaf'),
        pathParameters: const <String, String>{},
      );

      final RouteMatchList result = currentMatchList.push(
        ImperativeRouteMatch(
          pageKey: const ValueKey<String>('push'),
          matches: pushedMatchList,
          completer: Completer<void>(),
        ),
      );

      final pushedOuterMatch = result.matches.last as ShellRouteMatch;
      final pushedNestedMatch = pushedOuterMatch.matches.single as ShellRouteMatch;
      expect(pushedOuterMatch.pageKey, pushedOuterPageKey);
      expect(pushedOuterMatch.navigatorKey, same(pushedOuterRoute.navigatorKey));
      expect(pushedNestedMatch.pageKey, isNot(nestedPageKey));
      expect(pushedNestedMatch.navigatorKey, isNot(equals(nestedNavigatorKey)));

      // ignore: prefer_const_constructors
      final equivalentNestedNavigatorKey = _ValueNavigatorKey('nested');
      expect(equivalentNestedNavigatorKey, equals(nestedNavigatorKey));
      expect(equivalentNestedNavigatorKey, isNot(same(nestedNavigatorKey)));
      final equivalentLeafRoute = GoRoute(path: '/leaf', builder: _builder);
      final equivalentNestedRoute = ShellRoute(
        navigatorKey: equivalentNestedNavigatorKey,
        builder: _shellBuilder,
        routes: <RouteBase>[equivalentLeafRoute],
      );
      final equivalentPushedOuterRoute = ShellRoute(
        builder: _shellBuilder,
        routes: <RouteBase>[equivalentNestedRoute],
      );
      final equivalentPushedMatchList = RouteMatchList(
        matches: <RouteMatchBase>[
          ShellRouteMatch(
            route: equivalentPushedOuterRoute,
            matches: <RouteMatchBase>[
              ShellRouteMatch(
                route: equivalentNestedRoute,
                matches: <RouteMatchBase>[
                  RouteMatch(
                    route: equivalentLeafRoute,
                    matchedLocation: '/leaf',
                    pageKey: const ValueKey<String>('/leaf'),
                  ),
                ],
                matchedLocation: '/leaf',
                pageKey: nestedPageKey,
                navigatorKey: equivalentNestedNavigatorKey,
              ),
            ],
            matchedLocation: '/leaf',
            pageKey: pushedOuterPageKey,
            navigatorKey: equivalentPushedOuterRoute.navigatorKey,
          ),
        ],
        uri: Uri.parse('/leaf'),
        pathParameters: const <String, String>{},
      );
      final RouteMatchList equivalentResult = currentMatchList.push(
        ImperativeRouteMatch(
          pageKey: const ValueKey<String>('push'),
          matches: equivalentPushedMatchList,
          completer: Completer<void>(),
        ),
      );
      final equivalentPushedOuterMatch = equivalentResult.matches.last as ShellRouteMatch;
      final equivalentPushedNestedMatch =
          equivalentPushedOuterMatch.matches.single as ShellRouteMatch;
      expect(equivalentPushedNestedMatch.pageKey, pushedNestedMatch.pageKey);
      expect(equivalentPushedNestedMatch.pageKey.value, pushedNestedMatch.pageKey.value);
      expect(equivalentPushedNestedMatch.navigatorKey, pushedNestedMatch.navigatorKey);
    });
  });
}

Widget _builder(BuildContext context, GoRouterState state) => const Placeholder();

Widget _shellBuilder(BuildContext context, GoRouterState state, Widget child) =>
    const Placeholder();

class _ValueNavigatorKey extends GlobalKey<NavigatorState> {
  const _ValueNavigatorKey(this.label) : super.constructor();

  final String label;

  @override
  bool operator ==(Object other) => other is _ValueNavigatorKey && other.label == label;

  @override
  int get hashCode => label.hashCode;
}
