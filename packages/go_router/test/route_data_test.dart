// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _GoRouteDataBuild extends GoRouteData {
  const _GoRouteDataBuild();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SizedBox(key: Key('build'));
}

final GoRoute _goRouteDataBuild = GoRouteData.$route(
  path: '/build',
  factory: (GoRouterState state) => const _GoRouteDataBuild(),
);

class _GoRouteDataBuildPage extends GoRouteData {
  const _GoRouteDataBuildPage();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const MaterialPage<void>(
        child: SizedBox(key: Key('buildPage')),
      );
}

final GoRoute _goRouteDataBuildPage = GoRouteData.$route(
  path: '/build-page',
  factory: (GoRouterState state) => const _GoRouteDataBuildPage(),
);

class _GoRouteDataRedirectPage extends GoRouteData {
  const _GoRouteDataRedirectPage();
  @override
  FutureOr<String> redirect(BuildContext context, GoRouterState state) =>
      '/build-page';
}

final GoRoute _goRouteDataRedirect = GoRouteData.$route(
  path: '/redirect',
  factory: (GoRouterState state) => const _GoRouteDataRedirectPage(),
);

final List<GoRoute> _routes = <GoRoute>[
  _goRouteDataBuild,
  _goRouteDataBuildPage,
  _goRouteDataRedirect,
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
    },
  );

  testWidgets(
    'It should build the page from the overridden buildPage method',
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
    },
  );
  testWidgets(
    'It should redirect using the overridden redirect method',
    (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/redirect',
        routes: _routes,
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsOneWidget);
    },
  );

  testWidgets(
    'It should redirect using the overridden redirect method',
    (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/redirect-with-state',
        routes: _routes,
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsNothing);
    },
  );
}
