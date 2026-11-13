// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/expansion_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('expansion tile can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, ExpansionTileUseCase());
    expect(find.byType(ExpansionTile), findsExactly(3));
  });

  testWidgets('expansion tile has one h1 tag', (WidgetTester tester) async {
    await pumpsUseCase(tester, ExpansionTileUseCase());
    final Finder findHeadingLevelOnes = find.bySemanticsLabel('ExpansionTile Demo');
    await tester.pumpAndSettle();
    expect(findHeadingLevelOnes, findsOne);
  });

  testWidgets('expansion tiles stay reachable at a 320x256 viewport', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 256);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpsUseCase(tester, ExpansionTileUseCase());
    // A non-scrolling layout overflows at this size and reports it as an error.
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('ExpansionTile 3'), 50);
    await tester.ensureVisible(find.text('ExpansionTile 3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ExpansionTile 3'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('This is tile number 3'));
    await tester.pumpAndSettle();
    expect(find.text('This is tile number 3'), findsOne);
  });
}
