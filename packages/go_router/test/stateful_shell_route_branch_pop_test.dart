// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('goBranch saves the current branch after a same-frame pop', (
    WidgetTester tester,
  ) async {
    late StatefulNavigationShell navigationShell;
    final router = GoRouter(
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
            navigationShell = shell;
            return Scaffold(body: shell);
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: (BuildContext context, GoRouterState state) => const Text('home'),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'details/:id',
                      builder: (BuildContext context, GoRouterState state) =>
                          Text('details ${state.pathParameters['id']}'),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/other',
                  builder: (BuildContext context, GoRouterState state) => const Text('other'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    unawaited(router.push<void>('/details/1'));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.text('details 1'))).pop();
    navigationShell.goBranch(1);
    await tester.pumpAndSettle();

    navigationShell.goBranch(0);
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);

    unawaited(router.push<void>('/details/2'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('details 2'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('details 1'), findsNothing);
  });

  testWidgets('goBranch does not save root routes in a nested shell branch', (
    WidgetTester tester,
  ) async {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    late StatefulNavigationShell navigationShell;
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) => child,
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
                navigationShell = shell;
                return Scaffold(body: shell);
              },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/',
                      builder: (BuildContext context, GoRouterState state) => const Text('home'),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'details/:id',
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (BuildContext context, GoRouterState state) =>
                              Text('root details ${state.pathParameters['id']}'),
                        ),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/other',
                      builder: (BuildContext context, GoRouterState state) => const Text('other'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    unawaited(router.push<void>('/details/1'));
    await tester.pumpAndSettle();
    expect(find.text('root details 1'), findsOneWidget);

    navigationShell.goBranch(1);
    await tester.pumpAndSettle();
    navigationShell.goBranch(0);
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.text('root details 1'), findsNothing);
  });
}
