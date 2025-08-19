// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/go_relative.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MyApp());
    expect(find.byType(example.HomeScreen), findsOneWidget);

    // From Home screen, go to Details screen
    await tester.tap(find.text('Go to the Details screen'));
    await tester.pumpAndSettle();
    expect(find.byType(example.DetailsScreen), findsOneWidget);

    await tester.tap(find.text('Go to the Settings screen'));
    await tester.pumpAndSettle();
    expect(find.byType(example.SettingsScreen), findsOneWidget);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(find.byType(example.DetailsScreen), findsOneWidget);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(find.byType(example.HomeScreen), findsOneWidget);

    await tester.tap(find.text('Go to the Dashboard screen'));
    await tester.pumpAndSettle();
    expect(find.byType(example.DashboardScreen), findsOneWidget);

    // From Dashboard screen, go to Details screen
    await tester.tap(find.text('Go to the Details screen'));
    await tester.pumpAndSettle();
    expect(find.byType(example.DetailsScreen), findsOneWidget);

    await tester.tap(find.text('Go to the Settings screen'));
    await tester.pumpAndSettle();
    expect(find.byType(example.SettingsScreen), findsOneWidget);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(find.byType(example.DetailsScreen), findsOneWidget);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(find.byType(example.DashboardScreen), findsOneWidget);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(find.byType(example.HomeScreen), findsOneWidget);
  });
}
