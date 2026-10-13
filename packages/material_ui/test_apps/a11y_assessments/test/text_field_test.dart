// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show SemanticsInputType;

import 'package:a11y_assessments/use_cases/text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('text field can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, TextFieldUseCase());
    expect(find.byType(TextField), findsExactly(2));

    // Test the enabled text field
    {
      final Finder finder = find.byKey(const Key('enabled text field'));
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await tester.enterText(finder, 'abc');
      await tester.pumpAndSettle();
      expect(find.text('abc'), findsOneWidget);
    }

    // Test the disabled text field
    {
      final Finder finder = find.byKey(const Key('disabled text field'));
      final TextField textField = tester.widget<TextField>(finder);
      expect(textField.enabled, isFalse);
    }
  });

  testWidgets('font size increase does not ellipsize hint text', (WidgetTester tester) async {
    await pumpsUseCase(tester, TextFieldUseCase());
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery.withClampedTextScaling(
          minScaleFactor: 3,
          maxScaleFactor: 3,
          child: Builder(
            builder: (BuildContext context) {
              return TextFieldUseCase().build(context);
            },
          ),
        ),
      ),
    );
    // Test the enabled text field
    {
      final Finder finder = find.byKey(const Key('enabled text field'));
      await tester.tap(finder);
      await tester.pumpAndSettle();
      final Size size = tester.getSize(finder);
      // Should have a multi-line height.
      expect(size.height, 280);
    }
  });

  testWidgets('text field wrapper exists', (WidgetTester tester) async {
    await pumpsUseCase(tester, TextFieldUseCase());
    const textFieldLabel = 'Input field with suffix @gmail.com';

    final Finder semanticsWidgets = find.bySemanticsLabel(RegExp(textFieldLabel));
    expect(semanticsWidgets, findsExactly(2));
  });

  testWidgets('text field demo page has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, TextFieldUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel('TextField Demo');
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });

  testWidgets('email text fields expose their input purpose', (WidgetTester tester) async {
    await pumpsUseCase(tester, TextFieldUseCase());
    await tester.pumpAndSettle();

    for (final key in <Key>[const Key('enabled text field'), const Key('disabled text field')]) {
      final Finder finder = find.byKey(key);
      // On web, a single-line field with the email input type renders an
      // <input autocomplete="email">. A multiline field renders a <textarea>
      // with autocomplete="off".
      expect(
        tester.getSemantics(finder),
        containsSemantics(inputType: SemanticsInputType.email, isMultiline: false),
      );
      final EditableText editableText = tester.widget<EditableText>(
        find.descendant(of: finder, matching: find.byType(EditableText)),
      );
      expect(editableText.autofillHints, contains(AutofillHints.email));
    }
  });
}
