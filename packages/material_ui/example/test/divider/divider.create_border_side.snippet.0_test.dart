// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/divider/divider.create_border_side.snippet.0.dart'
    as example;

void main() {
  testWidgets('DecoratedBox uses Divider.createBorderSide for top and bottom', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ExampleApp());

    final Finder boxFinder = find.descendant(
      of: find.byType(example.BorderedSection),
      matching: find.byType(DecoratedBox),
    );
    expect(boxFinder, findsOneWidget);

    final ThemeData theme = Theme.of(tester.element(boxFinder));
    final DecoratedBox decoratedBox = tester.widget<DecoratedBox>(boxFinder);
    final BoxDecoration decoration = decoratedBox.decoration as BoxDecoration;
    final Border border = decoration.border! as Border;

    expect(border.top.color, theme.colorScheme.outlineVariant);
    expect(border.bottom.color, theme.colorScheme.outlineVariant);
    expect(border.left, BorderSide.none);
    expect(border.right, BorderSide.none);

    await tester.pumpWidget(
      const MaterialApp(
        home: DividerTheme(
          data: DividerThemeData(color: Colors.purple, thickness: 2.0),
          child: SizedBox(
            width: 200,
            height: 100,
            child: example.BorderedSection(),
          ),
        ),
      ),
    );

    expect(
      find.byType(example.BorderedSection),
      paints
        ..path(color: Colors.purple)
        ..path(color: Colors.purple),
    );
  });
}
