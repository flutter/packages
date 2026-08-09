// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/radio_list_tile/radio_list_tile.toggleable.0.dart'
    as example;

void main() {
  testWidgets('RadioListTile is toggleable', (WidgetTester tester) async {
    await tester.pumpWidget(const example.RadioListTileApp());

    // Initially the third radio button is not selected.
    RadioGroup<int> group = tester.widget<RadioGroup<int>>(
      find.byType(RadioGroup<int>),
    );
    expect(group.groupValue, null);

    // Tap the third radio button.
    await tester.tap(find.text('Philip Schuyler'));
    await tester.pumpAndSettle();

    // The third radio button is now selected.
    group = tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>));
    expect(group.groupValue, 2);

    // Tap the third radio button again.
    await tester.tap(find.text('Philip Schuyler'));
    await tester.pumpAndSettle();

    // The third radio button is now unselected.
    group = tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>));
    expect(group.groupValue, null);
  });
}
