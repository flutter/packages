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
    addTearDown(router.dispose);
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
    addTearDown(showHomeValueNotifier.dispose);
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

    expect(homeScreenFinder, findsNothing);

    showHomeValueNotifier.value = true;

    await tester.pump();

    expect(homeScreenFinder, findsOneWidget);

    await tester.pumpAndSettle();

    showHomeValueNotifier.value = false;

    await tester.pump();

    expect(homeScreenFinder, findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('NoTransitionPage does not apply any reverse transition',
      (WidgetTester tester) async {
    final ValueNotifier<bool> showHomeValueNotifier = ValueNotifier<bool>(true);
    addTearDown(showHomeValueNotifier.dispose);
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

    showHomeValueNotifier.value = false;

    await tester.pump();

    expect(homeScreenFinder, findsNothing);
  });

  testWidgets('Dismiss a screen by tapping a modal barrier',
      (WidgetTester tester) async {
    const ValueKey<String> homeKey = ValueKey<String>('home');
    const ValueKey<String> dismissibleModalKey =
        ValueKey<String>('dismissibleModal');

    final GoRouter router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const HomeScreen(key: homeKey),
        ),
        GoRoute(
          path: '/dismissible-modal',
          pageBuilder: (_, GoRouterState state) => CustomTransitionPage<void>(
            key: state.pageKey,
            barrierDismissible: true,
            transitionsBuilder: (_, __, ___, Widget child) => child,
            child: const DismissibleModal(key: dismissibleModalKey),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.byKey(homeKey), findsOneWidget);
    router.push('/dismissible-modal');
    await tester.pumpAndSettle();
    expect(find.byKey(dismissibleModalKey), findsOneWidget);
    await tester.tapAt(const Offset(50, 50));
    await tester.pumpAndSettle();
    expect(find.byKey(homeKey), findsOneWidget);
  });

  testWidgets('transitionDuration and reverseTransitionDuration is different',
      (WidgetTester tester) async {
    const ValueKey<String> homeKey = ValueKey<String>('home');
    const ValueKey<String> loginKey = ValueKey<String>('login');
    const Duration transitionDuration = Duration(milliseconds: 50);
    const Duration reverseTransitionDuration = Duration(milliseconds: 500);

    final GoRouter router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const HomeScreen(key: homeKey),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (_, GoRouterState state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            transitionsBuilder:
                (_, Animation<double> animation, ___, Widget child) =>
                    FadeTransition(opacity: animation, child: child),
            child: const LoginScreen(key: loginKey),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.byKey(homeKey), findsOneWidget);

    router.push('/login');
    final int pushingPumped = await tester.pumpAndSettle();
    expect(find.byKey(loginKey), findsOneWidget);

    router.pop();
    final int poppingPumped = await tester.pumpAndSettle();
    expect(find.byKey(homeKey), findsOneWidget);

    expect(pushingPumped != poppingPumped, true);
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

class DismissibleModal extends StatelessWidget {
  const DismissibleModal({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 200,
      height: 200,
      child: Center(child: Text('Dismissible Modal')),
    );
  }
}
