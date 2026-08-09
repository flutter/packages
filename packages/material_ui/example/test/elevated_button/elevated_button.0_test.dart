// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/elevated_button/elevated_button.0.dart'
    as example;

void main() {
  testWidgets('ElevatedButton Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const example.ElevatedButtonExampleApp());

    expect(
      find.widgetWithText(AppBar, 'ElevatedButton Sample'),
      findsOneWidget,
    );
    final Finder disabledButton = find.widgetWithText(
      ElevatedButton,
      'Disabled',
    );
    expect(disabledButton, findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(disabledButton).onPressed.runtimeType,
      Null,
    );
    final Finder enabledButton = find.widgetWithText(ElevatedButton, 'Enabled');
    expect(enabledButton, findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(enabledButton).onPressed.runtimeType,
      VoidCallback,
    );
  });
}
