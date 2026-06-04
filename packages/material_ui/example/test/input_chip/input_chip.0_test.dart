// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/input_chip/input_chip.0.dart' as example;

void main() {
  testWidgets('', (WidgetTester tester) async {
    await tester.pumpWidget(const example.ChipApp());

    expect(find.byType(InputChip), findsNWidgets(3));

    await tester.tap(find.byIcon(Icons.clear).at(0));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.clear).at(0));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNWidgets(1));

    await tester.tap(find.byIcon(Icons.clear).at(0));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNWidgets(0));

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNWidgets(3));
  });
}
