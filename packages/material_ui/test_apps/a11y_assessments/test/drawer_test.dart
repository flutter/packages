// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/drawer.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('drawer can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, DrawerUseCase());

    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openEndDrawer();

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(Drawer), findsExactly(1));
  });

  testWidgets('drawer has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, DrawerUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel('drawer Demo');
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });

  testWidgets('drawer header is a heading', (WidgetTester tester) async {
    await pumpsUseCase(tester, DrawerUseCase());

    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openEndDrawer();
    await tester.pumpAndSettle();

    final SemanticsNode header = tester.getSemantics(find.text('Drawer Header'));
    expect(header.getSemanticsData().headingLevel, 2);
  });

  testWidgets('drawer exposes the selected item', (WidgetTester tester) async {
    await pumpsUseCase(tester, DrawerUseCase());

    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openEndDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Profile')),
      containsSemantics(label: 'Profile', hasSelectedState: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Messages')),
      containsSemantics(label: 'Messages', hasSelectedState: true, isSelected: false),
    );
  });
}
