// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('back button respects PopScope', (WidgetTester tester) async {
    final UniqueKey home = UniqueKey();

    bool onPopCalled = false;

    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            onPopCalled = true;
          },
          child: DummyScreen(key: home),
        ),
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);

    expect(await router.routerDelegate.popRoute(), true);
    await tester.pumpAndSettle();

    expect(onPopCalled, isTrue);

    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('back button is respects PopScope in ShellRoute',
      (WidgetTester tester) async {
    bool onPopCalled = false;

    final UniqueKey home = UniqueKey();

    final List<RouteBase> routes = <RouteBase>[
      ShellRoute(
        builder: (BuildContext contex, GoRouterState state, Widget child) =>
            child,
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (bool didPop, Object? result) {
                onPopCalled = true;
              },
              child: DummyScreen(key: home),
            ),
          ),
        ],
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);

    expect(await router.routerDelegate.popRoute(), true);
    await tester.pumpAndSettle();

    expect(onPopCalled, isTrue);

    expect(find.byKey(home), findsOneWidget);
  });
}
