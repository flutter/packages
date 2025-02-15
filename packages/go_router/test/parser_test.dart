// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

RouteInformation createRouteInformation(String location, [Object? extra]) {
  return RouteInformation(
      uri: Uri.parse(location),
      state:
          RouteInformationState<void>(type: NavigatingType.go, extra: extra));
}

void main() {
  Future<GoRouteInformationParser> createParser(
    WidgetTester tester, {
    required List<RouteBase> routes,
    int redirectLimit = 5,
    GoRouterRedirect? redirect,
  }) async {
    final GoRouter router = GoRouter(
      routes: routes,
      redirectLimit: redirectLimit,
      redirect: redirect,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
    ));
    return router.routeInformationParser;
  }

  testWidgets('GoRouteInformationParser can parse route',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));

    RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('/'), context);
    List<RouteMatchBase> matches = matchesObj.matches;
    expect(matches.length, 1);
    expect(matchesObj.uri.toString(), '/');
    expect(matchesObj.extra, isNull);
    expect(matches[0].matchedLocation, '/');
    expect(matches[0].route, routes[0]);

    final Object extra = Object();
    matchesObj = await parser.parseRouteInformationWithDependencies(
        createRouteInformation('/abc?def=ghi', extra), context);
    matches = matchesObj.matches;
    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/abc?def=ghi');
    expect(matchesObj.extra, extra);
    expect(matches[0].matchedLocation, '/');
    expect(matches[0].route, routes[0]);

    expect(matches[1].matchedLocation, '/abc');
    expect(matches[1].route, routes[0].routes[0]);
  });

  testWidgets('GoRouteInformationParser can handle empty path for non http uri',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));

    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('elbaapp://domain'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;
    expect(matches.length, 1);
    expect(matchesObj.uri.toString(), 'elbaapp://domain/');
  });

  testWidgets('GoRouteInformationParser cleans up uri',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));

    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('http://domain/abc/?query=bde'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;
    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), 'http://domain/abc?query=bde');
  });

  testWidgets(
      "GoRouteInformationParser can parse deeplink root route and maintain uri's scheme, host, query and fragment",
      (WidgetTester tester) async {
    const String expectedScheme = 'https';
    const String expectedHost = 'www.example.com';
    const String expectedQuery = 'abc=def';
    const String expectedFragment = 'abc';
    const String expectedUriString =
        '$expectedScheme://$expectedHost/?$expectedQuery#$expectedFragment';
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));

    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation(expectedUriString), context);
    final List<RouteMatchBase> matches = matchesObj.matches;
    expect(matches.length, 1);
    expect(matchesObj.uri.toString(), expectedUriString);
    expect(matchesObj.uri.scheme, expectedScheme);
    expect(matchesObj.uri.host, expectedHost);
    expect(matchesObj.uri.query, expectedQuery);
    expect(matchesObj.uri.fragment, expectedFragment);

    expect(matches[0].matchedLocation, '/');
    expect(matches[0].route, routes[0]);
  });

  testWidgets(
      "GoRouteInformationParser can parse deeplink route with a path and maintain uri's scheme, host, query and fragment",
      (WidgetTester tester) async {
    const String expectedScheme = 'https';
    const String expectedHost = 'www.example.com';
    const String expectedPath = '/abc';
    const String expectedQuery = 'abc=def';
    const String expectedFragment = 'abc';
    const String expectedUriString =
        '$expectedScheme://$expectedHost$expectedPath?$expectedQuery#$expectedFragment';
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));

    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation(expectedUriString), context);
    final List<RouteMatchBase> matches = matchesObj.matches;
    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), expectedUriString);
    expect(matchesObj.uri.scheme, expectedScheme);
    expect(matchesObj.uri.host, expectedHost);
    expect(matchesObj.uri.path, expectedPath);
    expect(matchesObj.uri.query, expectedQuery);
    expect(matchesObj.uri.fragment, expectedFragment);

    expect(matches[0].matchedLocation, '/');
    expect(matches[0].route, routes[0]);

    expect(matches[1].matchedLocation, '/abc');
    expect(matches[1].route, routes[0].routes[0]);
  });

  testWidgets(
      'GoRouteInformationParser can restore full route matches if optionURLReflectsImperativeAPIs is true',
      (WidgetTester tester) async {
    final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    GoRouter.optionURLReflectsImperativeAPIs = true;
    final GoRouter router =
        await createRouter(routes, tester, navigatorKey: navKey);

    // Generate RouteMatchList with imperative route match
    router.go('/abc');
    await tester.pumpAndSettle();
    router.push('/');
    await tester.pumpAndSettle();
    final RouteMatchList matchList = router.routerDelegate.currentConfiguration;
    expect(matchList.uri.toString(), '/abc');
    expect(matchList.matches.length, 3);

    final RouteInformation restoredRouteInformation =
        router.routeInformationParser.restoreRouteInformation(matchList)!;
    expect(restoredRouteInformation.uri.path, '/');

    // Can restore back to original RouteMatchList.
    final RouteMatchList parsedRouteMatch = await router.routeInformationParser
        .parseRouteInformationWithDependencies(
            restoredRouteInformation, navKey.currentContext!);
    expect(parsedRouteMatch.uri.toString(), '/abc');
    expect(parsedRouteMatch.matches.length, 3);

    GoRouter.optionURLReflectsImperativeAPIs = false;
  });

  test('GoRouteInformationParser can retrieve route by name', () async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            name: 'lowercase',
            builder: (_, __) => const Placeholder(),
          ),
          GoRoute(
            path: 'efg',
            name: 'camelCase',
            builder: (_, __) => const Placeholder(),
          ),
          GoRoute(
            path: 'hij',
            name: 'snake_case',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];

    final RouteConfiguration configuration = createRouteConfiguration(
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_, __) => null,
      navigatorKey: GlobalKey<NavigatorState>(),
    );

    expect(configuration.namedLocation('lowercase'), '/abc');
    expect(configuration.namedLocation('camelCase'), '/efg');
    expect(configuration.namedLocation('snake_case'), '/hij');

    // With query parameters
    expect(configuration.namedLocation('lowercase'), '/abc');
    expect(
        configuration.namedLocation('lowercase',
            queryParameters: const <String, String>{'q': '1'}),
        '/abc?q=1');
    expect(
        configuration.namedLocation('lowercase',
            queryParameters: const <String, String>{'q': '1', 'g': '2'}),
        '/abc?q=1&g=2');
  });

  test(
      'GoRouteInformationParser can retrieve route by name with query parameters',
      () async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            name: 'routeName',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];

    final RouteConfiguration configuration = createRouteConfiguration(
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_, __) => null,
      navigatorKey: GlobalKey<NavigatorState>(),
    );

    expect(
      configuration
          .namedLocation('routeName', queryParameters: const <String, dynamic>{
        'q1': 'v1',
        'q2': <String>['v2', 'v3'],
      }),
      '/abc?q1=v1&q2=v2&q2=v3',
    );
  });

  testWidgets('GoRouteInformationParser returns error when unknown route',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));

    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('/def'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;
    expect(matches.length, 0);
    expect(matchesObj.uri.toString(), '/def');
    expect(matchesObj.extra, isNull);
    expect(matchesObj.error!.toString(),
        'GoException: no routes for location: /def');
  });

  testWidgets(
      'GoRouteInformationParser calls redirector with correct uri when unknown route',
      (WidgetTester tester) async {
    String? lastRedirectLocation;
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: 'abc',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, GoRouterState state) {
        lastRedirectLocation = state.uri.toString();
        return null;
      },
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    await parser.parseRouteInformationWithDependencies(
        createRouteInformation('/def'), context);
    expect(lastRedirectLocation, '/def');
  });

  testWidgets('GoRouteInformationParser can work with route parameters',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: ':uid/family/:fid',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('/123/family/456'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/123/family/456');
    expect(matchesObj.pathParameters.length, 2);
    expect(matchesObj.pathParameters['uid'], '123');
    expect(matchesObj.pathParameters['fid'], '456');
    expect(matchesObj.extra, isNull);
    expect(matches[0].matchedLocation, '/');

    expect(matches[1].matchedLocation, '/123/family/456');
  });

  testWidgets(
      'GoRouteInformationParser processes top level redirect when there is no match',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: ':uid/family/:fid',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (BuildContext context, GoRouterState state) {
        if (state.uri.toString() != '/123/family/345') {
          return '/123/family/345';
        }
        return null;
      },
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('/random/uri'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/123/family/345');
    expect(matches[0].matchedLocation, '/');

    expect(matches[1].matchedLocation, '/123/family/345');
  });

  testWidgets(
      'GoRouteInformationParser can do route level redirect when there is a match',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const Placeholder(),
        routes: <GoRoute>[
          GoRoute(
            path: ':uid/family/:fid',
            builder: (_, __) => const Placeholder(),
          ),
          GoRoute(
            path: 'redirect',
            redirect: (_, __) => '/123/family/345',
            builder: (_, __) => throw UnimplementedError(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('/redirect'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/123/family/345');
    expect(matches[0].matchedLocation, '/');

    expect(matches[1].matchedLocation, '/123/family/345');
  });

  testWidgets(
      'GoRouteInformationParser throws an exception when route is malformed',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/abc',
        builder: (_, __) => const Placeholder(),
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirectLimit: 100,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    expect(() async {
      await parser.parseRouteInformationWithDependencies(
          createRouteInformation('::Not valid URI::'), context);
    }, throwsA(isA<FormatException>()));
  });

  testWidgets(
      'GoRouteInformationParser returns an error if a redirect is detected.',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/abc',
        builder: (_, __) => const Placeholder(),
        redirect: (BuildContext context, GoRouterState state) =>
            state.uri.toString(),
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('/abd'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;

    expect(matches, hasLength(0));
    expect(matchesObj.error, isNotNull);
  });

  testWidgets('Creates a match for ShellRoute', (WidgetTester tester) async {
    final List<RouteBase> routes = <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return Scaffold(
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(
                body: Text('Screen A'),
              );
            },
          ),
          GoRoute(
            path: '/b',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(
                body: Text('Screen B'),
              );
            },
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = await createParser(
      tester,
      routes: routes,
      redirect: (_, __) => null,
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            createRouteInformation('/a'), context);
    final List<RouteMatchBase> matches = matchesObj.matches;

    expect(matches, hasLength(1));
    final ShellRouteMatch match = matches.first as ShellRouteMatch;
    expect(match.matches, hasLength(1));
    expect(matchesObj.error, isNull);
  });

  testWidgets(
    'GoRouteInformationParser handles onEnter navigation control correctly',
    (WidgetTester tester) async {
      // Track states for verification
      GoRouterState? capturedCurrentState;
      GoRouterState? capturedNextState;
      int onEnterCallCount = 0;

      final GoRouter router = GoRouter(
        initialLocation: '/',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) {
          onEnterCallCount++;
          capturedCurrentState = current;
          capturedNextState = next;

          // Block navigation only to /blocked route
          return !next.uri.path.contains('blocked');
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

      // Important: Dispose router at end
      addTearDown(() async {
        router.dispose();
        // Allow pending timers and microtasks to complete
        await tester.pumpAndSettle();
      });

      // Initialize the router
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final GoRouteInformationParser parser = router.routeInformationParser;
      final BuildContext context = tester.element(find.byType(Router<Object>));

      // Test Case 1: Initial Route
      expect(onEnterCallCount, 1,
          reason: 'onEnter should be called for initial route');
      expect(
        capturedCurrentState?.uri.path,
        capturedNextState?.uri.path,
        reason: 'Initial route should have same current and next state',
      );

      // Test Case 2: Blocked Navigation
      final RouteMatchList beforeBlockedNav =
          router.routerDelegate.currentConfiguration;

      final RouteInformation blockedRouteInfo = RouteInformation(
        uri: Uri.parse('/blocked'),
        state: RouteInformationState<void>(type: NavigatingType.go),
      );

      final RouteMatchList blockedMatch =
          await parser.parseRouteInformationWithDependencies(
        blockedRouteInfo,
        context,
      );

      // Wait for any animations to complete
      await tester.pumpAndSettle();

      expect(onEnterCallCount, 2,
          reason: 'onEnter should be called for blocked route');
      expect(
        blockedMatch.uri.toString(),
        equals(beforeBlockedNav.uri.toString()),
        reason: 'Navigation to blocked route should retain previous uri',
      );
      expect(
        capturedCurrentState?.uri.path,
        '/',
        reason: 'Current state should be root path',
      );
      expect(
        capturedNextState?.uri.path,
        '/blocked',
        reason: 'Next state should be blocked path',
      );

      // Cleanup properly
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'Navigation is blocked correctly when onEnter returns false',
    (WidgetTester tester) async {
      final List<String> navigationAttempts = <String>[];
      String currentPath = '/';
      late final GoRouter router;

      router = GoRouter(
        initialLocation: '/',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) {
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

      // Important: Add tearDown before any test code
      addTearDown(() async {
        router.dispose();
        await tester.pumpAndSettle(); // Allow pending timers to complete
      });

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final BuildContext context = tester.element(find.byType(Router<Object>));
      final GoRouteInformationParser parser = router.routeInformationParser;

      // Try blocked route
      final RouteInformation blockedInfo = RouteInformation(
        uri: Uri.parse('/blocked'),
        state: RouteInformationState<void>(type: NavigatingType.go),
      );

      final RouteMatchList blockedResult =
          await parser.parseRouteInformationWithDependencies(
        blockedInfo,
        context,
      );

      expect(blockedResult.uri.path, '/');
      expect(currentPath, '/');
      expect(navigationAttempts, contains('/blocked'));

      // Try allowed route
      final RouteInformation allowedInfo = RouteInformation(
        uri: Uri.parse('/allowed'),
        state: RouteInformationState<void>(type: NavigatingType.go),
      );

      final RouteMatchList allowedResult =
          await parser.parseRouteInformationWithDependencies(
        allowedInfo,
        context,
      );

      expect(allowedResult.uri.path, '/allowed');
      expect(navigationAttempts, contains('/allowed'));

      // Important: Final cleanup
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'onEnter returns safe fallback for blocked route without triggering loop detection',
    (WidgetTester tester) async {
      final List<String> navigationAttempts = <String>[];
      int onEnterCallCount = 0;

      final GoRouter router = GoRouter(
        initialLocation: '/',
        redirectLimit: 3,
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) {
          onEnterCallCount++;
          navigationAttempts.add(next.uri.path);
          // Only allow navigation when already at the safe fallback ('/')
          return next.uri.path == '/';
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Placeholder(),
            routes: <GoRoute>[
              GoRoute(
                path: 'loop',
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
        ],
      );

      addTearDown(() async {
        router.dispose();
        await tester.pumpAndSettle();
      });

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final BuildContext context = tester.element(find.byType(Router<Object>));
      final GoRouteInformationParser parser = router.routeInformationParser;

      // Try navigating to '/loop', which onEnter always blocks.
      final RouteInformation loopInfo = RouteInformation(
        uri: Uri.parse('/loop'),
        state: RouteInformationState<void>(type: NavigatingType.go),
      );

      final RouteMatchList result =
          await parser.parseRouteInformationWithDependencies(loopInfo, context);

      expect(result.uri.path, equals('/'));
      expect(onEnterCallCount, greaterThanOrEqualTo(1));
      expect(navigationAttempts, contains('/loop'));
    },
  );
  testWidgets('onEnter handles asynchronous decisions correctly',
      (WidgetTester tester) async {
    // Wrap our async test in runAsync so that real async timers run properly.
    await tester.runAsync(() async {
      final List<String> navigationAttempts = <String>[];
      int onEnterCallCount = 0;

      final GoRouter router = GoRouter(
        initialLocation: '/',
        onEnter: (
          BuildContext context,
          GoRouterState current,
          GoRouterState next,
          GoRouter goRouter,
        ) async {
          onEnterCallCount++;
          navigationAttempts.add(next.uri.path);

          // Simulate a short asynchronous operation (e.g., data fetch)
          await Future<void>.delayed(const Duration(milliseconds: 100));

          // Block navigation for paths containing 'delayed-blocked'
          return !next.uri.path.contains('delayed-blocked');
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Placeholder(),
            routes: <GoRoute>[
              GoRoute(
                path: 'delayed-allowed',
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path: 'delayed-blocked',
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
        ],
      );

      // Tear down the router after the test
      addTearDown(() async {
        router.dispose();
        await tester.pumpAndSettle();
      });

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final BuildContext context = tester.element(find.byType(Router<Object>));
      final GoRouteInformationParser parser = router.routeInformationParser;

      // Test Case 1: Allowed Route (with async delay)
      final RouteInformation allowedInfo = RouteInformation(
        uri: Uri.parse('/delayed-allowed'),
        state: RouteInformationState<void>(type: NavigatingType.go),
      );

      final RouteMatchList allowedResult = await parser
          .parseRouteInformationWithDependencies(allowedInfo, context);
      // Pump to advance the timer past our 100ms delay.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(allowedResult.uri.path, '/delayed-allowed');
      expect(onEnterCallCount, greaterThan(0));
      expect(navigationAttempts, contains('/delayed-allowed'));

      // Test Case 2: Blocked Route (with async delay)
      final RouteInformation blockedInfo = RouteInformation(
        uri: Uri.parse('/delayed-blocked'),
        state: RouteInformationState<void>(type: NavigatingType.go),
      );

      final RouteMatchList blockedResult = await parser
          .parseRouteInformationWithDependencies(blockedInfo, context);
      // Again, pump past the delay.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Since we already have a last successful match (from the allowed route),
      // our fallback returns that match. So we expect '/delayed-allowed'.
      expect(blockedResult.uri.path, '/delayed-allowed');
      expect(onEnterCallCount, greaterThan(1));
      expect(navigationAttempts, contains('/delayed-blocked'));
    });
  });
}
