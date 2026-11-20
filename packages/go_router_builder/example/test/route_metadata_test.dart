// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_builder_example/route_metadata.dart' as example;
import 'package:go_router_builder_example/shared/metadata.dart' as data;
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'generated routes preserve metadata types and merge child values',
    (WidgetTester tester) async {
      final List<RouteBase> routes = example.$appRoutes;
      expect(routes.single.metadata!['labels'], isA<Set<String>>());
      final RouteBase child = routes.single.routes.single;
      expect(child.metadata, data.previewMetadata);
      expect(child.metadata!['codes'], isA<List<int>>());
      expect(child.metadata!['options'], isA<Map<String, bool>>());
      expect(child.metadata!['nullableLists'], isA<List<List<int>?>>());

      final router = GoRouter(routes: routes, initialLocation: '/library/42');
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Library 42'), findsOneWidget);
      expect(router.state.metadata['requiresAuth'], isTrue);

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      expect(find.text('Section: library'), findsOneWidget);
      expect(router.state.metadata, <String, Object?>{
        'section': 'library',
        'labels': <String>{'books'},
        ...data.previewMetadata,
      });
    },
  );

  testWidgets('onEnter can enforce policy using generated metadata', (
    WidgetTester tester,
  ) async {
    final enteredMetadata = <Map<String, dynamic>>[];
    final router = GoRouter(
      routes: example.$appRoutes,
      initialLocation: '/library/42/preview',
      onEnter:
          (
            BuildContext context,
            GoRouterState currentState,
            GoRouterState nextState,
            GoRouter goRouter,
          ) {
            enteredMetadata.add(nextState.metadata);
            return nextState.metadata['requiresAuth'] == true
                ? const Block.stop()
                : const Allow();
          },
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(enteredMetadata.last['section'], 'library');
    expect(enteredMetadata.last['requiresAuth'], isFalse);
    expect(router.state.uri.path, '/library/42/preview');

    router.go('/library/42');
    await tester.pumpAndSettle();
    expect(enteredMetadata.last['requiresAuth'], isTrue);
    expect(router.state.uri.path, '/library/42/preview');
  });
}
