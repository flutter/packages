// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('routing config works', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
        redirect: (_, _) => '/',
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(config, tester);
    expect(find.text('home'), findsOneWidget);

    router.go('/abcd'); // should be redirected to home
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('routing config works after builder changes', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(config, tester);
    expect(find.text('home'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home1'))],
    );
    await tester.pumpAndSettle();
    expect(find.text('home1'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.go('/abc');
    await tester.pumpAndSettle();
    expect(find.text('error'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes case 2', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
        ],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.go('/abc');
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
    );
    await tester.pumpAndSettle();
    expect(find.text('error'), findsOneWidget);
  });

  testWidgets('routing config works after routing changes case 3', (WidgetTester tester) async {
    final key = GlobalKey<_StatefulTestState>(debugLabel: 'testState');
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, _) => StatefulTest(key: key, child: const Text('home')),
          ),
        ],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(
      navigatorKey: rootNavigatorKey,
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    key.currentState!.value = 1;

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => StatefulTest(key: key, child: const Text('home')),
        ),
        GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
      ],
    );
    await tester.pumpAndSettle();
    expect(key.currentState!.value == 1, isTrue);
  });

  testWidgets('routing config preserves pushed shell routes', (WidgetTester tester) async {
    final branchANavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'branch-a');
    final branchBNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'branch-b');
    RoutingConfig createConfig({required List<RouteBase> additionalRoutes}) {
      return RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/top', builder: (_, _) => const Text('Top-level route')),
          StatefulShellRoute.indexedStack(
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                navigatorKey: branchANavigatorKey,
                routes: <RouteBase>[
                  GoRoute(path: '/a', builder: (_, _) => const Text('Screen A')),
                  ...additionalRoutes,
                ],
              ),
              StatefulShellBranch(
                navigatorKey: branchBNavigatorKey,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/b',
                    builder: (_, _) => const Text('Screen B'),
                    routes: <RouteBase>[
                      GoRoute(path: 'details', builder: (_, _) => const Text('Screen B Detail')),
                    ],
                  ),
                ],
              ),
            ],
            pageBuilder: (_, _, StatefulNavigationShell navigationShell) =>
                MaterialPage<void>(child: navigationShell),
          ),
        ],
      );
    }

    final config = ValueNotifier<RoutingConfig>(createConfig(additionalRoutes: <RouteBase>[]));
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      initialLocation: '/a',
    );
    unawaited(router.push('/b/details'));
    await tester.pumpAndSettle();
    unawaited(router.push('/top'));
    await tester.pumpAndSettle();

    config.value = createConfig(
      additionalRoutes: <RouteBase>[GoRoute(path: '/c', builder: (_, _) => const Text('Screen C'))],
    );
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Screen B Detail'), findsOneWidget);
  });

  testWidgets('routing config works with shell route', (WidgetTester tester) async {
    final key = GlobalKey<_StatefulTestState>(debugLabel: 'testState');
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => const Text('home'))],
            builder: (_, _, Widget widget) => StatefulTest(key: key, child: widget),
          ),
        ],
      ),
    );
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(
      navigatorKey: rootNavigatorKey,
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );
    expect(find.text('home'), findsOneWidget);
    final _StatefulTestState shellState = key.currentState!;
    final NavigatorState shellNavigatorState = shellNavigatorKey.currentState!;
    shellState.value = 1;

    config.value = RoutingConfig(
      routes: <RouteBase>[
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          routes: <RouteBase>[
            GoRoute(path: '/', builder: (_, _) => const Text('home')),
            GoRoute(path: '/abc', builder: (_, _) => const Text('/abc')),
          ],
          builder: (_, _, Widget widget) => StatefulTest(key: key, child: widget),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(key.currentState, same(shellState));
    expect(shellNavigatorKey.currentState, same(shellNavigatorState));
    expect(shellState.value, 1);
  });

  testWidgets('routing config preserves nested imperative shell state', (
    WidgetTester tester,
  ) async {
    final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
    final detailKey = GlobalKey<_StatefulTestState>(debugLabel: 'detailState');

    RoutingConfig buildConfig() => RoutingConfig(
      routes: <RouteBase>[
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          routes: <RouteBase>[
            GoRoute(path: '/', builder: (_, _) => const Text('home')),
            GoRoute(
              path: '/detail',
              builder: (_, _) => StatefulTest(key: detailKey, child: const Text('detail')),
            ),
          ],
          builder: (_, _, Widget widget) => widget,
        ),
      ],
    );

    final config = ValueNotifier<RoutingConfig>(buildConfig());
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(config, tester);
    final NavigatorState configuredNavigator = shellNavigatorKey.currentState!;

    router.push('/detail');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final _StatefulTestState detailState = detailKey.currentState!;
    final NavigatorState scopedNavigator = Navigator.of(detailState.context);
    final State<StatefulWidget> scopedNavigatorWrapper = _customNavigatorStateFor(scopedNavigator);
    detailState.value = 1;

    config.value = buildConfig();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('detail'), findsOneWidget);
    expect(shellNavigatorKey.currentState, same(configuredNavigator));
    expect(detailKey.currentState, same(detailState));
    expect(Navigator.of(detailState.context), same(scopedNavigator));
    expect(_customNavigatorStateFor(scopedNavigator), same(scopedNavigatorWrapper));
    expect(detailState.value, 1);
  });

  testWidgets('routing config preserves multiple nested imperative shell matches', (
    WidgetTester tester,
  ) async {
    final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
    final firstDetailKey = GlobalKey<_StatefulTestState>(debugLabel: 'firstDetailState');
    final secondDetailKey = GlobalKey<_StatefulTestState>(debugLabel: 'secondDetailState');

    RoutingConfig buildConfig() => RoutingConfig(
      routes: <RouteBase>[
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          routes: <RouteBase>[
            GoRoute(path: '/', builder: (_, _) => const Text('home')),
            GoRoute(
              path: '/detail/:id',
              builder: (_, GoRouterState state) {
                final isFirst = state.pathParameters['id'] == 'first';
                return StatefulTest(
                  key: isFirst ? firstDetailKey : secondDetailKey,
                  child: Text('detail ${state.pathParameters['id']}'),
                );
              },
            ),
          ],
          builder: (_, _, Widget widget) => widget,
        ),
      ],
    );

    final config = ValueNotifier<RoutingConfig>(buildConfig());
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(config, tester);

    final Future<String?> firstResult = router.push<String>('/detail/first');
    await tester.pumpAndSettle();
    final _StatefulTestState firstDetailState = firstDetailKey.currentState!;
    firstDetailState.value = 1;

    final Future<String?> secondResult = router.push<String>('/detail/second');
    await tester.pumpAndSettle();
    final _StatefulTestState secondDetailState = secondDetailKey.currentState!;
    secondDetailState.value = 2;

    config.value = buildConfig();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('detail second'), findsOneWidget);
    expect(firstDetailKey.currentState, same(firstDetailState));
    expect(secondDetailKey.currentState, same(secondDetailState));
    expect(firstDetailState.value, 1);
    expect(secondDetailState.value, 2);

    router.pop('second result');
    await tester.pumpAndSettle();
    expect(await secondResult, 'second result');
    expect(find.text('detail first'), findsOneWidget);
    expect(firstDetailKey.currentState, same(firstDetailState));
    expect(firstDetailState.value, 1);

    router.pop('first result');
    await tester.pumpAndSettle();
    expect(await firstResult, 'first result');
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('routing config preserves stateful shell branch state', (WidgetTester tester) async {
    final shellKey = GlobalKey<StatefulNavigationShellState>(debugLabel: 'statefulShell');
    final branchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'branch');
    final pageKey = GlobalKey<_StatefulTestState>(debugLabel: 'branchPage');

    RoutingConfig buildConfig({required bool includeSecondRoute}) => RoutingConfig(
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          key: shellKey,
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              navigatorKey: branchNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: (_, _) => StatefulTest(key: pageKey, child: const Text('home')),
                ),
                if (includeSecondRoute)
                  GoRoute(path: '/second', builder: (_, _) => const Text('second')),
              ],
            ),
          ],
          builder: (_, _, StatefulNavigationShell navigationShell) => navigationShell,
        ),
      ],
    );

    final config = ValueNotifier<RoutingConfig>(buildConfig(includeSecondRoute: false));
    addTearDown(config.dispose);
    await createRouterWithRoutingConfig(config, tester);
    final StatefulNavigationShellState shellState = shellKey.currentState!;
    final NavigatorState branchNavigator = branchNavigatorKey.currentState!;
    final _StatefulTestState pageState = pageKey.currentState!;
    pageState.value = 1;

    config.value = buildConfig(includeSecondRoute: true);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(shellKey.currentState, same(shellState));
    expect(branchNavigatorKey.currentState, same(branchNavigator));
    expect(pageKey.currentState, same(pageState));
    expect(pageState.value, 1);
  });

  testWidgets('routing config reparses inactive loaded stateful shell branches', (
    WidgetTester tester,
  ) async {
    final shellKey = GlobalKey<StatefulNavigationShellState>(debugLabel: 'statefulShell');
    final branchAKey = GlobalKey<NavigatorState>(debugLabel: 'branchA');
    final branchBKey = GlobalKey<NavigatorState>(debugLabel: 'branchB');
    final branchCKey = GlobalKey<NavigatorState>(debugLabel: 'branchC');

    RoutingConfig buildConfig({
      required String aLabel,
      required bool includeBranchC,
      String aPath = '/a',
    }) => RoutingConfig(
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          key: shellKey,
          builder: (_, _, StatefulNavigationShell shell) => shell,
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              navigatorKey: branchAKey,
              preload: true,
              routes: <RouteBase>[
                GoRoute(
                  path: aPath,
                  builder: (_, _) => Text(aLabel),
                  routes: <RouteBase>[
                    GoRoute(path: 'detail', builder: (_, _) => Text('Detail $aLabel')),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: branchBKey,
              routes: <RouteBase>[GoRoute(path: '/b', builder: (_, _) => const Text('Branch B'))],
            ),
            if (includeBranchC)
              StatefulShellBranch(
                navigatorKey: branchCKey,
                preload: true,
                routes: <RouteBase>[GoRoute(path: '/c', builder: (_, _) => const Text('Branch C'))],
              ),
          ],
        ),
      ],
    );

    final config = ValueNotifier<RoutingConfig>(
      buildConfig(aLabel: 'Branch A v1', includeBranchC: false),
    );
    addTearDown(config.dispose);
    final router = GoRouter.routingConfig(routingConfig: config, initialLocation: '/a');
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Branch A v1'), findsOneWidget);
    final NavigatorState branchANavigator = branchAKey.currentState!;

    final Future<void> detailResult = router.push<void>('/a/detail');
    await tester.pumpAndSettle();
    expect(find.text('Detail Branch A v1'), findsOneWidget);

    shellKey.currentState!.goBranch(1);
    await tester.pumpAndSettle();
    expect(find.text('Branch B'), findsOneWidget);

    config.value = buildConfig(aLabel: 'Branch A v2', includeBranchC: true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(branchCKey.currentState, isNotNull);

    shellKey.currentState!.goBranch(0);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Detail Branch A v2'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    await detailResult;
    expect(tester.takeException(), isNull);
    expect(find.text('Branch A v2'), findsOneWidget);
    expect(branchAKey.currentState, same(branchANavigator));
    expect(branchCKey.currentState, isNotNull);

    shellKey.currentState!.goBranch(1);
    await tester.pumpAndSettle();
    config.value = buildConfig(aLabel: 'Branch A v3', includeBranchC: true, aPath: '/new-a');
    await tester.pumpAndSettle();
    shellKey.currentState!.goBranch(0);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Branch A v3'), findsOneWidget);
  });

  for (final preload in <bool>[false, true]) {
    testWidgets('routing config resets an inactive branch with a removed base and surviving push '
        '(preload: $preload)', (WidgetTester tester) async {
      final shellKey = GlobalKey<StatefulNavigationShellState>();
      final branchAKey = GlobalKey<NavigatorState>();
      final branchBKey = GlobalKey<NavigatorState>();

      RoutingConfig buildConfig({required String aPath, required String label}) => RoutingConfig(
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            key: shellKey,
            builder: (_, _, StatefulNavigationShell shell) => shell,
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                navigatorKey: branchAKey,
                preload: preload,
                routes: <RouteBase>[
                  GoRoute(path: aPath, builder: (_, _) => Text(label)),
                  GoRoute(path: '/a-pushed', builder: (_, _) => Text('Pushed $label')),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: branchBKey,
                routes: <RouteBase>[GoRoute(path: '/b', builder: (_, _) => const Text('Branch B'))],
              ),
            ],
          ),
        ],
      );

      final config = ValueNotifier<RoutingConfig>(buildConfig(aPath: '/a', label: 'v1'));
      addTearDown(config.dispose);
      final GoRouter router = await createRouterWithRoutingConfig(
        config,
        tester,
        initialLocation: '/a',
      );
      await tester.pumpAndSettle();
      unawaited(router.push<void>('/a-pushed'));
      await tester.pumpAndSettle();
      expect(find.text('Pushed v1'), findsOneWidget);

      shellKey.currentState!.goBranch(1);
      await tester.pumpAndSettle();
      config.value = buildConfig(aPath: '/new-a', label: 'v2');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Branch B'), findsOneWidget);

      shellKey.currentState!.goBranch(0);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('v2'), findsOneWidget);
      expect(find.text('Pushed v2'), findsNothing);
      expect(router.routerDelegate.currentConfiguration.isError, isFalse);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/new-a');
    });
  }

  testWidgets('routing config preserves an inactive branch at a replaced nested route', (
    WidgetTester tester,
  ) async {
    final shellKey = GlobalKey<StatefulNavigationShellState>();
    final branchAKey = GlobalKey<NavigatorState>();
    final branchBKey = GlobalKey<NavigatorState>();

    RoutingConfig buildConfig({required String label}) => RoutingConfig(
      routes: <RouteBase>[
        GoRoute(
          path: '/root',
          builder: (_, _) => const Text('Root'),
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              key: shellKey,
              builder: (_, _, StatefulNavigationShell shell) => shell,
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  navigatorKey: branchAKey,
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'a',
                      builder: (_, _) => Text('A $label'),
                      routes: <RouteBase>[
                        GoRoute(path: 'detail', builder: (_, _) => Text('Detail $label')),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  navigatorKey: branchBKey,
                  routes: <RouteBase>[
                    GoRoute(path: 'b', builder: (_, _) => const Text('Branch B')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final config = ValueNotifier<RoutingConfig>(buildConfig(label: 'v1'));
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      initialLocation: '/root/a',
    );
    await tester.pumpAndSettle();
    final NavigatorState branchANavigator = branchAKey.currentState!;
    unawaited(router.pushReplacement<void>('/root/a/detail'));
    await tester.pumpAndSettle();
    expect(find.text('Detail v1'), findsOneWidget);

    shellKey.currentState!.goBranch(1);
    await tester.pumpAndSettle();
    config.value = buildConfig(label: 'v2');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Branch B'), findsOneWidget);

    shellKey.currentState!.goBranch(0);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Detail v2'), findsOneWidget);
    expect(branchAKey.currentState, same(branchANavigator));
  });

  testWidgets('routing config discards a removed push from an inactive branch', (
    WidgetTester tester,
  ) async {
    final shellKey = GlobalKey<StatefulNavigationShellState>();
    final branchAKey = GlobalKey<NavigatorState>();
    final branchBKey = GlobalKey<NavigatorState>();

    RoutingConfig buildConfig({required bool includeDetail, required String label}) =>
        RoutingConfig(
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              key: shellKey,
              builder: (_, _, StatefulNavigationShell shell) => shell,
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  navigatorKey: branchAKey,
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/a',
                      builder: (_, _) => Text('Branch A $label'),
                      routes: <RouteBase>[
                        if (includeDetail)
                          GoRoute(path: 'detail', builder: (_, _) => Text('Detail $label')),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  navigatorKey: branchBKey,
                  routes: <RouteBase>[
                    GoRoute(path: '/b', builder: (_, _) => const Text('Branch B')),
                  ],
                ),
              ],
            ),
          ],
        );

    final config = ValueNotifier<RoutingConfig>(buildConfig(includeDetail: true, label: 'v1'));
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      initialLocation: '/a',
      errorBuilder: (_, _) => const Text('Routing error'),
    );
    await tester.pumpAndSettle();
    final NavigatorState branchANavigator = branchAKey.currentState!;
    unawaited(router.push<void>('/a/detail'));
    await tester.pumpAndSettle();
    expect(find.text('Detail v1'), findsOneWidget);

    shellKey.currentState!.goBranch(1);
    await tester.pumpAndSettle();
    config.value = buildConfig(includeDetail: false, label: 'v2');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    shellKey.currentState!.goBranch(0);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Branch A v2'), findsOneWidget);
    expect(find.text('Routing error'), findsNothing);
    expect(branchAKey.currentState, same(branchANavigator));
    expect(router.routerDelegate.currentConfiguration.isError, isFalse);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/a');
  });

  for (final preload in <bool>[false, true]) {
    for (final notifyRootObserver in <bool>[false, true]) {
      testWidgets('routing config preserves inactive branch observers '
          '(preload: $preload, notifyRootObserver: $notifyRootObserver)', (
        WidgetTester tester,
      ) async {
        final shellKey = GlobalKey<StatefulNavigationShellState>();
        final branchAKey = GlobalKey<NavigatorState>();
        final branchBKey = GlobalKey<NavigatorState>();
        final rootObserver = _RecordingNavigatorObserver();
        final branchObserver = _RecordingNavigatorObserver();

        RoutingConfig buildConfig({required String label, required Clip clipBehavior}) =>
            RoutingConfig(
              routes: <RouteBase>[
                StatefulShellRoute.indexedStack(
                  key: shellKey,
                  notifyRootObserver: notifyRootObserver,
                  builder: (_, _, StatefulNavigationShell shell) => shell,
                  branches: <StatefulShellBranch>[
                    StatefulShellBranch(
                      navigatorKey: branchAKey,
                      preload: preload,
                      observers: <NavigatorObserver>[branchObserver],
                      clipBehavior: clipBehavior,
                      routes: <RouteBase>[
                        GoRoute(
                          path: '/a',
                          builder: (_, _) => Text('Branch A $label'),
                          routes: <RouteBase>[
                            GoRoute(path: 'detail', builder: (_, _) => Text('Detail $label')),
                          ],
                        ),
                      ],
                    ),
                    StatefulShellBranch(
                      navigatorKey: branchBKey,
                      routes: <RouteBase>[
                        GoRoute(path: '/b', builder: (_, _) => const Text('Branch B')),
                      ],
                    ),
                  ],
                ),
              ],
            );

        final config = ValueNotifier<RoutingConfig>(
          buildConfig(label: 'v1', clipBehavior: Clip.none),
        );
        addTearDown(config.dispose);
        final router = GoRouter.routingConfig(
          routingConfig: config,
          initialLocation: '/b',
          observers: <NavigatorObserver>[rootObserver],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        shellKey.currentState!.goBranch(0);
        await tester.pumpAndSettle();
        expect(branchObserver.pushedRoutes, hasLength(1));
        expect(
          rootObserver.pushedRoutes.contains(branchObserver.pushedRoutes.single),
          notifyRootObserver,
        );
        final NavigatorState branchANavigator = branchAKey.currentState!;

        shellKey.currentState!.goBranch(1);
        await tester.pumpAndSettle();
        config.value = buildConfig(label: 'v2', clipBehavior: Clip.antiAlias);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        shellKey.currentState!.goBranch(0);
        await tester.pumpAndSettle();
        expect(branchAKey.currentState, same(branchANavigator));
        expect(branchANavigator.widget.clipBehavior, Clip.antiAlias);

        rootObserver.pushedRoutes.clear();
        branchObserver.pushedRoutes.clear();
        final Future<void> result = branchANavigator.push<void>(
          MaterialPageRoute<void>(builder: (_) => const Text('Pageless detail')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Pageless detail'), findsOneWidget);
        expect(branchObserver.pushedRoutes, hasLength(1));
        if (notifyRootObserver) {
          expect(rootObserver.pushedRoutes, branchObserver.pushedRoutes);
        } else {
          expect(rootObserver.pushedRoutes, isEmpty);
        }
        branchANavigator.pop();
        await tester.pumpAndSettle();
        await result;
        expect(find.text('Branch A v2'), findsOneWidget);
      });
    }
  }

  testWidgets('routing config works with named route', (WidgetTester tester) async {
    final config = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/abc', name: 'abc', builder: (_, _) => const Text('/abc')),
        ],
      ),
    );
    addTearDown(config.dispose);
    final GoRouter router = await createRouterWithRoutingConfig(
      config,
      tester,
      errorBuilder: (_, _) => const Text('error'),
    );

    expect(find.text('home'), findsOneWidget);
    // Sanity check.
    router.goNamed('abc');
    await tester.pumpAndSettle();
    expect(find.text('/abc'), findsOneWidget);

    config.value = RoutingConfig(
      routes: <RouteBase>[
        GoRoute(path: '/', name: 'home', builder: (_, _) => const Text('home')),
        GoRoute(path: '/abc', name: 'def', builder: (_, _) => const Text('def')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('def'), findsOneWidget);

    router.goNamed('home');
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);

    router.goNamed('def');
    await tester.pumpAndSettle();
    expect(find.text('def'), findsOneWidget);
  });
}

class StatefulTest extends StatefulWidget {
  const StatefulTest({super.key, required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _StatefulTestState();
}

class _StatefulTestState extends State<StatefulTest> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[widget.child, Text('State: $value')]);
  }
}

State<StatefulWidget> _customNavigatorStateFor(NavigatorState navigator) {
  StatefulElement? customNavigatorElement;
  (navigator.context as Element).visitAncestorElements((Element element) {
    if (element.widget.runtimeType.toString() == '_CustomNavigator') {
      customNavigatorElement = element as StatefulElement;
      return false;
    }
    return true;
  });
  return customNavigatorElement!.state;
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }
}
