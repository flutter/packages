// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/configuration.dart';
import 'package:go_router/src/delegate.dart';
import 'package:go_router/src/matching.dart';
import 'package:go_router/src/router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('RouteMatchList toString prints the fullPath',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
          path: '/page-0',
          builder: (BuildContext context, GoRouterState state) =>
              const Placeholder()),
    ];

    final GoRouter router = await createRouter(routes, tester);
    router.go('/page-0');
    await tester.pumpAndSettle();

    final RouteMatchList matches = router.routerDelegate.matches;
    expect(matches.toString(), contains('/page-0'));
  });

  test('RouteMatchList is encoded and decoded correctly', () {
    final RouteConfiguration configuration = RouteConfiguration(
      routes: <GoRoute>[
        GoRoute(
          path: '/a',
          builder: (BuildContext context, GoRouterState state) =>
              const Placeholder(),
        ),
        GoRoute(
          path: '/b',
          builder: (BuildContext context, GoRouterState state) =>
              const Placeholder(),
        ),
      ],
      redirectLimit: 0,
      navigatorKey: GlobalKey<NavigatorState>(),
      topRedirect: (_, __) => null,
    );
    final RouteMatcher matcher = RouteMatcher(configuration);
    final RouteMatchListCodec codec = RouteMatchListCodec(matcher);

    final RouteMatchList list1 = matcher.findMatch('/a');
    final RouteMatchList list2 = matcher.findMatch('/b');
    list1.push(ImperativeRouteMatch<Object?>(
        pageKey: const ValueKey<String>('/b-p0'), matches: list2));

    final Object? encoded = codec.encodeMatchList(list1);
    final RouteMatchList? decoded = codec.decodeMatchList(encoded);

    expect(decoded, isNotNull);
    expect(RouteMatchList.matchListEquals(decoded!, list1), isTrue);
  });
}
