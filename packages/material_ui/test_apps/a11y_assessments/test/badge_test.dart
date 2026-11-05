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

  testWidgets('badge label meets the 4.5:1 text contrast ratio', (WidgetTester tester) async {
    await pumpsUseCase(tester, BadgeUseCase());

    final Container background = tester.widget<Container>(
      find.descendant(of: find.byType(Badge), matching: find.byType(Container)),
    );
    final Color backgroundColor = (background.decoration! as ShapeDecoration).color!;
    final Color textColor = paintedTextColor(tester, find.text('5'));

    expect(contrastRatio(textColor, backgroundColor), greaterThanOrEqualTo(4.5));
  });
}
