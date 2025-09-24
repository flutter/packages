// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

// Regression test for https://github.com/flutter/flutter/issues/120353
void main() {
  group('iOS back gesture inside a StatefulShellRoute', () {
    testWidgets('pops the top sub-route '
        'when there is an active sub-route', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Comment'), findsOneWidget);

      await simulateIosBackGesture(tester);
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('pops StatefulShellRoute '
        'when there are no active sub-routes', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await simulateIosBackGesture(tester);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('Android back button inside a StatefulShellRoute', () {
    testWidgets('pops the top sub-route '
        'when there is an active sub-route', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Comment'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('pops StatefulShellRoute '
        'when there are no active sub-routes', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}

class _TestApp extends StatefulWidget {
  const _TestApp();

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: FilledButton(
                onPressed: () {
                  GoRouter.of(context).go('/post');
                },
                child: const Text('Go to Post'),
              ),
            ),
          );
        },
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return navigationShell;
            },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <GoRoute>[
                  GoRoute(
                    path: '/post',
                    builder: (BuildContext context, GoRouterState state) {
                      return Scaffold(
                        appBar: AppBar(title: const Text('Post')),
                        body: Center(
                          child: FilledButton(
                            onPressed: () {
                              GoRouter.of(context).go('/post/comment');
                            },
                            child: const Text('Comment'),
                          ),
                        ),
                      );
                    },
                    routes: <GoRoute>[
                      GoRoute(
                        path: 'comment',
                        builder: (BuildContext context, GoRouterState state) {
                          return Scaffold(
                            appBar: AppBar(title: const Text('Comment')),
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
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
