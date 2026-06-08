// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/text_form_field/text_form_field.1.dart'
    as example;

void main() {
  testWidgets('Pressing space should focus the next field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.TextFormFieldExampleApp());
    final Finder textFormField = find.byType(TextFormField);

    expect(textFormField, findsExactly(5));

    final Finder editableText = find.byType(EditableText);
    expect(editableText, findsExactly(5));

    List<bool> getFocuses() {
      return editableText
          .evaluate()
          .map(
            (Element finderResult) =>
                (finderResult.widget as EditableText).focusNode.hasFocus,
          )
          .toList();
    }

    expect(getFocuses(), const <bool>[false, false, false, false, false]);

    await tester.tap(textFormField.first);
    await tester.pump();

    expect(getFocuses(), const <bool>[true, false, false, false, false]);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(getFocuses(), const <bool>[false, true, false, false, false]);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(getFocuses(), const <bool>[false, false, true, false, false]);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(getFocuses(), const <bool>[false, false, false, true, false]);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(getFocuses(), const <bool>[false, false, false, false, true]);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    if (isBrowser) {
      expect(getFocuses(), const <bool>[false, false, false, false, false]);
    } else {
      expect(getFocuses(), const <bool>[true, false, false, false, false]);
    }
  });
}
