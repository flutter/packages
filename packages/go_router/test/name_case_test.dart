// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'Route names are case sensitive',
    (WidgetTester tester) async {
      // config router with 2 routes with the same name but different case (Name, name)
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      final GoRouter router = GoRouter(
        navigatorKey: navKey,
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            name: 'Name',
            builder: (_, __) => const ScreenA(),
          ),
          GoRoute(
            path: '/path',
            name: 'name',
            builder: (_, __) => const ScreenB(),
          ),
        ],
      );

      // run MaterialApp, initial screen path is '/' -> ScreenA
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Testcase',
        ),
      );

      // go to ScreenB
      navKey.currentContext!.goNamed('name');
      assert(GoRouter.of(navKey.currentContext!).location == '/path');

      // go to ScreenA
      navKey.currentContext!.goNamed('Name');
      assert(GoRouter.of(navKey.currentContext!).location == '/');
    },
  );
}

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
