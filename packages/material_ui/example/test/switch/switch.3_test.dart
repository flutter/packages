// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/switch/switch.3.dart' as example;

void main() {
  testWidgets('Can toggle switch', (WidgetTester tester) async {
    await tester.pumpWidget(const example.SwitchApp());

    final Finder switchFinder = find.byType(Switch).first;
    Switch materialSwitch = tester.widget<Switch>(switchFinder);
    expect(materialSwitch.value, true);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    materialSwitch = tester.widget<Switch>(switchFinder);
    expect(materialSwitch.value, false);
  });
}
