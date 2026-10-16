// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/badge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('badge can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, BadgeUseCase());
    expect(find.semantics.byLabel('5 new messages'), findsOne);
    expect(find.semantics.byLabel('Messages'), findsOne);
  });

  testWidgets('badge has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, BadgeUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel(RegExp('Badge Demo'));
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });

  for (final Brightness brightness in Brightness.values) {
    testWidgets('badge label meets text contrast guideline in $brightness', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Builder(builder: BadgeUseCase().buildWithTitle),
        ),
      );

      // The semantics label differs from the rendered text, so the default
      // text contrast guideline cannot find this label.
      await expectLater(
        tester,
        meetsGuideline(CustomMinimumContrastGuideline(finder: find.text('5'))),
      );
    });
  }
}
