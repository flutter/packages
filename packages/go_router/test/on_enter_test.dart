// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: cascade_invocations, diagnostic_describe_all_properties, unawaited_futures

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('onEnter', () {
    late GoRouter router;

    tearDown(() {
      return Future<void>.delayed(Duration.zero).then((_) => router.dispose());
    });

    testWidgets(
      'Should set current/next state correctly',
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
      'Should block navigation when onEnter returns false',
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

    testWidgets('Should allow navigation when onEnter returns true',
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
        'Should trigger onException when the redirection limit is exceeded',
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

    testWidgets('Should handle `go` usage in onEnter',
        (WidgetTester tester) async {
      bool isAuthenticatedResult = false;

      Future<bool> isAuthenticated() =>
          Future<bool>.value(isAuthenticatedResult);

      final StreamController<({String current, String next})> paramsSink =
          StreamController<({String current, String next})>();
      final Stream<({String current, String next})> paramsStream =
          paramsSink.stream.asBroadcastStream();

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          final bool isProtected = next.uri.toString().contains('protected');
          paramsSink.add(
              (current: current.uri.toString(), next: next.uri.toString()));

          if (!isProtected) {
            return true;
          }
          if (await isAuthenticated()) {
            return true;
          }
          router.go('/sign-in');
          return false;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/protected',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Protected'))),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Sign-in'))),
          ),
        ],
      );

      expect(paramsStream, emits((current: '/home', next: '/home')));

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(
        paramsStream,
        emitsInOrder(<({String current, String next})>[
          (current: '/home', next: '/protected'),
          (current: '/home', next: '/sign-in')
        ]),
      );
      router.go('/protected');
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), equals('/sign-in'));

      isAuthenticatedResult = true;
      expect(
        paramsStream,
        emits((current: '/sign-in', next: '/protected')),
      );
      router.go('/protected');
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), equals('/protected'));
      await paramsSink.close();
    });

    testWidgets('Should handle `goNamed` usage in onEnter',
        (WidgetTester tester) async {
      final List<String> navigationAttempts = <String>[];

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          navigationAttempts.add(next.uri.path);

          if (next.uri.path == '/requires-auth') {
            goRouter.goNamed('login-page',
                queryParameters: <String, String>{'from': next.uri.toString()});
            return false;
          }
          return true;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
          ),
          GoRoute(
            path: '/requires-auth',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Authenticated Content')),
            ),
          ),
          GoRoute(
            path: '/login',
            name: 'login-page',
            builder: (_, GoRouterState state) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        'Login Page - From: ${state.uri.queryParameters['from'] ?? 'unknown'}'),
                    ElevatedButton(
                      onPressed: () => router.go('/home'),
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/requires-auth');
      await tester.pumpAndSettle();

      expect(navigationAttempts, contains('/requires-auth'));
      expect(router.state.uri.path, equals('/login'));
      expect(find.text('Login Page - From: /requires-auth'), findsOneWidget);
    });

    testWidgets('Should handle `push` usage in onEnter',
        (WidgetTester tester) async {
      const bool isAuthenticatedResult = false;

      Future<bool> isAuthenticated() =>
          Future<bool>.value(isAuthenticatedResult);

      final StreamController<({String current, String next})> paramsSink =
          StreamController<({String current, String next})>();
      final Stream<({String current, String next})> paramsStream =
          paramsSink.stream.asBroadcastStream();

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          final bool isProtected = next.uri.toString().contains('protected');
          paramsSink.add(
              (current: current.uri.toString(), next: next.uri.toString()));
          if (!isProtected) {
            return true;
          }
          if (await isAuthenticated()) {
            return true;
          }
          await router.push<bool?>('/sign-in').then((bool? isLoggedIn) {
            if (isLoggedIn ?? false) {
              router.go(next.uri.toString());
            }
          });

          return false;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/protected',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Protected'))),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (_, __) => Scaffold(
              appBar: AppBar(
                title: const Text('Sign in'),
              ),
              body: const Center(child: Text('Sign-in')),
            ),
          ),
        ],
      );

      expect(paramsStream, emits((current: '/home', next: '/home')));
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/protected');
      expect(
        paramsStream,
        emitsInOrder(<({String current, String next})>[
          (current: '/home', next: '/protected'),
          (current: '/home', next: '/sign-in')
        ]),
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), equals('/sign-in'));
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), equals('/home'));
      await paramsSink.close();
    });

    testWidgets('Should handle `replace` usage in onEnter',
        (WidgetTester tester) async {
      final List<String> navigationHistory = <String>[];

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          navigationHistory.add('Entering: ${next.uri.path}');

          if (next.uri.path == '/old-page') {
            navigationHistory.add('Replacing with /new-version');
            await goRouter.replace<void>('/new-version');
            return false;
          }
          return true;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
          ),
          GoRoute(
            path: '/old-page',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Old Page')),
            ),
          ),
          GoRoute(
            path: '/new-version',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('New Version')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/old-page');
      await tester.pumpAndSettle();

      expect(navigationHistory, contains('Entering: /old-page'));
      expect(navigationHistory, contains('Replacing with /new-version'));
      expect(router.state.uri.path, equals('/new-version'));
      expect(find.text('New Version'), findsOneWidget);

      // Verify back behavior works as expected with replace
      router.go('/home');
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Should handle `pushReplacement` usage in onEnter',
        (WidgetTester tester) async {
      final List<String> navigationLog = <String>[];

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          navigationLog.add('Entering: ${next.uri.path}');

          if (next.uri.path == '/outdated') {
            navigationLog.add('Push replacing with /updated');
            await goRouter.pushReplacement('/updated');
            return false;
          }
          return true;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
          ),
          GoRoute(
            path: '/outdated',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Outdated')),
            ),
          ),
          GoRoute(
            path: '/updated',
            builder: (_, __) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Updated'),
                    ElevatedButton(
                      onPressed: () =>
                          router.go('/home'), // Use go instead of pop
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/outdated');
      await tester.pumpAndSettle();

      expect(navigationLog, contains('Entering: /outdated'));
      expect(navigationLog, contains('Push replacing with /updated'));
      expect(router.state.uri.path, equals('/updated'));
      expect(find.text('Updated'), findsOneWidget);

      // Test navigation to home
      await tester.tap(find.text('Go Home'));
      await tester.pumpAndSettle();

      // Should now be at home
      expect(router.state.uri.path, equals('/home'));
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Should allow redirection with query parameters',
        (WidgetTester tester) async {
      bool isAuthenticatedResult = false;

      Future<bool> isAuthenticated() =>
          Future<bool>.value(isAuthenticatedResult);

      final StreamController<({String current, String next})> paramsSink =
          StreamController<({String current, String next})>();
      final Stream<({String current, String next})> paramsStream = paramsSink
          .stream
          .asBroadcastStream(); // Use broadcast for multiple expects

      void goToRedirect(GoRouter router, GoRouterState state) {
        final String redirect = state.uri.queryParameters['redirectTo'] ?? '';
        if (redirect.isNotEmpty) {
          router.go(Uri.decodeComponent(redirect));
        } else {
          router.go('/home');
        }
      }

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          // Log the attempt
          paramsSink.add(
              (current: current.uri.toString(), next: next.uri.toString()));

          final bool isProtected = next.uri.path.startsWith('/protected');
          if (!isProtected) {
            return true;
          }
          if (await isAuthenticated()) {
            return true;
          }
          // Use pushNamed as originally intended
          await goRouter.pushNamed<bool?>('sign-in',
              queryParameters: <String, String>{
                'redirectTo': next.uri.toString()
              });
          return false;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/protected',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Protected'))),
          ),
          GoRoute(
            path: '/sign-in',
            name: 'sign-in',
            builder: (_, GoRouterState state) => Scaffold(
              appBar: AppBar(
                title: const Text('Sign in Title'),
              ),
              body: Center(
                child: ElevatedButton(
                    child: const Text('Sign in Button'),
                    onPressed: () => goToRedirect(router, state)),
              ),
            ),
          ),
        ],
      );

      // Using expectLater with emitsInOrder covering the whole sequence
      unawaited(
        // Don't await this expectLater itself
        expectLater(
          paramsStream,
          emitsInOrder(<dynamic>[
            // Use dynamic or Matcher type
            // 1. Initial Load
            equals((current: '/home', next: '/home')),
            // 2. Attempt go('/protected') -> onEnter blocks, pushes sign-in
            equals((current: '/home', next: '/protected')),
            // 3. onEnter runs for the push('/sign-in?...')
            equals(
                (current: '/home', next: '/sign-in?redirectTo=%2Fprotected')),
            // 4. Tap button -> go('/protected') -> onEnter allows
            equals((
              current: '/sign-in?redirectTo=%2Fprotected',
              next: '/protected'
            )),
          ]),
        ),
      );

      // Initial load
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle(); // Let initial navigation complete
      expect(find.text('Home'), findsOneWidget);

      // Trigger first navigation (go protected -> push sign-in)
      router.go('/protected');
      await tester.pumpAndSettle(); // Let navigation to sign-in complete

      // Verify state after first navigation attempt
      expect(router.state.uri.toString(),
          equals('/sign-in?redirectTo=%2Fprotected'));
      expect(find.widgetWithText(ElevatedButton, 'Sign in Button'),
          findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      // Simulate login
      isAuthenticatedResult = true;

      // Trigger second navigation (tap button -> go protected)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in Button'));
      await tester.pumpAndSettle(); // Let navigation to protected complete

      // Verify final state
      expect(router.state.uri.toString(), equals('/protected'));
      expect(find.text('Protected'), findsOneWidget);

      // clean up
      await paramsSink.close();
    });

    testWidgets('Should handle sequential navigation steps in onEnter',
        (WidgetTester tester) async {
      final List<String> navigationChain = <String>[];
      final Completer<void> navigationComplete = Completer<void>();

      router = GoRouter(
        initialLocation: '/start',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          final String targetPath = next.uri.path;
          navigationChain.add('Entering: $targetPath');

          // Execute a simpler navigation sequence
          if (targetPath == '/multi-step') {
            // Step 1: Go to a different route
            navigationChain.add('Step 1: Go to /step-one');
            goRouter.go('/step-one');

            // We're blocking the original navigation
            return false;
          }

          // When we reach step-one, mark test as complete
          if (targetPath == '/step-one') {
            navigationComplete.complete();
          }

          return true;
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/start',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Start')),
            ),
          ),
          GoRoute(
            path: '/multi-step',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Multi Step')),
            ),
          ),
          GoRoute(
            path: '/step-one',
            builder: (_, __) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Step One'),
                    ElevatedButton(
                      onPressed: () => router.go('/start'),
                      child: const Text('Go Back to Start'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Trigger the navigation sequence
      router.go('/multi-step');

      // Wait for navigation to complete
      await navigationComplete.future;
      await tester.pumpAndSettle();

      // Verify the navigation chain steps were executed
      expect(navigationChain, contains('Entering: /multi-step'));
      expect(navigationChain, contains('Step 1: Go to /step-one'));
      expect(navigationChain, contains('Entering: /step-one'));

      // Verify we ended up at the right destination
      expect(router.state.uri.path, equals('/step-one'));
      expect(find.text('Step One'), findsOneWidget);

      // Test going back to start
      await tester.tap(find.text('Go Back to Start'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, equals('/start'));
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets(
        'Should call onException when exceptions thrown in onEnter callback',
        (WidgetTester tester) async {
      final Completer<void> completer = Completer<void>();
      Object? capturedError;

      // Set up the router. Note that we short-circuit onEnter for '/fallback'
      // to avoid triggering the exception when navigating to the fallback route.
      router = GoRouter(
        initialLocation: '/error',
        onException:
            (BuildContext context, GoRouterState state, GoRouter goRouter) {
          capturedError = state.error;
          // Navigate to a safe fallback route.
          goRouter.go('/fallback');
          completer.complete();
        },
        onEnter: (BuildContext context, GoRouterState current,
            GoRouterState next, GoRouter goRouter) async {
          // If the navigation target is '/fallback', allow it without throwing.
          if (next.uri.path == '/fallback') {
            return true;
          }
          // For any other target, throw an exception.
          throw Exception('onEnter error triggered');
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/error',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Error Page'))),
          ),
          GoRoute(
            path: '/fallback',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Fallback Page'))),
          ),
        ],
      );

      // Build the app with the router.
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Since the onEnter callback for '/error' throws, onException should be triggered.
      // Wait for the onException handler to complete.
      await completer.future;
      await tester.pumpAndSettle();

      // Check that an error was captured and it contains the thrown exception message.
      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('onEnter error triggered'));
      // Verify that the fallback route was navigated to.
      expect(find.text('Fallback Page'), findsOneWidget);
    });
  });
}
