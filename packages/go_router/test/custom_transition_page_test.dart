// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('CustomTransitionPage builds its child using transitionsBuilder',
      (WidgetTester tester) async {
    const HomeScreen child = HomeScreen();
    final CustomTransitionPage<void> transition = CustomTransitionPage<void>(
      transitionsBuilder: expectAsync4((_, __, ___, Widget child) => child),
      child: child,
    );
    final GoRouter router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          pageBuilder: (_, __) => transition,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        title: 'GoRouter Example',
      ),
    );
    expect(find.byWidget(child), findsOneWidget);
  });

  testWidgets('NoTransitionPage does not apply any transition',
      (WidgetTester tester) async {
    final ValueNotifier<bool> showHomeValueNotifier =
        ValueNotifier<bool>(false);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: showHomeValueNotifier,
          builder: (_, bool showHome, __) {
            return Navigator(
              pages: <Page<void>>[
                const NoTransitionPage<void>(
                  child: LoginScreen(),
                ),
                if (showHome)
                  const NoTransitionPage<void>(
                    child: HomeScreen(),
                  ),
              ],
              onPopPage: (Route<dynamic> route, dynamic result) {
                return route.didPop(result);
              },
            );
          },
        ),
      ),
    );

    final Finder homeScreenFinder = find.byType(HomeScreen);

    showHomeValueNotifier.value = true;
    await tester.pump();
    final Offset homeScreenPositionInTheMiddleOfAddition =
        tester.getTopLeft(homeScreenFinder);
    await tester.pumpAndSettle();
    final Offset homeScreenPositionAfterAddition =
        tester.getTopLeft(homeScreenFinder);

    showHomeValueNotifier.value = false;
    await tester.pump();
    final Offset homeScreenPositionInTheMiddleOfRemoval =
        tester.getTopLeft(homeScreenFinder);
    await tester.pumpAndSettle();

    expect(
      homeScreenPositionInTheMiddleOfAddition,
      homeScreenPositionAfterAddition,
    );
    expect(
      homeScreenPositionAfterAddition,
      homeScreenPositionInTheMiddleOfRemoval,
    );
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('HomeScreen'),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('LoginScreen'),
      ),
    );
  }
}
