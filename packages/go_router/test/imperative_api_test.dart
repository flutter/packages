// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('replace inside shell route', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/134524.
    final a = UniqueKey();
    final b = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, __, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (_, __) => DummyScreen(key: a),
          ),
          GoRoute(
            path: '/b',
            builder: (_, __) => DummyScreen(key: b),
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/a',
    );

    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(a), findsOneWidget);

    router.replace<void>('/b');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(a), findsNothing);
    expect(find.byKey(b), findsOneWidget);
  });

  testWidgets('push from outside of shell route', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/130406.
    final a = UniqueKey();
    final b = UniqueKey();
    final routes = <RouteBase>[
      GoRoute(
        path: '/a',
        builder: (_, __) => DummyScreen(key: a),
      ),
      ShellRoute(
        builder: (_, __, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/b',
            builder: (_, __) => DummyScreen(key: b),
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/a',
    );

    expect(find.text('shell'), findsNothing);
    expect(find.byKey(a), findsOneWidget);

    router.push('/b');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(a), findsNothing);
    expect(find.byKey(b), findsOneWidget);
  });

  testWidgets('shell route reflect imperative push', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/125752.
    final home = UniqueKey();
    final a = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, GoRouterState state, Widget child) {
          return Scaffold(
            appBar: AppBar(title: Text('location: ${state.uri.path}')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => DummyScreen(key: home),
            routes: <RouteBase>[
              GoRoute(
                path: 'a',
                builder: (_, __) => DummyScreen(key: a),
              ),
            ],
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/a',
    );

    expect(find.text('location: /a'), findsOneWidget);
    expect(find.byKey(a), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('location: /'), findsOneWidget);
    expect(find.byKey(a), findsNothing);
    expect(find.byKey(home), findsOneWidget);

    router.push('/a');
    await tester.pumpAndSettle();
    expect(find.text('location: /a'), findsOneWidget);
    expect(find.byKey(a), findsOneWidget);
    expect(find.byKey(home), findsNothing);
  });

  testWidgets('push shell route in another shell route', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/120791.
    final b = UniqueKey();
    final a = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, __, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell1')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (_, __) => DummyScreen(key: a),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, __, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell2')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/b',
            builder: (_, __) => DummyScreen(key: b),
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/a',
    );

    expect(find.text('shell1'), findsOneWidget);
    expect(find.byKey(a), findsOneWidget);

    router.push('/b');
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsNothing);
    expect(find.byKey(a), findsNothing);
    expect(find.text('shell2'), findsOneWidget);
    expect(find.byKey(b), findsOneWidget);
  });

  testWidgets('push inside or outside shell route', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/120665.
    final inside = UniqueKey();
    final outside = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, __, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/in',
            builder: (_, __) => DummyScreen(key: inside),
          ),
        ],
      ),
      GoRoute(
        path: '/out',
        builder: (_, __) => DummyScreen(key: outside),
      ),
    ];
    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/out',
    );

    expect(find.text('shell'), findsNothing);
    expect(find.byKey(outside), findsOneWidget);

    router.push('/in');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(outside), findsNothing);
    expect(find.byKey(inside), findsOneWidget);

    router.push('/out');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsNothing);
    expect(find.byKey(outside), findsOneWidget);
    expect(find.byKey(inside), findsNothing);
  });

  testWidgets('complex case 1', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/113001.
    final a = UniqueKey();
    final b = UniqueKey();
    final c = UniqueKey();
    final d = UniqueKey();
    final e = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, __, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (_, __) => DummyScreen(key: a),
          ),
          GoRoute(
            path: '/c',
            builder: (_, __) => DummyScreen(key: c),
          ),
        ],
      ),
      GoRoute(
        path: '/d',
        builder: (_, __) => DummyScreen(key: d),
        routes: <RouteBase>[
          GoRoute(
            path: 'e',
            builder: (_, __) => DummyScreen(key: e),
          ),
        ],
      ),
      GoRoute(
        path: '/b',
        builder: (_, __) => DummyScreen(key: b),
      ),
    ];
    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/a',
    );

    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(a), findsOneWidget);

    router.push('/b');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsNothing);
    expect(find.byKey(a), findsNothing);
    expect(find.byKey(b), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(a), findsOneWidget);

    router.go('/c');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(c), findsOneWidget);

    router.push('/d');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsNothing);
    expect(find.byKey(d), findsOneWidget);

    router.push('/d/e');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsNothing);
    expect(find.byKey(e), findsOneWidget);
  });
}
