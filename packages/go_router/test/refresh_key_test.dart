// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/match.dart';

import 'test_helpers.dart';

void main() {
  group('RefreshKey Tests', () {
    // Test 1: RouteMatch.copyWith preserves refreshKey
    test('RouteMatch.copyWith preserves refreshKey', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      const ValueKey<String> originalRefreshKey = ValueKey<String>(
        'original-key',
      );
      final RouteMatch original = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: originalRefreshKey,
      );

      final RouteMatch copied = original.copyWith();

      expect(copied.refreshKey, equals(originalRefreshKey));
      expect(copied.route, equals(original.route));
      expect(copied.matchedLocation, equals(original.matchedLocation));
      expect(copied.pageKey, equals(original.pageKey));
    });

    // Test 2: RouteMatch.copyWith updates refreshKey
    test('RouteMatch.copyWith updates refreshKey', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      const ValueKey<String> originalRefreshKey = ValueKey<String>(
        'original-key',
      );
      const ValueKey<String> newRefreshKey = ValueKey<String>('new-key');

      final RouteMatch original = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: originalRefreshKey,
      );

      final RouteMatch copied = original.copyWith(refreshKey: newRefreshKey);

      expect(copied.refreshKey, equals(newRefreshKey));
      expect(copied.refreshKey, isNot(equals(originalRefreshKey)));
    });

    // Test 3: RouteMatch equality includes refreshKey
    test('RouteMatch equality includes refreshKey', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final RouteMatch match1 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('key-1'),
      );

      final RouteMatch match2 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('key-1'),
      );

      final RouteMatch match3 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('key-2'),
      );

      expect(match1, equals(match2));
      expect(match1, isNot(equals(match3)));
    });

    // Test 4: RouteMatch hashCode includes refreshKey
    test('RouteMatch hashCode includes refreshKey', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final RouteMatch match1 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('key-1'),
      );

      final RouteMatch match2 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('key-2'),
      );

      expect(match1.hashCode, isNot(equals(match2.hashCode)));
    });

    // Test 5: RouteMatch with null refreshKey
    test('RouteMatch with null refreshKey', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final RouteMatch match1 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
      );

      final RouteMatch match2 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
      );

      expect(match1.refreshKey, isNull);
      expect(match1, equals(match2));
    });

    // Test 6: RouteMatch with different refreshKeys are not equal
    test('RouteMatch with different refreshKeys are not equal', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final RouteMatch match1 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('key-1'),
      );

      final RouteMatch match2 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('key-2'),
      );

      final RouteMatch match3 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
      );

      expect(match1 == match2, isFalse);
      expect(match1 == match3, isFalse);
      expect(match2 == match3, isFalse);
    });

    // Test 7: ShellRouteMatch.copyWith preserves refreshKey
    test('ShellRouteMatch.copyWith preserves refreshKey', () {
      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      final ShellRoute shellRoute = ShellRoute(
        navigatorKey: navigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return child;
        },
        routes: <GoRoute>[
          GoRoute(
            path: '/test',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
        ],
      );

      final GoRoute childRoute = shellRoute.routes.first as GoRoute;
      final RouteMatch childMatch = RouteMatch(
        route: childRoute,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('child-key'),
      );

      const ValueKey<String> originalRefreshKey = ValueKey<String>(
        'shell-refresh-key',
      );
      final ShellRouteMatch original = ShellRouteMatch(
        route: shellRoute,
        matches: <RouteMatchBase>[childMatch],
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('shell-page-key'),
        navigatorKey: navigatorKey,
        refreshKey: originalRefreshKey,
      );

      final ShellRouteMatch copied = original.copyWith(
        matches: original.matches,
      );

      expect(copied.refreshKey, equals(originalRefreshKey));
    });

    // Test 8: ImperativeRouteMatch preserves refreshKey
    test('ImperativeRouteMatch preserves refreshKey', () {
      final RouteConfiguration configuration = createRouteConfiguration(
        routes: <GoRoute>[
          GoRoute(
            path: '/a',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
        ],
        redirectLimit: 0,
        navigatorKey: GlobalKey<NavigatorState>(),
        topRedirect: (_, __) => null,
      );

      final RouteMatchList matchList = configuration.findMatch(Uri.parse('/a'));
      const ValueKey<String> refreshKey = ValueKey<String>('imperative-key');

      final ImperativeRouteMatch imperativeMatch = ImperativeRouteMatch(
        pageKey: const ValueKey<String>('page-key'),
        matches: matchList,
        completer: Completer<Object?>(),
        refreshKey: refreshKey,
      );

      expect(imperativeMatch.refreshKey, equals(refreshKey));
    });

    // Test 9: RouteMatchListCodec encodes and decodes refreshKey
    test('RouteMatchListCodec encodes and decodes refreshKey', () {
      final RouteConfiguration configuration = createRouteConfiguration(
        routes: <GoRoute>[
          GoRoute(
            path: '/a',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
          GoRoute(
            path: '/b',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
        ],
        redirectLimit: 0,
        navigatorKey: GlobalKey<NavigatorState>(),
        topRedirect: (_, __) => null,
      );

      final RouteMatchListCodec codec = RouteMatchListCodec(configuration);

      final RouteMatchList list1 = configuration.findMatch(Uri.parse('/a'));
      final RouteMatchList list2 = configuration.findMatch(Uri.parse('/b'));

      const ValueKey<String> refreshKey = ValueKey<String>('test-refresh-key');
      final ImperativeRouteMatch imperativeMatch = ImperativeRouteMatch(
        pageKey: const ValueKey<String>('/b-p0'),
        matches: list2,
        completer: Completer<Object?>(),
        refreshKey: refreshKey,
      );

      final RouteMatchList listWithPushed = list1.push(imperativeMatch);

      final Map<Object?, Object?> encoded = codec.encode(listWithPushed);
      final RouteMatchList decoded = codec.decode(encoded);

      expect(decoded, isNotNull);
      expect(decoded.matches.length, equals(listWithPushed.matches.length));

      final ImperativeRouteMatch decodedImperative =
          decoded.matches.last as ImperativeRouteMatch;
      expect(decodedImperative.refreshKey, isNotNull);
      expect(decodedImperative.refreshKey!.value, equals(refreshKey.value));
    });

    // Test 10: RouteMatchListCodec handles null refreshKey
    test('RouteMatchListCodec handles null refreshKey', () {
      final RouteConfiguration configuration = createRouteConfiguration(
        routes: <GoRoute>[
          GoRoute(
            path: '/a',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
          GoRoute(
            path: '/b',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
        ],
        redirectLimit: 0,
        navigatorKey: GlobalKey<NavigatorState>(),
        topRedirect: (_, __) => null,
      );

      final RouteMatchListCodec codec = RouteMatchListCodec(configuration);

      final RouteMatchList list1 = configuration.findMatch(Uri.parse('/a'));
      final RouteMatchList list2 = configuration.findMatch(Uri.parse('/b'));

      final ImperativeRouteMatch imperativeMatch = ImperativeRouteMatch(
        pageKey: const ValueKey<String>('/b-p0'),
        matches: list2,
        completer: Completer<Object?>(),
        // No refreshKey provided
      );

      final RouteMatchList listWithPushed = list1.push(imperativeMatch);

      final Map<Object?, Object?> encoded = codec.encode(listWithPushed);
      final RouteMatchList decoded = codec.decode(encoded);

      expect(decoded, isNotNull);
      final ImperativeRouteMatch decodedImperative =
          decoded.matches.last as ImperativeRouteMatch;
      expect(decodedImperative.refreshKey, isNull);
    });

    // Test 11: Configuration.reparse preserves refreshKey
    test('Configuration.reparse preserves refreshKey', () {
      final RouteConfiguration configuration = createRouteConfiguration(
        routes: <GoRoute>[
          GoRoute(
            path: '/a',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
          GoRoute(
            path: '/b',
            builder:
                (BuildContext context, GoRouterState state) =>
                    const Placeholder(),
          ),
        ],
        redirectLimit: 0,
        navigatorKey: GlobalKey<NavigatorState>(),
        topRedirect: (_, __) => null,
      );

      final RouteMatchList list1 = configuration.findMatch(Uri.parse('/a'));
      final RouteMatchList list2 = configuration.findMatch(Uri.parse('/b'));

      const ValueKey<String> refreshKey = ValueKey<String>('preserved-key');
      final ImperativeRouteMatch imperativeMatch = ImperativeRouteMatch(
        pageKey: const ValueKey<String>('/b-p0'),
        matches: list2,
        completer: Completer<Object?>(),
        refreshKey: refreshKey,
      );

      final RouteMatchList listWithPushed = list1.push(imperativeMatch);

      // Reparse the match list
      final RouteMatchList reparsed = configuration.reparse(listWithPushed);

      expect(reparsed, isNotNull);
      expect(reparsed.matches.length, equals(listWithPushed.matches.length));

      final ImperativeRouteMatch reparsedImperative =
          reparsed.matches.last as ImperativeRouteMatch;
      expect(reparsedImperative.refreshKey, isNotNull);
      expect(reparsedImperative.refreshKey!.value, equals(refreshKey.value));
    });

    // Test 12: RouteMatchList with refreshKey in matches
    test('RouteMatchList with refreshKey in matches', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final RouteMatch match1 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('refresh-1'),
      );

      final RouteMatch match2 = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
        refreshKey: const ValueKey<String>('refresh-2'),
      );

      final RouteMatchList list1 = RouteMatchList(
        matches: <RouteMatchBase>[match1],
        uri: Uri.parse('/test'),
        pathParameters: const <String, String>{},
      );

      final RouteMatchList list2 = RouteMatchList(
        matches: <RouteMatchBase>[match2],
        uri: Uri.parse('/test'),
        pathParameters: const <String, String>{},
      );

      // Lists should not be equal because refreshKeys are different
      expect(list1 == list2, isFalse);
    });

    // Test 13: RouteMatch.copyWith with all parameters
    test('RouteMatch.copyWith with all parameters', () {
      final GoRoute route1 = GoRoute(
        path: '/test1',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final GoRoute route2 = GoRoute(
        path: '/test2',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final RouteMatch original = RouteMatch(
        route: route1,
        matchedLocation: '/test1',
        pageKey: const ValueKey<String>('page-key-1'),
        refreshKey: const ValueKey<String>('refresh-key-1'),
      );

      final RouteMatch copied = original.copyWith(
        route: route2,
        matchedLocation: '/test2',
        pageKey: const ValueKey<String>('page-key-2'),
        refreshKey: const ValueKey<String>('refresh-key-2'),
      );

      expect(copied.route, equals(route2));
      expect(copied.matchedLocation, equals('/test2'));
      expect(copied.pageKey.value, equals('page-key-2'));
      expect(copied.refreshKey!.value, equals('refresh-key-2'));
    });

    // Test 14: Multiple RouteMatches with different refreshKeys
    test('Multiple RouteMatches with different refreshKeys', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      final List<RouteMatch> matches = <RouteMatch>[
        RouteMatch(
          route: route,
          matchedLocation: '/test',
          pageKey: const ValueKey<String>('page-key'),
          refreshKey: const ValueKey<String>('key-1'),
        ),
        RouteMatch(
          route: route,
          matchedLocation: '/test',
          pageKey: const ValueKey<String>('page-key'),
          refreshKey: const ValueKey<String>('key-2'),
        ),
        RouteMatch(
          route: route,
          matchedLocation: '/test',
          pageKey: const ValueKey<String>('page-key'),
          refreshKey: const ValueKey<String>('key-3'),
        ),
      ];

      // All matches should be different
      expect(matches[0] == matches[1], isFalse);
      expect(matches[1] == matches[2], isFalse);
      expect(matches[0] == matches[2], isFalse);
    });

    // Test 15: RefreshKey is optional
    test('RefreshKey is optional in RouteMatch', () {
      final GoRoute route = GoRoute(
        path: '/test',
        builder:
            (BuildContext context, GoRouterState state) => const Placeholder(),
      );

      // Should not throw when refreshKey is not provided
      final RouteMatch match = RouteMatch(
        route: route,
        matchedLocation: '/test',
        pageKey: const ValueKey<String>('page-key'),
      );

      expect(match.refreshKey, isNull);
      expect(match.route, equals(route));
      expect(match.matchedLocation, equals('/test'));
    });
  });
}
