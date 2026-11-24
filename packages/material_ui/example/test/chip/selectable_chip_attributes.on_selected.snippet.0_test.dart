// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/chip/selectable_chip_attributes.on_selected.snippet.0.dart'
    as example;

void main() {
  testWidgets('Wood InputChip toggles selected state when tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.Wood())),
    );

    expect(find.text('Use Chisel'), findsOneWidget);
    expect(tester.widget<InputChip>(find.byType(InputChip)).selected, isFalse);

    await tester.tap(find.byType(InputChip));
    await tester.pumpAndSettle();

    expect(tester.widget<InputChip>(find.byType(InputChip)).selected, isTrue);

    await tester.tap(find.byType(InputChip));
    await tester.pumpAndSettle();

    expect(tester.widget<InputChip>(find.byType(InputChip)).selected, isFalse);
  });
}
