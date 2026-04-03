// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets(
    'PopScope in StatefulShellRoute branch works on subsequent visits',
    (WidgetTester tester) async {
      int tabBPopCount = 0;

      final routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return Scaffold(
                  body: navigationShell,
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: navigationShell.currentIndex,
                    onTap: (int index) => navigationShell.goBranch(index),
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'A',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.business),
                        label: 'B',
                      ),
                    ],
                  ),
                );
              },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/tabA',
                  builder: (BuildContext context, GoRouterState state) =>
                      const DummyScreen(key: ValueKey<String>('tabA')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/tabB',
                  builder: (BuildContext context, GoRouterState state) {
                    return PopScope(
                      canPop: false,
                      onPopInvokedWithResult: (bool didPop, Object? result) {
                        tabBPopCount++;
                        if (!didPop) {
                          context.go('/tabA');
                        }
                      },
                      child: const DummyScreen(key: ValueKey<String>('tabB')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/tabA',
      );

      // 1. Visit Tab A
      expect(find.byKey(const ValueKey<String>('tabA')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('tabB')), findsNothing);

      // 2. Switch to Tab B
      router.go('/tabB');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('tabB')), findsOneWidget);

      // 3. Press back button on Tab B (First Visit)
      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      // Should have switched back to Tab A
      expect(find.byKey(const ValueKey<String>('tabA')), findsOneWidget);
      expect(tabBPopCount, 1);

      // 4. Switch to Tab B again (Second Visit)
      router.go('/tabB');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('tabB')), findsOneWidget);

      // 5. Press back button on Tab B (Second Visit)
      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      // Verify that the PopScope was triggered again
      expect(tabBPopCount, 2);

      // Should have switched back to Tab A again
      expect(find.byKey(const ValueKey<String>('tabA')), findsOneWidget);
    },
  );

  testWidgets(
    'StatefulShellRoute switches to root branch by default on back button',
    (WidgetTester tester) async {
      final routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return Scaffold(
                  body: navigationShell,
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: navigationShell.currentIndex,
                    onTap: (int index) => navigationShell.goBranch(index),
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'A',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.business),
                        label: 'B',
                      ),
                    ],
                  ),
                );
              },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/tabA',
                  builder: (BuildContext context, GoRouterState state) =>
                      const DummyScreen(key: ValueKey<String>('tabA')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/tabB',
                  builder: (BuildContext context, GoRouterState state) =>
                      const DummyScreen(key: ValueKey<String>('tabB')),
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/tabA',
      );

      expect(find.byKey(const ValueKey<String>('tabA')), findsOneWidget);

      router.go('/tabB');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('tabB')), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('tabA')), findsOneWidget);
    },
  );
}
