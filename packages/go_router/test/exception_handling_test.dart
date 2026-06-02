// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('throws if more than one exception handlers are provided.', (
    WidgetTester tester,
  ) async {
    var thrown = false;
    try {
      GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, GoRouterState state) => const Text('home'),
          ),
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
            builder: (_, GoRouterState state) => const Text('home'),
          ),
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
            builder: (_, GoRouterState state) => const Text('home'),
          ),
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
      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
            path: '/error',
            builder: (_, GoRouterState state) =>
                Text('redirected ${state.extra}'),
          ),
        ],
        tester,
        onException: (_, GoRouterState state, GoRouter router) =>
            router.go('/error', extra: state.uri.toString()),
      );
      expect(find.text('redirected /'), findsOneWidget);

      router.go('/some-other-location');
      await tester.pumpAndSettle();
      expect(find.text('redirected /some-other-location'), findsOneWidget);
    });

    testWidgets('can redirect with extra', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
            path: '/error',
            builder: (_, GoRouterState state) => Text('extra: ${state.extra}'),
          ),
        ],
        tester,
        onException: (_, GoRouterState state, GoRouter router) =>
            router.go('/error', extra: state.extra),
      );
      expect(find.text('extra: null'), findsOneWidget);

      router.go('/some-other-location', extra: 'X');
      await tester.pumpAndSettle();
      expect(find.text('extra: X'), findsOneWidget);
    });

    testWidgets('stays on the same page if noop.', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, GoRouterState state) => const Text('home'),
          ),
        ],
        tester,
        onException: (_, __, ___) {},
      );
      expect(find.text('home'), findsOneWidget);

      router.go('/some-other-location');
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('can catch errors thrown in redirect callbacks', (
      WidgetTester tester,
    ) async {
      var exceptionCaught = false;
      String? errorMessage;

      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, GoRouterState state) => const Text('home'),
          ),
          GoRoute(
            path: '/error-page',
            builder: (_, GoRouterState state) =>
                Text('error handled: ${state.extra}'),
          ),
          GoRoute(
            path: '/trigger-error',
            builder: (_, GoRouterState state) =>
                const Text('should not reach here'),
          ),
        ],
        tester,
        redirect: (BuildContext context, GoRouterState state) {
          if (state.matchedLocation == '/trigger-error') {
            // Simulate an error in redirect callback
            throw Exception('Redirect error occurred');
          }
          return null;
        },
        onException:
            (BuildContext context, GoRouterState state, GoRouter router) {
              exceptionCaught = true;
              errorMessage = 'Caught exception for ${state.uri}';
              router.go('/error-page', extra: errorMessage);
            },
      );

      expect(find.text('home'), findsOneWidget);
      expect(exceptionCaught, isFalse);

      // Navigate to a route that will trigger an error in the redirect callback
      router.go('/trigger-error');
      await tester.pumpAndSettle();

      // Verify the exception was caught and handled
      expect(exceptionCaught, isTrue);
      expect(errorMessage, isNotNull);
      expect(
        find.text('error handled: Caught exception for /trigger-error'),
        findsOneWidget,
      );
      expect(find.text('should not reach here'), findsNothing);
    });

    testWidgets('can catch non-GoException errors thrown in redirect callbacks', (
      WidgetTester tester,
    ) async {
      var exceptionCaught = false;

      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, GoRouterState state) => const Text('home'),
          ),
          GoRoute(
            path: '/error-page',
            builder: (_, GoRouterState state) =>
                const Text('generic error handled'),
          ),
          GoRoute(
            path: '/trigger-runtime-error',
            builder: (_, GoRouterState state) =>
                const Text('should not reach here'),
          ),
        ],
        tester,
        redirect: (BuildContext context, GoRouterState state) {
          if (state.matchedLocation == '/trigger-runtime-error') {
            // Simulate a runtime error (not GoException)
            throw StateError('Runtime error in redirect');
          }
          return null;
        },
        onException:
            (BuildContext context, GoRouterState state, GoRouter router) {
              exceptionCaught = true;
              router.go('/error-page');
            },
      );

      expect(find.text('home'), findsOneWidget);
      expect(exceptionCaught, isFalse);

      // Navigate to a route that will trigger a runtime error in the redirect callback
      router.go('/trigger-runtime-error');
      await tester.pumpAndSettle();

      // Verify the exception was caught and handled
      expect(exceptionCaught, isTrue);
      expect(find.text('generic error handled'), findsOneWidget);
      expect(find.text('should not reach here'), findsNothing);
    });
  });
}
