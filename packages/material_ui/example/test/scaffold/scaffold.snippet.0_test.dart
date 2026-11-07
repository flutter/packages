// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold.snippet.0.dart'
    as example;

void main() {
  testWidgets('TabController listener updates Scaffold AppBar title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: example.ScaffoldExample()));

    expect(find.widgetWithText(AppBar, 'Tab 0'), findsOneWidget);

    await tester.tap(find.text('Item 2'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Tab 2'), findsOneWidget);
  });
}
