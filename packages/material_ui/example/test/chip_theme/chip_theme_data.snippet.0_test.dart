// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/chip_theme/chip_theme_data.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'CarColor applies lightBlue ChipThemeData and toggles ChoiceChip selection',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: example.CarColor())),
      );

      expect(find.widgetWithText(ChoiceChip, 'Light Blue'), findsOneWidget);
      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip)).selected,
        isFalse,
      );
      expect(
        find.byType(ChoiceChip),
        paints..rrect(color: Colors.lightBlue.shade500),
      );

      await tester.tap(find.byType(ChoiceChip));
      await tester.pumpAndSettle();

      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip)).selected,
        isTrue,
      );

      await tester.tap(find.byType(ChoiceChip));
      await tester.pumpAndSettle();

      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip)).selected,
        isFalse,
      );
    },
  );
}
