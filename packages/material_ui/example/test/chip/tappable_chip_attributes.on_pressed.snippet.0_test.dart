// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/chip/tappable_chip_attributes.on_pressed.snippet.0.dart'
    as example;

void main() {
  testWidgets('Blacksmith InputChip calls startHammering when tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.Blacksmith())),
    );

    expect(find.text('Apply Hammer'), findsOneWidget);
    await expectLater(
      () => tester.tap(find.byType(InputChip)),
      prints('bang bang bang\n'),
    );
  });
}
