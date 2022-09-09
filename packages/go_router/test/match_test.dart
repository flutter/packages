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
      final RouteMatch? match = RouteMatch.match(
        route: route,
        restLoc: '/users/123',
        parentSubloc: '',
        fullpath: '/users/:userId',
        queryParams: <String, String>{},
        extra: const _Extra('foo'),
        queryParametersAll: <String, List<String>>{
          'bar': <String>['baz', 'biz'],
        },
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.subloc, '/users/123');
      expect(match.fullpath, '/users/:userId');
      expect(match.encodedParams['userId'], '123');
      expect(match.queryParams['foo'], isNull);
      expect(match.queryParametersAll['bar'], <String>['baz', 'biz']);
      expect(match.extra, const _Extra('foo'));
      expect(match.error, isNull);
      expect(match.pageKey, isNull);
      expect(match.fullUriString, '/users/123?bar=baz&bar=biz');
    });
    test('subloc', () {
      final GoRoute route = GoRoute(
        path: 'users/:userId',
        builder: _builder,
      );
      final RouteMatch? match = RouteMatch.match(
        route: route,
        restLoc: 'users/123',
        parentSubloc: '/home',
        fullpath: '/home/users/:userId',
        queryParams: <String, String>{
          'foo': 'bar',
        },
        queryParametersAll: <String, List<String>>{
          'foo': <String>['bar'],
        },
        extra: const _Extra('foo'),
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.subloc, '/home/users/123');
      expect(match.fullpath, '/home/users/:userId');
      expect(match.encodedParams['userId'], '123');
      expect(match.queryParams['foo'], 'bar');
      expect(match.extra, const _Extra('foo'));
      expect(match.error, isNull);
      expect(match.pageKey, isNull);
      expect(match.fullUriString, '/home/users/123?foo=bar');
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
      final RouteMatch? match = RouteMatch.match(
        route: route,
        restLoc: 'users/123',
        parentSubloc: '/home',
        fullpath: '/home/users/:userId',
        queryParams: <String, String>{
          'foo': 'bar',
        },
        queryParametersAll: <String, List<String>>{
          'foo': <String>['bar'],
        },
        extra: const _Extra('foo'),
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.pageKey, isNotNull);
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
