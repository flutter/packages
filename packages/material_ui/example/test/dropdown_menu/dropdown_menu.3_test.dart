// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dropdown_menu/dropdown_menu.3.dart'
    as example;

void main() {
  testWidgets('Selecting an entry updates the text field and state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.DropdownMenuClearExampleApp());

    expect(find.text('Selected: None'), findsOneWidget);
    expect(find.widgetWithText(TextField, ''), findsOneWidget);

    // Open menu and select Green.
    await tester.tap(find.byType(DropdownMenu<example.ColorItem>));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(MenuItemButton, 'Green').last);
    await tester.pumpAndSettle();

    expect(find.text('Selected: Green'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Green'), findsOneWidget);
  });

  testWidgets(
    'Pressing clear selection button resets the text field and state',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.DropdownMenuClearExampleApp());

      // Open menu and select Blue.
      await tester.tap(find.byType(DropdownMenu<example.ColorItem>));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(MenuItemButton, 'Blue').last);
      await tester.pumpAndSettle();

      expect(find.text('Selected: Blue'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Blue'), findsOneWidget);

      // Tap clear button.
      await tester.tap(find.widgetWithText(FilledButton, 'Clear selection'));
      await tester.pumpAndSettle();

      expect(find.text('Selected: None'), findsOneWidget);
      expect(find.widgetWithText(TextField, ''), findsOneWidget);
    },
  );
}
