// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('TextField with null decoration works without a Material ancestor', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/133662.
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      CupertinoApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
        ],
        home: Center(child: TextField(controller: controller, decoration: null)),
      ),
    );

    expect(find.byType(Material), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Hello Flutter');
    await tester.pump();
    expect(controller.text, 'Hello Flutter');
    expect(tester.takeException(), isNull);

    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
    await tester.pump();
    final EditableTextState editableText = tester.state<EditableTextState>(
      find.byType(EditableText),
    );
    expect(editableText.showToolbar(), isTrue);
    await tester.pumpAndSettle();
    expect(controller.selection.isCollapsed, isFalse);
    expect(find.text('Copy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.mobile());
}
