// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dropdown_menu/dropdown_menu.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'DropdownMenu.filterCallback filters entries using trimmed lowercase query',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const Scaffold(body: example.DropdownMenuExample()),
        ),
      );

      Finder findMenuItem(String label) {
        return find.widgetWithText(MenuItemButton, label).hitTestable();
      }

      await tester.tap(find.byType(DropdownMenu<Text>));
      await tester.pumpAndSettle();

      expect(findMenuItem('All'), findsOneWidget);
      expect(findMenuItem('Unread'), findsOneWidget);
      expect(findMenuItem('Read'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '  READ  ');
      await tester.pumpAndSettle();

      expect(findMenuItem('All'), findsNothing);
      expect(findMenuItem('Unread'), findsOneWidget);
      expect(findMenuItem('Read'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();

      expect(findMenuItem('All'), findsOneWidget);
      expect(findMenuItem('Unread'), findsOneWidget);
      expect(findMenuItem('Read'), findsOneWidget);
    },
  );
}
