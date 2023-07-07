// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('throws if more than one exception handlers are provided.',
      (WidgetTester tester) async {
    bool thrown = false;
    try {
      GoRouter(
        routes: <RouteBase>[
          GoRoute(
              path: '/',
              builder: (_, GoRouterState state) => const Text('home')),
        ],
        errorBuilder: (_, __) => const Text(''),
        onException: (_, __, ___) {},
      );
    } on Error {
      thrown = true;
    }
    expect(thrown, true);

    thrown = false;
    try {
      GoRouter(
        routes: <RouteBase>[
          GoRoute(
              path: '/',
              builder: (_, GoRouterState state) => const Text('home')),
        ],
        errorBuilder: (_, __) => const Text(''),
        errorPageBuilder: (_, __) => const MaterialPage<void>(child: Text('')),
      );
    } on Error {
      thrown = true;
    }
    expect(thrown, true);

    thrown = false;
    try {
      GoRouter(
        routes: <RouteBase>[
          GoRoute(
              path: '/',
              builder: (_, GoRouterState state) => const Text('home')),
        ],
        onException: (_, __, ___) {},
        errorPageBuilder: (_, __) => const MaterialPage<void>(child: Text('')),
      );
    } on Error {
      thrown = true;
    }
    expect(thrown, true);
  });

  group('onException', () {
    testWidgets('can redirect.', (WidgetTester tester) async {
      final GoRouter router = await createRouter(<RouteBase>[
        GoRoute(
            path: '/error',
            builder: (_, GoRouterState state) =>
                Text('redirected ${state.extra}')),
      ], tester,
          onException: (_, GoRouterState state, GoRouter router) =>
              router.go('/error', extra: state.location));
      expect(find.text('redirected /'), findsOneWidget);

      router.go('/some-other-location');
      await tester.pumpAndSettle();
      expect(find.text('redirected /some-other-location'), findsOneWidget);
    });

    testWidgets('stays on the same page if noop.', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
              path: '/',
              builder: (_, GoRouterState state) => const Text('home')),
        ],
        tester,
        onException: (_, __, ___) {},
      );
      expect(find.text('home'), findsOneWidget);

      router.go('/some-other-location');
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
    });
  });
}
