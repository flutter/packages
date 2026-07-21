// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/checkbox/checkbox.0.dart' as example;

void main() {
  testWidgets('Checkbox can be checked', (WidgetTester tester) async {
    await tester.pumpWidget(const example.CheckboxExampleApp());

    Checkbox checkbox = tester.widget(find.byType(Checkbox));
    expect(checkbox.value, isFalse);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    checkbox = tester.widget(find.byType(Checkbox));
    expect(checkbox.value, isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    checkbox = tester.widget(find.byType(Checkbox));
    expect(checkbox.value, isFalse);
  });

  testWidgets('Checkbox color can be changed', (WidgetTester tester) async {
    await tester.pumpWidget(const example.CheckboxExampleApp());
    final Checkbox checkbox = tester.widget(find.byType(Checkbox));

    expect(checkbox.checkColor, Colors.white);
    expect(checkbox.fillColor!.resolve(<WidgetState>{}), Colors.red);
    expect(
      checkbox.fillColor!.resolve(<WidgetState>{WidgetState.pressed}),
      Colors.blue,
    );
    expect(
      checkbox.fillColor!.resolve(<WidgetState>{WidgetState.hovered}),
      Colors.blue,
    );
    expect(
      checkbox.fillColor!.resolve(<WidgetState>{WidgetState.focused}),
      Colors.blue,
    );
  });
}
