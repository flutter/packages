// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/chip_theme/chip_theme.of.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'Spaceship copies ambient ChipThemeData with red backgroundColor and handles tap',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            chipTheme: const ChipThemeData(labelStyle: TextStyle(fontSize: 20)),
          ),
          home: const Scaffold(body: example.Spaceship()),
        ),
      );

      expect(find.widgetWithText(ActionChip, 'Launch'), findsOneWidget);
      expect(
        find.byType(ActionChip),
        paints..rrect(color: Colors.red.shade500),
      );
      final RichText labelText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(ActionChip),
          matching: find.byType(RichText),
        ),
      );
      expect(labelText.text.style?.fontSize, 20);

      await expectLater(
        () => tester.tap(find.byType(ActionChip)),
        prints('We have liftoff!\n'),
      );
    },
  );
}
