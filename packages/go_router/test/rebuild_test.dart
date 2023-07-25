// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('GoRouter.push does not trigger unnecessary rebuilds',
      (WidgetTester tester) async {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
          path: '/', builder: (BuildContext context, __) => const HomePage()),
      GoRoute(
          path: '/1',
          builder: (BuildContext context, __) {
            return ElevatedButton(
              onPressed: () {
                context.push('/1');
              },
              child: const Text('/1'),
            );
          }),
    ];

    await createRouter(routes, tester);
    expect(find.text('/'), findsOneWidget);
    // first build
    expect(HomePage.built, isTrue);

    HomePage.built = false;
    // Should not be built again afterward.
    await tester.tap(find.text('/'));
    await tester.pumpAndSettle();
    expect(find.text('/1'), findsOneWidget);
    expect(HomePage.built, isFalse);

    await tester.tap(find.text('/1'));
    await tester.pumpAndSettle();
    expect(find.text('/1'), findsOneWidget);
    expect(HomePage.built, isFalse);

    await tester.tap(find.text('/1'));
    await tester.pumpAndSettle();
    expect(find.text('/1'), findsOneWidget);
    expect(HomePage.built, isFalse);
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static bool built = false;
  @override
  Widget build(BuildContext context) {
    built = true;
    return ElevatedButton(
      onPressed: () {
        context.push('/1');
      },
      child: const Text('/'),
    );
  }
}
