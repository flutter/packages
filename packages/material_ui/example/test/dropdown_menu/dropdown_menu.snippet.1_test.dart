// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dropdown_menu/dropdown_menu.snippet.1.dart'
    as example;

void main() {
  testWidgets(
    'DropdownMenu.searchCallback highlights only exact label matches',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const Scaffold(body: example.DropdownMenuExample()),
        ),
      );

      Color itemColor(String label) {
        final Finder material = find.descendant(
          of: find.widgetWithText(MenuItemButton, label).last,
          matching: find.byType(Material),
        );
        return tester.widget<Material>(material).color!;
      }

      await tester.tap(find.byType(DropdownMenu<Text>));
      await tester.pumpAndSettle();

      // Partial/lowercase 'read' does not match exact label 'Read' or 'Unread'.
      await tester.enterText(find.byType(TextField), 'read');
      await tester.pump();
      expect(itemColor('All'), Colors.transparent);
      expect(itemColor('Unread'), Colors.transparent);
      expect(itemColor('Read'), Colors.transparent);

      // Exact query 'Read' highlights 'Read' rather than 'Unread'.
      await tester.enterText(find.byType(TextField), 'Read');
      await tester.pump();
      expect(itemColor('All'), Colors.transparent);
      expect(itemColor('Unread'), Colors.transparent);
      expect(itemColor('Read'), isNot(Colors.transparent));
    },
  );
}
