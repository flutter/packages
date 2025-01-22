// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('routing config works', (WidgetTester tester) async {
    final ValueNotifier<RoutingConfig> config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, __) => const Text('home')),
        ],
        redirect: (_, __) => '/',
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(config, tester);
    expect(find.text('home'), findsOneWidget);

    router.go('/abcd'); // should be redirected to home
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('routing config works after builder changes',
      (WidgetTester tester) async {
    final ValueNotifier<RoutingConfig> config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, __) => const Text('home')),
        ],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(config, tester);
    expect(find.text('home'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, __) => const Text('home1')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('home1'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes',
      (WidgetTester tester) async {
    final ValueNotifier<RoutingConfig> config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, __) => const Text('home')),
        ],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, __) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.go('/abc');
    await tester.pumpAndSettle();
    expect(find.text('error'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, __) => const Text('home')),
        GoRoute(path: '/abc', builder: (_, __) => const Text('/abc')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes case 2',
      (WidgetTester tester) async {
    final ValueNotifier<RoutingConfig> config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, __) => const Text('home')),
          GoRoute(path: '/abc', builder: (_, __) => const Text('/abc')),
        ],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, __) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.go('/abc');
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, __) => const Text('home')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('error'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes case 3',
      (WidgetTester tester) async {
    final GlobalKey<_StatefulTestState> key =
        GlobalKey<_StatefulTestState>(debugLabel: 'testState');
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>(debugLabel: 'root');

    final ValueNotifier<RoutingConfig> config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(
              path: '/',
              builder: (_, __) =>
                  StatefulTest(key: key, child: const Text('home'))),
        ],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(
      navigatorKey: rootNavigatorKey,
      config,
      tester,
      errorBuilder: (_, __) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    key.currentState!.value = 1;

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(
            path: '/',
            builder: (_, __) =>
                StatefulTest(key: key, child: const Text('home'))),
        GoRoute(path: '/abc', builder: (_, __) => const Text('/abc')),
      ],
    );
    await tester.pumpAndSettle();
    expect(key.currentState!.value == 1, isTrue);
  });

  testWidgets('routing config works with shell route',
      // TODO(tolo): Temporarily skipped due to a bug that causes test to faiL
      skip: true, (WidgetTester tester) async {
    final GlobalKey<_StatefulTestState> key =
        GlobalKey<_StatefulTestState>(debugLabel: 'testState');
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>(debugLabel: 'root');
    final GlobalKey<NavigatorState> shellNavigatorKey =
        GlobalKey<NavigatorState>(debugLabel: 'shell');

    final ValueNotifier<RoutingConfig> config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          ShellRoute(
              navigatorKey: shellNavigatorKey,
              routes: <RouteBase>[
                GoRoute(path: '/', builder: (_, __) => const Text('home')),
              ],
              builder: (_, __, Widget widget) =>
                  StatefulTest(key: key, child: widget)),
        ],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(
      navigatorKey: rootNavigatorKey,
      config,
      tester,
      errorBuilder: (_, __) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    key.currentState!.value = 1;

    config.value = RoutingConfig(
      routes: <RouteBase>[
        ShellRoute(
            navigatorKey: shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(path: '/', builder: (_, __) => const Text('home')),
              GoRoute(path: '/abc', builder: (_, __) => const Text('/abc')),
            ],
            builder: (_, __, Widget widget) =>
                StatefulTest(key: key, child: widget)),
      ],
    );
    await tester.pumpAndSettle();

    expect(key.currentState!.value == 1, isTrue);
  });

  testWidgets('routing config works with named route',
      (WidgetTester tester) async {
    final ValueNotifier<RoutingConfig> config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, __) => const Text('home')),
          GoRoute(
              path: '/abc',
              name: 'abc',
              builder: (_, __) => const Text('/abc')),
        ],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, __) => const Text('error'),
    );

    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.goNamed('abc');
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(
            path: '/', name: 'home', builder: (_, __) => const Text('home')),
        GoRoute(
            path: '/abc', name: 'def', builder: (_, __) => const Text('def')),
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
    return Column(
      children: <Widget>[
        widget.child,
        Text('State: $value'),
      ],
    );
  }
}
