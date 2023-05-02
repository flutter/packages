// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/configuration.dart';
import 'package:go_router/src/match.dart';
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

  test('RouteMatchList compares', () async {
    final GoRoute route = GoRoute(
      path: '/page-0',
      builder: (BuildContext context, GoRouterState state) =>
          const Placeholder(),
    );
    final Map<String, String> params1 = <String, String>{};
    final RouteMatch match1 = RouteMatch.match(
      route: route,
      remainingLocation: '/page-0',
      matchedLocation: '',
      pathParameters: params1,
      extra: null,
    )!;

    final Map<String, String> params2 = <String, String>{};
    final RouteMatch match2 = RouteMatch.match(
      route: route,
      remainingLocation: '/page-0',
      matchedLocation: '',
      pathParameters: params2,
      extra: null,
    )!;

    final RouteMatchList matches1 = RouteMatchList(
      matches: <RouteMatch>[match1],
      uri: Uri.parse(''),
      pathParameters: params1,
    );

    final RouteMatchList matches2 = RouteMatchList(
      matches: <RouteMatch>[match2],
      uri: Uri.parse(''),
      pathParameters: params2,
    );

    final RouteMatchList matches3 = RouteMatchList(
      matches: <RouteMatch>[match2],
      uri: Uri.parse('/page-0'),
      pathParameters: params2,
    );

    expect(matches1 == matches2, isTrue);
    expect(matches1 == matches3, isFalse);
  });
}
