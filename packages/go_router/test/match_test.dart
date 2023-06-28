// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/match.dart';

void main() {
  group('RouteMatch', () {
    test('simple', () {
      final GoRoute route = GoRoute(
        path: '/users/:userId',
        builder: _builder,
      );
      final Map<String, String> pathParameters = <String, String>{};
      final RouteMatch? match = RouteMatch.match(
        route: route,
        remainingLocation: '/users/123',
        matchedLocation: '',
        pathParameters: pathParameters,
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.matchedLocation, '/users/123');
      expect(pathParameters['userId'], '123');
      expect(match.pageKey, isNotNull);
    });

    test('matchedLocation', () {
      final GoRoute route = GoRoute(
        path: 'users/:userId',
        builder: _builder,
      );
      final Map<String, String> pathParameters = <String, String>{};
      final RouteMatch? match = RouteMatch.match(
        route: route,
        remainingLocation: 'users/123',
        matchedLocation: '/home',
        pathParameters: pathParameters,
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.matchedLocation, '/home/users/123');
      expect(pathParameters['userId'], '123');
      expect(match.pageKey, isNotNull);
    });

    test('ShellRoute has a unique pageKey', () {
      final ShellRoute route = ShellRoute(
        builder: _shellBuilder,
        routes: <GoRoute>[
          GoRoute(
            path: '/users/:userId',
            builder: _builder,
          ),
        ],
      );
      final Map<String, String> pathParameters = <String, String>{};
      final RouteMatch? match = RouteMatch.match(
        route: route,
        remainingLocation: 'users/123',
        matchedLocation: '/home',
        pathParameters: pathParameters,
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.pageKey, isNotNull);
    });

    test('ShellRoute Match has stable unique key', () {
      final ShellRoute route = ShellRoute(
        builder: _shellBuilder,
        routes: <GoRoute>[
          GoRoute(
            path: '/users/:userId',
            builder: _builder,
          ),
        ],
      );
      final Map<String, String> pathParameters = <String, String>{};
      final RouteMatch? match1 = RouteMatch.match(
        route: route,
        remainingLocation: 'users/123',
        matchedLocation: '/home',
        pathParameters: pathParameters,
      );

      final RouteMatch? match2 = RouteMatch.match(
        route: route,
        remainingLocation: 'users/1234',
        matchedLocation: '/home',
        pathParameters: pathParameters,
      );

      expect(match1!.pageKey, match2!.pageKey);
    });

    test('GoRoute Match has stable unique key', () {
      final GoRoute route = GoRoute(
        path: 'users/:userId',
        builder: _builder,
      );
      final Map<String, String> pathParameters = <String, String>{};
      final RouteMatch? match1 = RouteMatch.match(
        route: route,
        remainingLocation: 'users/123',
        matchedLocation: '/home',
        pathParameters: pathParameters,
      );

      final RouteMatch? match2 = RouteMatch.match(
        route: route,
        remainingLocation: 'users/1234',
        matchedLocation: '/home',
        pathParameters: pathParameters,
      );

      expect(match1!.pageKey, match2!.pageKey);
    });
  });
}

Widget _builder(BuildContext context, GoRouterState state) =>
    const Placeholder();

Widget _shellBuilder(BuildContext context, GoRouterState state, Widget child) =>
    const Placeholder();
