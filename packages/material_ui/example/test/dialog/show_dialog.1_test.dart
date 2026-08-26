// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/show_dialog.1.dart' as example;

void main() {
  testWidgets('Show dialog', (WidgetTester tester) async {
    const String dialogTitle = 'Basic dialog title';
    await tester.pumpWidget(const example.ShowDialogExampleApp());

    expect(find.text(dialogTitle), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Open Dialog'));
    await tester.pumpAndSettle();
    expect(find.text(dialogTitle), findsOneWidget);

    await tester.tap(find.text('Enable'));
    await tester.pumpAndSettle();
    expect(find.text(dialogTitle), findsNothing);
  });
}
