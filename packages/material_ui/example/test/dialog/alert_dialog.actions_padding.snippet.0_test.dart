// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/alert_dialog.actions_padding.snippet.0.dart'
    as example;

void main() {
  testWidgets('AlertDialog.actionsPadding aligns actions with content widget', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.AlertDialogExample())),
    );

    final Finder dialogMaterial = find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Material),
        )
        .first;
    final Finder contentContainer = find.byType(Container);
    final Finder button2 = find.widgetWithText(ElevatedButton, 'Button 2');

    final double dialogRight = tester.getTopRight(dialogMaterial).dx;
    final double contentRight = tester.getTopRight(contentContainer).dx;
    final double button2Right = tester.getTopRight(button2).dx;

    expect(dialogRight - contentRight, 8.0);
    expect(dialogRight - button2Right, 8.0);
    expect(button2Right, contentRight);
  });
}
