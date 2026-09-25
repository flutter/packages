// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.3.dart' as example;

void main() {
  testWidgets('WidgetsApp shortcuts maps select key to ActivateIntent', (
    WidgetTester tester,
  ) async {
    bool invoked = false;
    await tester.pumpWidget(
      Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              invoked = true;
              return null;
            },
          ),
        },
        child: const example.MaterialAppExample(),
      ),
    );

    final Element placeholderElement = tester.element(find.byType(Placeholder));
    final FocusNode focusNode = Focus.of(placeholderElement);
    focusNode.canRequestFocus = true;
    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(invoked, isTrue);
  });
}
