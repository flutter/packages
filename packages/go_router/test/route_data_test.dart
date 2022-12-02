// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/route_data.dart';

class _GoRouteDataBuild extends GoRouteData {
  const _GoRouteDataBuild();
  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('build'));
}

class _ShellRouteDataBuilder extends ShellRouteData {
  const _ShellRouteDataBuilder();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      SizedBox(
        key: const Key('builder'),
        child: navigator,
      );
}

final GoRoute _goRouteDataBuild = GoRouteData.$route(
  path: '/build',
  factory: (GoRouterState state) => const _GoRouteDataBuild(),
);

final ShellRoute _shellRouteDataBuilder = ShellRouteData.$route(
  factory: (GoRouterState state) => const _ShellRouteDataBuilder(),
  routes: <RouteBase>[
    GoRouteData.$route(
      path: '/child',
      factory: (GoRouterState state) => const _GoRouteDataBuild(),
    ),
  ],
);

class _GoRouteDataBuildPage extends GoRouteData {
  const _GoRouteDataBuildPage();
  @override
  Page<void> buildPage(BuildContext context) => const MaterialPage<void>(
        child: SizedBox(key: Key('buildPage')),
      );
}

class _ShellRouteDataPageBuilder extends ShellRouteData {
  const _ShellRouteDataPageBuilder();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      MaterialPage<void>(
        child: SizedBox(
          key: const Key('page-builder'),
          child: navigator,
        ),
      );
}

final GoRoute _goRouteDataBuildPage = GoRouteData.$route(
  path: '/build-page',
  factory: (GoRouterState state) => const _GoRouteDataBuildPage(),
);

final ShellRoute _shellRouteDataPageBuilder = ShellRouteData.$route(
  factory: (GoRouterState state) => const _ShellRouteDataPageBuilder(),
  routes: <RouteBase>[
    GoRouteData.$route(
      path: '/child',
      factory: (GoRouterState state) => const _GoRouteDataBuild(),
    ),
  ],
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
  group('GoRouteData >', () {
    testWidgets(
      'build',
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
      'buildPage',
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
      'buildPageWithState',
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
  });

  group('ShellRouteData >', () {
    testWidgets(
      'builder',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _shellRouteDataBuilder,
          ],
        );
        await tester.pumpWidget(MaterialApp.router(
          routeInformationProvider: goRouter.routeInformationProvider,
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
        ));
        expect(find.byKey(const Key('builder')), findsOneWidget);
        expect(find.byKey(const Key('page-builder')), findsNothing);
      },
    );

    testWidgets(
      'pageBuilder',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _shellRouteDataPageBuilder,
          ],
        );
        await tester.pumpWidget(MaterialApp.router(
          routeInformationProvider: goRouter.routeInformationProvider,
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
        ));
        expect(find.byKey(const Key('builder')), findsNothing);
        expect(find.byKey(const Key('page-builder')), findsOneWidget);
      },
    );
  });
}
