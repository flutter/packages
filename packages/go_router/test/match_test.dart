// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
        matchedPath: '',
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
        matchedPath: '/home',
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
        matchedPath: '/home',
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
        matchedPath: '/home',
        pathParameters: pathParameters,
      );

      final RouteMatch? match2 = RouteMatch.match(
        route: route,
        remainingLocation: 'users/1234',
        matchedLocation: '/home',
        matchedPath: '/home',
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
        matchedPath: '/home',
        pathParameters: pathParameters,
      );

      final RouteMatch? match2 = RouteMatch.match(
        route: route,
        remainingLocation: 'users/1234',
        matchedLocation: '/home',
        matchedPath: '/home',
        pathParameters: pathParameters,
      );

      expect(match1!.pageKey, match2!.pageKey);
    });
  });

  group('ImperativeRouteMatch', () {
    final RouteMatchList matchList1 = RouteMatchList(
        matches: <RouteMatch>[
          RouteMatch(
            route: GoRoute(path: '/', builder: (_, __) => const Text('hi')),
            matchedLocation: '/',
            pageKey: const ValueKey<String>('dummy'),
          ),
        ],
        uri: Uri.parse('/'),
        pathParameters: const <String, String>{});

    final RouteMatchList matchList2 = RouteMatchList(
        matches: <RouteMatch>[
          RouteMatch(
            route: GoRoute(path: '/a', builder: (_, __) => const Text('a')),
            matchedLocation: '/a',
            pageKey: const ValueKey<String>('dummy'),
          ),
        ],
        uri: Uri.parse('/a'),
        pathParameters: const <String, String>{});

    const ValueKey<String> key1 = ValueKey<String>('key1');
    const ValueKey<String> key2 = ValueKey<String>('key2');

    final Completer<void> completer1 = Completer<void>();
    final Completer<void> completer2 = Completer<void>();

    test('can equal and has', () async {
      ImperativeRouteMatch match1 = ImperativeRouteMatch(
          pageKey: key1, matches: matchList1, completer: completer1);
      ImperativeRouteMatch match2 = ImperativeRouteMatch(
          pageKey: key1, matches: matchList1, completer: completer1);
      expect(match1 == match2, isTrue);
      expect(match1.hashCode == match2.hashCode, isTrue);

      match1 = ImperativeRouteMatch(
          pageKey: key1, matches: matchList1, completer: completer1);
      match2 = ImperativeRouteMatch(
          pageKey: key2, matches: matchList1, completer: completer1);
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);

      match1 = ImperativeRouteMatch(
          pageKey: key1, matches: matchList1, completer: completer1);
      match2 = ImperativeRouteMatch(
          pageKey: key1, matches: matchList2, completer: completer1);
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);

      match1 = ImperativeRouteMatch(
          pageKey: key1, matches: matchList1, completer: completer1);
      match2 = ImperativeRouteMatch(
          pageKey: key1, matches: matchList1, completer: completer2);
      expect(match1 == match2, isFalse);
      expect(match1.hashCode == match2.hashCode, isFalse);
    });
  });
}

Widget _builder(BuildContext context, GoRouterState state) =>
    const Placeholder();

Widget _shellBuilder(BuildContext context, GoRouterState state, Widget child) =>
    const Placeholder();
