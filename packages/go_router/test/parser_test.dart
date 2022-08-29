// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/configuration.dart';
import 'package:go_router/src/match.dart';
import 'package:go_router/src/matching.dart';
import 'package:go_router/src/parser.dart';

void main() {
  test('GoRouteInformationParser can parse route', () async {
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
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 100,
        topRedirect: (_) => null,
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    RouteMatchList matchesObj = await parser
        .parseRouteInformation(const RouteInformation(location: '/'));
    List<GoRouteMatch> matches = matchesObj.matches;
    expect(matches.length, 1);
    expect(matches[0].queryParams.isEmpty, isTrue);
    expect(matches[0].extra, isNull);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].location, '/');
    expect(matches[0].route, routes[0]);

    final Object extra = Object();
    matchesObj = await parser.parseRouteInformation(
        RouteInformation(location: '/abc?def=ghi', state: extra));
    matches = matchesObj.matches;
    expect(matches.length, 2);
    expect(matches[0].queryParams.length, 1);
    expect(matches[0].queryParams['def'], 'ghi');
    expect(matches[0].extra, extra);
    expect(matches[0].fullUriString, '/?def=ghi');
    expect(matches[0].location, '/');
    expect(matches[0].route, routes[0]);

    expect(matches[1].queryParams.length, 1);
    expect(matches[1].queryParams['def'], 'ghi');
    expect(matches[1].extra, extra);
    expect(matches[1].fullUriString, '/abc?def=ghi');
    expect(matches[1].location, '/abc');
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
      topRedirect: (_) => null,
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
      topRedirect: (_) => null,
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

  test('GoRouteInformationParser returns error when unknown route', () async {
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
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 100,
        topRedirect: (_) => null,
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    final RouteMatchList matchesObj = await parser
        .parseRouteInformation(const RouteInformation(location: '/def'));
    final List<GoRouteMatch> matches = matchesObj.matches;
    expect(matches.length, 1);
    expect(matches[0].queryParams.isEmpty, isTrue);
    expect(matches[0].extra, isNull);
    expect(matches[0].fullUriString, '/def');
    expect(matches[0].location, '/def');
    expect(matches[0].error!.toString(),
        'Exception: no routes for location: /def');
  });

  test('GoRouteInformationParser can work with route parameters', () async {
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
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 100,
        topRedirect: (_) => null,
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    final RouteMatchList matchesObj = await parser.parseRouteInformation(
        const RouteInformation(location: '/123/family/456'));
    final List<GoRouteMatch> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matches[0].queryParams.isEmpty, isTrue);
    expect(matches[0].extra, isNull);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].location, '/');

    expect(matches[1].queryParams.isEmpty, isTrue);
    expect(matches[1].extra, isNull);
    expect(matches[1].fullUriString, '/123/family/456');
    expect(matches[1].location, '/123/family/456');
    expect(matches[1].encodedParams.length, 2);
    expect(matches[1].encodedParams['uid'], '123');
    expect(matches[1].encodedParams['fid'], '456');
  });

  test(
      'GoRouteInformationParser processes top level redirect when there is no match',
      () async {
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
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 100,
        topRedirect: (GoRouterState state) {
          if (state.location != '/123/family/345') {
            return '/123/family/345';
          }
          return null;
        },
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    final RouteMatchList matchesObj = await parser
        .parseRouteInformation(const RouteInformation(location: '/random/uri'));
    final List<GoRouteMatch> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].location, '/');

    expect(matches[1].fullUriString, '/123/family/345');
    expect(matches[1].location, '/123/family/345');
  });

  test(
      'GoRouteInformationParser can do route level redirect when there is a match',
      () async {
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
            redirect: (_) => '/123/family/345',
            builder: (_, __) => throw UnimplementedError(),
          ),
        ],
      ),
    ];
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 100,
        topRedirect: (_) => null,
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    final RouteMatchList matchesObj = await parser
        .parseRouteInformation(const RouteInformation(location: '/redirect'));
    final List<GoRouteMatch> matches = matchesObj.matches;

    expect(matches.length, 2);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].location, '/');

    expect(matches[1].fullUriString, '/123/family/345');
    expect(matches[1].location, '/123/family/345');
  });

  test('GoRouteInformationParser throws an exception when route is malformed',
      () async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/abc',
        builder: (_, __) => const Placeholder(),
      ),
    ];
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 100,
        topRedirect: (_) => null,
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    expect(() async {
      await parser.parseRouteInformation(
          const RouteInformation(location: '::Not valid URI::'));
    }, throwsA(isA<FormatException>()));
  });

  test('GoRouteInformationParser returns an error if a redirect is detected.',
      () async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/abc',
        builder: (_, __) => const Placeholder(),
        redirect: (GoRouterState state) => state.location,
      ),
    ];
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 5,
        topRedirect: (_) => null,
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    final RouteMatchList matchesObj = await parser
        .parseRouteInformation(const RouteInformation(location: '/abd'));
    final List<GoRouteMatch> matches = matchesObj.matches;

    expect(matches, hasLength(1));
    expect(matches.first.error, isNotNull);
  });

  test('Creates a match for ShellRoute', () async {
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
    final GoRouteInformationParser parser = GoRouteInformationParser(
      configuration: RouteConfiguration(
        routes: routes,
        redirectLimit: 5,
        topRedirect: (_) => null,
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );

    final RouteMatchList matchesObj = await parser
        .parseRouteInformation(const RouteInformation(location: '/a'));
    final List<GoRouteMatch> matches = matchesObj.matches;

    expect(matches, hasLength(2));
    expect(matches.first.error, isNull);
  });
}
