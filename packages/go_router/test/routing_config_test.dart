// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('routing config works', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
        redirect: (_, _) => '/',
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(config, tester);
    expect(find.text('home'), findsOneWidget);

    router.go('/abcd'); // should be redirected to home
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('routing config works after builder changes', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(config, tester);
    expect(find.text('home'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home1'))],
    );
    await tester.pumpAndSettle();
    expect(find.text('home1'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.go('/abc');
    await tester.pumpAndSettle();
    expect(find.text('error'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes case 2', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
        ],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.go('/abc');
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
    );
    await tester.pumpAndSettle();
    expect(find.text('error'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes case 3', (WidgetTester tester) async {
    final key = GlobalKey<_StatefulTestState>(debugLabel: 'testState');
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, _) => StatefulTest(key: key, child: const Text('home')),
          ),
        ],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(
      navigatorKey: rootNavigatorKey,
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    key.currentState!.value = 1;

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => StatefulTest(key: key, child: const Text('home')),
        ),
        GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
      ],
    );
    await tester.pumpAndSettle();
    expect(key.currentState!.value == 1, isTrue);
  });

  testWidgets('routing config preserves pushed shell routes', (WidgetTester tester) async {
    final branchANavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'branch-a');
    final branchBNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'branch-b');
    RoutingConfig createConfig({required List<RouteBase> additionalRoutes}) {
      return RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/top', builder: (_, _) => const Text('Top-level route')),
          StatefulShellRoute.indexedStack(
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                navigatorKey: branchANavigatorKey,
                routes: <RouteBase>[
                  GoRoute(path: '/a', builder: (_, _) => const Text('Screen A')),
                  ...additionalRoutes,
                ],
              ),
              StatefulShellBranch(
                navigatorKey: branchBNavigatorKey,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/b',
                    builder: (_, _) => const Text('Screen B'),
                    routes: <RouteBase>[
                      GoRoute(path: 'details', builder: (_, _) => const Text('Screen B Detail')),
                    ],
                  ),
                ],
              ),
            ],
            pageBuilder: (_, _, StatefulNavigationShell navigationShell) =>
                MaterialPage<void>(child: navigationShell),
          ),
        ],
      );
    }

    final config = ValueNotifier<RoutingConfig>(createConfig(additionalRoutes: <RouteBase>[]));
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      initialLocation: '/a',
    );
    unawaited(router.push('/b/details'));
    await tester.pumpAndSettle();
    unawaited(router.push('/top'));
    await tester.pumpAndSettle();

    config.value = createConfig(
      additionalRoutes: <RouteBase>[GoRoute(path: '/c', builder: (_, _) => const Text('Screen C'))],
    );
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Screen B Detail'), findsOneWidget);
  });

  testWidgets(
    'routing config works with shell route',
    // TODO(tolo): Temporarily skipped due to a bug that causes test to faiL
    skip: true,
    (WidgetTester tester) async {
      final key = GlobalKey<_StatefulTestState>(debugLabel: 'testState');
      final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
      final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

      final config = ValueNotifier<RoutingConfig>(
        RoutingConfig(
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: shellNavigatorKey,
              routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
              builder: (_, _, Widget widget) => StatefulTest(key: key, child: widget),
            ),
          ],
        ),
      );
      addTearDown(config.dispose);
      await createRouterWithRoutingConfig(
        navigatorKey: rootNavigatorKey,
        config,
        tester,
        errorBuilder: (_, _) => const Text('error'),
      );
      expect(find.text('home'), findsOneWidget);
      key.currentState!.value = 1;

      config.value = RoutingConfig(
        routes: <RouteBase>[
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(path: '/', builder: (_, _) => const Text('home')),
              GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
            ],
            builder: (_, _, Widget widget) => StatefulTest(key: key, child: widget),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.value == 1, isTrue);
    },
  );

  testWidgets('routing config works with named route', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/abc', name: 'abc', builder: (_, _) => const Text('/abc')),
        ],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );

    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.goNamed('abc');
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(path: '/', name: 'home', builder: (_, _) => const Text('home')),
        GoRoute(path: '/abc', name: 'def', builder: (_, _) => const Text('def')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('def'), findsOneWidget);

    router.goNamed('home');
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);

    router.goNamed('def');
    await tester.pumpAndSettle();
    expect(find.text('def'), findsOneWidget);
  });
}

class StatefulTest extends StatefulWidget {
  const StatefulTest({super.key, required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _StatefulTestState();
}

class _StatefulTestState extends State<StatefulTest> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[widget.child, Text('State: $value')]);
  }
}
