// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('push retains extra through an async mixed redirect chain', (tester) async {
    final payload = Object();
    final seen = <Object?>[];
    final GoRouter router = await createRouter(
      <GoRoute>[
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/middle',
          redirect: (_, state) {
            seen.add(state.extra);
            return '/end';
          },
        ),
        GoRoute(
          path: '/end',
          builder: (_, state) {
            seen.add(state.extra);
            return const LoginScreen();
          },
        ),
      ],
      tester,
      redirect: (_, state) async => state.uri.path == '/start' ? '/middle' : null,
    );

    unawaited(router.push<void>('/start', extra: payload));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(seen, isNotEmpty);
    expect(seen, everyElement(same(payload)));

    seen.clear();
    router.go('/end');
    await tester.pumpAndSettle();
    expect(seen, isNotEmpty);
    expect(seen, everyElement(isNull));
  });

  for (final target in <String>['/missing', '/loop']) {
    testWidgets('redirect to $target retains extra for onException recovery', (tester) async {
      final payload = Object();
      Object? errorExtra;
      String? errorMessage;
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/start', redirect: (_, _) => target),
          GoRoute(path: '/loop', redirect: (_, _) => '/start'),
          GoRoute(path: '/error', builder: (_, _) => const Text('Routing error')),
        ],
        tester,
        onException: (_, state, router) {
          errorExtra = state.extra;
          errorMessage = state.error.toString();
          router.go('/error');
        },
      );

      router.go('/start', extra: payload);
      await tester.pumpAndSettle();
      expect(find.text('Routing error'), findsOneWidget);
      expect(errorExtra, same(payload));
      expect(errorMessage, contains(target == '/loop' ? 'redirect loop' : 'no routes'));
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  }
}
