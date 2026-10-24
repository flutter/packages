// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold.snippet.3.dart'
    as example;

void main() {
  testWidgets('tapping Show presents a floating SnackBar with margin', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: example.ScaffoldExample()),
    );

    await tester.tap(find.widgetWithText(TextButton, 'Show'));
    await tester.pump();

    expect(find.widgetWithText(SnackBar, 'Saved'), findsOneWidget);

    final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
    expect(snackBar.margin, const EdgeInsets.fromLTRB(16, 0, 16, 16));
  });
}
