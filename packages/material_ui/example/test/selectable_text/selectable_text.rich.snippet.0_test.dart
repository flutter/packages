// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/selectable_text/selectable_text.rich.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'SelectableText.rich displays Hello beautiful world with distinct word styles',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: example.SelectableTextRichExample()),
        ),
      );

      final EditableTextState state = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      final RenderEditable renderEditable = state.renderEditable;
      final TextSpan rootSpan = renderEditable.text! as TextSpan;

      expect(rootSpan.toPlainText(), 'Hello beautiful world');
      final TextSpan textSpan = rootSpan.children!.single as TextSpan;
      expect(textSpan.text, 'Hello');
      final List<InlineSpan> children = textSpan.children!;
      expect((children[0] as TextSpan).text, ' beautiful ');
      expect((children[0] as TextSpan).style?.fontStyle, FontStyle.italic);
      expect((children[1] as TextSpan).text, 'world');
      expect((children[1] as TextSpan).style?.fontWeight, FontWeight.bold);
    },
  );
}
