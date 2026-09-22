// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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

  // Regression test for https://github.com/flutter/flutter/issues/193098
  group('Inactive StatefulShellRoute branch with an active sub-route', () {
    testWidgets('does not prevent the root route from being popped', (WidgetTester tester) async {
      await tester.pumpWidget(const _MultiBranchTestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byKey(const Key('toSettings')));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.byKey(const Key('toGeneral')));
      await tester.pumpAndSettle();
      expect(find.text('General'), findsOneWidget);

      // Leave the Settings branch without popping its sub-route first.
      await tester.tap(find.byKey(const Key('toHome')));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      // The Home branch has nothing to pop, so the system back must not be
      // handled by the framework, allowing the platform to close the app.
      expect(await tester.binding.handlePopRoute(), isFalse);
    });

    testWidgets('keeps popping its sub-route once the branch is active again', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _MultiBranchTestApp());

      await tester.tap(find.byKey(const Key('toSettings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('toGeneral')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('toHome')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('toSettings')));
      await tester.pumpAndSettle();
      expect(find.text('General'), findsOneWidget);

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // The Settings branch no longer has a sub-route, so back is unhandled.
      expect(await tester.binding.handlePopRoute(), isFalse);
    });

    testWidgets('only the active branch guards against popping the shell', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _MultiBranchTestApp());
      // Only the Navigator of the initial branch has been created so far.
      expect(_branchCanPopValues(tester), <bool>[true]);

      await tester.tap(find.byKey(const Key('toSettings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('toGeneral')));
      await tester.pumpAndSettle();

      // The active Settings branch has a sub-route, so the shell itself must
      // stay protected against being popped, for example by an iOS back
      // gesture.
      expect(_branchCanPopValues(tester), <bool>[true, false]);

      await tester.tap(find.byKey(const Key('toHome')));
      await tester.pumpAndSettle();

      // Settings is now inactive and must no longer veto pops, even though it
      // still has an active sub-route.
      expect(_branchCanPopValues(tester), <bool>[true, true]);
    });
  });
}

/// The `canPop` value of the [PopScope] wrapping each branch Navigator, in
/// branch order.
List<bool> _branchCanPopValues(WidgetTester tester) => tester
    .widgetList(find.byWidgetPredicate((Widget widget) => widget is PopScope, skipOffstage: false))
    .map((Widget widget) => (widget as PopScope<dynamic>).canPop)
    .toList();

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
            builder:
                (
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
                          return Scaffold(appBar: AppBar(title: const Text('Comment')));
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

class _MultiBranchTestApp extends StatefulWidget {
  const _MultiBranchTestApp();

  @override
  State<_MultiBranchTestApp> createState() => _MultiBranchTestAppState();
}

class _MultiBranchTestAppState extends State<_MultiBranchTestApp> {
  final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
              return Scaffold(
                body: navigationShell,
                bottomNavigationBar: Row(
                  children: <Widget>[
                    FilledButton(
                      key: const Key('toHome'),
                      onPressed: () => navigationShell.goBranch(0),
                      child: const Text('To Home'),
                    ),
                    FilledButton(
                      key: const Key('toSettings'),
                      onPressed: () => navigationShell.goBranch(1),
                      child: const Text('To Settings'),
                    ),
                  ],
                ),
              );
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) {
                  return const Scaffold(body: Center(child: Text('Home')));
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (BuildContext context, GoRouterState state) {
                  return Scaffold(
                    body: Center(
                      child: FilledButton(
                        key: const Key('toGeneral'),
                        onPressed: () => GoRouter.of(context).go('/settings/general'),
                        child: const Text('Settings'),
                      ),
                    ),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'general',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Scaffold(body: Center(child: Text('General')));
                    },
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
