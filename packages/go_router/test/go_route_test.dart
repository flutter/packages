// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  test('throws when a builder is not set', () {
    expect(() => GoRoute(path: '/'), throwsA(isAssertionError));
  });

  test('throws when a path is empty', () {
    expect(() => GoRoute(path: ''), throwsA(isAssertionError));
  });

  test('does not throw when only redirect is provided', () {
    GoRoute(path: '/', redirect: (_, __) => '/a');
  });

  testWidgets('ShellRoute can use parent navigator key',
      (WidgetTester tester) async {
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();
    final GlobalKey<NavigatorState> shellNavigatorKey =
        GlobalKey<NavigatorState>();

    final List<RouteBase> routes = <RouteBase>[
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                const Text('Screen A'),
                Expanded(child: child),
              ],
            ),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/b',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(
                body: Text('Screen B'),
              );
            },
            routes: <RouteBase>[
              ShellRoute(
                parentNavigatorKey: rootNavigatorKey,
                builder:
                    (BuildContext context, GoRouterState state, Widget child) {
                  return Scaffold(
                    body: Column(
                      children: <Widget>[
                        const Text('Screen D'),
                        Expanded(child: child),
                      ],
                    ),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'c',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Scaffold(
                        body: Text('Screen C'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    await createRouter(routes, tester,
        initialLocation: '/b/c', navigatorKey: rootNavigatorKey);
    expect(find.text('Screen A'), findsNothing);
    expect(find.text('Screen B'), findsNothing);
    expect(find.text('Screen D'), findsOneWidget);
    expect(find.text('Screen C'), findsOneWidget);
  });

  testWidgets('StatefulShellRoute can use parent navigator key',
      (WidgetTester tester) async {
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();
    final GlobalKey<NavigatorState> shellNavigatorKey =
        GlobalKey<NavigatorState>();

    final List<RouteBase> routes = <RouteBase>[
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                const Text('Screen A'),
                Expanded(child: child),
              ],
            ),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/b',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(
                body: Text('Screen B'),
              );
            },
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, __, StatefulNavigationShell navigationShell) {
                  return Column(
                    children: <Widget>[
                      const Text('Screen D'),
                      Expanded(child: navigationShell),
                    ],
                  );
                },
                branches: <StatefulShellBranch>[
                  StatefulShellBranch(
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'c',
                        builder: (BuildContext context, GoRouterState state) {
                          return const Scaffold(
                            body: Text('Screen C'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    await createRouter(routes, tester,
        initialLocation: '/b/c', navigatorKey: rootNavigatorKey);
    expect(find.text('Screen A'), findsNothing);
    expect(find.text('Screen B'), findsNothing);
    expect(find.text('Screen D'), findsOneWidget);
    expect(find.text('Screen C'), findsOneWidget);
  });
}
