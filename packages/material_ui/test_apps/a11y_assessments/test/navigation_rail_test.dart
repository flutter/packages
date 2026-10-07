// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/navigation_rail.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('navigation rail can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, NavigationRailUseCase());

    expect(find.byType(NavigationRail), findsExactly(1));
  });

  testWidgets('navigation rail can show/hide leading', (WidgetTester tester) async {
    await pumpsUseCase(tester, NavigationRailUseCase());
    final Finder findLeading = find.byTooltip('Add');

    expect(findLeading, findsNothing);

    await tester.tap(find.text('Show Leading'));
    await tester.pump();
    expect(findLeading, findsOne);

    await tester.tap(find.text('Hide Leading'));
    await tester.pump();
    expect(findLeading, findsNothing);
  });

  testWidgets('navigation rail can show/hide trailing', (WidgetTester tester) async {
    await pumpsUseCase(tester, NavigationRailUseCase());
    final Finder findTrailing = find.byTooltip('More');

    expect(findTrailing, findsNothing);

    await tester.tap(find.text('Show Trailing'));
    await tester.pump();
    expect(findTrailing, findsOne);

    await tester.tap(find.text('Hide Trailing'));
    await tester.pump();
    expect(findTrailing, findsNothing);
  });

  testWidgets('navigation rail options are grouped with their labels', (WidgetTester tester) async {
    await pumpsUseCase(tester, NavigationRailUseCase());
    await tester.pumpAndSettle();

    final SemanticsNode labelTypeGroup = find.semantics
        .byLabel(RegExp('^Label type'))
        .evaluate()
        .single;
    expect(
      descendantSemanticsLabels(labelTypeGroup),
      containsAll(<String>['None', 'Selected', 'All']),
    );

    final SemanticsNode groupAlignmentGroup = find.semantics
        .byLabel(RegExp('^Group alignment'))
        .evaluate()
        .single;
    expect(
      descendantSemanticsLabels(groupAlignmentGroup),
      containsAll(<String>['Top', 'Center', 'Bottom']),
    );
  });

  testWidgets('navigation rail options expose the selected state', (WidgetTester tester) async {
    await pumpsUseCase(tester, NavigationRailUseCase());
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('All')),
      containsSemantics(hasSelectedState: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('None')),
      containsSemantics(hasSelectedState: true, isSelected: false),
    );
    expect(
      tester.getSemantics(find.text('Top')),
      containsSemantics(hasSelectedState: true, isSelected: true),
    );

    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('None')),
      containsSemantics(hasSelectedState: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('All')),
      containsSemantics(hasSelectedState: true, isSelected: false),
    );
  });
}
