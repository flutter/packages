// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

/// Reads the clip behavior of the [Navigator] identified by [navigatorKey].
///
/// Offstage widgets are included so that the Navigators of inactive
/// [StatefulShellBranch]es can be inspected too.
Clip clipBehaviorOf(WidgetTester tester, GlobalKey<NavigatorState> navigatorKey) =>
    tester.widget<Navigator>(find.byKey(navigatorKey, skipOffstage: false)).clipBehavior;

void main() {
  group('ShellRoute', () {
    testWidgets('clips the nested Navigator by default', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
      await createRouter(<RouteBase>[
        ShellRoute(
          navigatorKey: navigatorKey,
          builder: (_, _, Widget child) => child,
          routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('Home'))],
        ),
      ], tester);

      expect(clipBehaviorOf(tester, navigatorKey), Clip.hardEdge);
    });

    testWidgets('forwards clipBehavior to the nested Navigator', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
      await createRouter(<RouteBase>[
        ShellRoute(
          navigatorKey: navigatorKey,
          clipBehavior: Clip.none,
          builder: (_, _, Widget child) => child,
          routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('Home'))],
        ),
      ], tester);

      expect(clipBehaviorOf(tester, navigatorKey), Clip.none);
    });

    testWidgets('forwards clipBehavior to the nested Navigator when using pageBuilder', (
      WidgetTester tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
      await createRouter(<RouteBase>[
        ShellRoute(
          navigatorKey: navigatorKey,
          clipBehavior: Clip.antiAlias,
          pageBuilder: (_, _, Widget child) => MaterialPage<void>(child: child),
          routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('Home'))],
        ),
      ], tester);

      expect(clipBehaviorOf(tester, navigatorKey), Clip.antiAlias);
    });
  });

  group('StatefulShellBranch', () {
    testWidgets('clips the branch Navigator by default', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'branch');
      await createRouter(<RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (_, _, StatefulNavigationShell shell) => shell,
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              navigatorKey: navigatorKey,
              routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('A'))],
            ),
          ],
        ),
      ], tester);

      expect(clipBehaviorOf(tester, navigatorKey), Clip.hardEdge);
    });

    testWidgets('forwards clipBehavior per branch', (WidgetTester tester) async {
      final keyA = GlobalKey<NavigatorState>(debugLabel: 'a');
      final keyB = GlobalKey<NavigatorState>(debugLabel: 'b');
      final root = GlobalKey<NavigatorState>(debugLabel: 'root');
      await createRouter(
        <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (_, _, StatefulNavigationShell shell) => shell,
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                navigatorKey: keyA,
                clipBehavior: Clip.none,
                routes: <RouteBase>[GoRoute(path: '/a', builder: (_, _) => const Text('A'))],
              ),
              StatefulShellBranch(
                navigatorKey: keyB,
                routes: <RouteBase>[GoRoute(path: '/b', builder: (_, _) => const Text('B'))],
              ),
            ],
          ),
        ],
        tester,
        navigatorKey: root,
        initialLocation: '/a',
      );

      expect(clipBehaviorOf(tester, keyA), Clip.none);

      root.currentContext!.go('/b');
      await tester.pumpAndSettle();

      // Each branch keeps its own clip behavior; the loaded branches stay in
      // the tree because StatefulShellRoute preserves their state.
      expect(clipBehaviorOf(tester, keyA), Clip.none);
      expect(clipBehaviorOf(tester, keyB), Clip.hardEdge);
    });

    testWidgets('forwards clipBehavior to preloaded branches', (WidgetTester tester) async {
      final keyA = GlobalKey<NavigatorState>(debugLabel: 'a');
      final keyB = GlobalKey<NavigatorState>(debugLabel: 'b');
      await createRouter(
        <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (_, _, StatefulNavigationShell shell) => shell,
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                navigatorKey: keyA,
                routes: <RouteBase>[GoRoute(path: '/a', builder: (_, _) => const Text('A'))],
              ),
              StatefulShellBranch(
                navigatorKey: keyB,
                preload: true,
                clipBehavior: Clip.none,
                routes: <RouteBase>[GoRoute(path: '/b', builder: (_, _) => const Text('B'))],
              ),
            ],
          ),
        ],
        tester,
        initialLocation: '/a',
      );
      await tester.pumpAndSettle();

      expect(clipBehaviorOf(tester, keyB), Clip.none);
    });
  });
}
