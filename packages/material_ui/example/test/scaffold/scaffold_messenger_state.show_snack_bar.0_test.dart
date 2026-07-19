// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold_messenger_state.show_snack_bar.0.dart'
    as example;

void main() {
  testWidgets('Pressing the button should display a snack bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ShowSnackBarExampleApp());

    expect(
      find.widgetWithText(AppBar, 'ScaffoldMessengerState Sample'),
      findsOne,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Show SnackBar'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(SnackBar, 'A SnackBar has been shown.'),
      findsOne,
    );
  });
}
