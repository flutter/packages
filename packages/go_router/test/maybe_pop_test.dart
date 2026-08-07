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
      final router = GoRouter(
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

    testWidgets('does not consult onExit when every navigator bubbles', (
      WidgetTester tester,
    ) async {
      var onExitCalled = false;
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            onExit: (_, _) {
              onExitCalled = true;
              return true;
            },
            builder: (_, _) => const Text('Home'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(await router.maybePop(), isFalse);
      expect(onExitCalled, isFalse);
      expect(find.text('Home'), findsOneWidget);
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
      final state = router.routeInformationProvider.value.state! as RouteInformationState<void>;
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
      final key = GlobalKey<State<StatefulWidget>>();
      final router = GoRouter(
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
      final key = GlobalKey<State<StatefulWidget>>();
      final router = GoRouter(
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
      final key = GlobalKey<State<StatefulWidget>>();
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          GoRoute(
            path: '/a',
            builder: (_, _) => PopScope(canPop: false, child: Text('A', key: key)),
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

  group('shell and nested navigators', () {
    testWidgets('falls through to parent when shell leaf bubbles', (WidgetTester tester) async {
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, _, Widget child) => child,
            routes: <GoRoute>[GoRoute(path: '/a', builder: (_, _) => const Text('A'))],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(shellNavigatorKey.currentState?.canPop(), isFalse);
      expect(router.canPop(), isTrue);

      // Local Navigator stays on the shell; GoRouter falls through like pop().
      expect(await shellNavigatorKey.currentState!.maybePop(), isFalse);
      expect(await router.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('honors PopScope on shell leaf when shell canPop is false', (
      WidgetTester tester,
    ) async {
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, _, Widget child) => child,
            routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (_, _) => const PopScope(canPop: false, child: Text('A')),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(shellNavigatorKey.currentState?.canPop(), isFalse);
      expect(router.canPop(), isTrue);

      // Must consult shell maybePop (doNotPop) before falling through to root.
      expect(await router.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Home'), findsNothing);

      // pop() still forces the parent pop by filtering on canPop.
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('pops the innermost navigator without touching parent history', (
      WidgetTester tester,
    ) async {
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, _, Widget child) => child,
            routes: <GoRoute>[
              GoRoute(path: '/a', builder: (_, _) => const Text('A')),
              GoRoute(path: '/b', builder: (_, _) => const Text('B')),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      router.push('/b');
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(shellNavigatorKey.currentState?.canPop(), isTrue);

      expect(await router.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(shellNavigatorKey.currentState?.canPop(), isFalse);
    });

    testWidgets('PopScope veto on inner shell page does not fall through', (
      WidgetTester tester,
    ) async {
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, _, Widget child) => child,
            routes: <GoRoute>[
              GoRoute(path: '/a', builder: (_, _) => const Text('A')),
              GoRoute(
                path: '/b',
                builder: (_, _) => const PopScope(canPop: false, child: Text('B')),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      router.push('/b');
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(shellNavigatorKey.currentState?.canPop(), isTrue);

      expect(await router.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('dismisses a dialog above a shell route', (WidgetTester tester) async {
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final GlobalKey screenKey = GlobalKey();
      final router = GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, _, Widget child) => child,
            routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (_, _) => Text('A', key: screenKey),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();

      showDialog<void>(
        context: screenKey.currentContext!,
        builder: (_) => const AlertDialog(content: Text('Dialog')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsOneWidget);

      expect(await router.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsNothing);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('falls through from StatefulShellRoute branch leaf like pop', (
      WidgetTester tester,
    ) async {
      final rootKey = GlobalKey<NavigatorState>();
      final branchAKey = GlobalKey<NavigatorState>();
      final branchBKey = GlobalKey<NavigatorState>();

      final router = GoRouter(
        initialLocation: '/',
        navigatorKey: rootKey,
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          StatefulShellRoute.indexedStack(
            builder: (_, _, StatefulNavigationShell navigationShell) => navigationShell,
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                navigatorKey: branchAKey,
                routes: <RouteBase>[GoRoute(path: '/a', builder: (_, _) => const Text('A'))],
              ),
              StatefulShellBranch(
                navigatorKey: branchBKey,
                routes: <RouteBase>[GoRoute(path: '/b', builder: (_, _) => const Text('B'))],
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(branchAKey.currentState!.canPop(), isFalse);
      expect(router.canPop(), isTrue);

      expect(await router.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('system back leaves a shell leaf via popRoute', (WidgetTester tester) async {
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, _, Widget child) => child,
            routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (_, _) => Scaffold(
                  appBar: AppBar(title: const Text('A')),
                  body: const Text('A body'),
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      expect(router.canPop(), isTrue);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
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
