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
              ? const Block()
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
              ? const Block()
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
              goRouter.push('/recursive');
              return const Block();
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
          router.go('/sign-in');
          return const Block();
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
            goRouter.goNamed(
              'login-page',
              queryParameters: <String, String>{'from': next.uri.toString()},
            );
            return const Block();
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

          return const Block();
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
            return const Block();
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
            return const Block();
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
            return const Block();
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
            goRouter.go('/step-one');

            // We're blocking the original navigation
            return const Block();
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
            return const Block();
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
            return const Block();
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
  });
}
