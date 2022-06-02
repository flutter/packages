// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_route_information_parser.dart';
import 'package:go_router/src/go_route_match.dart';

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
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_) => null,
    );

    List<GoRouteMatch> matches = await parser
        .parseRouteInformation(const RouteInformation(location: '/'));
    expect(matches.length, 1);
    expect(matches[0].queryParams.isEmpty, isTrue);
    expect(matches[0].extra, isNull);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].subloc, '/');
    expect(matches[0].route, routes[0]);

    final Object extra = Object();
    matches = await parser.parseRouteInformation(
        RouteInformation(location: '/abc?def=ghi', state: extra));
    expect(matches.length, 2);
    expect(matches[0].queryParams.length, 1);
    expect(matches[0].queryParams['def'], 'ghi');
    expect(matches[0].extra, extra);
    expect(matches[0].fullUriString, '/?def=ghi');
    expect(matches[0].subloc, '/');
    expect(matches[0].route, routes[0]);

    expect(matches[1].queryParams.length, 1);
    expect(matches[1].queryParams['def'], 'ghi');
    expect(matches[1].extra, extra);
    expect(matches[1].fullUriString, '/abc?def=ghi');
    expect(matches[1].subloc, '/abc');
    expect(matches[1].route, routes[0].routes[0]);
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
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_) => null,
    );

    final List<GoRouteMatch> matches = await parser
        .parseRouteInformation(const RouteInformation(location: '/def'));
    expect(matches.length, 1);
    expect(matches[0].queryParams.isEmpty, isTrue);
    expect(matches[0].extra, isNull);
    expect(matches[0].fullUriString, '/def');
    expect(matches[0].subloc, '/def');
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
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_) => null,
    );

    final List<GoRouteMatch> matches = await parser.parseRouteInformation(
        const RouteInformation(location: '/123/family/456'));
    expect(matches.length, 2);
    expect(matches[0].queryParams.isEmpty, isTrue);
    expect(matches[0].extra, isNull);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].subloc, '/');

    expect(matches[1].queryParams.isEmpty, isTrue);
    expect(matches[1].extra, isNull);
    expect(matches[1].fullUriString, '/123/family/456');
    expect(matches[1].subloc, '/123/family/456');
    expect(matches[1].encodedParams.length, 2);
    expect(matches[1].encodedParams['uid'], '123');
    expect(matches[1].encodedParams['fid'], '456');
  });

  test('GoRouteInformationParser can do top level redirect', () async {
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
      routes: routes,
      redirectLimit: 100,
      topRedirect: (GoRouterState state) {
        if (state.location != '/123/family/345') {
          return '/123/family/345';
        }
        return null;
      },
    );

    final List<GoRouteMatch> matches = await parser
        .parseRouteInformation(const RouteInformation(location: '/random/uri'));
    expect(matches.length, 2);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].subloc, '/');

    expect(matches[1].fullUriString, '/123/family/345');
    expect(matches[1].subloc, '/123/family/345');
  });

  test('GoRouteInformationParser can do route level redirect', () async {
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
      routes: routes,
      redirectLimit: 100,
      topRedirect: (_) => null,
    );

    final List<GoRouteMatch> matches = await parser
        .parseRouteInformation(const RouteInformation(location: '/redirect'));
    expect(matches.length, 2);
    expect(matches[0].fullUriString, '/');
    expect(matches[0].subloc, '/');

    expect(matches[1].fullUriString, '/123/family/345');
    expect(matches[1].subloc, '/123/family/345');
  });
}
