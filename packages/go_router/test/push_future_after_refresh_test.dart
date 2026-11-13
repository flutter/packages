// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  final routes = <RouteBase>[
    GoRoute(
      path: '/',
      builder: (_, _) => const Text('home'),
      routes: <RouteBase>[GoRoute(path: 'a', builder: (_, _) => const Text('a'))],
    ),
    GoRoute(path: '/b', builder: (_, _) => const Text('b')),
  ];

  testWidgets('push completes with the value of a pop after a refresh', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await createRouter(routes, tester);
    String? result;
    router.push<String>('/a').then((String? value) => result = value);
    await tester.pumpAndSettle();

    router.refresh();
    await tester.pumpAndSettle();
    expect(find.text('a'), findsOneWidget);

    router.pop('closed');
    await tester.pumpAndSettle();
    expect(result, 'closed');
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('push completes after a refreshListenable notifies twice', (
    WidgetTester tester,
  ) async {
    final refresh = ValueNotifier<int>(0);
    addTearDown(refresh.dispose);
    final router = GoRouter(routes: routes, refreshListenable: refresh);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    String? result;
    router.push<String>('/a').then((String? value) => result = value);
    await tester.pumpAndSettle();

    refresh.value++;
    await tester.pumpAndSettle();
    refresh.value++;
    await tester.pumpAndSettle();

    router.pop('closed');
    await tester.pumpAndSettle();
    expect(result, 'closed');
  });

  testWidgets('each of two pushed pages keeps its own future after a refresh', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await createRouter(routes, tester);
    String? first;
    String? second;
    router.push<String>('/a').then((String? v) => first = v);
    await tester.pumpAndSettle();
    router.push<String>('/b').then((String? v) => second = v);
    await tester.pumpAndSettle();

    router.refresh();
    await tester.pumpAndSettle();

    router.pop('from b');
    await tester.pumpAndSettle();
    expect(second, 'from b');
    expect(first, isNull);

    router.pop('from a');
    await tester.pumpAndSettle();
    expect(first, 'from a');
  });

  testWidgets('a page in a shell keeps its future after a refresh', (WidgetTester tester) async {
    final GoRouter router = await createRouter(<RouteBase>[
      ShellRoute(
        builder: (_, _, Widget child) => Scaffold(body: child),
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/a', builder: (_, _) => const Text('a')),
        ],
      ),
    ], tester);
    String? result;
    router.push<String>('/a').then((String? value) => result = value);
    await tester.pumpAndSettle();

    router.refresh();
    await tester.pumpAndSettle();

    router.pop('closed');
    await tester.pumpAndSettle();
    expect(result, 'closed');
  });

  testWidgets('a refresh that changes nothing does not notify the delegate', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await createRouter(routes, tester);
    router.push<String>('/a').ignore();
    await tester.pumpAndSettle();

    var notified = 0;
    void listener() => notified++;
    router.routerDelegate.addListener(listener);
    addTearDown(() => router.routerDelegate.removeListener(listener));

    router.refresh();
    await tester.pumpAndSettle();
    expect(notified, 0);
  });

  testWidgets('a pop right after a refresh closes the page', (WidgetTester tester) async {
    final GoRouter router = await createRouter(routes, tester);
    String? result;
    router.push<String>('/a').then((String? value) => result = value);
    await tester.pumpAndSettle();

    router.refresh();
    router.pop('closed');
    await tester.pumpAndSettle();

    expect(result, 'closed');
    expect(find.text('a'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  for (final frameBetween in <bool>[false, true]) {
    testWidgets('a page closed during the redirect of a refresh stays closed, '
        '${frameBetween ? 'with' : 'without'} a frame between the two', (
      WidgetTester tester,
    ) async {
      const redirectTime = Duration(milliseconds: 100);
      var redirectWaits = false;
      final GoRouter router = await createRouter(
        routes,
        tester,
        redirect: (_, _) => redirectWaits ? Future<String?>.delayed(redirectTime) : null,
      );
      String? result;
      router.push<String>('/a').then((String? value) => result = value);
      await tester.pumpAndSettle();

      redirectWaits = true;
      router.refresh();
      tester.state<NavigatorState>(find.byType(Navigator)).pop('closed');
      if (frameBetween) {
        await tester.pump();
      }
      await tester.pump(redirectTime);
      await tester.pumpAndSettle();

      expect(result, 'closed');
      expect(find.text('a'), findsNothing);
      expect(find.text('home'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches, hasLength(1));
    });
  }
}
