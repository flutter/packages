// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/configuration.dart';
import 'package:go_router/src/match.dart';
import 'package:go_router/src/matching.dart';
import 'package:go_router/src/parser.dart';

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
            const RouteInformation(location: '/'), context);
    List<RouteMatch> matches = matchesObj.matches;
    expect(matches.length, 1);
    expect(matchesObj.uri.toString(), '/');
    expect(matches[0].extra, isNull);
    expect(matches[0].subloc, '/');
    expect(matches[0].route, routes[0]);

    final Object extra = Object();
    matchesObj = await parser.parseRouteInformationWithDependencies(
        RouteInformation(location: '/abc?def=ghi', state: extra), context);
    matches = matchesObj.matches;
    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/abc?def=ghi');
    expect(matches[0].extra, extra);
    expect(matches[0].subloc, '/');
    expect(matches[0].route, routes[0]);

    expect(matches[1].extra, extra);
    expect(matches[1].subloc, '/abc');
    expect(matches[1].route, routes[0].routes[0]);
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

    final RouteConfiguration configuration = RouteConfiguration(
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_, __) => null,
      navigatorKey: GlobalKey<NavigatorState>(),
    );

    expect(configuration.namedLocation('lowercase'), '/abc');
    expect(configuration.namedLocation('LOWERCASE'), '/abc');
    expect(configuration.namedLocation('camelCase'), '/efg');
    expect(configuration.namedLocation('camelcase'), '/efg');
    expect(configuration.namedLocation('snake_case'), '/hij');
    expect(configuration.namedLocation('SNAKE_CASE'), '/hij');

    // With query parameters
    expect(configuration.namedLocation('lowercase'), '/abc');
    expect(
        configuration.namedLocation('lowercase',
            queryParams: const <String, String>{'q': '1'}),
        '/abc?q=1');
    expect(
        configuration.namedLocation('lowercase',
            queryParams: const <String, String>{'q': '1', 'g': '2'}),
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

    final RouteConfiguration configuration = RouteConfiguration(
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_, __) => null,
      navigatorKey: GlobalKey<NavigatorState>(),
    );

    expect(
      configuration
          .namedLocation('routeName', queryParams: const <String, dynamic>{
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
            const RouteInformation(location: '/def'), context);
    final List<RouteMatch> matches = matchesObj.matches;
    expect(matches.length, 1);
    expect(matchesObj.uri.toString(), '/def');
    expect(matches[0].extra, isNull);
    expect(matches[0].subloc, '/def');
    expect(matches[0].error!.toString(),
        'Exception: no routes for location: /def');
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
            const RouteInformation(location: '/123/family/456'), context);
    final List<RouteMatch> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/123/family/456');
    expect(matchesObj.pathParameters.length, 2);
    expect(matchesObj.pathParameters['uid'], '123');
    expect(matchesObj.pathParameters['fid'], '456');
    expect(matches[0].extra, isNull);
    expect(matches[0].subloc, '/');

    expect(matches[1].extra, isNull);
    expect(matches[1].subloc, '/123/family/456');
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
        if (state.location != '/123/family/345') {
          return '/123/family/345';
        }
        return null;
      },
    );

    final BuildContext context = tester.element(find.byType(Router<Object>));
    final RouteMatchList matchesObj =
        await parser.parseRouteInformationWithDependencies(
            const RouteInformation(location: '/random/uri'), context);
    final List<RouteMatch> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/123/family/345');
    expect(matches[0].subloc, '/');

    expect(matches[1].subloc, '/123/family/345');
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
            const RouteInformation(location: '/redirect'), context);
    final List<RouteMatch> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matchesObj.uri.toString(), '/123/family/345');
    expect(matches[0].subloc, '/');

    expect(matches[1].subloc, '/123/family/345');
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
          const RouteInformation(location: '::Not valid URI::'), context);
    }, throwsA(isA<FormatException>()));
  });

  testWidgets(
      'GoRouteInformationParser returns an error if a redirect is detected.',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/abc',
        builder: (_, __) => const Placeholder(),
        redirect: (BuildContext context, GoRouterState state) => state.location,
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
            const RouteInformation(location: '/abd'), context);
    final List<RouteMatch> matches = matchesObj.matches;

    expect(matches, hasLength(1));
    expect(matches.first.error, isNotNull);
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
            const RouteInformation(location: '/a'), context);
    final List<RouteMatch> matches = matchesObj.matches;

    expect(matches, hasLength(2));
    expect(matches.first.error, isNull);
  });
}
