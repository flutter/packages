// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../go_router_test.dart';

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
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        title: 'GoRouter Example',
      ),
    );
    expect(find.byWidget(child), findsOneWidget);
  });

  test('NoTransitionPage does not apply any transition', () {
    const HomeScreen homeScreen = HomeScreen();
    const NoTransitionPage<void> page =
        NoTransitionPage<void>(child: homeScreen);
    const AlwaysStoppedAnimation<double> primaryAnimation =
        AlwaysStoppedAnimation<double>(0);
    const AlwaysStoppedAnimation<double> secondaryAnimation =
        AlwaysStoppedAnimation<double>(1);
    final Widget widget = page.transitionsBuilder(
      DummyBuildContext(),
      primaryAnimation,
      secondaryAnimation,
      homeScreen,
    );
    expect(widget, homeScreen);
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}
