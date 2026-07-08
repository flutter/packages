// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/switch_list_tile/custom_labeled_switch.0.dart'
    as example;

void main() {
  testWidgets('LinkedLabelSwitch contains RichText and Switch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LabeledSwitchApp());

    // Label text is in a RichText widget with the correct text.
    final RichText richText = tester.widget(find.byType(RichText).first);
    expect(richText.text.toPlainText(), 'Linked, tappable label text');

    // Switch is initially off.
    Switch switchWidget = tester.widget(find.byType(Switch));
    expect(switchWidget.value, isFalse);

    // Tap to toggle the switch.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Switch is now on.
    switchWidget = tester.widget(find.byType(Switch));
    expect(switchWidget.value, isTrue);
  });
}
