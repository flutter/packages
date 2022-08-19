// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _GoRouteDataBuild extends GoRouteData {
  const _GoRouteDataBuild();
  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('build'));
}

final GoRoute _goRouteDataBuild = GoRouteData.$route(
  path: '/build',
  factory: (GoRouterState state) => const _GoRouteDataBuild(),
);

class _GoRouteDataBuildPage extends GoRouteData {
  const _GoRouteDataBuildPage();
  @override
  Page<void> buildPage(BuildContext context) => const MaterialPage<void>(
        child: SizedBox(key: Key('buildPage')),
      );
}

final GoRoute _goRouteDataBuildPage = GoRouteData.$route(
  path: '/build-page',
  factory: (GoRouterState state) => const _GoRouteDataBuildPage(),
);

class _GoRouteDataBuildPageWithState extends GoRouteData {
  const _GoRouteDataBuildPageWithState();
  @override
  Page<void> buildPageWithState(BuildContext context, GoRouterState state) =>
      const MaterialPage<void>(
        child: SizedBox(key: Key('buildPageWithState')),
      );
}

final GoRoute _goRouteDataBuildPageWithState = GoRouteData.$route(
  path: '/build-page-with-state',
  factory: (GoRouterState state) => const _GoRouteDataBuildPageWithState(),
);

final List<GoRoute> _routes = <GoRoute>[
  _goRouteDataBuild,
  _goRouteDataBuildPage,
  _goRouteDataBuildPageWithState,
];

void main() {
  testWidgets(
    'It should build the page from the overridden build method',
    (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/build',
        routes: _routes,
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));
      expect(find.byKey(const Key('build')), findsOneWidget);
      expect(find.byKey(const Key('buildPage')), findsNothing);
      expect(find.byKey(const Key('buildPageWithState')), findsNothing);
    },
  );

  testWidgets(
    'It should build the page from the overridden buildPage method',
    (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/build-page',
        routes: _routes,
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsOneWidget);
      expect(find.byKey(const Key('buildPageWithState')), findsNothing);
    },
  );

  testWidgets(
    'It should build the page from the overridden buildPageWithState method',
    (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/build-page-with-state',
        routes: _routes,
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsNothing);
      expect(find.byKey(const Key('buildPageWithState')), findsOneWidget);
    },
  );
}
