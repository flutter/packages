// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/adaptive_alert_dialog.0.dart'
    as example;

void main() {
  testWidgets('Show Adaptive Alert dialog', (WidgetTester tester) async {
    const String dialogTitle = 'AlertDialog Title';
    await tester.pumpWidget(const example.AdaptiveAlertDialogApp());

    expect(find.text(dialogTitle), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Show Dialog'));
    await tester.pumpAndSettle();
    expect(find.text(dialogTitle), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(dialogTitle), findsNothing);
  });
}
