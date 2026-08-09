// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/search_anchor/search_anchor.2.dart'
    as example;

void main() {
  testWidgets('Suggestion of the search bar can be selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.SearchBarApp());

    expect(find.widgetWithText(AppBar, 'Search Anchor Sample'), findsOne);
    expect(find.text('No item selected'), findsOne);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    for (int i = 0; i < 5; i++) {
      expect(find.widgetWithText(ListTile, 'item $i'), findsOne);
    }

    await tester.tap(find.text('item 2'));
    await tester.pumpAndSettle();

    expect(find.text('Selected item: item 2'), findsOne);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'item 3'));
    await tester.pumpAndSettle();

    expect(find.text('Selected item: item 3'), findsOne);
  });
}
