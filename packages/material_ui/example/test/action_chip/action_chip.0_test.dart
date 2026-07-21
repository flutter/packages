// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/action_chip/action_chip.0.dart' as example;

void main() {
  testWidgets('ActionChip updates avatar when tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ChipApp());

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byType(ActionChip));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
