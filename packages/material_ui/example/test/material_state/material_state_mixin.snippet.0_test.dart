// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/material_state/material_state_mixin.snippet.0.dart'
    as example;

void main() {
  testWidgets('MyWidget updates ColoredBox color when focus changes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ExampleApp());

    Finder coloredBoxFinder() => find.descendant(
      of: find.byType(example.MyWidget),
      matching: find.byType(ColoredBox),
    );

    expect(tester.widget<ColoredBox>(coloredBoxFinder()).color, Colors.blue);

    final FocusNode focusNode = Focus.of(tester.element(coloredBoxFinder()));
    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(tester.widget<ColoredBox>(coloredBoxFinder()).color, Colors.orange);

    focusNode.unfocus();
    await tester.pumpAndSettle();

    expect(tester.widget<ColoredBox>(coloredBoxFinder()).color, Colors.blue);
  });
}
