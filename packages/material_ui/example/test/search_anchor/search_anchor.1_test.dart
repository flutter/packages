// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/search_anchor/search_anchor.1.dart'
    as example;

void main() {
  testWidgets('The SearchAnchor should be floating', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.PinnedSearchBarApp());

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    for (int i = 0; i < 5; i++) {
      expect(find.widgetWithText(ListTile, 'Initial list item $i'), findsOne);
    }

    await tester.tap(find.backButton());
    await tester.pumpAndSettle();
    expect(find.byType(SearchBar), findsOne);

    final double searchBarHeight = tester
        .getSize(find.byType(SearchBar))
        .height;
    final TestPointer testPointer = TestPointer(1, ui.PointerDeviceKind.mouse);
    testPointer.hover(tester.getCenter(find.byType(CustomScrollView)));
    await tester.sendEventToBinding(
      testPointer.scroll(Offset(0.0, 2 * searchBarHeight)),
    );
    await tester.pump();
    expect(find.byType(SearchBar), findsNothing);

    await tester.sendEventToBinding(
      testPointer.scroll(Offset(0.0, -0.5 * searchBarHeight)),
    );
    await tester.pump();
    expect(find.byType(SearchBar), findsOne);

    await tester.sendEventToBinding(
      testPointer.scroll(Offset(0.0, 0.5 * searchBarHeight)),
    );
    await tester.pump();
    expect(find.byType(SearchBar), findsNothing);
  });
}
