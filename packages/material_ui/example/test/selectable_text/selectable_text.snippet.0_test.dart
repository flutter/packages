// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/selectable_text/selectable_text.snippet.0.dart'
    as example;

void main() {
  testWidgets('SelectableText renders centered bold text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.SelectableTextExample())),
    );

    expect(find.text('Hello! How are you?'), findsOneWidget);
    final EditableText editableText = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editableText.textAlign, TextAlign.center);
    expect(editableText.style.fontWeight, FontWeight.bold);
  });
}
