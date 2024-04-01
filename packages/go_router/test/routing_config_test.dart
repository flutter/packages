// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
