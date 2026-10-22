// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.4.dart' as example;

void main() {
  testWidgets('WidgetsApp actions handles ActivateIntent', (
    WidgetTester tester,
  ) async {
    bool activated = false;
    await tester.pumpWidget(
      example.MaterialAppExample(
        onActivated: () {
          activated = true;
        },
      ),
    );

    final Element placeholderElement = tester.element(find.byType(Placeholder));
    final FocusNode focusNode = Focus.of(placeholderElement);
    focusNode.canRequestFocus = true;
    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(activated, isTrue);
  });
}
