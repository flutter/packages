// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('back button works synchronously', (WidgetTester tester) async {
    bool allow = false;
    final UniqueKey home = UniqueKey();
    final UniqueKey page1 = UniqueKey();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: home),
        routes: <GoRoute>[
          GoRoute(
            path: '1',
            builder: (BuildContext context, GoRouterState state) =>
                DummyScreen(key: page1),
            onExit: (BuildContext context, GoRouterState state) {
              return allow;
            },
          )
        ],
      ),
    ];

    final GoRouter router =
        await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = true;
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('context.go works synchronously', (WidgetTester tester) async {
    bool allow = false;
    final UniqueKey home = UniqueKey();
    final UniqueKey page1 = UniqueKey();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: home),
      ),
      GoRoute(
        path: '/1',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: page1),
        onExit: (BuildContext context, GoRouterState state) {
          return allow;
        },
      )
    ];

    final GoRouter router =
        await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = true;
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('back button works asynchronously', (WidgetTester tester) async {
    Completer<bool> allow = Completer<bool>();
    final UniqueKey home = UniqueKey();
    final UniqueKey page1 = UniqueKey();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: home),
        routes: <GoRoute>[
          GoRoute(
            path: '1',
            builder: (BuildContext context, GoRouterState state) =>
                DummyScreen(key: page1),
            onExit: (BuildContext context, GoRouterState state) async {
              return allow.future;
            },
          )
        ],
      ),
    ];

    final GoRouter router =
        await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(false);
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = Completer<bool>();
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('context.go works asynchronously', (WidgetTester tester) async {
    Completer<bool> allow = Completer<bool>();
    final UniqueKey home = UniqueKey();
    final UniqueKey page1 = UniqueKey();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: home),
      ),
      GoRoute(
        path: '/1',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: page1),
        onExit: (BuildContext context, GoRouterState state) async {
          return allow.future;
        },
      )
    ];

    final GoRouter router =
        await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(false);
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = Completer<bool>();
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('android back button respects the last route.',
      (WidgetTester tester) async {
    bool allow = false;
    final UniqueKey home = UniqueKey();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: home),
        onExit: (BuildContext context, GoRouterState state) {
          return allow;
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);
    expect(find.byKey(home), findsOneWidget);

    // Not allow system pop.
    expect(await router.routerDelegate.popRoute(), true);

    allow = true;
    expect(await router.routerDelegate.popRoute(), false);
  });

  testWidgets('android back button respects the last route. async',
      (WidgetTester tester) async {
    bool allow = false;
    final UniqueKey home = UniqueKey();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: home),
        onExit: (BuildContext context, GoRouterState state) async {
          return allow;
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);
    expect(find.byKey(home), findsOneWidget);

    // Not allow system pop.
    expect(await router.routerDelegate.popRoute(), true);

    allow = true;
    expect(await router.routerDelegate.popRoute(), false);
  });

  testWidgets('android back button respects the last route with shell route.',
      (WidgetTester tester) async {
    bool allow = false;
    final UniqueKey home = UniqueKey();
    final List<RouteBase> routes = <RouteBase>[
      ShellRoute(builder: (_, __, Widget child) => child, routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              DummyScreen(key: home),
          onExit: (BuildContext context, GoRouterState state) {
            return allow;
          },
        ),
      ])
    ];

    final GoRouter router = await createRouter(routes, tester);
    expect(find.byKey(home), findsOneWidget);

    // Not allow system pop.
    expect(await router.routerDelegate.popRoute(), true);

    allow = true;
    expect(await router.routerDelegate.popRoute(), false);
  });

  testWidgets('It should provide the correct uri to the onExit callback',
      (WidgetTester tester) async {
    final UniqueKey home = UniqueKey();
    final UniqueKey page1 = UniqueKey();
    final UniqueKey page2 = UniqueKey();
    final UniqueKey page3 = UniqueKey();
    late final GoRouterState onExitState1;
    late final GoRouterState onExitState2;
    late final GoRouterState onExitState3;
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            DummyScreen(key: home),
        routes: <GoRoute>[
          GoRoute(
            path: '1',
            builder: (BuildContext context, GoRouterState state) =>
                DummyScreen(key: page1),
            onExit: (BuildContext context, GoRouterState state) {
              onExitState1 = state;
              return true;
            },
            routes: <GoRoute>[
              GoRoute(
                path: '2',
                builder: (BuildContext context, GoRouterState state) =>
                    DummyScreen(key: page2),
                onExit: (BuildContext context, GoRouterState state) {
                  onExitState2 = state;
                  return true;
                },
                routes: <GoRoute>[
                  GoRoute(
                    path: '3',
                    builder: (BuildContext context, GoRouterState state) =>
                        DummyScreen(key: page3),
                    onExit: (BuildContext context, GoRouterState state) {
                      onExitState3 = state;
                      return true;
                    },
                  )
                ],
              )
            ],
          )
        ],
      ),
    ];

    final GoRouter router =
        await createRouter(routes, tester, initialLocation: '/1/2/3');
    expect(find.byKey(page3), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page2), findsOneWidget);

    expect(onExitState3.uri.toString(), '/1/2/3');

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);
    expect(onExitState2.uri.toString(), '/1/2');

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
    expect(onExitState1.uri.toString(), '/1');
  });

  testWidgets(
    'It should provide the correct path parameters to the onExit callback',
    (WidgetTester tester) async {
      final UniqueKey page0 = UniqueKey();
      final UniqueKey page1 = UniqueKey();
      final UniqueKey page2 = UniqueKey();
      final UniqueKey page3 = UniqueKey();
      late final GoRouterState onExitState1;
      late final GoRouterState onExitState2;
      late final GoRouterState onExitState3;
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/route-0/:id0',
          builder: (BuildContext context, GoRouterState state) =>
              DummyScreen(key: page0),
        ),
        GoRoute(
          path: '/route-1/:id1',
          builder: (BuildContext context, GoRouterState state) =>
              DummyScreen(key: page1),
          onExit: (BuildContext context, GoRouterState state) {
            onExitState1 = state;
            return true;
          },
        ),
        GoRoute(
          path: '/route-2/:id2',
          builder: (BuildContext context, GoRouterState state) =>
              DummyScreen(key: page2),
          onExit: (BuildContext context, GoRouterState state) {
            onExitState2 = state;
            return true;
          },
        ),
        GoRoute(
          path: '/route-3/:id3',
          builder: (BuildContext context, GoRouterState state) {
            return DummyScreen(key: page3);
          },
          onExit: (BuildContext context, GoRouterState state) {
            onExitState3 = state;
            return true;
          },
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/route-0/0?param0=0',
      );
      unawaited(router.push('/route-1/1?param1=1'));
      unawaited(router.push('/route-2/2?param2=2'));
      unawaited(router.push('/route-3/3?param3=3'));

      await tester.pumpAndSettle();
      expect(find.byKey(page3), findsOne);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byKey(page2), findsOne);
      expect(onExitState3.uri.toString(), '/route-3/3?param3=3');
      expect(onExitState3.pathParameters, const <String, String>{'id3': '3'});
      expect(onExitState3.fullPath, '/route-3/:id3');

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byKey(page1), findsOne);
      expect(onExitState2.uri.toString(), '/route-2/2?param2=2');
      expect(onExitState2.pathParameters, const <String, String>{'id2': '2'});
      expect(onExitState2.fullPath, '/route-2/:id2');

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byKey(page0), findsOne);
      expect(onExitState1.uri.toString(), '/route-1/1?param1=1');
      expect(onExitState1.pathParameters, const <String, String>{'id1': '1'});
      expect(onExitState1.fullPath, '/route-1/:id1');
    },
  );

  testWidgets(
    'It should provide the correct path parameters to the onExit callback during a go',
    (WidgetTester tester) async {
      final UniqueKey page0 = UniqueKey();
      final UniqueKey page1 = UniqueKey();
      final UniqueKey page2 = UniqueKey();
      final UniqueKey page3 = UniqueKey();
      late final GoRouterState onExitState0;
      late final GoRouterState onExitState1;
      late final GoRouterState onExitState2;
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/route-0/:id0',
          builder: (BuildContext context, GoRouterState state) =>
              DummyScreen(key: page0),
          onExit: (BuildContext context, GoRouterState state) {
            onExitState0 = state;
            return true;
          },
        ),
        GoRoute(
          path: '/route-1/:id1',
          builder: (BuildContext context, GoRouterState state) =>
              DummyScreen(key: page1),
          onExit: (BuildContext context, GoRouterState state) {
            onExitState1 = state;
            return true;
          },
        ),
        GoRoute(
          path: '/route-2/:id2',
          builder: (BuildContext context, GoRouterState state) =>
              DummyScreen(key: page2),
          onExit: (BuildContext context, GoRouterState state) {
            onExitState2 = state;
            return true;
          },
        ),
        GoRoute(
          path: '/route-3/:id3',
          builder: (BuildContext context, GoRouterState state) {
            return DummyScreen(key: page3);
          },
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/route-0/0?param0=0',
      );
      expect(find.byKey(page0), findsOne);

      router.go('/route-1/1?param1=1');
      await tester.pumpAndSettle();
      expect(find.byKey(page1), findsOne);
      expect(onExitState0.uri.toString(), '/route-0/0?param0=0');
      expect(onExitState0.pathParameters, const <String, String>{'id0': '0'});
      expect(onExitState0.fullPath, '/route-0/:id0');

      router.go('/route-2/2?param2=2');
      await tester.pumpAndSettle();
      expect(find.byKey(page2), findsOne);
      expect(onExitState1.uri.toString(), '/route-1/1?param1=1');
      expect(onExitState1.pathParameters, const <String, String>{'id1': '1'});
      expect(onExitState1.fullPath, '/route-1/:id1');

      router.go('/route-3/3?param3=3');
      await tester.pumpAndSettle();
      expect(find.byKey(page3), findsOne);
      expect(onExitState2.uri.toString(), '/route-2/2?param2=2');
      expect(onExitState2.pathParameters, const <String, String>{'id2': '2'});
      expect(onExitState2.fullPath, '/route-2/:id2');
    },
  );
}
