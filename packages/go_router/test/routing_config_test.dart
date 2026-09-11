// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
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

  testWidgets('routing config rematches an inactive stateful shell branch', (
    WidgetTester tester,
  ) async {
    final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
    final shellKey = GlobalKey<StatefulNavigationShellState>(debugLabel: 'statefulShell');
    final firstBranchKey = GlobalKey<NavigatorState>(debugLabel: 'first');
    final secondBranchKey = GlobalKey<NavigatorState>(debugLabel: 'second');

    final branches = <StatefulShellBranch>[
      StatefulShellBranch(
        navigatorKey: firstBranchKey,
        routes: <RouteBase>[
          GoRoute(
            path: '/first',
            builder: (_, _) => const Text('first'),
            routes: <RouteBase>[
              GoRoute(
                path: 'details',
                parentNavigatorKey: shellNavigatorKey,
                builder: (_, _) => const Text('details'),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: secondBranchKey,
        routes: <RouteBase>[GoRoute(path: '/second', builder: (_, _) => const Text('second'))],
      ),
    ];

    RoutingConfig buildConfig() => RoutingConfig(
      routes: <RouteBase>[
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          pageBuilder: (_, _, Widget child) => NoTransitionPage<void>(child: child),
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              key: shellKey,
              branches: branches,
              pageBuilder: (_, _, StatefulNavigationShell navigationShell) =>
                  NoTransitionPage<void>(child: navigationShell),
            ),
          ],
        ),
      ],
    );

    final config = ValueNotifier<RoutingConfig>(buildConfig());
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      initialLocation: '/first',
    );

    shellKey.currentState!.goBranch(1);
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);

    config.value = buildConfig();
    await tester.pumpAndSettle();

    shellKey.currentState!.goBranch(0);
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);

    router.push<void>('/first/details');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('details'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.matches, hasLength(1));
    expect(shellNavigatorKey.currentState!.canPop(), isTrue);
  });

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
