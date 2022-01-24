// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Selection Controls', () {
    testWidgets(
      'header with line of text',
      (WidgetTester tester) async {
        const String data = 'Hello _World_!';
        await tester.pumpWidget(
          MaterialApp(
            home: boilerplate(
              Markdown(
                data: data,
                selectionControls: materialTextSelectionControls,
                selectable: true,
              ),
            ),
          ),
        );

        final Offset selectableTextStart =
            tester.getTopLeft(find.byType(SelectableText).last);

        await tester.longPressAt(selectableTextStart + const Offset(50.0, 5.0));
        await tester.pump();

        final EditableText editableTextWidget =
            tester.widget(find.byType(EditableText).last);
        final TextEditingController controller = editableTextWidget.controller;

        expect(
          controller.selection.textInside(controller.text),
          'Hello',
        );

        // Collapsed toolbar shows 2 buttons: copy, select all
        expect(find.byType(TextButton), findsNWidgets(2));
      },
    );
  });
}
