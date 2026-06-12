// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/selection_area/selection_area.0.dart'
    as example;

void main() {
  testWidgets('Texts are descendant of the SelectionArea', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.SelectionAreaExampleApp());

    expect(
      find.descendant(
        of: find.byType(SelectionArea),
        matching: find.byType(Text),
      ),
      findsExactly(4),
    );

    final List<String> selectableTexts = <String>[
      'SelectionArea Sample',
      'Row 1',
      'Row 2',
      'Row 3',
    ];

    for (final String text in selectableTexts) {
      expect(
        find.descendant(
          of: find.byType(SelectionArea),
          matching: find.text(text),
        ),
        findsExactly(1),
      );
    }
  });
}
