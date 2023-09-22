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
            onExit: (BuildContext context) {
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
        onExit: (BuildContext context) {
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
            onExit: (BuildContext context) async {
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
        onExit: (BuildContext context) async {
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
}
