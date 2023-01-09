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
        restLoc: '/users/123',
        parentSubloc: '',
        pathParameters: pathParameters,
        extra: const _Extra('foo'),
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.subloc, '/users/123');
      expect(pathParameters['userId'], '123');
      expect(match.extra, const _Extra('foo'));
      expect(match.error, isNull);
      expect(match.pageKey, isNotNull);
    });

    test('subloc', () {
      final GoRoute route = GoRoute(
        path: 'users/:userId',
        builder: _builder,
      );
      final Map<String, String> pathParameters = <String, String>{};
      final RouteMatch? match = RouteMatch.match(
        route: route,
        restLoc: 'users/123',
        parentSubloc: '/home',
        pathParameters: pathParameters,
        extra: const _Extra('foo'),
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.subloc, '/home/users/123');
      expect(pathParameters['userId'], '123');
      expect(match.extra, const _Extra('foo'));
      expect(match.error, isNull);
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
        restLoc: 'users/123',
        parentSubloc: '/home',
        pathParameters: pathParameters,
        extra: const _Extra('foo'),
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
        restLoc: 'users/123',
        parentSubloc: '/home',
        pathParameters: pathParameters,
        extra: const _Extra('foo'),
      );

      final RouteMatch? match2 = RouteMatch.match(
        route: route,
        restLoc: 'users/1234',
        parentSubloc: '/home',
        pathParameters: pathParameters,
        extra: const _Extra('foo1'),
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
        restLoc: 'users/123',
        parentSubloc: '/home',
        pathParameters: pathParameters,
        extra: const _Extra('foo'),
      );

      final RouteMatch? match2 = RouteMatch.match(
        route: route,
        restLoc: 'users/1234',
        parentSubloc: '/home',
        pathParameters: pathParameters,
        extra: const _Extra('foo1'),
      );

      expect(match1!.pageKey, match2!.pageKey);
    });
  });
}

@immutable
class _Extra {
  const _Extra(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return other is _Extra && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

Widget _builder(BuildContext context, GoRouterState state) =>
    const Placeholder();

Widget _shellBuilder(BuildContext context, GoRouterState state, Widget child) =>
    const Placeholder();
