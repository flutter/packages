// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/radio_list_tile.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets('radio list tile use-case renders radio buttons', (WidgetTester tester) async {
    await pumpsUseCase(tester, RadioListTileUseCase());
    expect(find.text('Lafayette'), findsOneWidget);
    expect(find.text('Jefferson'), findsOneWidget);
  });

  testWidgets('radio list tile demo page has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, RadioListTileUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel('RadioListTile Demo');
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });

  testWidgets('radio buttons are in a labeled radio group', (WidgetTester tester) async {
    await pumpsUseCase(tester, RadioListTileUseCase());
    await tester.pumpAndSettle();

    final SemanticsFinder findRadioGroup = find.semantics.byPredicate(
      (SemanticsNode node) => node.getSemanticsData().role == SemanticsRole.radioGroup,
    );
    expect(findRadioGroup, findsOne);

    final SemanticsNode radioGroup = findRadioGroup.evaluate().single;
    expect(radioGroup.label, isNotEmpty);
    expect(descendantSemanticsLabels(radioGroup), containsAll(<String>['Lafayette', 'Jefferson']));
  });
}
