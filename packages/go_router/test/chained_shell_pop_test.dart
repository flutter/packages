// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  for (final exitMode in <String>['none', 'synchronous', 'asynchronous', 'veto']) {
    testWidgets('chained pops cross a shell boundary with $exitMode onExit', (
      WidgetTester tester,
    ) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>();
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final home = UniqueKey();
      final pageB = UniqueKey();
      final pageC = UniqueKey();
      late BuildContext pageBContext;
      var bExitCalls = 0;
      var cExitCalls = 0;
      var allowBExit = exitMode != 'veto';
      int? bResult;
      int? cResult;

      final GoRouter router = await createRouter(
        <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, _) => DummyScreen(key: home),
          ),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, _, Widget child) => child,
            routes: <RouteBase>[
              GoRoute(
                path: '/b',
                builder: (BuildContext context, GoRouterState state) {
                  pageBContext = context;
                  return DummyScreen(key: pageB);
                },
                onExit: exitMode == 'none'
                    ? null
                    : (_, _) {
                        bExitCalls += 1;
                        return exitMode == 'asynchronous'
                            ? Future<bool>.value(allowBExit)
                            : allowBExit;
                      },
              ),
              GoRoute(
                path: '/c',
                builder: (_, _) => DummyScreen(key: pageC),
                onExit: exitMode == 'none'
                    ? null
                    : (_, _) {
                        cExitCalls += 1;
                        return exitMode == 'asynchronous' ? Future<bool>.value(true) : true;
                      },
              ),
            ],
          ),
        ],
        tester,
        navigatorKey: rootNavigatorKey,
      );

      unawaited(router.push<int>('/b').then<void>((int? result) => bResult = result));
      await tester.pumpAndSettle();
      expect(find.byKey(pageB), findsOneWidget);
      expect(shellNavigatorKey.currentState!.canPop(), isFalse);
      expect(rootNavigatorKey.currentState!.canPop(), isTrue);

      Future<void> pushCAndPopB() async {
        cResult = await pageBContext.push<int>('/c');
        // There must be no frame between receiving C's result and popping B.
        // The last child of the shell is popped through the root Navigator.
        pageBContext.pop<int>(cResult! + 1);
      }

      unawaited(pushCAndPopB());
      await tester.pumpAndSettle();
      expect(find.byKey(pageC), findsOneWidget);
      expect(shellNavigatorKey.currentState!.canPop(), isTrue);

      router.pop<int>(42);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(cResult, 42);
      expect(cExitCalls, exitMode == 'none' ? 0 : 1);
      expect(bExitCalls, exitMode == 'none' ? 0 : 1);
      if (exitMode == 'veto') {
        expect(bResult, isNull);
        expect(find.byKey(pageB), findsOneWidget);
        expect(find.byKey(pageC), findsNothing);
        expect(router.routerDelegate.currentConfiguration.last.route.path, '/b');
        allowBExit = true;
        router.pop<int>(43);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(bExitCalls, 2);
        expect(cExitCalls, 1);
      }
      expect(bResult, 43);
      expect(find.byKey(home), findsOneWidget);
      expect(find.byKey(pageB), findsNothing);
      expect(find.byKey(pageC), findsNothing);
      expect(router.routerDelegate.currentConfiguration.matches, hasLength(1));
      expect(router.routerDelegate.currentConfiguration.last.route.path, '/');
      expect(rootNavigatorKey.currentState!.canPop(), isFalse);
    });
  }
}
