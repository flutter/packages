// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/input_decorator/input_decoration.widget_state.0.dart'
    as example;

void main() {
  testWidgets('TextFormField updates decorations depending on state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialStateExampleApp());
    expect(find.text('InputDecoration Sample'), findsOneWidget);

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('abc'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    expect(
      tester
          .widget<TextField>(find.byType(TextField))
          .decoration
          ?.prefixIconColor,
      isA<WidgetStateColor>()
          .having(
            (WidgetStateColor color) => color.resolve(<WidgetState>{}),
            'default',
            Colors.grey,
          )
          .having(
            (WidgetStateColor color) =>
                color.resolve(<WidgetState>{WidgetState.focused}),
            'focused',
            Colors.green,
          ),
    );
  });
}
