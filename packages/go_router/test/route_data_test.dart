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

class _ShellRouteDataRedirectPage extends ShellRouteData {
  const _ShellRouteDataRedirectPage();

  @override
  FutureOr<String> redirect(BuildContext context, GoRouterState state) =>
      '/build-page';
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

class _ShellRouteDataWithKey extends ShellRouteData {
  const _ShellRouteDataWithKey(this.key);

  final Key key;

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      SizedBox(
        key: key,
        child: navigator,
      );
}

class _GoRouteDataBuildWithKey extends GoRouteData {
  const _GoRouteDataBuildWithKey(this.key);

  final Key key;

  @override
  Widget build(BuildContext context, GoRouterState state) => SizedBox(key: key);
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
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const MaterialPage<void>(
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

class _StatefulShellRouteDataRedirectPage extends StatefulShellRouteData {
  const _StatefulShellRouteDataRedirectPage();

  @override
  FutureOr<String> redirect(BuildContext context, GoRouterState state) =>
      '/build-page';
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

final ShellRoute _shellRouteDataRedirect = ShellRouteData.$route(
  factory: (GoRouterState state) => const _ShellRouteDataPageBuilder(),
  routes: <RouteBase>[
    ShellRouteData.$route(
      factory: (GoRouterState state) => const _ShellRouteDataRedirectPage(),
      routes: <RouteBase>[
        GoRouteData.$route(
          path: '/child',
          factory: (GoRouterState state) => const _GoRouteDataBuild(),
        ),
      ],
    ),
  ],
);

class _StatefulShellRouteDataBuilder extends StatefulShellRouteData {
  const _StatefulShellRouteDataBuilder();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigator,
  ) =>
      SizedBox(
        key: const Key('builder'),
        child: navigator,
      );
}

final StatefulShellRoute _statefulShellRouteDataBuilder =
    StatefulShellRouteData.$route(
  factory: (GoRouterState state) => const _StatefulShellRouteDataBuilder(),
  branches: <StatefulShellBranch>[
    StatefulShellBranchData.$branch(
      routes: <RouteBase>[
        GoRouteData.$route(
          path: '/child',
          factory: (GoRouterState state) => const _GoRouteDataBuild(),
        ),
      ],
    ),
  ],
);

class _StatefulShellRouteDataPageBuilder extends StatefulShellRouteData {
  const _StatefulShellRouteDataPageBuilder();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigator,
  ) =>
      MaterialPage<void>(
        child: SizedBox(
          key: const Key('page-builder'),
          child: navigator,
        ),
      );
}

final StatefulShellRoute _statefulShellRouteDataPageBuilder =
    StatefulShellRouteData.$route(
  factory: (GoRouterState state) => const _StatefulShellRouteDataPageBuilder(),
  branches: <StatefulShellBranch>[
    StatefulShellBranchData.$branch(
      routes: <RouteBase>[
        GoRouteData.$route(
          path: '/child',
          factory: (GoRouterState state) => const _GoRouteDataBuild(),
        ),
      ],
    ),
  ],
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
  group('GoRouteData', () {
    testWidgets(
      'It should build the page from the overridden build method',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/build',
          routes: _routes,
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
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
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('build')), findsNothing);
        expect(find.byKey(const Key('buildPage')), findsOneWidget);
      },
    );
  });

  group('ShellRouteData', () {
    testWidgets(
      'It should build the page from the overridden build method',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _shellRouteDataBuilder,
          ],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('builder')), findsOneWidget);
        expect(find.byKey(const Key('page-builder')), findsNothing);
      },
    );

    testWidgets(
      'It should build the page from the overridden build method',
      (WidgetTester tester) async {
        final GlobalKey<NavigatorState> root = GlobalKey<NavigatorState>();
        final GlobalKey<NavigatorState> inner = GlobalKey<NavigatorState>();
        final GoRouter goRouter = GoRouter(
          navigatorKey: root,
          initialLocation: '/child/test',
          routes: <RouteBase>[
            ShellRouteData.$route(
              factory: (GoRouterState state) =>
                  const _ShellRouteDataWithKey(Key('under-shell')),
              routes: <RouteBase>[
                GoRouteData.$route(
                    path: '/child',
                    factory: (GoRouterState state) =>
                        const _GoRouteDataBuildWithKey(Key('under')),
                    routes: <RouteBase>[
                      ShellRouteData.$route(
                        factory: (GoRouterState state) =>
                            const _ShellRouteDataWithKey(Key('above-shell')),
                        navigatorKey: inner,
                        parentNavigatorKey: root,
                        routes: <RouteBase>[
                          GoRouteData.$route(
                            parentNavigatorKey: inner,
                            path: 'test',
                            factory: (GoRouterState state) =>
                                const _GoRouteDataBuildWithKey(Key('above')),
                          ),
                        ],
                      ),
                    ]),
              ],
            ),
          ],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(
          routerConfig: goRouter,
        ));
        expect(find.byKey(const Key('under-shell')), findsNothing);
        expect(find.byKey(const Key('under')), findsNothing);

        expect(find.byKey(const Key('above-shell')), findsOneWidget);
        expect(find.byKey(const Key('above')), findsOneWidget);

        goRouter.pop();
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('under-shell')), findsOneWidget);
        expect(find.byKey(const Key('under')), findsOneWidget);

        expect(find.byKey(const Key('above-shell')), findsNothing);
        expect(find.byKey(const Key('above')), findsNothing);
      },
    );

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _shellRouteDataPageBuilder,
          ],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('builder')), findsNothing);
        expect(find.byKey(const Key('page-builder')), findsOneWidget);
      },
    );

    testWidgets(
      'It should redirect using the overridden redirect method',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _goRouteDataBuildPage,
            _shellRouteDataRedirect,
          ],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('build')), findsNothing);
        expect(find.byKey(const Key('buildPage')), findsOneWidget);
      },
    );
  });

  group('StatefulShellRouteData', () {
    testWidgets(
      'It should build the page from the overridden build method',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _statefulShellRouteDataBuilder,
          ],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('builder')), findsOneWidget);
        expect(find.byKey(const Key('page-builder')), findsNothing);
      },
    );

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _statefulShellRouteDataPageBuilder,
          ],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('builder')), findsNothing);
        expect(find.byKey(const Key('page-builder')), findsOneWidget);
      },
    );

    test('Can assign parent navigator key', () {
      final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
      final StatefulShellRoute route = StatefulShellRouteData.$route(
        parentNavigatorKey: key,
        factory: (GoRouterState state) =>
            const _StatefulShellRouteDataPageBuilder(),
        branches: <StatefulShellBranch>[
          StatefulShellBranchData.$branch(
            routes: <RouteBase>[
              GoRouteData.$route(
                path: '/child',
                factory: (GoRouterState state) => const _GoRouteDataBuild(),
              ),
            ],
          ),
        ],
      );
      expect(route.parentNavigatorKey, key);
    });
  });

  testWidgets(
    'It should redirect using the overridden redirect method',
    (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/redirect',
        routes: _routes,
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsOneWidget);
    },
  );

  testWidgets(
    'It should redirect using the overridden StatefulShellRoute redirect method',
    (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/child',
        routes: <RouteBase>[
          _goRouteDataBuildPage,
          StatefulShellRouteData.$route(
            factory: (GoRouterState state) =>
                const _StatefulShellRouteDataRedirectPage(),
            branches: <StatefulShellBranch>[
              StatefulShellBranchData.$branch(
                routes: <GoRoute>[
                  GoRouteData.$route(
                    path: '/child',
                    factory: (GoRouterState state) => const _GoRouteDataBuild(),
                  ),
                ],
              )
            ],
          )
        ],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
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
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsNothing);
    },
  );
}
