// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('card can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, CardUseCase());
    expect(find.byType(Card), findsExactly(1));
  });

  testWidgets('card has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, CardUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel(RegExp('Card Demo'));
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });
}
