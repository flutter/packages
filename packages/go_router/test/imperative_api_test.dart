// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/match.dart';
import 'package:material_ui/material_ui.dart';

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

  testWidgets('push to a sibling shell route under the same parent shell route', (
    WidgetTester tester,
  ) async {
    const firstNavigatorKey = _CollidingNavigatorKey('first');
    const secondNavigatorKey = _CollidingNavigatorKey('second');
    expect(firstNavigatorKey, isNot(equals(secondNavigatorKey)));
    expect(firstNavigatorKey.hashCode, secondNavigatorKey.hashCode);
    final secondPageKey = UniqueKey();
    final firstRoute = _CollidingShellRoute(
      navigatorKey: firstNavigatorKey,
      builder: (_, _, Widget child) => child,
      routes: <RouteBase>[GoRoute(path: '/first', builder: (_, _) => const DummyStatefulWidget())],
    );
    final secondRoute = _CollidingShellRoute(
      navigatorKey: secondNavigatorKey,
      builder: (_, _, Widget child) => child,
      routes: <RouteBase>[
        GoRoute(
          path: '/second',
          builder: (_, _) => DummyScreen(key: secondPageKey),
        ),
      ],
    );
    expect(firstRoute, isNot(equals(secondRoute)));
    expect(firstRoute.hashCode, secondRoute.hashCode);
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, _, Widget child) => child,
        routes: <RouteBase>[firstRoute, secondRoute],
      ),
    ];
    final GoRouter router = await createRouter(routes, tester, initialLocation: '/first');

    final NavigatorState firstNavigator = firstNavigatorKey.currentState!;
    final DummyStatefulWidgetState firstPage = tester.state<DummyStatefulWidgetState>(
      find.byType(DummyStatefulWidget),
    );
    expect(secondNavigatorKey.currentState, isNull);

    firstPage.increment();
    await tester.pump();
    expect(firstPage.counter, 1);

    router.push('/second');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final NavigatorState secondNavigator = secondNavigatorKey.currentState!;
    expect(firstNavigatorKey.currentState, same(firstNavigator));
    expect(secondNavigator, isNot(same(firstNavigator)));
    expect(firstNavigator.mounted, isTrue);
    expect(secondNavigator.mounted, isTrue);
    expect(firstPage.mounted, isTrue);
    expect(firstPage.counter, 1);
    expect(find.byKey(secondPageKey), findsOneWidget);

    router.push('/first');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(firstNavigatorKey.currentState, same(firstNavigator));
    expect(secondNavigatorKey.currentState, same(secondNavigator));
    expect(firstNavigator.mounted, isTrue);
    expect(secondNavigator.mounted, isTrue);
    expect(firstPage.mounted, isTrue);
    expect(firstPage.counter, 1);
    expect(find.byType(DummyStatefulWidget), findsOneWidget);

    final DummyStatefulWidgetState pushedFirstPage = tester.state<DummyStatefulWidgetState>(
      find.byType(DummyStatefulWidget),
    );
    final NavigatorState pushedFirstNavigator = Navigator.of(pushedFirstPage.context);
    expect(pushedFirstPage, isNot(same(firstPage)));
    expect(pushedFirstNavigator, isNot(same(firstNavigator)));
    expect(pushedFirstNavigator, isNot(same(secondNavigator)));
    pushedFirstPage.increment();
    await tester.pump();
    expect(pushedFirstPage.counter, 1);

    // Recreate the full match list so the scoped shell keys are reconstructed
    // from the stable imperative page key.
    final codec = RouteMatchListCodec(router.configuration);
    final RouteMatchList restoredConfiguration = codec.decode(
      codec.encode(router.routerDelegate.currentConfiguration),
    );
    expect(restoredConfiguration, isNot(same(router.routerDelegate.currentConfiguration)));
    router.restore(restoredConfiguration);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.state<DummyStatefulWidgetState>(find.byType(DummyStatefulWidget)),
      same(pushedFirstPage),
    );
    expect(Navigator.of(pushedFirstPage.context), same(pushedFirstNavigator));

    router.refresh();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(firstNavigatorKey.currentState, same(firstNavigator));
    expect(secondNavigatorKey.currentState, same(secondNavigator));
    expect(pushedFirstPage.mounted, isTrue);
    expect(pushedFirstPage.counter, 1);

    router.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(secondNavigatorKey.currentState, same(secondNavigator));
    expect(secondNavigator.mounted, isTrue);
    expect(find.byKey(secondPageKey), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(firstNavigatorKey.currentState, same(firstNavigator));
    expect(firstNavigator.mounted, isTrue);
    expect(secondNavigatorKey.currentState, isNull);
    expect(secondNavigator.mounted, isFalse);
    expect(firstPage.mounted, isTrue);
    expect(firstPage.counter, 1);
    expect(find.byKey(secondPageKey), findsNothing);

    router.refresh();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(firstNavigatorKey.currentState, same(firstNavigator));
    expect(firstPage.mounted, isTrue);
    expect(firstPage.counter, 1);

    router.go('/second');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(secondNavigatorKey.currentState, isNotNull);
    expect(find.byKey(secondPageKey), findsOneWidget);
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
}

class _CollidingShellRoute extends ShellRoute {
  _CollidingShellRoute({
    required super.navigatorKey,
    required super.builder,
    required super.routes,
  });

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;
}

class _CollidingNavigatorKey extends GlobalKey<NavigatorState> {
  const _CollidingNavigatorKey(this._label) : super.constructor();

  final String _label;

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) => other is _CollidingNavigatorKey && other._label == _label;
}
