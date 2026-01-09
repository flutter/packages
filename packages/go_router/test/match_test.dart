// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
                            GoRoute(
                              parentNavigatorKey: root,
                              path: 'd',
                              builder: _builder,
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
    expect(
      matches[0].route,
      isA<GoRoute>().having((GoRoute route) => route.path, 'path', '/'),
    );
    expect(
      matches[1].route,
      isA<ShellRoute>().having(
        (ShellRoute route) => route.navigatorKey,
        'navigator key',
        shell1,
      ),
    );
    expect(
      matches[2].route,
      isA<GoRoute>().having((GoRoute route) => route.path, 'path', 'b'),
    );
    expect(
      matches[3].route,
      isA<GoRoute>().having((GoRoute route) => route.path, 'path', 'd'),
    );
  });

  group('ImperativeRouteMatch', () {
    final matchList1 = RouteMatchList(
      matches: <RouteMatch>[
        RouteMatch(
          route: GoRoute(path: '/', builder: (_, __) => const Text('hi')),
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
          route: GoRoute(path: '/a', builder: (_, __) => const Text('a')),
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
      var match1 = ImperativeRouteMatch(
        pageKey: key1,
        matches: matchList1,
        completer: completer1,
      );
      var match2 = ImperativeRouteMatch(
        pageKey: key1,
        matches: matchList1,
        completer: completer1,
      );
      expect(match1 == match2, isTrue);
      expect(match1.hashCode == match2.hashCode, isTrue);

      match1 = ImperativeRouteMatch(
        pageKey: key1,
        matches: matchList1,
        completer: completer1,
      );
      match2 = ImperativeRouteMatch(
        pageKey: key2,
        matches: matchList1,
        completer: completer1,
      );
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);

      match1 = ImperativeRouteMatch(
        pageKey: key1,
        matches: matchList1,
        completer: completer1,
      );
      match2 = ImperativeRouteMatch(
        pageKey: key1,
        matches: matchList2,
        completer: completer1,
      );
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);

      match1 = ImperativeRouteMatch(
        pageKey: key1,
        matches: matchList1,
        completer: completer1,
      );
      match2 = ImperativeRouteMatch(
        pageKey: key1,
        matches: matchList1,
        completer: completer2,
      );
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);
    });
  });
}

Widget _builder(BuildContext context, GoRouterState state) =>
    const Placeholder();

Widget _shellBuilder(BuildContext context, GoRouterState state, Widget child) =>
    const Placeholder();
