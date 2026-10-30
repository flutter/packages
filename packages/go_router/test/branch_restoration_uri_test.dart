// Copyright 2026 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> mount(WidgetTester tester, _TestRouter fixture) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      fixture.router.dispose();
    });
    await tester.pumpWidget(
      MaterialApp.router(restorationScopeId: 'app', routerConfig: fixture.router),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('restores a root-navigator redirect on every branch entry', (
    WidgetTester tester,
  ) async {
    final fixture = _TestRouter(redirectToWelcome: true);
    await mount(tester, fixture);

    for (var entry = 0; entry < 3; entry++) {
      fixture.shell.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Welcome'), findsOneWidget);
      expect(fixture.router.routerDelegate.currentConfiguration.uri.path, '/b/17/welcome');

      fixture.router.go('/a');
      await tester.pumpAndSettle();
      expect(find.text('Branch A'), findsOneWidget);
    }
  });

  testWidgets('scoped branch location excludes root route path parameters', (
    WidgetTester tester,
  ) async {
    final fixture = _TestRouter();
    await mount(tester, fixture);
    fixture.router.go('/b/17/popup/99?source=branch#section', extra: 'payload');
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsOneWidget);

    fixture.router.go('/a');
    await tester.pumpAndSettle();
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();

    final RouteMatchList configuration = fixture.router.routerDelegate.currentConfiguration;
    expect(find.text('Branch B'), findsOneWidget);
    expect(find.text('Popup'), findsNothing);
    expect(configuration.uri.toString(), '/b/17?source=branch#section');
    expect(configuration.pathParameters, <String, String>{'branchId': '17'});
    expect(configuration.extra, 'payload');
  });

  testWidgets('scoping a root popup preserves the branch imperative stack', (
    WidgetTester tester,
  ) async {
    final fixture = _TestRouter();
    await mount(tester, fixture);
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();
    unawaited(fixture.router.push<void>('/b/17/details/42', extra: 'payload'));
    await tester.pumpAndSettle();
    expect(find.text('Details 42 payload'), findsOneWidget);
    unawaited(fixture.router.push<void>('/b/17/popup/99'));
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsOneWidget);

    fixture.router.go('/a');
    await tester.pumpAndSettle();
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();

    expect(find.text('Details 42 payload'), findsOneWidget);
    expect(find.text('Popup'), findsNothing);
    expect(fixture.router.canPop(), isTrue);
    fixture.router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Branch B'), findsOneWidget);
  });

  testWidgets('scoped branch location preserves encoded path delimiters', (
    WidgetTester tester,
  ) async {
    final fixture = _TestRouter();
    await mount(tester, fixture);
    fixture.router.go('/b/a%2Fb/popup/99?source=branch#section', extra: 'payload');
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsOneWidget);

    fixture.router.go('/a');
    await tester.pumpAndSettle();
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();

    final RouteMatchList configuration = fixture.router.routerDelegate.currentConfiguration;
    expect(find.text('Branch B'), findsOneWidget);
    expect(configuration.uri.toString(), '/b/a%2Fb?source=branch#section');
    expect(configuration.pathParameters, <String, String>{'branchId': 'a/b'});
    expect(configuration.extra, 'payload');
  });

  testWidgets('scoping through ancestor navigators preserves branch location metadata', (
    WidgetTester tester,
  ) async {
    final fixture = _TestRouter(withOuterShell: true);
    await mount(tester, fixture);
    fixture.router.go('/b/17/mid/end?source=branch#section', extra: 'payload');
    await tester.pumpAndSettle();
    expect(find.text('End'), findsOneWidget);

    fixture.router.go('/a');
    await tester.pumpAndSettle();
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();

    final RouteMatchList configuration = fixture.router.routerDelegate.currentConfiguration;
    expect(find.text('Branch B'), findsOneWidget);
    expect(find.text('End'), findsNothing);
    expect(configuration.uri.toString(), '/b/17?source=branch#section');
    expect(configuration.pathParameters, <String, String>{'branchId': '17'});
    expect(configuration.extra, 'payload');
  });

  testWidgets('scoping through ancestor navigators preserves branch imperative pages', (
    WidgetTester tester,
  ) async {
    final fixture = _TestRouter(withOuterShell: true);
    await mount(tester, fixture);
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();
    unawaited(fixture.router.push<void>('/b/17/details/42', extra: 'payload'));
    await tester.pumpAndSettle();
    expect(find.text('Details 42 payload'), findsOneWidget);
    unawaited(fixture.router.push<void>('/b/17/mid/end'));
    await tester.pumpAndSettle();
    expect(find.text('End'), findsOneWidget);

    fixture.router.go('/a');
    await tester.pumpAndSettle();
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();

    expect(find.text('Details 42 payload'), findsOneWidget);
    expect(find.text('Middle'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(fixture.router.canPop(), isTrue);
  });

  testWidgets('scoped branch location survives state restoration', (WidgetTester tester) async {
    final fixture = _TestRouter();
    await mount(tester, fixture);
    fixture.router.go('/b/a%2Fb/popup/99?source=branch#section', extra: 'payload');
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsOneWidget);
    fixture.router.go('/a');
    await tester.pumpAndSettle();

    await tester.restartAndRestore();
    await tester.pumpAndSettle();
    expect(find.text('Branch A'), findsOneWidget);
    fixture.shell.goBranch(1);
    await tester.pumpAndSettle();

    final RouteMatchList configuration = fixture.router.routerDelegate.currentConfiguration;
    expect(find.text('Branch B'), findsOneWidget);
    expect(find.text('Popup'), findsNothing);
    expect(configuration.uri.toString(), '/b/a%2Fb?source=branch#section');
    expect(configuration.pathParameters, <String, String>{'branchId': 'a/b'});
    expect(configuration.extra, 'payload');
  });
}

class _TestRouter {
  _TestRouter({this.redirectToWelcome = false, this.withOuterShell = false});

  final bool redirectToWelcome;
  final bool withOuterShell;
  final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> outerKey = GlobalKey<NavigatorState>();
  late StatefulNavigationShell shell;

  late final GoRouter router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/a',
    restorationScopeId: 'router',
    routes: <RouteBase>[
      if (withOuterShell)
        ShellRoute(
          navigatorKey: outerKey,
          restorationScopeId: 'outer',
          builder: (BuildContext context, GoRouterState state, Widget child) => child,
          routes: <RouteBase>[_shellRoute],
        )
      else
        _shellRoute,
    ],
  );

  late final StatefulShellRoute _shellRoute = StatefulShellRoute.indexedStack(
    restorationScopeId: 'shell',
    builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
      this.shell = shell;
      return Scaffold(body: shell);
    },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        restorationScopeId: 'a',
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (BuildContext context, GoRouterState state) => const Text('Branch A'),
          ),
        ],
      ),
      StatefulShellBranch(
        initialLocation: '/b/17',
        restorationScopeId: 'b',
        routes: <RouteBase>[
          GoRoute(
            path: '/b/:branchId',
            redirect: (BuildContext context, GoRouterState state) {
              if (redirectToWelcome && state.uri.path != '/b/17/welcome') {
                return '/b/17/welcome';
              }
              return null;
            },
            builder: (BuildContext context, GoRouterState state) => const Text('Branch B'),
            routes: <RouteBase>[
              GoRoute(
                path: 'welcome',
                parentNavigatorKey: rootKey,
                builder: (BuildContext context, GoRouterState state) =>
                    const Scaffold(body: Text('Welcome')),
              ),
              GoRoute(
                path: 'popup/:popupId',
                parentNavigatorKey: rootKey,
                builder: (BuildContext context, GoRouterState state) =>
                    const Scaffold(body: Text('Popup')),
              ),
              GoRoute(
                path: 'details/:detailId',
                builder: (BuildContext context, GoRouterState state) =>
                    Text('Details ${state.pathParameters['detailId']} ${state.extra}'),
              ),
              if (withOuterShell)
                GoRoute(
                  path: 'mid',
                  parentNavigatorKey: outerKey,
                  builder: (BuildContext context, GoRouterState state) =>
                      const Scaffold(body: Text('Middle')),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'end',
                      parentNavigatorKey: rootKey,
                      builder: (BuildContext context, GoRouterState state) =>
                          const Scaffold(body: Text('End')),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ],
  );
}
