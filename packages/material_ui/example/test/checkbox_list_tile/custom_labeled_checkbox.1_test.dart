// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/checkbox_list_tile/custom_labeled_checkbox.1.dart'
    as example;

void main() {
  testWidgets('Tapping LabeledCheckbox toggles the checkbox', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LabeledCheckboxApp());

    // Checkbox is initially unchecked.
    Checkbox checkbox = tester.widget(find.byType(Checkbox));
    expect(checkbox.value, isFalse);

    // Tap the LabeledCheckBoxApp to toggle the checkbox.
    await tester.tap(find.byType(example.LabeledCheckbox));
    await tester.pumpAndSettle();

    // Checkbox is now checked.
    checkbox = tester.widget(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
  });
}
