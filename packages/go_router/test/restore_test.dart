// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  group('RouteInformationState.restore', () {
    test('uses base extra when extra is not provided', () {
      final base = RouteMatchList(
        matches: const <RouteMatchBase>[],
        uri: Uri.parse('/home'),
        pathParameters: const <String, String>{},
        extra: 'base-extra',
      );

      final RouteInformationState<void> state = RouteInformationState.restore(base: base);

      expect(state.type, NavigatingType.restore);
      expect(state.baseRouteMatchList, base);
      expect(state.extra, 'base-extra');
      expect(state.completer, isNull);
    });

    test('allows overriding extra', () {
      final base = RouteMatchList(
        matches: const <RouteMatchBase>[],
        uri: Uri.parse('/home'),
        pathParameters: const <String, String>{},
        extra: 'base-extra',
      );

      final RouteInformationState<void> state = RouteInformationState.restore(
        base: base,
        extra: 'override-extra',
      );

      expect(state.extra, 'override-extra');
    });
  });

  group('GoRouteInformationProvider.restore', () {
    testWidgets('updates value with restore navigation type', (WidgetTester tester) async {
      final provider = GoRouteInformationProvider(initialLocation: '/', initialExtra: null);
      addTearDown(provider.dispose);

      final router = GoRouter(
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          GoRoute(path: '/a', builder: (_, _) => const Text('A')),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      final RouteMatchList matchList = router.routerDelegate.currentConfiguration;

      var notified = false;
      provider.addListener(() => notified = true);
      provider.restore(matchList.uri.toString(), matchList: matchList);

      expect(notified, isTrue);
      final state = provider.value.state! as RouteInformationState<void>;
      expect(state.type, NavigatingType.restore);
      expect(state.baseRouteMatchList, matchList);
      expect(state.extra, matchList.extra);
      expect(provider.value.uri, matchList.uri);
    });
  });

  group('GoRouter.restore', () {
    testWidgets('syncs routeInformationProvider with the given match list', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          GoRoute(path: '/a', builder: (_, _) => const Text('A')),
          GoRoute(path: '/b', builder: (_, _) => const Text('B')),
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

      final RouteMatchList twoDeep = router.routerDelegate.currentConfiguration;
      expect(twoDeep.matches.length, 3);

      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      router.restore(twoDeep);
      final stateAfterRestore =
          router.routeInformationProvider.value.state! as RouteInformationState<void>;
      expect(stateAfterRestore.type, NavigatingType.restore);
      await tester.pumpAndSettle();

      expect(find.text('B'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 3);
    });

    testWidgets('is called when routing config changes', (WidgetTester tester) async {
      final config = ValueNotifier<RoutingConfig>(
        RoutingConfig(
          routes: <RouteBase>[
            GoRoute(path: '/', builder: (_, _) => const Text('Home v1')),
            GoRoute(path: '/a', builder: (_, _) => const Text('A v1')),
          ],
        ),
      );
      addTearDown(config.dispose);

      final GoRouter router = await createRouterWithRoutingConfig(config, tester);
      router.push('/a');
      await tester.pumpAndSettle();
      expect(find.text('A v1'), findsOneWidget);

      config.value = RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('Home v2')),
          GoRoute(path: '/a', builder: (_, _) => const Text('A v2')),
        ],
      );
      final stateAfterConfigChange =
          router.routeInformationProvider.value.state! as RouteInformationState<void>;
      expect(stateAfterConfigChange.type, NavigatingType.restore);
      await tester.pumpAndSettle();

      expect(find.text('A v2'), findsOneWidget);
    });

    testWidgets('StatefulShellRoute goBranch restores the branch match list', (
      WidgetTester tester,
    ) async {
      StatefulNavigationShell? navigationShell;
      final router = GoRouter(
        initialLocation: '/a',
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (_, _, StatefulNavigationShell shell) {
              navigationShell = shell;
              return shell;
            },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <GoRoute>[GoRoute(path: '/a', builder: (_, _) => const Text('Branch A'))],
              ),
              StatefulShellBranch(
                routes: <GoRoute>[GoRoute(path: '/b', builder: (_, _) => const Text('Branch B'))],
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Branch A'), findsOneWidget);

      navigationShell!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Branch B'), findsOneWidget);

      navigationShell!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Branch A'), findsOneWidget);

      navigationShell!.goBranch(1);
      final stateAfterBranch =
          router.routeInformationProvider.value.state! as RouteInformationState<void>;
      expect(stateAfterBranch.type, NavigatingType.restore);
      await tester.pumpAndSettle();
      expect(find.text('Branch B'), findsOneWidget);
    });
  });

  group('GoRouter.pop restore integration', () {
    testWidgets('context.pop calls restore and syncs provider after push', (
      WidgetTester tester,
    ) async {
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

      router.push('/a');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/home');

      router.pop();
      final stateAfterPop =
          router.routeInformationProvider.value.state! as RouteInformationState<void>;
      expect(stateAfterPop.type, NavigatingType.restore);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 1);
    });

    testWidgets('Navigator.pop updates stack but context.pop restores provider URL', (
      WidgetTester tester,
    ) async {
      GoRouter.optionURLReflectsImperativeAPIs = true;
      addTearDown(() => GoRouter.optionURLReflectsImperativeAPIs = false);

      final router = GoRouter(
        initialLocation: '/home',
        routes: <GoRoute>[
          GoRoute(path: '/home', builder: (_, _) => const Text('Home')),
          GoRoute(path: '/a', builder: (_, _) => const Text('A')),
          GoRoute(path: '/b', builder: (_, _) => const Text('B')),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/a');
      await tester.pumpAndSettle();
      router.push('/b');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/b');

      Navigator.of(tester.element(find.text('B'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 2);

      router.pop();
      final stateAfterGoRouterPop =
          router.routeInformationProvider.value.state! as RouteInformationState<void>;
      expect(stateAfterGoRouterPop.type, NavigatingType.restore);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/home');
    });

    testWidgets('does not call restore synchronously when onExit defers pop', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, _) => const Text('Home'),
            routes: <RouteBase>[
              GoRoute(
                path: 'detail',
                onExit: (_, _) async {
                  await Future<void>.delayed(Duration.zero);
                  return true;
                },
                builder: (_, _) => const Text('Detail'),
              ),
            ],
          ),
        ],
        tester,
        initialLocation: '/detail',
      );

      final RouteMatchList beforePop = router.routerDelegate.currentConfiguration;
      router.pop();
      // Pop is deferred; configuration should be unchanged synchronously.
      expect(identical(router.routerDelegate.currentConfiguration, beforePop), isTrue);

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('GoRouteInformationParser restore', () {
    testWidgets('keeps imperative stack when restore URIs match', (WidgetTester tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) => const Text('Home'),
            routes: <GoRoute>[GoRoute(path: 'a', builder: (_, _) => const Text('A'))],
          ),
        ],
        tester,
        navigatorKey: navKey,
      );

      router.push('/a');
      await tester.pumpAndSettle();
      final RouteMatchList imperativeStack = router.routerDelegate.currentConfiguration;
      expect(imperativeStack.matches.length, 2);

      final BuildContext context = navKey.currentContext!;
      final RouteMatchList restored = await router.routeInformationParser
          .parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/'),
              state: RouteInformationState<void>(
                type: NavigatingType.restore,
                baseRouteMatchList: imperativeStack,
              ),
            ),
            context,
          );

      expect(restored.matches.length, 2);
      expect(restored.uri.path, '/');
    });

    testWidgets('uses new matches when restore URI differs from base', (WidgetTester tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(path: '/home', builder: (_, _) => const Text('Home')),
          GoRoute(path: '/a', builder: (_, _) => const Text('A')),
        ],
        tester,
        initialLocation: '/home',
        navigatorKey: navKey,
      );

      final RouteMatchList homeOnly = router.routerDelegate.currentConfiguration;
      final BuildContext context = navKey.currentContext!;

      final RouteMatchList restored = await router.routeInformationParser
          .parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/a'),
              state: RouteInformationState<void>(
                type: NavigatingType.restore,
                baseRouteMatchList: homeOnly,
              ),
            ),
            context,
          );

      expect(restored.uri.path, '/a');
      expect(restored.matches.length, 1);
      expect(restored.matches.last.matchedLocation, '/a');
    });

    testWidgets('decodes encoded match list state from browser back-forward', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await createRouter(<GoRoute>[
        GoRoute(path: '/', builder: (_, _) => const Text('Home')),
        GoRoute(path: '/a', builder: (_, _) => const Text('A')),
      ], tester);

      router.push('/a');
      await tester.pumpAndSettle();
      final RouteMatchList matchList = router.routerDelegate.currentConfiguration;
      final RouteInformation encoded = router.routeInformationParser.restoreRouteInformation(
        matchList,
      )!;

      expect(encoded.state, isNot(isA<RouteInformationState>()));

      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      router.routeInformationProvider.didPushRouteInformation(encoded);
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 2);
    });

    testWidgets('restoreRouteInformation round-trips imperative stack', (
      WidgetTester tester,
    ) async {
      GoRouter.optionURLReflectsImperativeAPIs = true;
      addTearDown(() => GoRouter.optionURLReflectsImperativeAPIs = false);

      final navKey = GlobalKey<NavigatorState>();
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) => const Text('Home'),
            routes: <GoRoute>[GoRoute(path: 'a', builder: (_, _) => const Text('A'))],
          ),
        ],
        tester,
        navigatorKey: navKey,
      );

      router.go('/a');
      await tester.pumpAndSettle();
      router.push('/');
      await tester.pumpAndSettle();

      final RouteMatchList original = router.routerDelegate.currentConfiguration;
      final RouteInformation routeInformation = router.routeInformationParser
          .restoreRouteInformation(original)!;

      final RouteMatchList parsed = await router.routeInformationParser
          .parseRouteInformationWithDependencies(routeInformation, navKey.currentContext!);

      expect(parsed.uri.toString(), original.uri.toString());
      expect(parsed.matches.length, original.matches.length);
    });
  });
}
