// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/outlined_button/outlined_button.0.dart'
    as example;

void main() {
  testWidgets('OutlinedButton Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const example.OutlinedButtonExampleApp());

    expect(
      find.widgetWithText(AppBar, 'OutlinedButton Sample'),
      findsOneWidget,
    );
    final Finder outlinedButton = find.widgetWithText(
      OutlinedButton,
      'Click Me',
    );
    expect(outlinedButton, findsOneWidget);
    final OutlinedButton outlinedButtonWidget = tester.widget<OutlinedButton>(
      outlinedButton,
    );
    expect(outlinedButtonWidget.onPressed.runtimeType, VoidCallback);
  });
}
