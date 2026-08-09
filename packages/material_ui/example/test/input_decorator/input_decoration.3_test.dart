// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/input_decorator/input_decoration.3.dart'
    as example;

void main() {
  testWidgets('TextFormField is decorated', (WidgetTester tester) async {
    await tester.pumpWidget(const example.InputDecorationExampleApp());
    expect(find.text('InputDecoration Sample'), findsOneWidget);

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Prefix'), findsOneWidget);
    expect(find.text('abc'), findsOneWidget);
    expect(find.text('Suffix'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.border,
      const OutlineInputBorder(),
    );
  });

  testWidgets('Decorations are correctly ordered', (WidgetTester tester) async {
    await tester.pumpWidget(const example.InputDecorationExampleApp());
    expect(find.text('InputDecoration Sample'), findsOneWidget);

    expect(find.byType(TextFormField), findsOneWidget);

    final double prefixX = tester.getCenter(find.text('Prefix')).dx;
    final double contentX = tester.getCenter(find.text('abc')).dx;
    final double suffixX = tester.getCenter(find.text('Suffix')).dx;

    expect(prefixX, lessThan(contentX));
    expect(contentX, lessThan(suffixX));
  });
}
