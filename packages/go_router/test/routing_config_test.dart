// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
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
