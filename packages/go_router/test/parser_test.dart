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
}
