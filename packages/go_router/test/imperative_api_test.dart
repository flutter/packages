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

  testWidgets(
    'push to a sibling shell route under the same parent shell route',
    (WidgetTester tester) async {
      const firstNavigatorKey = _CollidingNavigatorKey('first');
      const secondNavigatorKey = _CollidingNavigatorKey('second');
      final routes = <RouteBase>[
        ShellRoute(
          builder: (_, __, Widget child) =>
              _ShellScaffold(label: 'project-shell', child: child),
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: firstNavigatorKey,
              builder: (_, __, Widget child) =>
                  _ShellScaffold(label: 'first-shell', child: child),
              routes: <RouteBase>[
                GoRoute(
                  path: '/first',
                  builder: (_, __) => const _CounterPage(label: 'first count'),
                ),
              ],
            ),
            ShellRoute(
              navigatorKey: secondNavigatorKey,
              builder: (_, __, Widget child) =>
                  _ShellScaffold(label: 'second-shell', child: child),
              routes: <RouteBase>[
                GoRoute(
                  path: '/second',
                  builder: (_, __) => const Text('second page'),
                ),
              ],
            ),
          ],
        ),
      ];
      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/first',
      );

      expect(find.text('project-shell'), findsOneWidget);
      expect(find.text('first-shell'), findsOneWidget);
      expect(find.text('first count: 0'), findsOneWidget);

      await tester.tap(find.text('first count: 0'));
      await tester.pump();
      expect(find.text('first count: 1'), findsOneWidget);

      router.push('/second');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('project-shell'), findsOneWidget);
      expect(find.text('first-shell'), findsNothing);
      expect(find.text('second-shell'), findsOneWidget);
      expect(find.text('second page'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('project-shell'), findsOneWidget);
      expect(find.text('second-shell'), findsNothing);
      expect(find.text('first-shell'), findsOneWidget);
      expect(find.text('first count: 1'), findsOneWidget);
    },
  );

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

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          Text(label),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CounterPage extends StatefulWidget {
  const _CounterPage({required this.label});

  final String label;

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            _count++;
          });
        },
        child: Text('${widget.label}: $_count'),
      ),
    );
  }
}

class _CollidingNavigatorKey extends GlobalKey<NavigatorState> {
  const _CollidingNavigatorKey(this._label) : super.constructor();

  final String _label;

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      other is _CollidingNavigatorKey && other._label == _label;
}
