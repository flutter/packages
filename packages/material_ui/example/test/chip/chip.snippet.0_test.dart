// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/chip/chip.snippet.0.dart' as example;

void main() {
  testWidgets('Chip renders CircleAvatar and label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.ChipExample())),
    );

    expect(find.widgetWithText(Chip, 'Aaron Burr'), findsOneWidget);
    expect(find.widgetWithText(CircleAvatar, 'AB'), findsOneWidget);
    expect(
      find.byType(CircleAvatar),
      paints..circle(color: Colors.grey.shade800),
    );
  });
}
