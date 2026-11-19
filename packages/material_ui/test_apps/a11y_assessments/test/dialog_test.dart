// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/dialog.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('dialog can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, DialogUseCase());
    expect(find.text('Show Dialog'), findsOneWidget);

    Future<void> invokeDialog() async {
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('This is a typical dialog.'), findsOneWidget);
    }

    await invokeDialog();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('This is a typical dialog.'), findsNothing);

    await invokeDialog();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('This is a typical dialog.'), findsNothing);
  });

  testWidgets('ok button has autofocus when dialog opens', (WidgetTester tester) async {
    await pumpsUseCase(tester, DialogUseCase());

    Future<void> invokeDialog() async {
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
    }

    await invokeDialog();
    final Finder okButton = find.byKey(const Key('OK Button'));
    expect((okButton.evaluate().single.widget as TextButton).autofocus, true);
  });

  testWidgets('dialog has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, DialogUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel('Dialog Demo');
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });

  testWidgets('dialog text describes the dialog', (WidgetTester tester) async {
    await pumpsUseCase(tester, DialogUseCase());
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // On web, a namesRoute node inside a dialog route becomes the dialog's
    // aria-describedby, so screen readers read the text when focus moves to
    // the autofocused OK button.
    final SemanticsNode text = tester.getSemantics(find.text('This is a typical dialog.'));
    expect(text, containsSemantics(label: 'This is a typical dialog.', namesRoute: true));

    // The web engine attaches the description to the nearest ancestor that is
    // a dialog or a route, which must be the dialog itself.
    SemanticsNode? route = text.parent;
    while (route != null &&
        route.getSemanticsData().role != SemanticsRole.dialog &&
        !route.hasFlag(SemanticsFlag.scopesRoute)) {
      route = route.parent;
    }
    expect(route, isNotNull);
    expect(route!.getSemanticsData().role, SemanticsRole.dialog);
  });
}
