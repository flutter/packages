import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('GoRouter onEnter navigation control tests', () {
    late GoRouter router;

    tearDown(() async {
      router.dispose();
    });

    testWidgets(
      'Initial route calls onEnter and sets current/next state correctly',
      (WidgetTester tester) async {
        GoRouterState? capturedCurrentState;
        GoRouterState? capturedNextState;
        int onEnterCallCount = 0;

        router = GoRouter(
          initialLocation: '/',
          onEnter: (
            BuildContext context,
            GoRouterState current,
            GoRouterState next,
            GoRouter goRouter,
          ) async {
            onEnterCallCount++;
            capturedCurrentState = current;
            capturedNextState = next;
            return true;
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (_, __) => const Placeholder(),
              routes: <GoRoute>[
                GoRoute(
                  path: 'allowed',
                  builder: (_, __) => const Placeholder(),
                ),
                GoRoute(
                  path: 'blocked',
                  builder: (_, __) => const Placeholder(),
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(onEnterCallCount, equals(1));
        expect(
          capturedCurrentState?.uri.path,
          capturedNextState?.uri.path,
        );
      },
    );

    testWidgets(
      'Navigation is blocked correctly when onEnter returns false',
      (WidgetTester tester) async {
        final List<String> navigationAttempts = <String>[];
        String currentPath = '/';

        router = GoRouter(
          initialLocation: '/',
          onEnter: (
            BuildContext context,
            GoRouterState current,
            GoRouterState next,
            GoRouter goRouter,
          ) async {
            navigationAttempts.add(next.uri.path);
            currentPath = current.uri.path;
            return !next.uri.path.contains('blocked');
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (_, __) => const Placeholder(),
              routes: <GoRoute>[
                GoRoute(
                  path: 'blocked',
                  builder: (_, __) => const Placeholder(),
                ),
                GoRoute(
                  path: 'allowed',
                  builder: (_, __) => const Placeholder(),
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final BuildContext context =
            tester.element(find.byType(Router<Object>));
        final GoRouteInformationParser parser = router.routeInformationParser;
        final RouteMatchList beforeBlockedNav =
            router.routerDelegate.currentConfiguration;

        // Try blocked route
        final RouteMatchList blockedMatch =
            await parser.parseRouteInformationWithDependencies(
          RouteInformation(
            uri: Uri.parse('/blocked'),
            state: RouteInformationState<void>(type: NavigatingType.go),
          ),
          context,
        );
        await tester.pumpAndSettle();

        expect(blockedMatch.uri.toString(),
            equals(beforeBlockedNav.uri.toString()));
        expect(currentPath, equals('/'));
        expect(navigationAttempts, contains('/blocked'));

        // Try allowed route
        final RouteMatchList allowedMatch =
            await parser.parseRouteInformationWithDependencies(
          RouteInformation(
            uri: Uri.parse('/allowed'),
            state: RouteInformationState<void>(type: NavigatingType.go),
          ),
          context,
        );
        expect(allowedMatch.uri.path, equals('/allowed'));
        expect(navigationAttempts, contains('/allowed'));
        await tester.pumpAndSettle();
      },
    );
  });

  group('onEnter redirection tests', () {
    late GoRouter router;

    tearDown(() async {
      router.dispose();
    });

    testWidgets('allows navigation when onEnter does not exceed limit',
        (WidgetTester tester) async {
      int onEnterCallCount = 0;

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          onEnterCallCount++;
          return !next.uri.path.contains('block');
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Home'))),
            routes: <GoRoute>[
              GoRoute(
                path: 'allowed',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('Allowed'))),
              ),
              GoRoute(
                path: 'block',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('Blocked'))),
              ),
            ],
          ),
        ],
        redirectLimit: 3,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(Scaffold));
      final RouteMatchList matchList = await router.routeInformationParser
          .parseRouteInformationWithDependencies(
        RouteInformation(
          uri: Uri.parse('/home/allowed'),
          state: RouteInformationState<void>(type: NavigatingType.go),
        ),
        context,
      );

      expect(matchList.uri.path, equals('/home/allowed'));
      expect(onEnterCallCount, greaterThan(0));
    });

    testWidgets(
        'recursive onEnter limit triggers onException and resets navigation',
        (WidgetTester tester) async {
      final Completer<void> completer = Completer<void>();
      Object? capturedError;

      router = GoRouter(
        initialLocation: '/start',
        redirectLimit: 2,
        onException:
            (BuildContext context, GoRouterState state, GoRouter goRouter) {
          capturedError = state.error;
          goRouter.go('/fallback');
          completer.complete();
        },
        onEnter: (BuildContext context, GoRouterState current,
            GoRouterState next, GoRouter goRouter) async {
          if (next.uri.path == '/recursive') {
            goRouter.push('/recursive');
            return false;
          }
          return true;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/start',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Start'))),
          ),
          GoRoute(
            path: '/recursive',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Recursive'))),
          ),
          GoRoute(
            path: '/fallback',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Fallback'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/recursive');
      await completer.future;
      await tester.pumpAndSettle();

      expect(capturedError, isNotNull);
      expect(capturedError.toString(),
          contains('Too many onEnter calls detected'));
      expect(find.text('Fallback'), findsOneWidget);
    });
    testWidgets(
        'recursive onEnter limit triggers onException and resets navigation',
        (WidgetTester tester) async {
      final Completer<void> completer = Completer<void>();
      Object? capturedError;

      router = GoRouter(
        initialLocation: '/start',
        redirectLimit: 2,
        onException:
            (BuildContext context, GoRouterState state, GoRouter goRouter) {
          capturedError = state.error;
          goRouter.go('/fallback');
          completer.complete();
        },
        onEnter: (BuildContext context, GoRouterState current,
            GoRouterState next, GoRouter goRouter) async {
          if (next.uri.path == '/recursive') {
            goRouter.push('/recursive');
            return false;
          }
          return true;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/start',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Start'))),
          ),
          GoRoute(
            path: '/recursive',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Recursive'))),
          ),
          GoRoute(
            path: '/fallback',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Fallback'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/recursive');
      await completer.future;
      await tester.pumpAndSettle();

      expect(capturedError, isNotNull);
      expect(capturedError.toString(),
          contains('Too many onEnter calls detected'));
      expect(find.text('Fallback'), findsOneWidget);
    });
  });
}
