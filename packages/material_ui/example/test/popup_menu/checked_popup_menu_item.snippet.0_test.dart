// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/popup_menu/checked_popup_menu_item.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'CheckedPopupMenuItem toggles checkmark and handles second command',
    (WidgetTester tester) async {
      bool hurricaneTriggered = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: example.CheckedPopupMenuItemExample(
              onHurricane: () {
                hurricaneTriggered = true;
              },
            ),
          ),
        ),
      );

      // Open menu: initially unchecked.
      await tester.tap(find.byType(PopupMenuButton<example.Commands>));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckedPopupMenuItem<example.Commands>>(
              find.byType(CheckedPopupMenuItem<example.Commands>),
            )
            .checked,
        isFalse,
      );
      expect(find.byType(PopupMenuDivider), findsOneWidget);

      // Tap CheckedPopupMenuItem to toggle _heroAndScholar to true.
      await tester.tap(find.byType(CheckedPopupMenuItem<example.Commands>));
      await tester.pumpAndSettle();

      // Re-open menu and verify checked is now true.
      await tester.tap(find.byType(PopupMenuButton<example.Commands>));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckedPopupMenuItem<example.Commands>>(
              find.byType(CheckedPopupMenuItem<example.Commands>),
            )
            .checked,
        isTrue,
      );

      // Tap 'Bring hurricane' and verify callback fires.
      await tester.tap(
        find.widgetWithText(PopupMenuItem<example.Commands>, 'Bring hurricane'),
      );
      await tester.pumpAndSettle();
      expect(hurricaneTriggered, isTrue);
    },
  );
}
