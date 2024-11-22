// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('replaceNamed', () {
    Future<GoRouter> createGoRouter(
      WidgetTester tester, {
      Listenable? refreshListenable,
    }) async {
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            name: 'home',
            builder: (_, __) => const _MyWidget(),
          ),
          GoRoute(
              path: '/page-0/:tab',
              name: 'page-0',
              builder: (_, __) => const SizedBox())
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));
      return router;
    }

    testWidgets('Passes GoRouter parameters through context call.',
        (WidgetTester tester) async {
      final GoRouter router = await createGoRouter(tester);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.toString(),
          '/page-0/settings?search=notification');
    });
  });
}

class _MyWidget extends StatelessWidget {
  const _MyWidget();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => context.replaceNamed('page-0',
            pathParameters: <String, String>{'tab': 'settings'},
            queryParameters: <String, String>{'search': 'notification'}),
        child: const Text('Settings'));
  }
}
