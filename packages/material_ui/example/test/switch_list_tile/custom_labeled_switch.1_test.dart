// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/switch_list_tile/custom_labeled_switch.1.dart'
    as example;

void main() {
  testWidgets('Tapping LabeledSwitch toggles the switch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LabeledSwitchApp());

    // Switch is initially off.
    Switch switchWidget = tester.widget(find.byType(Switch));
    expect(switchWidget.value, isFalse);

    // Tap to toggle the switch.
    await tester.tap(find.byType(example.LabeledSwitch));
    await tester.pumpAndSettle();

    // Switch is now on.
    switchWidget = tester.widget(find.byType(Switch));
    expect(switchWidget.value, isTrue);
  });
}
