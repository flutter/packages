// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold_messenger.of.0.dart'
    as example;

void main() {
  testWidgets('The snack bar should be visible after tapping the button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.OfExampleApp());

    expect(
      find.widgetWithText(AppBar, 'ScaffoldMessenger.of Sample'),
      findsOne,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'SHOW A SNACKBAR'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SnackBar, 'Have a snack!'), findsOne);
  });
}
