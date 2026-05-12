// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/radio_list_tile/custom_labeled_radio.1.dart'
    as example;

void main() {
  testWidgets('Tapping LabeledRadio toggles the radio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LabeledRadioApp());

    RadioGroup<bool> group = tester.widget<RadioGroup<bool>>(
      find.byType(RadioGroup<bool>),
    );
    // Second radio is checked.
    expect(group.groupValue, isFalse);

    // Tap the first labeled radio to toggle the Radio widget.
    await tester.tap(find.byType(example.LabeledRadio).first);
    await tester.pumpAndSettle();

    group = tester.widget<RadioGroup<bool>>(find.byType(RadioGroup<bool>));
    // Second radio is checked.
    expect(group.groupValue, isTrue);
  });
}
