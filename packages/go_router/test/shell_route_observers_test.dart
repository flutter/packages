// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  test('ShellRoute observers test', () {
    final shell = ShellRoute(
      observers: <NavigatorObserver>[HeroController()],
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return SafeArea(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return Container();
          },
        ),
      ],
    );

    expect(shell.observers!.length, 1);
  });

  testWidgets(
    'GoRouter observers should be notified when navigating within ShellRoute',
    (WidgetTester tester) async {
      final observer = MockObserver();

      final root = GlobalKey<NavigatorState>(debugLabel: 'root');
      await createRouter(
        <RouteBase>[
          GoRoute(path: '/', builder: (_, __) => const Text('Home')),
          ShellRoute(
            builder: (_, __, Widget child) => child,
            routes: <RouteBase>[
              GoRoute(path: '/test1', builder: (_, __) => const Text('Test1')),
            ],
          ),
          StatefulShellRoute.indexedStack(
            builder: (_, __, Widget child) => child,
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/test2',
                    builder: (_, __) => const Text('Test2'),
                  ),
                ],
              ),
            ],
          ),
        ],
        tester,
        navigatorKey: root,
        observers: <NavigatorObserver>[observer],
      );
      await tester.pumpAndSettle();

      root.currentContext!.push('/test1');
      await tester.pumpAndSettle();
      expect(observer.getCallCount('/test1'), 1);

      root.currentContext!.push('/test2');
      await tester.pumpAndSettle();
      expect(observer.getCallCount('/test2'), 1);
    },
  );
}

class MockObserver extends NavigatorObserver {
  final Map<String, int> _callCounts = <String, int>{};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final String? routeName = route.settings.name;
    if (routeName != null) {
      test(routeName);
    }
  }

  void test(String name) {
    _callCounts[name] = (_callCounts[name] ?? 0) + 1;
  }

  int getCallCount(String name) {
    return _callCounts[name] ?? 0;
  }
}
