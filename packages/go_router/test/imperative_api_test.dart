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
        builder: (_, _, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (_, _) => DummyScreen(key: a),
          ),
          GoRoute(
            path: '/b',
            builder: (_, _) => DummyScreen(key: b),
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

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
        builder: (_, _) => DummyScreen(key: a),
      ),
      ShellRoute(
        builder: (_, _, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/b',
            builder: (_, _) => DummyScreen(key: b),
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

    expect(find.text('shell'), findsNothing);
    expect(find.byKey(a), findsOneWidget);

    router.push('/b');
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsOneWidget);
    expect(find.byKey(a), findsNothing);
    expect(find.byKey(b), findsOneWidget);
  });

  testWidgets('shell route reflect imperative push', (WidgetTester tester) async {
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
            builder: (_, _) => DummyScreen(key: home),
            routes: <RouteBase>[
              GoRoute(
                path: 'a',
                builder: (_, _) => DummyScreen(key: a),
              ),
            ],
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

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

  testWidgets('push shell route in another shell route', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/120791.
    final b = UniqueKey();
    final a = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, _, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell1')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (_, _) => DummyScreen(key: a),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, _, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell2')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/b',
            builder: (_, _) => DummyScreen(key: b),
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

    expect(find.text('shell1'), findsOneWidget);
    expect(find.byKey(a), findsOneWidget);

    router.push('/b');
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsNothing);
    expect(find.byKey(a), findsNothing);
    expect(find.text('shell2'), findsOneWidget);
    expect(find.byKey(b), findsOneWidget);
  });

  testWidgets('push inside or outside shell route', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/120665.
    final inside = UniqueKey();
    final outside = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, _, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/in',
            builder: (_, _) => DummyScreen(key: inside),
          ),
        ],
      ),
      GoRoute(
        path: '/out',
        builder: (_, _) => DummyScreen(key: outside),
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/out');

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
        builder: (_, _, Widget child) {
          return Scaffold(
            appBar: AppBar(title: const Text('shell')),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (_, _) => DummyScreen(key: a),
          ),
          GoRoute(
            path: '/c',
            builder: (_, _) => DummyScreen(key: c),
          ),
        ],
      ),
      GoRoute(
        path: '/d',
        builder: (_, _) => DummyScreen(key: d),
        routes: <RouteBase>[
          GoRoute(
            path: 'e',
            builder: (_, _) => DummyScreen(key: e),
          ),
        ],
      ),
      GoRoute(
        path: '/b',
        builder: (_, _) => DummyScreen(key: b),
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

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

  testWidgets('re-enter a shell route still in the stack', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/140586.
    final shellKey = GlobalKey<NavigatorState>();
    final a = UniqueKey();
    final b = UniqueKey();
    final c = UniqueKey();
    final routes = <RouteBase>[
      GoRoute(
        path: '/a',
        builder: (_, _) => DummyScreen(key: a),
      ),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (_, _, Widget child) => child,
        routes: <RouteBase>[
          GoRoute(
            path: '/b',
            builder: (_, _) => DummyScreen(key: b),
          ),
          GoRoute(
            path: '/c',
            builder: (_, _) => DummyScreen(key: c),
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

    router.push('/b');
    await tester.pumpAndSettle();
    router.push('/c');
    await tester.pumpAndSettle();
    router.pushReplacement('/a');
    await tester.pumpAndSettle();

    // Re-entering the shell route while a previous instance is still in the
    // stack used to throw a duplicate page key assertion.
    router.push('/b');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(b), findsOneWidget);

    // Popping the re-entered shell restores the replaced top-level page.
    router.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(a), findsOneWidget);
  });

  testWidgets('re-enter a nested shell route still in the stack', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/140586.
    // Variant with a nested shell and auto-generated navigator keys.
    final a = UniqueKey();
    final b = UniqueKey();
    final c = UniqueKey();
    final routes = <RouteBase>[
      GoRoute(
        path: '/a',
        builder: (_, _) => DummyScreen(key: a),
        routes: <RouteBase>[
          ShellRoute(
            builder: (_, _, Widget child) => child,
            routes: <RouteBase>[
              GoRoute(
                path: 'b',
                builder: (_, _) => DummyScreen(key: b),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/c',
        builder: (_, _) => DummyScreen(key: c),
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

    router.push('/a/b');
    await tester.pumpAndSettle();
    router.push('/c');
    await tester.pumpAndSettle();
    router.push('/a/b');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(b), findsOneWidget);
  });

  testWidgets('re-enter nested shell routes still in the stack', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/140586.
    // Two nested shell routes are both duplicated when re-entered; each cloned
    // shell must get its own distinct navigator key.
    final outerKey = GlobalKey<NavigatorState>();
    final innerKey = GlobalKey<NavigatorState>();
    final a = UniqueKey();
    final b = UniqueKey();
    final c = UniqueKey();
    final routes = <RouteBase>[
      GoRoute(
        path: '/a',
        builder: (_, _) => DummyScreen(key: a),
      ),
      ShellRoute(
        navigatorKey: outerKey,
        builder: (_, _, Widget child) => child,
        routes: <RouteBase>[
          ShellRoute(
            navigatorKey: innerKey,
            builder: (_, _, Widget child) => child,
            routes: <RouteBase>[
              GoRoute(
                path: '/b',
                builder: (_, _) => DummyScreen(key: b),
              ),
              GoRoute(
                path: '/c',
                builder: (_, _) => DummyScreen(key: c),
              ),
            ],
          ),
        ],
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/a');

    router.push('/b');
    await tester.pumpAndSettle();
    router.push('/c');
    await tester.pumpAndSettle();
    router.pushReplacement('/a');
    await tester.pumpAndSettle();
    router.push('/b');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(b), findsOneWidget);

    // The original navigator keys still resolve to the bottom-most instances.
    expect(outerKey.currentState, isNotNull);
    expect(innerKey.currentState, isNotNull);
  });
}
