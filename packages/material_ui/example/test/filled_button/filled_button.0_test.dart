// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/filled_button/filled_button.0.dart'
    as example;

void main() {
  testWidgets('FilledButton Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const example.FilledButtonApp());

    expect(find.widgetWithText(AppBar, 'FilledButton Sample'), findsOneWidget);
    final Finder disabledButton = find.widgetWithText(FilledButton, 'Disabled');
    expect(disabledButton, findsNWidgets(2));
    expect(
      tester.widget<FilledButton>(disabledButton.first).onPressed.runtimeType,
      Null,
    );
    expect(
      tester.widget<FilledButton>(disabledButton.last).onPressed.runtimeType,
      Null,
    );
    final Finder enabledButton = find.widgetWithText(FilledButton, 'Enabled');
    expect(enabledButton, findsNWidgets(2));
    expect(
      tester.widget<FilledButton>(enabledButton.first).onPressed.runtimeType,
      VoidCallback,
    );
    expect(
      tester.widget<FilledButton>(enabledButton.last).onPressed.runtimeType,
      VoidCallback,
    );
  });
}
