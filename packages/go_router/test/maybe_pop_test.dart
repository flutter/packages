// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  group('GoRouter.maybePop', () {
    Future<GoRouter> pumpRouter(WidgetTester tester) async {
      final GoRouter router = GoRouter(
        initialLocation: '/home',
        routes: <GoRoute>[
          GoRoute(path: '/home', builder: (_, _) => const Text('Home')),
          GoRoute(path: '/a', builder: (_, _) => const Text('A')),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('returns false without throwing when there is nothing to pop', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpRouter(tester);

      expect(router.canPop(), isFalse);
      expect(await router.maybePop(), isFalse);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('returns false after go when there is no pop stack', (WidgetTester tester) async {
      final GoRouter router = await pumpRouter(tester);

      router.go('/a');
      await tester.pumpAndSettle();

      expect(router.canPop(), isFalse);
      expect(await router.maybePop(), isFalse);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('returns true and pops after push', (WidgetTester tester) async {
      final GoRouter router = await pumpRouter(tester);

      router.push('/a');
      await tester.pumpAndSettle();
      expect(router.canPop(), isTrue);

      expect(await router.maybePop(), isTrue);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });

    testWidgets('calls restore when pop completes synchronously', (WidgetTester tester) async {
      final GoRouter router = await pumpRouter(tester);

      router.push('/a');
      await tester.pumpAndSettle();

      expect(await router.maybePop(), isTrue);
      final RouteInformationState<void> state =
          router.routeInformationProvider.value.state! as RouteInformationState<void>;
      expect(state.type, NavigatingType.restore);
      await tester.pumpAndSettle();
    });

    testWidgets('pop still throws when there is nothing to pop', (WidgetTester tester) async {
      final GoRouter router = await pumpRouter(tester);
      expect(router.pop, throwsA(isA<GoError>()));
    });
  });

  group('context.maybePop', () {
    testWidgets('returns false on root route like BackButton would no-op', (
      WidgetTester tester,
    ) async {
      final GlobalKey<State<StatefulWidget>> key = GlobalKey<State<StatefulWidget>>();
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              key: key,
              appBar: AppBar(title: const Text('Home')),
              body: const Text('Home body'),
            ),
          ),
          GoRoute(
            path: '/a',
            builder: (_, _) => Scaffold(
              appBar: AppBar(title: const Text('A')),
              body: const Text('A body'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(await key.currentContext!.maybePop(), isFalse);
      expect(find.text('Home body'), findsOneWidget);
    });

    testWidgets('pops after push like BackButton', (WidgetTester tester) async {
      final GlobalKey<State<StatefulWidget>> key = GlobalKey<State<StatefulWidget>>();
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              key: key,
              appBar: AppBar(title: const Text('Home')),
              body: const Text('Home body'),
            ),
          ),
          GoRoute(
            path: '/a',
            builder: (_, _) => Scaffold(
              appBar: AppBar(title: const Text('A')),
              body: const Text('A body'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      expect(find.text('A body'), findsOneWidget);

      expect(await key.currentContext!.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Home body'), findsOneWidget);
    });

    testWidgets('matches Navigator.maybePop when PopScope blocks the pop', (
      WidgetTester tester,
    ) async {
      final GlobalKey<State<StatefulWidget>> key = GlobalKey<State<StatefulWidget>>();
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          GoRoute(
            path: '/a',
            builder: (_, _) => PopScope(
              canPop: false,
              child: Text('A', key: key),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.push('/a');
      await tester.pumpAndSettle();

      final BuildContext context = key.currentContext!;
      final bool navigatorDidPop = await Navigator.of(context).maybePop();
      final bool goRouterDidPop = await context.maybePop();
      expect(goRouterDidPop, navigatorDidPop);
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('GoRouterDelegate.maybePop', () {
    testWidgets('delegates to Navigator.maybePop', (WidgetTester tester) async {
      final GoRouter router = await createRouter(<RouteBase>[
        GoRoute(path: '/', builder: (_, _) => const Text('Home')),
        GoRoute(path: '/a', builder: (_, _) => const Text('A')),
      ], tester);

      router.push('/a');
      await tester.pumpAndSettle();

      expect(await router.routerDelegate.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(await router.routerDelegate.maybePop(), isFalse);
    });
  });
}
