// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  test('ShellRoute observers test', () {
    final ShellRoute shell = ShellRoute(
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

  testWidgets('observers should be merged', (WidgetTester tester) async {
    final HeroController observer = HeroController();
    final List<NavigatorObserver> observers = <NavigatorObserver>[observer];
    addTearDown(observer.dispose);

    final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
    await createRouter(
      <RouteBase>[
        ShellRoute(
          navigatorKey: navKey,
          builder: (_, __, Widget child) => child,
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              parentNavigatorKey: navKey,
              builder: (_, __) => const Text('Home'),
            ),
          ],
        ),
      ],
      tester,
      observers: observers,
    );
    await tester.pumpAndSettle();

    final List<NavigatorObserver> shellRouteObservers =
        navKey.currentState!.widget.observers;
    final MergedNavigatorObserver mergedObservers =
        shellRouteObservers.single as MergedNavigatorObserver;
    expect(listEquals(observers, mergedObservers.observers), isTrue);
  });
}
