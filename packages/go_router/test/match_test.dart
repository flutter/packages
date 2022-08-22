import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/match.dart';

void main() {
  group('GoRouteMatch', () {
    test('simple', () {
      final GoRoute route = GoRoute(
          path: '/users/:userId',
          builder: _builder,
      );
      final GoRouteMatch? match = GoRouteMatch.match(
        route: route,
        restLoc: '/users/123',
        parentSubloc: '',
        fullpath: '/users/:userId',
        queryParams: <String, String>{
          'foo': 'bar',
        },
        extra: const _Extra('foo'),
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.location, '/users/123');
      expect(match.template, '/users/:userId');
      expect(match.encodedParams['userId'], '123');
      expect(match.queryParams['foo'], 'bar');
      expect(match.extra, const _Extra('foo'));
      expect(match.error, isNull);
      expect(match.pageKey, isNull);
      expect(match.fullUriString, '/users/123?foo=bar');
    });
    test('subloc', () {
      final GoRoute route = GoRoute(
        path: 'users/:userId',
        builder: _builder,
      );
      final GoRouteMatch? match = GoRouteMatch.match(
        route: route,
        restLoc: 'users/123',
        parentSubloc: '/home',
        fullpath: '/home/users/:userId',
        queryParams: <String, String>{
          'foo': 'bar',
        },
        extra: const _Extra('foo'),
      );
      if (match == null) {
        fail('Null match');
      }
      expect(match.route, route);
      expect(match.location, '/home/users/123');
      expect(match.template, '/home/users/:userId');
      expect(match.encodedParams['userId'], '123');
      expect(match.queryParams['foo'], 'bar');
      expect(match.extra, const _Extra('foo'));
      expect(match.error, isNull);
      expect(match.pageKey, isNull);
      expect(match.fullUriString, '/home/users/123?foo=bar');
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
