// Copyright 2013 The Flutter Authors
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

    testWidgets('Should set current/next state correctly', (
      WidgetTester tester,
    ) async {
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
          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Placeholder(),
            routes: <GoRoute>[
              GoRoute(path: 'allowed', builder: (_, __) => const Placeholder()),
              GoRoute(path: 'blocked', builder: (_, __) => const Placeholder()),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(onEnterCallCount, equals(1));
      expect(capturedCurrentState?.uri.path, capturedNextState?.uri.path);
    });

    testWidgets('Should block navigation when onEnter returns false', (
      WidgetTester tester,
    ) async {
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
          return next.uri.path.contains('blocked')
              ? const Block.stop()
              : const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Placeholder(),
            routes: <GoRoute>[
              GoRoute(path: 'blocked', builder: (_, __) => const Placeholder()),
              GoRoute(path: 'allowed', builder: (_, __) => const Placeholder()),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(Router<Object>));
      final GoRouteInformationParser parser = router.routeInformationParser;
      final RouteMatchList beforeBlockedNav =
          router.routerDelegate.currentConfiguration;

      // Try blocked route
      final RouteMatchList blockedMatch = await parser
          .parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/blocked'),
              state: RouteInformationState<void>(type: NavigatingType.go),
            ),
            context,
          );
      await tester.pumpAndSettle();

      expect(
        blockedMatch.uri.toString(),
        equals(beforeBlockedNav.uri.toString()),
      );
      expect(currentPath, equals('/'));
      expect(navigationAttempts, contains('/blocked'));

      // Try allowed route
      final RouteMatchList allowedMatch = await parser
          .parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/allowed'),
              state: RouteInformationState<void>(type: NavigatingType.go),
            ),
            context,
          );
      expect(allowedMatch.uri.path, equals('/allowed'));
      expect(navigationAttempts, contains('/allowed'));
      await tester.pumpAndSettle();
    });

    testWidgets('Should allow navigation when onEnter returns true', (
      WidgetTester tester,
    ) async {
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
          return next.uri.path.contains('block')
              ? const Block.stop()
              : const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Home'))),
            routes: <GoRoute>[
              GoRoute(
                path: 'allowed',
                builder:
                    (_, __) =>
                        const Scaffold(body: Center(child: Text('Allowed'))),
              ),
              GoRoute(
                path: 'block',
                builder:
                    (_, __) =>
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
          onException: (
            BuildContext context,
            GoRouterState state,
            GoRouter goRouter,
          ) {
            capturedError = state.error;
            goRouter.go('/fallback');
            completer.complete();
          },
          onEnter: (
            BuildContext context,
            GoRouterState current,
            GoRouterState next,
            GoRouter goRouter,
          ) async {
            if (next.uri.path == '/recursive') {
              return Block.then(() => goRouter.push('/recursive'));
            }
            return const Allow();
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/start',
              builder:
                  (_, __) => const Scaffold(body: Center(child: Text('Start'))),
            ),
            GoRoute(
              path: '/recursive',
              builder:
                  (_, __) =>
                      const Scaffold(body: Center(child: Text('Recursive'))),
            ),
            GoRoute(
              path: '/fallback',
              builder:
                  (_, __) =>
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
        expect(
          capturedError.toString(),
          contains('Too many onEnter calls detected'),
        );
        expect(find.text('Fallback'), findsOneWidget);
      },
    );

    testWidgets('Should handle `go` usage in onEnter', (
      WidgetTester tester,
    ) async {
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
          paramsSink.add((
            current: current.uri.toString(),
            next: next.uri.toString(),
          ));

          if (!isProtected) {
            return const Allow();
          }
          if (await isAuthenticated()) {
            return const Allow();
          }
          return Block.then(() => router.go('/sign-in'));
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/protected',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('Protected'))),
          ),
          GoRoute(
            path: '/sign-in',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Sign-in'))),
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
          (current: '/home', next: '/sign-in'),
        ]),
      );
      router.go('/protected');
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), equals('/sign-in'));

      isAuthenticatedResult = true;
      expect(paramsStream, emits((current: '/sign-in', next: '/protected')));
      router.go('/protected');
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), equals('/protected'));
      await paramsSink.close();
    });

    testWidgets('Should handle `goNamed` usage in onEnter', (
      WidgetTester tester,
    ) async {
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
            return Block.then(
              () => goRouter.goNamed(
                'login-page',
                queryParameters: <String, String>{'from': next.uri.toString()},
              ),
            );
          }
          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/requires-auth',
            builder:
                (_, __) => const Scaffold(
                  body: Center(child: Text('Authenticated Content')),
                ),
          ),
          GoRoute(
            path: '/login',
            name: 'login-page',
            builder:
                (_, GoRouterState state) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Login Page - From: ${state.uri.queryParameters['from'] ?? 'unknown'}',
                        ),
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

    testWidgets('Should handle `push` usage in onEnter', (
      WidgetTester tester,
    ) async {
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
          paramsSink.add((
            current: current.uri.toString(),
            next: next.uri.toString(),
          ));
          if (!isProtected) {
            return const Allow();
          }
          if (await isAuthenticated()) {
            return const Allow();
          }
          await router.push<bool?>('/sign-in').then((bool? isLoggedIn) {
            if (isLoggedIn ?? false) {
              router.go(next.uri.toString());
            }
          });

          return const Block.stop();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/protected',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('Protected'))),
          ),
          GoRoute(
            path: '/sign-in',
            builder:
                (_, __) => Scaffold(
                  appBar: AppBar(title: const Text('Sign in')),
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
          (current: '/home', next: '/sign-in'),
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

    testWidgets('Should handle `replace` usage in onEnter', (
      WidgetTester tester,
    ) async {
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
            return const Block.stop();
          }
          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/old-page',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('Old Page'))),
          ),
          GoRoute(
            path: '/new-version',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('New Version'))),
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

    testWidgets('Should handle `pushReplacement` usage in onEnter', (
      WidgetTester tester,
    ) async {
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
            return const Block.stop();
          }
          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/outdated',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('Outdated'))),
          ),
          GoRoute(
            path: '/updated',
            builder:
                (_, __) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Updated'),
                        ElevatedButton(
                          onPressed:
                              () => router.go('/home'), // Use go instead of pop
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

    testWidgets(
      'onEnter should handle protected route redirection with query parameters',
      (WidgetTester tester) async {
        // Test setup
        bool isAuthenticatedResult = false;
        Future<bool> isAuthenticated() =>
            Future<bool>.value(isAuthenticatedResult);

        // Stream to capture onEnter calls
        final StreamController<({String current, String next})> paramsSink =
            StreamController<({String current, String next})>();
        // Use broadcast stream for potentially multiple listeners/expects if needed,
        // although expectLater handles one listener well.
        final Stream<({String current, String next})> paramsStream =
            paramsSink.stream.asBroadcastStream();

        // Helper to navigate after sign-in button press
        void goToRedirect(GoRouter router, GoRouterState state) {
          final String? redirect = state.uri.queryParameters['redirectTo'];
          // Use null check and Uri.tryParse for safety
          if (redirect != null && Uri.tryParse(redirect) != null) {
            // Decode potentially encoded URI component
            router.go(Uri.decodeComponent(redirect));
          } else {
            // Fallback if redirectTo is missing or invalid
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
            // Renamed parameter to avoid shadowing router variable
          ) async {
            // Log the navigation attempt state URIs
            paramsSink.add((
              current: current.uri.toString(),
              next: next.uri.toString(),
            ));

            final bool isNavigatingToProtected = next.uri.path == '/protected';

            // Allow navigation if not going to the protected route
            if (!isNavigatingToProtected) {
              return const Allow();
            }

            // Allow navigation if authenticated
            if (await isAuthenticated()) {
              return const Allow();
            }

            // If unauthenticated and going to protected route:
            // 1. Redirect to sign-in using pushNamed, passing the intended destination
            await goRouter.pushNamed<void>(
              'sign-in', // Return type likely void or not needed
              queryParameters: <String, String>{
                'redirectTo': next.uri.toString(), // Pass the full next URI
              },
            );
            // 2. Block the original navigation to '/protected'
            return const Block.stop();
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              name: 'home', // Good practice to name routes
              builder:
                  (_, __) => const Scaffold(
                    body: Center(child: Text('Home Screen')),
                  ), // Unique text
            ),
            GoRoute(
              path: '/protected',
              name: 'protected', // Good practice to name routes
              builder:
                  (_, __) => const Scaffold(
                    body: Center(child: Text('Protected Screen')),
                  ), // Unique text
            ),
            GoRoute(
              path: '/sign-in',
              name: 'sign-in',
              builder:
                  (_, GoRouterState state) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Sign In Screen Title'), // Unique text
                    ),
                    body: Center(
                      child: ElevatedButton(
                        child: const Text('Sign In Button'), // Unique text
                        onPressed: () => goToRedirect(router, state),
                      ),
                    ),
                  ),
            ),
          ],
        );

        // Expect the stream of onEnter calls to emit events in this specific order
        // We use unawaited because expectLater returns a Future that completes
        // when the expectation is met or fails, but we want the test execution
        // (pumping widgets, triggering actions) to proceed concurrently.
        unawaited(
          expectLater(
            paramsStream,
            emitsInOrder(<dynamic>[
              // 1. Initial Load to '/home'
              equals((current: '/home', next: '/home')),
              // 2. Attempt go('/protected') -> onEnter blocks
              equals((current: '/home', next: '/protected')),
              // 3. onEnter runs for the push('/sign-in?redirectTo=...') triggered internally
              equals((
                current: '/home',
                next: '/sign-in?redirectTo=%2Fprotected',
              )),
              // 4. Tap button -> go('/protected') -> onEnter allows access
              equals((
                current:
                    // State when button is tapped
                    '/sign-in?redirectTo=%2Fprotected',
                // Target of the 'go' call
                next: '/protected',
              )),
            ]),
          ),
        );

        // Initial widget pump
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        // Let initial navigation and builds complete
        await tester.pumpAndSettle();
        // Verify initial screen
        expect(find.text('Home Screen'), findsOneWidget);

        // Trigger navigation to protected route (user is not authenticated)
        router.go('/protected');
        // Allow navigation/redirection to complete
        await tester.pumpAndSettle();

        // Verify state after redirection to sign-in
        expect(
          router.state.uri.toString(),
          equals('/sign-in?redirectTo=%2Fprotected'),
        );
        // Verify app bar title
        expect(find.text('Sign In Screen Title'), findsOneWidget);
        // Verify button exists
        expect(
          find.widgetWithText(ElevatedButton, 'Sign In Button'),
          findsOneWidget,
        );
        // BackButton appears because sign-in was pushed onto the stack
        expect(find.byType(BackButton), findsOneWidget);

        // Simulate successful authentication
        isAuthenticatedResult = true;

        // Trigger navigation back to protected route by tapping the sign-in button
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In Button'));
        // Allow navigation to protected route to complete
        await tester.pumpAndSettle();

        // Verify final state
        expect(router.state.uri.toString(), equals('/protected'));
        // Verify final screen
        expect(find.text('Protected Screen'), findsOneWidget);
        // Verify sign-in screen is gone
        expect(find.text('Sign In Screen Title'), findsNothing);

        // Close the stream controller
        await paramsSink.close();
      },
    );

    testWidgets('Should handle sequential navigation steps in onEnter', (
      WidgetTester tester,
    ) async {
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
            // We're blocking the original navigation and deferring the go
            return Block.then(() => goRouter.go('/step-one'));
          }

          // When we reach step-one, mark test as complete
          if (targetPath == '/step-one') {
            navigationComplete.complete();
          }

          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/start',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Start'))),
          ),
          GoRoute(
            path: '/multi-step',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('Multi Step'))),
          ),
          GoRoute(
            path: '/step-one',
            builder:
                (_, __) => Scaffold(
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

    testWidgets('Should call onException when exceptions thrown in onEnter callback', (
      WidgetTester tester,
    ) async {
      final Completer<void> completer = Completer<void>();
      Object? capturedError;

      // Set up the router. Note that we short-circuit onEnter for '/fallback'
      // to avoid triggering the exception when navigating to the fallback route.
      router = GoRouter(
        initialLocation: '/error',
        onException: (
          BuildContext context,
          GoRouterState state,
          GoRouter goRouter,
        ) {
          capturedError = state.error;
          // Navigate to a safe fallback route.
          goRouter.go('/fallback');
          completer.complete();
        },
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          // If the navigation target is '/fallback', allow it without throwing.
          if (next.uri.path == '/fallback') {
            return const Allow();
          }
          // For any other target, throw an exception.
          throw Exception('onEnter error triggered');
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/error',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('Error Page'))),
          ),
          GoRoute(
            path: '/fallback',
            builder:
                (_, __) =>
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

    testWidgets('onEnter has priority over deprecated redirect', (
      WidgetTester tester,
    ) async {
      int redirectCallCount = 0;
      int onEnterCallCount = 0;
      bool lastOnEnterBlocked = false;

      router = GoRouter(
        initialLocation: '/start',
        routes: <GoRoute>[
          GoRoute(path: '/start', builder: (_, __) => const Text('Start')),
          GoRoute(path: '/blocked', builder: (_, __) => const Text('Blocked')),
          GoRoute(path: '/allowed', builder: (_, __) => const Text('Allowed')),
        ],
        onEnter: (_, __, GoRouterState next, ___) async {
          onEnterCallCount++;
          lastOnEnterBlocked = next.uri.path == '/blocked';
          if (lastOnEnterBlocked) {
            return const Block.stop();
          }
          return const Allow();
        },
        // ignore: deprecated_member_use_from_same_package
        redirect: (_, GoRouterState state) {
          redirectCallCount++;
          // This should never be called for /blocked
          return null;
        },
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Record initial counts
      final int initialRedirectCount = redirectCallCount;
      final int initialOnEnterCount = onEnterCallCount;

      // Test blocked route
      router.go('/blocked');
      await tester.pumpAndSettle();

      expect(onEnterCallCount, greaterThan(initialOnEnterCount));
      expect(
        redirectCallCount,
        equals(initialRedirectCount),
      ); // redirect should not be called for blocked routes
      expect(find.text('Start'), findsOneWidget); // Should stay on start
      expect(lastOnEnterBlocked, isTrue);

      // Test allowed route
      final int beforeAllowedRedirectCount = redirectCallCount;
      router.go('/allowed');
      await tester.pumpAndSettle();

      expect(onEnterCallCount, greaterThan(initialOnEnterCount + 1));
      expect(
        redirectCallCount,
        greaterThan(beforeAllowedRedirectCount),
      ); // redirect should be called this time
      expect(find.text('Allowed'), findsOneWidget);
    });

    testWidgets('onEnter blocks navigation and preserves current route', (
      WidgetTester tester,
    ) async {
      String? capturedCurrentPath;
      String? capturedNextPath;

      router = GoRouter(
        initialLocation: '/page1',
        routes: <GoRoute>[
          GoRoute(path: '/page1', builder: (_, __) => const Text('Page 1')),
          GoRoute(path: '/page2', builder: (_, __) => const Text('Page 2')),
          GoRoute(
            path: '/protected',
            builder: (_, __) => const Text('Protected'),
          ),
        ],
        onEnter: (_, GoRouterState current, GoRouterState next, ___) async {
          capturedCurrentPath = current.uri.path;
          capturedNextPath = next.uri.path;

          if (next.uri.path == '/protected') {
            return const Block.stop();
          }
          return const Allow();
        },
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      // Navigate to page2 (allowed)
      router.go('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);
      expect(capturedCurrentPath, equals('/page1'));
      expect(capturedNextPath, equals('/page2'));

      // Try to navigate to protected (blocked)
      router.go('/protected');
      await tester.pumpAndSettle();

      // Should stay on page2
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Protected'), findsNothing);
      expect(capturedCurrentPath, equals('/page2'));
      expect(capturedNextPath, equals('/protected'));
    });

    testWidgets('pop does not call onEnter but restore does', (
      WidgetTester tester,
    ) async {
      int onEnterCount = 0;

      router = GoRouter(
        initialLocation: '/a',
        onEnter: (_, __, ___, ____) async {
          onEnterCount++;
          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (_, __) => const Scaffold(body: Text('A')),
            routes: <RouteBase>[
              GoRoute(
                path: 'b',
                builder: (_, __) => const Scaffold(body: Text('B')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(onEnterCount, 1); // initial navigation

      router.go('/a/b');
      await tester.pumpAndSettle();
      expect(onEnterCount, 2); // forward nav is guarded

      // Pop back to /a
      router.pop();
      await tester.pumpAndSettle();

      // Pop calls restore which now goes through onEnter
      expect(onEnterCount, 3); // onEnter called for restore
      expect(find.text('A'), findsOneWidget);

      // Explicit restore would call onEnter (tested separately in integration)
    });

    testWidgets('restore navigation calls onEnter for re-validation', (
      WidgetTester tester,
    ) async {
      int onEnterCount = 0;
      bool allowNavigation = true;

      router = GoRouter(
        initialLocation: '/home',
        onEnter: (_, __, GoRouterState next, ____) async {
          onEnterCount++;
          // Simulate auth check - block protected route if not allowed
          if (next.uri.path == '/protected' && !allowNavigation) {
            return const Block.stop();
          }
          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/protected',
            builder: (_, __) => const Scaffold(body: Text('Protected')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(onEnterCount, 1); // initial navigation

      // Navigate to protected route (allowed)
      router.go('/protected');
      await tester.pumpAndSettle();
      expect(onEnterCount, 2);
      expect(find.text('Protected'), findsOneWidget);

      // Simulate state restoration by explicitly calling parser with restore type
      final BuildContext context = tester.element(find.byType(Router<Object>));
      final GoRouteInformationParser parser = router.routeInformationParser;

      // Create a restore navigation to protected route
      final RouteMatchList restoredMatch = await parser
          .parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/protected'),
              state: RouteInformationState<void>(
                type: NavigatingType.restore,
                baseRouteMatchList: router.routerDelegate.currentConfiguration,
              ),
            ),
            context,
          );

      // onEnter should be called again for restore
      expect(onEnterCount, 3);
      expect(restoredMatch.uri.path, equals('/protected'));

      // Now simulate session expired - block on restore
      allowNavigation = false;
      final RouteMatchList blockedRestore = await parser
          .parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/protected'),
              state: RouteInformationState<void>(
                type: NavigatingType.restore,
                baseRouteMatchList: router.routerDelegate.currentConfiguration,
              ),
            ),
            context,
          );

      // onEnter called again but blocks this time
      expect(onEnterCount, 4);
      // Should stay on protected since we're blocking but not redirecting
      expect(blockedRestore.uri.path, equals('/protected'));
    });

    testWidgets(
      'goNamed supports fragment (hash) and preserves it in state.uri',
      (WidgetTester tester) async {
        router = GoRouter(
          initialLocation: '/',
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder:
                  (_, __) => const Scaffold(body: Center(child: Text('Root'))),
            ),
            GoRoute(
              path: '/article/:id',
              name: 'article',
              builder: (_, GoRouterState state) {
                return Scaffold(
                  body: Center(
                    child: Text(
                      'article=${state.pathParameters['id']};frag=${state.uri.fragment}',
                    ),
                  ),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // Navigate with a fragment
        router.goNamed(
          'article',
          pathParameters: <String, String>{'id': '42'},
          fragment: 'section-2',
        );
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/article/42');
        expect(router.state.uri.fragment, 'section-2');
        expect(find.text('article=42;frag=section-2'), findsOneWidget);
      },
    );

    testWidgets('relative "./" navigation resolves against current location', (
      WidgetTester tester,
    ) async {
      router = GoRouter(
        initialLocation: '/parent',
        routes: <RouteBase>[
          GoRoute(
            path: '/parent',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Parent'))),
            routes: <RouteBase>[
              GoRoute(
                path: 'child',
                builder:
                    (_, __) =>
                        const Scaffold(body: Center(child: Text('Child'))),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Parent'), findsOneWidget);

      // Use a relative location. This exercises GoRouteInformationProvider._setValue
      // and concatenateUris().
      router.go('./child');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/parent/child');
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('route-level redirect still runs after onEnter allows', (
      WidgetTester tester,
    ) async {
      final List<String> seenNextPaths = <String>[];

      router = GoRouter(
        initialLocation: '/',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          seenNextPaths.add(next.uri.path);
          return const Allow(); // don't block; let route-level redirect run
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Root'))),
          ),
          GoRoute(
            path: '/old',
            builder: (_, __) => const SizedBox.shrink(),
            // Route-level redirect: should run AFTER onEnter allows
            redirect: (_, __) => '/new',
          ),
          GoRoute(
            path: '/new',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('New'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Trigger navigation that hits the redirecting route
      router.go('/old');
      await tester.pumpAndSettle();

      // onEnter should have seen the original target ('/old')
      expect(seenNextPaths, contains('/old'));

      // Final destination should be the redirect target
      expect(router.state.uri.path, '/new');
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets(
      'Allow(then) error is reported but does not revert navigation',
      (WidgetTester tester) async {
        // Capture FlutterError.reportError calls
        FlutterErrorDetails? reported;
        final void Function(FlutterErrorDetails)? oldHandler =
            FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          reported = details;
        };
        addTearDown(() => FlutterError.onError = oldHandler);

        router = GoRouter(
          initialLocation: '/home',
          onEnter: (_, __, GoRouterState next, ___) async {
            if (next.uri.path == '/boom') {
              // Allow, but run a failing "then" callback
              return Allow(then: () => throw StateError('then blew up'));
            }
            return const Allow();
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder:
                  (_, __) => const Scaffold(body: Center(child: Text('Home'))),
            ),
            GoRoute(
              path: '/boom',
              builder:
                  (_, __) => const Scaffold(body: Center(child: Text('Boom'))),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);

        router.go('/boom');
        await tester.pumpAndSettle(); // commits nav + runs deferred microtask

        // Navigation should be committed
        expect(router.state.uri.path, equals('/boom'));
        expect(find.text('Boom'), findsOneWidget);

        // Error from deferred callback should be reported (but not crash)
        expect(reported, isNotNull);
        expect(reported!.exception.toString(), contains('then blew up'));
      },
    );

    testWidgets('Hard-stop vs chaining resets onEnter history', (
      WidgetTester tester,
    ) async {
      // With redirectLimit=1:
      //  - Block.stop() resets history so repeated attempts don't hit the limit.
      //  - Block.then(() => go(...)) keeps history and will exceed the limit.
      int onExceptionCalls = 0;
      final Completer<void> exceededCompleter = Completer<void>();

      router = GoRouter(
        initialLocation: '/start',
        redirectLimit: 1,
        onException: (_, __, ___) {
          onExceptionCalls++;
          if (!exceededCompleter.isCompleted) {
            exceededCompleter.complete();
          }
        },
        onEnter: (_, __, GoRouterState next, GoRouter goRouter) async {
          if (next.uri.path == '/blocked-once') {
            // Hard stop: no then -> history should reset
            return const Block.stop();
          }
          if (next.uri.path == '/chain') {
            // Chaining block: keep history -> will exceed limit
            return Block.then(() => goRouter.go('/chain'));
          }
          return const Allow();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/start',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Start'))),
          ),
          GoRoute(
            path: '/blocked-once',
            builder:
                (_, __) =>
                    const Scaffold(body: Center(child: Text('BlockedOnce'))),
          ),
          GoRoute(
            path: '/chain',
            builder:
                (_, __) => const Scaffold(body: Center(child: Text('Chain'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/start');

      // 1st attempt: hard-stop; should not trigger onException
      router.go('/blocked-once');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/start');
      expect(onExceptionCalls, 0);

      // 2nd attempt: history should have been reset; still no onException
      router.go('/blocked-once');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/start');
      expect(onExceptionCalls, 0);

      // Chaining case: should exceed limit and fire onException once
      router.go('/chain');
      await exceededCompleter.future;
      await tester.pumpAndSettle();
      expect(onExceptionCalls, 1);
      // We're still on '/start' because the guarded nav never committed
      expect(router.state.uri.path, '/start');
    });

    testWidgets('restore runs onEnter -> legacy -> route-level redirect', (
      WidgetTester tester,
    ) async {
      final List<String> calls = <String>[];

      router = GoRouter(
        initialLocation: '/home',
        routes: <GoRoute>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/has-route-redirect',
            builder: (_, __) => const Scaffold(body: Text('Never shown')),
            redirect: (_, __) {
              calls.add('route-level');
              return '/redirected';
            },
          ),
          GoRoute(
            path: '/redirected',
            builder: (_, __) => const Scaffold(body: Text('Redirected')),
          ),
        ],
        onEnter: (_, __, ___, ____) {
          calls.add('onEnter');
          return const Allow();
        },
        // ignore: deprecated_member_use_from_same_package
        redirect: (_, __) {
          calls.add('legacy');
          return null;
        },
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Navigate to a route with route-level redirect
      router.go('/has-route-redirect');
      await tester.pumpAndSettle();

      // Verify execution order: onEnter -> legacy -> route-level
      expect(
        calls,
        containsAllInOrder(<String>['onEnter', 'legacy', 'route-level']),
      );
      expect(router.state.uri.path, '/redirected');
      expect(find.text('Redirected'), findsOneWidget);

      // Clear calls for restore test
      calls.clear();

      // Simulate restore by parsing with restore type
      final BuildContext context = tester.element(find.byType(Router<Object>));
      final GoRouteInformationParser parser = router.routeInformationParser;

      await parser.parseRouteInformationWithDependencies(
        RouteInformation(
          uri: Uri.parse('/has-route-redirect'),
          state: RouteInformationState<void>(
            type: NavigatingType.restore,
            baseRouteMatchList: router.routerDelegate.currentConfiguration,
          ),
        ),
        context,
      );

      // Verify restore also follows same order
      expect(
        calls,
        containsAllInOrder(<String>['onEnter', 'legacy', 'route-level']),
      );
    });
  });
}
