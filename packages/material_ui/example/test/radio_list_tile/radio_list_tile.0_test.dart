// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/radio_list_tile/radio_list_tile.0.dart'
    as example;

void main() {
  testWidgets('Can update RadioListTile group value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.RadioListTileApp());

    // Find the number of RadioListTiles.
    expect(
      find.byType(RadioListTile<example.SingingCharacter>),
      findsNWidgets(2),
    );

    // The initial group value is lafayette.
    RadioGroup<example.SingingCharacter> group = tester
        .widget<RadioGroup<example.SingingCharacter>>(
          find.byType(RadioGroup<example.SingingCharacter>),
        );
    // Second radio is checked.
    expect(group.groupValue, example.SingingCharacter.lafayette);

    // Tap the last RadioListTile to change the group value to jefferson.
    await tester.tap(find.byType(RadioListTile<example.SingingCharacter>).last);
    await tester.pump();

    // The group value is now jefferson.
    group = tester.widget<RadioGroup<example.SingingCharacter>>(
      find.byType(RadioGroup<example.SingingCharacter>),
    );
    // Second radio is checked.
    expect(group.groupValue, example.SingingCharacter.jefferson);
  });
}
