// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/main.dart';

void main() {
  testWidgets('Main builds & buttons work', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('TableView Explorer'), findsOneWidget);
    expect(find.text('TreeView Explorer'), findsOneWidget);

    await tester.tap(find.text('TableView Explorer'));
    await tester.pumpAndSettle();
    // First example on the TableView page.
    expect(find.text('Simple TableView'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Simple TableView'), findsNothing);
    await tester.tap(find.text('TreeView Explorer'));
    await tester.pumpAndSettle();
    // First example on the TreeView page.
    expect(find.text('Simple TreeView'), findsOneWidget);
  });
}
