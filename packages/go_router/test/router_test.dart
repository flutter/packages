// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  group('GoRouter', () {
    testWidgets('canPop delegates to routerDelegate', (WidgetTester tester) async {
      final GoRouter router = await createRouter(<RouteBase>[
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/a', builder: (_, _) => const Page1Screen()),
      ], tester);

      expect(router.canPop(), isFalse);

      router.push('/a');
      await tester.pumpAndSettle();

      expect(router.canPop(), isTrue);
      expect(router.canPop(), router.routerDelegate.canPop());
    });

    testWidgets('refresh notifies routeInformationProvider listeners', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await createRouter(<RouteBase>[
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      ], tester);

      var listenerCalled = false;
      router.routeInformationProvider.addListener(() {
        listenerCalled = true;
      });

      router.refresh();
      expect(listenerCalled, isTrue);
    });
  });
}
