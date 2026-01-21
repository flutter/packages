// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _GoRouteDataBuild extends GoRouteData {
  const _GoRouteDataBuild();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SizedBox(key: Key('build'));
}

class _RelativeGoRouteDataBuild extends RelativeGoRouteData {
  const _RelativeGoRouteDataBuild();

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
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) =>
      SizedBox(key: const Key('builder'), child: navigator);
}

class _ShellRouteDataWithKey extends ShellRouteData {
  const _ShellRouteDataWithKey(this.key);

  final Key key;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) =>
      KeyedSubtree(key: key, child: navigator);
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

final GoRoute _relativeGoRouteDataBuild = RelativeGoRouteData.$route(
  path: 'build',
  factory: (GoRouterState state) => const _RelativeGoRouteDataBuild(),
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
      const MaterialPage<void>(child: SizedBox(key: Key('buildPage')));
}

class _RelativeGoRouteDataBuildPage extends RelativeGoRouteData {
  const _RelativeGoRouteDataBuildPage();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const MaterialPage<void>(child: SizedBox(key: Key('buildPage')));
}

class _ShellRouteDataPageBuilder extends ShellRouteData {
  const _ShellRouteDataPageBuilder();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) => MaterialPage<void>(
    child: SizedBox(key: const Key('page-builder'), child: navigator),
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

final GoRoute _relativeGoRouteDataBuildPage = RelativeGoRouteData.$route(
  path: 'build-page',
  factory: (GoRouterState state) => const _RelativeGoRouteDataBuildPage(),
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
  ) => SizedBox(key: const Key('builder'), child: navigator);
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
  ) => MaterialPage<void>(
    child: SizedBox(key: const Key('page-builder'), child: navigator),
  );
}

final StatefulShellRoute _statefulShellRouteDataPageBuilder =
    StatefulShellRouteData.$route(
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

class _GoRouteDataRedirectPage extends GoRouteData {
  const _GoRouteDataRedirectPage();

  @override
  FutureOr<String> redirect(BuildContext context, GoRouterState state) =>
      '/build-page';
}

class _RelativeGoRouteDataRedirectPage extends RelativeGoRouteData {
  const _RelativeGoRouteDataRedirectPage();

  @override
  FutureOr<String> redirect(BuildContext context, GoRouterState state) =>
      '/build-page';
}

final GoRoute _goRouteDataRedirect = GoRouteData.$route(
  path: '/redirect',
  factory: (GoRouterState state) => const _GoRouteDataRedirectPage(),
);

final GoRoute _relativeGoRouteDataRedirect = RelativeGoRouteData.$route(
  path: 'redirect',
  factory: (GoRouterState state) => const _RelativeGoRouteDataRedirectPage(),
);

final List<GoRoute> _routes = <GoRoute>[
  _goRouteDataBuild,
  _goRouteDataBuildPage,
  _goRouteDataRedirect,
];

String fromBase64(String value) {
  return const Utf8Decoder().convert(base64.decode(value));
}

String toBase64(String value) {
  return base64.encode(const Utf8Encoder().convert(value));
}

final List<GoRoute> _relativeRoutes = <GoRoute>[
  GoRouteData.$route(
    path: '/',
    factory: (GoRouterState state) => const _GoRouteDataBuild(),
    routes: <RouteBase>[
      _relativeGoRouteDataBuild,
      _relativeGoRouteDataBuildPage,
      _relativeGoRouteDataRedirect,
    ],
  ),
];

void main() {
  group('GoRouteData', () {
    testWidgets('It should build the page from the overridden build method', (
      WidgetTester tester,
    ) async {
      final goRouter = GoRouter(initialLocation: '/build', routes: _routes);
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('build')), findsOneWidget);
      expect(find.byKey(const Key('buildPage')), findsNothing);
    });

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final goRouter = GoRouter(
          initialLocation: '/build-page',
          routes: _routes,
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('build')), findsNothing);
        expect(find.byKey(const Key('buildPage')), findsOneWidget);
      },
    );

    testWidgets(
      'It should build a go route with the default case sensitivity',
      (WidgetTester tester) async {
        final GoRoute routeWithDefaultCaseSensitivity = GoRouteData.$route(
          path: '/path',
          factory: (GoRouterState state) => const _GoRouteDataBuild(),
        );

        expect(routeWithDefaultCaseSensitivity.caseSensitive, true);
      },
    );

    testWidgets(
      'It should build a go route with the overridden case sensitivity',
      (WidgetTester tester) async {
        final GoRoute routeWithDefaultCaseSensitivity = GoRouteData.$route(
          path: '/path',
          caseSensitive: false,
          factory: (GoRouterState state) => const _GoRouteDataBuild(),
        );

        expect(routeWithDefaultCaseSensitivity.caseSensitive, false);
      },
    );

    testWidgets('It should throw because there is no code generated', (
      WidgetTester tester,
    ) async {
      final errors = <FlutterErrorDetails>[];

      FlutterError.onError = (FlutterErrorDetails details) =>
          errors.add(details);

      const errorText = 'Should be generated';

      Future<void> expectUnimplementedError(
        void Function(BuildContext) onTap,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) => GestureDetector(
                child: const Text('Tap'),
                onTap: () => onTap(context),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Tap'));

        expect(errors.first.exception, isA<UnimplementedError>());
        expect(errors.first.exception.toString(), contains(errorText));

        errors.clear();
      }

      await expectUnimplementedError((BuildContext context) {
        const _GoRouteDataBuild().location;
      });

      await expectUnimplementedError((BuildContext context) {
        const _GoRouteDataBuild().push<void>(context);
      });

      await expectUnimplementedError((BuildContext context) {
        const _GoRouteDataBuild().go(context);
      });

      await expectUnimplementedError((BuildContext context) {
        const _GoRouteDataBuild().pushReplacement(context);
      });

      await expectUnimplementedError((BuildContext context) {
        const _GoRouteDataBuild().replace(context);
      });

      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });
  });

  group('RelativeGoRouteData', () {
    testWidgets('It should build the page from the overridden build method', (
      WidgetTester tester,
    ) async {
      final goRouter = GoRouter(
        initialLocation: '/build',
        routes: _relativeRoutes,
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('build')), findsOneWidget);
      expect(find.byKey(const Key('buildPage')), findsNothing);
    });

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final goRouter = GoRouter(
          initialLocation: '/build-page',
          routes: _relativeRoutes,
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('build')), findsNothing);
        expect(find.byKey(const Key('buildPage')), findsOneWidget);
      },
    );

    testWidgets(
      'It should build a go route with the default case sensitivity',
      (WidgetTester tester) async {
        final GoRoute routeWithDefaultCaseSensitivity =
            RelativeGoRouteData.$route(
              path: 'path',
              factory: (GoRouterState state) =>
                  const _RelativeGoRouteDataBuild(),
            );

        expect(routeWithDefaultCaseSensitivity.caseSensitive, true);
      },
    );

    testWidgets(
      'It should build a go route with the overridden case sensitivity',
      (WidgetTester tester) async {
        final GoRoute routeWithDefaultCaseSensitivity =
            RelativeGoRouteData.$route(
              path: 'path',
              caseSensitive: false,
              factory: (GoRouterState state) =>
                  const _RelativeGoRouteDataBuild(),
            );

        expect(routeWithDefaultCaseSensitivity.caseSensitive, false);
      },
    );

    testWidgets('It should throw because there is no code generated', (
      WidgetTester tester,
    ) async {
      final errors = <FlutterErrorDetails>[];

      FlutterError.onError = (FlutterErrorDetails details) =>
          errors.add(details);

      const errorText = 'Should be generated';

      Future<void> expectUnimplementedError(
        void Function(BuildContext) onTap,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) => GestureDetector(
                child: const Text('Tap'),
                onTap: () => onTap(context),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Tap'));

        expect(errors.first.exception, isA<UnimplementedError>());
        expect(errors.first.exception.toString(), contains(errorText));

        errors.clear();
      }

      await expectUnimplementedError((BuildContext context) {
        const _RelativeGoRouteDataBuild().subLocation;
      });

      await expectUnimplementedError((BuildContext context) {
        const _RelativeGoRouteDataBuild().relativeLocation;
      });

      await expectUnimplementedError((BuildContext context) {
        const _RelativeGoRouteDataBuild().pushRelative<void>(context);
      });

      await expectUnimplementedError((BuildContext context) {
        const _RelativeGoRouteDataBuild().goRelative(context);
      });

      await expectUnimplementedError((BuildContext context) {
        const _RelativeGoRouteDataBuild().pushReplacementRelative(context);
      });

      await expectUnimplementedError((BuildContext context) {
        const _RelativeGoRouteDataBuild().replaceRelative(context);
      });

      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });
  });

  group('ShellRouteData', () {
    testWidgets('It should build the page from the overridden build method', (
      WidgetTester tester,
    ) async {
      final goRouter = GoRouter(
        initialLocation: '/child',
        routes: <RouteBase>[_shellRouteDataBuilder],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('builder')), findsOneWidget);
      expect(find.byKey(const Key('page-builder')), findsNothing);
    });

    testWidgets('It should build the page from the overridden build method', (
      WidgetTester tester,
    ) async {
      final root = GlobalKey<NavigatorState>();
      final inner = GlobalKey<NavigatorState>();
      final goRouter = GoRouter(
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
                ],
              ),
            ],
          ),
        ],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
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
    });

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[_shellRouteDataPageBuilder],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('builder')), findsNothing);
        expect(find.byKey(const Key('page-builder')), findsOneWidget);
      },
    );

    testWidgets('It should redirect using the overridden redirect method', (
      WidgetTester tester,
    ) async {
      final goRouter = GoRouter(
        initialLocation: '/child',
        routes: <RouteBase>[_goRouteDataBuildPage, _shellRouteDataRedirect],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsOneWidget);
    });
  });

  group('StatefulShellRouteData', () {
    testWidgets('It should build the page from the overridden build method', (
      WidgetTester tester,
    ) async {
      final goRouter = GoRouter(
        initialLocation: '/child',
        routes: <RouteBase>[_statefulShellRouteDataBuilder],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('builder')), findsOneWidget);
      expect(find.byKey(const Key('page-builder')), findsNothing);
    });

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final goRouter = GoRouter(
          initialLocation: '/child',
          routes: <RouteBase>[_statefulShellRouteDataPageBuilder],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
        expect(find.byKey(const Key('builder')), findsNothing);
        expect(find.byKey(const Key('page-builder')), findsOneWidget);
      },
    );

    test('Can assign parent navigator key', () {
      final key = GlobalKey<NavigatorState>();
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

  group('StatefulShellBranchData', () {
    test('Can assign preload', () {
      final StatefulShellBranch branch = StatefulShellBranchData.$branch(
        preload: true,
        routes: <RouteBase>[
          GoRouteData.$route(
            path: '/child',
            factory: (GoRouterState state) => const _GoRouteDataBuild(),
          ),
        ],
      );
      expect(branch.preload, true);
    });
  });

  testWidgets('It should redirect using the overridden redirect method', (
    WidgetTester tester,
  ) async {
    final goRouter = GoRouter(initialLocation: '/redirect', routes: _routes);
    addTearDown(goRouter.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
    expect(find.byKey(const Key('build')), findsNothing);
    expect(find.byKey(const Key('buildPage')), findsOneWidget);
  });

  testWidgets(
    'It should redirect using the overridden StatefulShellRoute redirect method',
    (WidgetTester tester) async {
      final goRouter = GoRouter(
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
              ),
            ],
          ),
        ],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsOneWidget);
    },
  );

  testWidgets('It should redirect using the overridden redirect method', (
    WidgetTester tester,
  ) async {
    final goRouter = GoRouter(
      initialLocation: '/redirect-with-state',
      routes: _routes,
    );
    addTearDown(goRouter.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
    expect(find.byKey(const Key('build')), findsNothing);
    expect(find.byKey(const Key('buildPage')), findsNothing);
  });
  test('TypedGoRoute with default parameters', () {
    const typedGoRoute = TypedGoRoute<GoRouteData>(path: '/path');

    expect(typedGoRoute.path, '/path');
    expect(typedGoRoute.name, isNull);
    expect(typedGoRoute.caseSensitive, true);
    expect(typedGoRoute.routes, isEmpty);
  });

  test('TypedGoRoute with provided parameters', () {
    const typedGoRoute = TypedGoRoute<GoRouteData>(
      path: '/path',
      name: 'name',
      caseSensitive: false,
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<GoRouteData>(
          path: 'sub-path',
          name: 'subName',
          caseSensitive: false,
        ),
      ],
    );

    expect(typedGoRoute.path, '/path');
    expect(typedGoRoute.name, 'name');
    expect(typedGoRoute.caseSensitive, false);
    expect(typedGoRoute.routes, hasLength(1));
    expect(
      typedGoRoute.routes.single,
      isA<TypedGoRoute<GoRouteData>>()
          .having(
            (TypedGoRoute<GoRouteData> route) => route.path,
            'path',
            'sub-path',
          )
          .having(
            (TypedGoRoute<GoRouteData> route) => route.name,
            'name',
            'subName',
          )
          .having(
            (TypedGoRoute<GoRouteData> route) => route.caseSensitive,
            'caseSensitive',
            false,
          ),
    );
  });

  test('CustomParameterCodec with required parameters', () {
    const customParameterCodec = CustomParameterCodec(
      encode: toBase64,
      decode: fromBase64,
    );

    expect(customParameterCodec.encode, toBase64);
    expect(customParameterCodec.decode, fromBase64);
  });

  test('TypedRelativeGoRoute with default parameters', () {
    const typedGoRoute = TypedRelativeGoRoute<RelativeGoRouteData>(
      path: 'path',
    );

    expect(typedGoRoute.path, 'path');
    expect(typedGoRoute.caseSensitive, true);
    expect(typedGoRoute.routes, isEmpty);
  });

  test('TypedRelativeGoRoute with provided parameters', () {
    const typedGoRoute = TypedRelativeGoRoute<RelativeGoRouteData>(
      path: 'path',
      caseSensitive: false,
      routes: <TypedRoute<RouteData>>[
        TypedRelativeGoRoute<RelativeGoRouteData>(
          path: 'sub-path',
          caseSensitive: false,
        ),
      ],
    );

    expect(typedGoRoute.path, 'path');
    expect(typedGoRoute.caseSensitive, false);
    expect(typedGoRoute.routes, hasLength(1));
    expect(
      typedGoRoute.routes.single,
      isA<TypedRelativeGoRoute<RelativeGoRouteData>>()
          .having(
            (TypedRelativeGoRoute<RelativeGoRouteData> route) => route.path,
            'path',
            'sub-path',
          )
          .having(
            (TypedRelativeGoRoute<RelativeGoRouteData> route) =>
                route.caseSensitive,
            'caseSensitive',
            false,
          ),
    );
  });
}
