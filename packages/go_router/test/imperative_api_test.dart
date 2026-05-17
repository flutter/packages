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

  // Regression test for https://github.com/flutter/flutter/issues/182441.
  // After an imperative push, relative-path navigation (`./...`) must
  // resolve against the pushed route, not against the underlying
  // non-imperative base URI that Flutter's Router reports back to
  // GoRouteInformationProvider after every parse.
  //
  // The bug shape from go_router_builder is: a TypedRelativeGoRoute child
  // shared by multiple parents always resolved to the FIRST parent in the
  // route tree, because the generated `pushRelative` calls
  // `context.push('./<child-path>')`, and the provider resolved that against
  // its stale `_value.uri` (which had been reset to the non-imperative base
  // by the Router callback).
  testWidgets(
    "push('./<child>') resolves against the imperatively-pushed parent, "
    "not the first sibling parent in the route tree",
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home')),
            routes: <RouteBase>[
              GoRoute(
                path: 'reviews',
                builder: (_, __) => const Scaffold(body: Text('HomeReviews')),
              ),
            ],
          ),
          GoRoute(
            path: '/products',
            builder: (_, __) => const Scaffold(body: Text('Products')),
            routes: <RouteBase>[
              GoRoute(
                path: 'reviews',
                builder: (_, __) =>
                    const Scaffold(body: Text('ProductsReviews')),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/home');

      // Step 1: imperative push to /products (mirrors `ProductsRoute().push(context)`).
      router.push('/products');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/products');

      // Step 2: push the SHARED relative child (mirrors
      // `ReviewsRoute().pushRelative(context)` which generates `./reviews`).
      router.push('./reviews');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/products/reviews');
      expect(find.text('ProductsReviews'), findsOneWidget);
      expect(find.text('HomeReviews'), findsNothing);
    },
  );

  // Same scenario, but using `pushReplacement` and `replace` to confirm the
  // relative-path resolution fix applies to all stack-based imperative APIs.
  testWidgets(
    "pushReplacement('./<child>') and replace('./<child>') also resolve "
    "against the current imperative top",
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home')),
            routes: <RouteBase>[
              GoRoute(
                path: 'reviews',
                builder: (_, __) => const Scaffold(body: Text('HomeReviews')),
              ),
            ],
          ),
          GoRoute(
            path: '/products',
            builder: (_, __) => const Scaffold(body: Text('Products')),
            routes: <RouteBase>[
              GoRoute(
                path: 'reviews',
                builder: (_, __) =>
                    const Scaffold(body: Text('ProductsReviews')),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/products');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/products');

      router.pushReplacement('./reviews');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/products/reviews');

      // Reset the stack and try the same with replace().
      router.go('/home');
      await tester.pumpAndSettle();
      router.push('/products');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/products');

      router.replace('./reviews');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/products/reviews');
    },
  );
}
