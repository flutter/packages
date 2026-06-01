// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/radio/radio.1.dart' as example;

void main() {
  testWidgets('Radio colors can be changed', (WidgetTester tester) async {
    await tester.pumpWidget(const example.RadioExampleApp());

    expect(find.widgetWithText(AppBar, 'Radio Sample'), findsOne);
    expect(find.widgetWithText(ListTile, 'Fill color'), findsOne);
    expect(find.widgetWithText(ListTile, 'Background color'), findsOne);
    expect(find.widgetWithText(ListTile, 'Side'), findsOne);
    expect(find.widgetWithText(ListTile, 'Inner radius'), findsOne);

    final Radio<example.RadioType> radioFillColor = tester
        .widget<Radio<example.RadioType>>(
          find.byType(Radio<example.RadioType>).first,
        );
    expect(
      radioFillColor.fillColor!.resolve(const <WidgetState>{
        WidgetState.selected,
      }),
      Colors.deepPurple,
    );
    expect(
      radioFillColor.fillColor!.resolve(const <WidgetState>{}),
      Colors.deepPurple.shade200,
    );

    final Radio<example.RadioType> radioBackgroundColor = tester
        .widget<Radio<example.RadioType>>(
          find.byType(Radio<example.RadioType>).at(1),
        );
    expect(
      radioBackgroundColor.backgroundColor!.resolve(const <WidgetState>{
        WidgetState.selected,
      }),
      Colors.greenAccent.withValues(alpha: 0.5),
    );
    expect(
      radioBackgroundColor.backgroundColor!.resolve(const <WidgetState>{}),
      Colors.grey.shade300.withValues(alpha: 0.3),
    );

    final Radio<example.RadioType> radioSide = tester
        .widget<Radio<example.RadioType>>(
          find.byType(Radio<example.RadioType>).at(2),
        );
    expect(
      (radioSide.side! as WidgetStateBorderSide).resolve(const <WidgetState>{
        WidgetState.selected,
      }),
      const BorderSide(
        color: Colors.red,
        width: 4,
        strokeAlign: BorderSide.strokeAlignCenter,
      ),
    );
    expect(
      (radioSide.side! as WidgetStateBorderSide).resolve(const <WidgetState>{}),
      const BorderSide(
        color: Colors.grey,
        width: 1.5,
        strokeAlign: BorderSide.strokeAlignCenter,
      ),
    );

    final Radio<example.RadioType> radioInnerRadius = tester
        .widget<Radio<example.RadioType>>(
          find.byType(Radio<example.RadioType>).last,
        );
    expect(
      radioInnerRadius.innerRadius!.resolve(const <WidgetState>{
        WidgetState.selected,
      }),
      6,
    );
  });
}
