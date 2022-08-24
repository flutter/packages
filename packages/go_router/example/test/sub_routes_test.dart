// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/sub_routes.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(example.App());
    expect(find.text('Go to family screen'), findsOneWidget);

    await tester.tap(find.text('Go to family screen'));
    await tester.pumpAndSettle();
    expect(find.text('Go to person screen'), findsOneWidget);

    await tester.tap(find.text('Go to person screen'));
    await tester.pumpAndSettle();
    expect(find.text('This is the person screen'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Go to person screen'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Go to family screen'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });
}
