// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/state.dart';

import 'test_helpers.dart';

void main() {
  group('GoRouterState from context', () {
    testWidgets('works in builder', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, _) {
              final GoRouterState state = GoRouterState.of(context);
              return Text('/ ${state.uri.queryParameters['p']}');
            }),
        GoRoute(
            path: '/a',
            builder: (BuildContext context, _) {
              final GoRouterState state = GoRouterState.of(context);
              return Text('/a ${state.uri.queryParameters['p']}');
            }),
      ];
      final GoRouter router = await createRouter(routes, tester);
      router.go('/?p=123');
      await tester.pumpAndSettle();
      expect(find.text('/ 123'), findsOneWidget);

      router.go('/a?p=456');
      await tester.pumpAndSettle();
      expect(find.text('/a 456'), findsOneWidget);
    });

    testWidgets('works in subtree', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) {
              return Builder(builder: (BuildContext context) {
                return Text('1 ${GoRouterState.of(context).uri.path}');
              });
            },
            routes: <GoRoute>[
              GoRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text('2 ${GoRouterState.of(context).uri.path}');
                    });
                  }),
            ]),
      ];
      final GoRouter router = await createRouter(routes, tester);
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('1 /'), findsOneWidget);

      router.go('/a');
      await tester.pumpAndSettle();
      expect(find.text('2 /a'), findsOneWidget);
      // The query parameter is removed, so is the location in first page.
      expect(find.text('1 /a', skipOffstage: false), findsOneWidget);
    });

    testWidgets('path parameter persists after page is popped',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) {
              return Builder(builder: (BuildContext context) {
                return Text('1 ${GoRouterState.of(context).uri.path}');
              });
            },
            routes: <GoRoute>[
              GoRoute(
                  path: ':id',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(
                          '2 ${GoRouterState.of(context).pathParameters['id']}');
                    });
                  }),
            ]),
      ];
      final GoRouter router = await createRouter(routes, tester);
      await tester.pumpAndSettle();
      expect(find.text('1 /'), findsOneWidget);

      router.go('/123');
      await tester.pumpAndSettle();
      expect(find.text('2 123'), findsOneWidget);
      router.pop();
      await tester.pump();
      // Page 2 is in popping animation but should still be on screen with the
      // correct path parameter.
      expect(find.text('2 123'), findsOneWidget);
    });

    testWidgets('registry retains GoRouterState for exiting route',
        (WidgetTester tester) async {
      final UniqueKey key = UniqueKey();
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) {
              return Builder(builder: (BuildContext context) {
                return Text(GoRouterState.of(context).uri.path);
              });
            },
            routes: <GoRoute>[
              GoRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(key: key, GoRouterState.of(context).uri.path);
                    });
                  }),
            ]),
      ];
      final GoRouter router =
          await createRouter(routes, tester, initialLocation: '/a');
      expect(tester.widget<Text>(find.byKey(key)).data, '/a');
      final GoRouterStateRegistry registry = tester
          .widget<GoRouterStateRegistryScope>(
              find.byType(GoRouterStateRegistryScope))
          .notifier!;
      expect(registry.registry.length, 2);
      router.go('/');
      await tester.pump();
      expect(registry.registry.length, 2);
      // should retain the same location even if the location has changed.
      expect(tester.widget<Text>(find.byKey(key)).data, '/a');

      // Finish the pop animation.
      await tester.pumpAndSettle();
      expect(registry.registry.length, 1);
      expect(find.byKey(key), findsNothing);
    });

    testWidgets('imperative pop clears out registry',
        (WidgetTester tester) async {
      final UniqueKey key = UniqueKey();
      final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) {
              return Builder(builder: (BuildContext context) {
                return Text(GoRouterState.of(context).uri.path);
              });
            },
            routes: <GoRoute>[
              GoRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(key: key, GoRouterState.of(context).uri.path);
                    });
                  }),
            ]),
      ];
      await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: nav);
      expect(tester.widget<Text>(find.byKey(key)).data, '/a');
      final GoRouterStateRegistry registry = tester
          .widget<GoRouterStateRegistryScope>(
              find.byType(GoRouterStateRegistryScope))
          .notifier!;
      expect(registry.registry.length, 2);
      nav.currentState!.pop();
      await tester.pump();
      expect(registry.registry.length, 2);
      // should retain the same location even if the location has changed.
      expect(tester.widget<Text>(find.byKey(key)).data, '/a');

      // Finish the pop animation.
      await tester.pumpAndSettle();
      expect(registry.registry.length, 1);
      expect(find.byKey(key), findsNothing);
    });

    testWidgets('GoRouterState topRoute accessible from StatefulShellRoute',
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
                  const Text('Screen 0'),
                  Expanded(child: child),
                ],
              ),
            );
          },
          routes: <RouteBase>[
            GoRoute(
              name: 'root',
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen 1'),
                );
              },
              routes: <RouteBase>[
                StatefulShellRoute.indexedStack(
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (
                    BuildContext context,
                    GoRouterState state,
                    StatefulNavigationShell navigationShell,
                  ) {
                    final String? routeName =
                        GoRouterState.of(context).topRoute?.name;
                    final String title = switch (routeName) {
                      'a' => 'A',
                      'b' => 'B',
                      _ => 'Unknown',
                    };
                    return Column(
                      children: <Widget>[
                        Text(title),
                        Expanded(child: navigationShell),
                      ],
                    );
                  },
                  branches: <StatefulShellBranch>[
                    StatefulShellBranch(
                      routes: <RouteBase>[
                        GoRoute(
                          name: 'a',
                          path: 'a',
                          builder: (BuildContext context, GoRouterState state) {
                            return const Scaffold(
                              body: Text('Screen 2'),
                            );
                          },
                        ),
                      ],
                    ),
                    StatefulShellBranch(
                      routes: <RouteBase>[
                        GoRoute(
                          name: 'b',
                          path: 'b',
                          builder: (BuildContext context, GoRouterState state) {
                            return const Scaffold(
                              body: Text('Screen 2'),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ];
      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: rootNavigatorKey);
      expect(find.text('A'), findsOneWidget);

      router.go('/b');
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
    });
  });
}
