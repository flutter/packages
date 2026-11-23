// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/text_selection_theme/text_selection_theme.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'TextSelectionTheme applies blue cursor, lightBlue handles, and DefaultSelectionStyle',
    (WidgetTester tester) async {
      EditableText.debugDeterministicCursor = true;
      addTearDown(() {
        EditableText.debugDeterministicCursor = false;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: example.TextSelectionThemeExample()),
        ),
      );

      final BuildContext textFieldContext = tester.element(
        find.byType(TextField),
      );
      expect(
        DefaultSelectionStyle.of(textFieldContext).cursorColor,
        Colors.blue,
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      final EditableTextState editableState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      expect(editableState.renderEditable.cursorColor, Colors.blue.shade500);

      await tester.longPressAt(
        tester.getTopLeft(find.byType(TextField)) + const Offset(10, 20),
      );
      await tester.pumpAndSettle();

      final Finder handlePaint = find
          .descendant(
            of: find.byType(CompositedTransformFollower),
            matching: find.byType(CustomPaint),
          )
          .first;
      expect(handlePaint, paints..path(color: Colors.lightBlue.shade500));
    },
  );
}
