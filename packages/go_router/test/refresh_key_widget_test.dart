// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/match.dart';

import 'test_helpers.dart';

void main() {
  group('RefreshKey Widget Tests', () {
    testWidgets('refresh() creates new refreshKey for simple route', (
      WidgetTester tester,
    ) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/page',
      );

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      final RouteMatch routeMatchBefore =
          matchesBefore.matches.first as RouteMatch;
      final ValueKey<String>? refreshKeyBefore = routeMatchBefore.refreshKey;

      // Wait to ensure timestamp changes
      await tester.pump(const Duration(milliseconds: 10));

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      final RouteMatch routeMatchAfter =
          matchesAfter.matches.first as RouteMatch;
      final ValueKey<String>? refreshKeyAfter = routeMatchAfter.refreshKey;

      expect(refreshKeyAfter, isNotNull);
      expect(refreshKeyBefore, isNot(equals(refreshKeyAfter)));
    });

    testWidgets('refresh() updates refreshKey for nested routes', (
      WidgetTester tester,
    ) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/parent',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'child',
              builder:
                  (BuildContext context, GoRouterState state) =>
                      const DummyScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/parent/child',
      );

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      final List<ValueKey<String>?> refreshKeysBefore =
          matchesBefore.matches
              .map((RouteMatchBase m) => m.refreshKey)
              .toList();

      await tester.pump(const Duration(milliseconds: 10));

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      final List<ValueKey<String>?> refreshKeysAfter =
          matchesAfter.matches.map((RouteMatchBase m) => m.refreshKey).toList();

      expect(refreshKeysAfter.length, equals(refreshKeysBefore.length));
      for (int i = 0; i < refreshKeysAfter.length; i++) {
        expect(refreshKeysAfter[i], isNotNull);
        expect(refreshKeysBefore[i], isNot(equals(refreshKeysAfter[i])));
      }
    });

    testWidgets('refresh() with ShellRoute updates child routes', (
      WidgetTester tester,
    ) async {
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>();
      final List<RouteBase> routes = <RouteBase>[
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return child;
          },
          routes: <GoRoute>[
            GoRoute(
              path: '/a',
              builder:
                  (BuildContext context, GoRouterState state) =>
                      const DummyScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/a',
      );

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      final ShellRouteMatch shellMatchBefore =
          matchesBefore.matches.first as ShellRouteMatch;
      final RouteMatch childMatchBefore =
          shellMatchBefore.matches.first as RouteMatch;
      final ValueKey<String>? childRefreshKeyBefore =
          childMatchBefore.refreshKey;

      await tester.pump(const Duration(milliseconds: 10));

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      final ShellRouteMatch shellMatchAfter =
          matchesAfter.matches.first as ShellRouteMatch;
      final RouteMatch childMatchAfter =
          shellMatchAfter.matches.first as RouteMatch;
      final ValueKey<String>? childRefreshKeyAfter = childMatchAfter.refreshKey;

      // Child route should have new refresh key
      expect(childRefreshKeyAfter, isNotNull);
      expect(childRefreshKeyBefore, isNot(equals(childRefreshKeyAfter)));
    });

    testWidgets('refresh() maintains route state', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/page',
      );

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      final String uriBefore = matchesBefore.uri.toString();
      final String matchedLocationBefore =
          matchesBefore.matches.first.matchedLocation;

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      final String uriAfter = matchesAfter.uri.toString();
      final String matchedLocationAfter =
          matchesAfter.matches.first.matchedLocation;

      // URI and matched location should remain the same
      expect(uriAfter, equals(uriBefore));
      expect(matchedLocationAfter, equals(matchedLocationBefore));
    });

    testWidgets('refresh() with query parameters', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/page?param=value',
      );

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      final ValueKey<String>? refreshKeyBefore =
          (matchesBefore.matches.first as RouteMatch).refreshKey;

      await tester.pump(const Duration(milliseconds: 10));

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      final ValueKey<String>? refreshKeyAfter =
          (matchesAfter.matches.first as RouteMatch).refreshKey;

      expect(matchesAfter.uri.queryParameters['param'], equals('value'));
      expect(refreshKeyAfter, isNotNull);
      expect(refreshKeyBefore, isNot(equals(refreshKeyAfter)));
    });

    testWidgets('refresh() with path parameters', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/user/:id',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/user/123',
      );

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      final ValueKey<String>? refreshKeyBefore =
          (matchesBefore.matches.first as RouteMatch).refreshKey;

      await tester.pump(const Duration(milliseconds: 10));

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      final ValueKey<String>? refreshKeyAfter =
          (matchesAfter.matches.first as RouteMatch).refreshKey;

      expect(matchesAfter.pathParameters['id'], equals('123'));
      expect(refreshKeyAfter, isNotNull);
      expect(refreshKeyBefore, isNot(equals(refreshKeyAfter)));
    });

    testWidgets('multiple refresh() calls create different keys', (
      WidgetTester tester,
    ) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/page',
      );

      final List<ValueKey<String>?> refreshKeys = <ValueKey<String>?>[];

      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        router.refresh();
        await tester.pump();

        final RouteMatchList matches =
            router.routerDelegate.currentConfiguration;
        final ValueKey<String>? refreshKey =
            (matches.matches.first as RouteMatch).refreshKey;
        refreshKeys.add(refreshKey);
      }

      // All refresh keys should be different
      expect(refreshKeys[0], isNot(equals(refreshKeys[1])));
      expect(refreshKeys[1], isNot(equals(refreshKeys[2])));
      expect(refreshKeys[0], isNot(equals(refreshKeys[2])));
    });

    testWidgets('refresh() preserves extra data', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);

      const Map<String, String> extraData = <String, String>{'key': 'value'};
      router.go('/page', extra: extraData);
      await tester.pump();

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      expect(matchesBefore.extra, equals(extraData));

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      expect(matchesAfter.extra, equals(extraData));
    });

    testWidgets('refresh() works with deeply nested routes', (
      WidgetTester tester,
    ) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/level1',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'level2',
              builder:
                  (BuildContext context, GoRouterState state) =>
                      const DummyScreen(),
              routes: <GoRoute>[
                GoRoute(
                  path: 'level3',
                  builder:
                      (BuildContext context, GoRouterState state) =>
                          const DummyScreen(),
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/level1/level2/level3',
      );

      final RouteMatchList matchesBefore =
          router.routerDelegate.currentConfiguration;
      expect(matchesBefore.matches.length, equals(3));

      await tester.pump(const Duration(milliseconds: 10));

      router.refresh();
      await tester.pump();

      final RouteMatchList matchesAfter =
          router.routerDelegate.currentConfiguration;
      expect(matchesAfter.matches.length, equals(3));

      // All matches should have new refresh keys
      for (int i = 0; i < matchesAfter.matches.length; i++) {
        final ValueKey<String>? keyBefore = matchesBefore.matches[i].refreshKey;
        final ValueKey<String>? keyAfter = matchesAfter.matches[i].refreshKey;
        expect(keyAfter, isNotNull);
        expect(keyBefore, isNot(equals(keyAfter)));
      }
    });
  });
}
