// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/on_exit.dart' as example;

void main() {
  testWidgets('should only pop the route if the user confirms',
      (WidgetTester tester) async {
    await tester.pumpWidget(const example.MyApp());

    await tester.tap(find.text('Go to the Details screen'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to leave?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(find.byType(example.DetailsScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.byType(example.HomeScreen), findsOneWidget);
  });
}
