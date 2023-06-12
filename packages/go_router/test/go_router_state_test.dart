// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/configuration.dart';

import 'test_helpers.dart';

void main() {
  group('GoRouterState from context', () {
    testWidgets('works in builder', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, _) {
              final GoRouterState state = GoRouterState.of(context);
              return Text('/ ${state.queryParameters['p']}');
            }),
        GoRoute(
            path: '/a',
            builder: (BuildContext context, _) {
              final GoRouterState state = GoRouterState.of(context);
              return Text('/a ${state.queryParameters['p']}');
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
                return Text('1 ${GoRouterState.of(context).location}');
              });
            },
            routes: <GoRoute>[
              GoRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text('2 ${GoRouterState.of(context).location}');
                    });
                  }),
            ]),
      ];
      final GoRouter router = await createRouter(routes, tester);
      router.go('/?p=123');
      await tester.pumpAndSettle();
      expect(find.text('1 /?p=123'), findsOneWidget);

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
                return Text('1 ${GoRouterState.of(context).location}');
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
                return Text(GoRouterState.of(context).location);
              });
            },
            routes: <GoRoute>[
              GoRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(key: key, GoRouterState.of(context).location);
                    });
                  }),
            ]),
      ];
      final GoRouter router =
          await createRouter(routes, tester, initialLocation: '/a?p=123');
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');
      final GoRouterStateRegistry registry = tester
          .widget<GoRouterStateRegistryScope>(
              find.byType(GoRouterStateRegistryScope))
          .notifier!;
      expect(registry.registry.length, 2);
      router.go('/');
      await tester.pump();
      expect(registry.registry.length, 2);
      // should retain the same location even if the location has changed.
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');

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
                return Text(GoRouterState.of(context).location);
              });
            },
            routes: <GoRoute>[
              GoRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(key: key, GoRouterState.of(context).location);
                    });
                  }),
            ]),
      ];
      await createRouter(routes, tester,
          initialLocation: '/a?p=123', navigatorKey: nav);
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');
      final GoRouterStateRegistry registry = tester
          .widget<GoRouterStateRegistryScope>(
              find.byType(GoRouterStateRegistryScope))
          .notifier!;
      expect(registry.registry.length, 2);
      nav.currentState!.pop();
      await tester.pump();
      expect(registry.registry.length, 2);
      // should retain the same location even if the location has changed.
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');

      // Finish the pop animation.
      await tester.pumpAndSettle();
      expect(registry.registry.length, 1);
      expect(find.byKey(key), findsNothing);
    });
  });
}
